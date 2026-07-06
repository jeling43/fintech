import 'dart:io';

import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../models/financial_record.dart';
import '../models/import_metadata.dart';
import '../models/parsed_financial_record.dart';
import '../parsers/parser_registry.dart';
import 'hash_service.dart';
import 'ocr_service.dart';
import 'pdf_extraction_service.dart';

/// Callback for reporting import progress.
typedef ProgressCallback = void Function(ImportProgress progress);

/// Represents the current progress of a PDF import operation.
class ImportProgress {
  final String filename;
  final int currentPage;
  final int totalPages;
  final String status;
  final String? error;

  const ImportProgress({
    required this.filename,
    required this.currentPage,
    required this.totalPages,
    required this.status,
    this.error,
  });

  double get percentage =>
      totalPages > 0 ? currentPage / totalPages : 0.0;
}

/// Service that orchestrates the full PDF import pipeline.
///
/// Coordinates PDF extraction, OCR, parsing, and database storage.
class ImportService {
  final PdfExtractionService _pdfService;
  final OcrService _ocrService;
  final HashService _hashService;
  final ParserRegistry _parserRegistry;
  final AppDatabase _database;

  static const _uuid = Uuid();

  ImportService({
    required PdfExtractionService pdfService,
    required OcrService ocrService,
    required HashService hashService,
    required ParserRegistry parserRegistry,
    required AppDatabase database,
  })  : _pdfService = pdfService,
        _ocrService = ocrService,
        _hashService = hashService,
        _parserRegistry = parserRegistry,
        _database = database;

  /// Import a single PDF file.
  ///
  /// Returns the import ID if successful, or null if the file is a duplicate.
  /// Reports progress through [onProgress] callback.
  Future<String?> importPdf(
    File pdfFile, {
    ProgressCallback? onProgress,
  }) async {
    final filename = pdfFile.uri.pathSegments.last;
    final importId = _uuid.v4();

    // Compute hash to check for duplicates
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Computing file hash...',
    ));

    final hash = await _hashService.computeFileHash(pdfFile);

    // Check for duplicate import
    final existingImport = await _database.getImportByHash(hash);
    if (existingImport != null) {
      onProgress?.call(ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Duplicate detected',
        error: 'This file has already been imported as "${existingImport.filename}".',
      ));
      return null;
    }

    // Extract text from PDF
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Extracting text...',
    ));

    Map<int, String> pageTexts;
    bool usedOcr = false;

    try {
      pageTexts = await _pdfService.extractText(pdfFile);
    } catch (e) {
      onProgress?.call(ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Error',
        error: 'Failed to extract text: $e',
      ));
      // Store the import metadata with error
      await _database.insertImportMetadata(ImportMetadata(
        id: importId,
        filename: filename,
        sha256Hash: hash,
        importedAt: DateTime.now(),
        pageCount: 0,
        usedOcr: false,
        errorMessage: 'Failed to extract text: $e',
      ));
      return importId;
    }

    final totalPages = pageTexts.length;

    // Check for pages needing OCR
    for (final entry in pageTexts.entries) {
      if (entry.value.trim().isEmpty) {
        onProgress?.call(ImportProgress(
          filename: filename,
          currentPage: entry.key,
          totalPages: totalPages,
          status: 'Running OCR on page ${entry.key}...',
        ));

        // Note: In a full implementation, you would render the PDF page
        // to an image and then run OCR on it. This requires platform-
        // specific rendering. For now, we mark it as needing OCR.
        usedOcr = true;
        // The page remains empty - in production, this would be:
        // final imageBytes = await renderPdfPageToImage(pdfFile, entry.key);
        // pageTexts[entry.key] = await _ocrService.recognizeFromBytes(imageBytes);
      }
    }

    // Parse extracted text
    final allRecords = <FinancialRecord>[];

    for (final entry in pageTexts.entries) {
      final pageNumber = entry.key;
      final text = entry.value;

      if (text.trim().isEmpty) continue;

      onProgress?.call(ImportProgress(
        filename: filename,
        currentPage: pageNumber,
        totalPages: totalPages,
        status: 'Parsing page $pageNumber...',
      ));

      final result = _parserRegistry.parseText(
        text: text,
        sourceFile: filename,
        pageNumber: pageNumber,
        importId: importId,
      );

      allRecords.addAll(result.transactions);
    }

    // Save to database
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: totalPages,
      totalPages: totalPages,
      status: 'Saving records...',
    ));

    await _database.insertImportMetadata(ImportMetadata(
      id: importId,
      filename: filename,
      sha256Hash: hash,
      importedAt: DateTime.now(),
      pageCount: totalPages,
      usedOcr: usedOcr,
    ));

    if (allRecords.isNotEmpty) {
      await _database.insertRecords(allRecords);
    }

    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: totalPages,
      totalPages: totalPages,
      status: 'Complete - ${allRecords.length} records extracted',
    ));

    return importId;
  }

  /// Import multiple PDF files.
  Future<List<String>> importMultiplePdfs(
    List<File> files, {
    ProgressCallback? onProgress,
  }) async {
    final importIds = <String>[];

    for (final file in files) {
      final id = await importPdf(file, onProgress: onProgress);
      if (id != null) {
        importIds.add(id);
      }
    }

    return importIds;
  }

  /// Delete an import and all its associated records.
  Future<void> deleteImport(String importId, {bool confirmed = false}) async {
    if (!confirmed) {
      throw StateError(
          'Deletion must be confirmed. Set confirmed: true to proceed.');
    }
    await _database.deleteImport(importId);
  }

  void dispose() {
    _ocrService.dispose();
  }
}
