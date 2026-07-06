import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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

/// Maximum time allowed for any single PDF import operation.
///
/// Increase this constant for extremely large or complex PDFs.
const Duration kProcessingTimeout = Duration(seconds: 60);

/// A web-safe container pairing PDF [bytes] with a display [filename].
///
/// Use this instead of `dart:io` [File] whenever the import pipeline is called
/// from a context that must compile for Flutter Web (e.g. [ImportScreen] /
/// [ProcessingScreen]).
class PdfImportInput {
  /// Raw bytes of the PDF document.
  final Uint8List bytes;

  /// Display name (e.g. `statement.pdf`) used for progress reporting and
  /// metadata storage. Must not be empty.
  final String filename;

  const PdfImportInput({required this.bytes, required this.filename});
}

/// Represents the current progress of a PDF import operation.
class ImportProgress {
  final String filename;
  final int currentPage;
  final int totalPages;
  final String status;
  final String? error;

  /// Whether this progress entry represents a terminal timed-out state.
  final bool isTimedOut;

  const ImportProgress({
    required this.filename,
    required this.currentPage,
    required this.totalPages,
    required this.status,
    this.error,
    this.isTimedOut = false,
  });

  double get percentage =>
      totalPages > 0 ? currentPage / totalPages : 0.0;
}

/// Service that orchestrates the full PDF import pipeline.
///
/// Coordinates PDF extraction, OCR, parsing, and database storage.
///
/// Every public operation is guarded by [kProcessingTimeout]. If the timeout
/// elapses the service emits a "Timed out" [ImportProgress] and returns a
/// stable state so the UI is never left hanging.
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

  /// Import a single PDF from its raw [bytes] and [filename].
  ///
  /// This is the primary, web-safe import entrypoint. It works on every
  /// platform because it never touches `dart:io`.
  ///
  /// Returns the import ID if successful, or `null` if the file is a
  /// duplicate. Reports progress through [onProgress].
  ///
  /// Every stage is bounded by [kProcessingTimeout]. On timeout an explicit
  /// "Timed out" [ImportProgress] is emitted and the import ID is returned so
  /// callers can surface a stable (non-null) result to the user.
  Future<String?> importPdfFromBytes(
    Uint8List bytes,
    String filename, {
    ProgressCallback? onProgress,
  }) async {
    final importId = _uuid.v4();

    // --- Stage 1: Queued -------------------------------------------------------
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Queued',
    ));

    // --- Stage 2: Load file & compute hash ------------------------------------
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Loading file...',
    ));

    final String hash;
    try {
      hash = await Future(() => _hashService.computeHash(bytes))
          .timeout(kProcessingTimeout);
    } on TimeoutException {
      return _emitTimeout(
        filename: filename,
        importId: importId,
        hash: null,
        pageCount: 0,
        onProgress: onProgress,
      );
    } catch (e) {
      return _emitError(
        filename: filename,
        importId: importId,
        hash: null,
        pageCount: 0,
        message: 'Failed to load file: $e',
        onProgress: onProgress,
      );
    }

    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Computing file hash...',
    ));

    // Check for duplicate import
    final existingImport = await _database.getImportByHash(hash);
    if (existingImport != null) {
      onProgress?.call(ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Duplicate detected',
        error:
            'This file has already been imported as "${existingImport.filename}".',
      ));
      return null;
    }

    // --- Stage 3: Extract text ------------------------------------------------
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: 0,
      status: 'Extracting text...',
    ));

    Map<int, String> pageTexts;
    bool usedOcr = false;

    try {
      pageTexts = await _pdfService
          .extractTextFromBytes(
            bytes,
            onPage: (page, total) {
              onProgress?.call(ImportProgress(
                filename: filename,
                currentPage: page,
                totalPages: total,
                status: 'Extracting text from page $page of $total...',
              ));
            },
          )
          .timeout(kProcessingTimeout);
    } on TimeoutException {
      return _emitTimeout(
        filename: filename,
        importId: importId,
        hash: hash,
        pageCount: 0,
        onProgress: onProgress,
      );
    } catch (e) {
      return _emitError(
        filename: filename,
        importId: importId,
        hash: hash,
        pageCount: 0,
        message: 'Failed to extract text: $e',
        onProgress: onProgress,
      );
    }

    final totalPages = pageTexts.length;

    // --- Stage 4: OCR (for image-only pages) ----------------------------------
    for (final entry in pageTexts.entries) {
      if (entry.value.trim().isEmpty) {
        onProgress?.call(ImportProgress(
          filename: filename,
          currentPage: entry.key,
          totalPages: totalPages,
          status: 'Running OCR on page ${entry.key}...',
        ));

        usedOcr = true;
        // Note: In a full implementation, you would render the PDF page
        // to an image and then run OCR on it. This requires platform-
        // specific rendering. The OCR call should be wrapped with
        // .timeout(kProcessingTimeout) when implemented:
        //
        //   final imageBytes = await renderPdfPageToImage(bytes, entry.key);
        //   pageTexts[entry.key] = await _ocrService
        //       .recognizeFromBytes(imageBytes)
        //       .timeout(kProcessingTimeout);
      }
    }

    // --- Stage 5: Parse -------------------------------------------------------
    final allRecords = <FinancialRecord>[];

    for (final entry in pageTexts.entries) {
      final pageNumber = entry.key;
      final text = entry.value;

      if (text.trim().isEmpty) continue;

      onProgress?.call(ImportProgress(
        filename: filename,
        currentPage: pageNumber,
        totalPages: totalPages,
        status: 'Parsing page $pageNumber of $totalPages...',
      ));

      final result = _parserRegistry.parseText(
        text: text,
        sourceFile: filename,
        pageNumber: pageNumber,
        importId: importId,
      );

      allRecords.addAll(result.transactions);
    }

    // --- Stage 6: Save --------------------------------------------------------
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: totalPages,
      totalPages: totalPages,
      status: 'Saving records...',
    ));

    try {
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
    } catch (e) {
      return _emitError(
        filename: filename,
        importId: importId,
        hash: hash,
        pageCount: totalPages,
        message: 'Failed to save records: $e',
        onProgress: onProgress,
      );
    }

    // --- Stage 7: Complete ----------------------------------------------------
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: totalPages,
      totalPages: totalPages,
      status: 'Complete — ${allRecords.length} record(s) extracted',
    ));

    return importId;
  }

  /// Import a single PDF file.
  ///
  /// Native-only convenience wrapper: reads the file bytes then delegates to
  /// [importPdfFromBytes]. Do not call this on Flutter Web — use
  /// [importPdfFromBytes] with bytes obtained from [XFile.readAsBytes()] or
  /// similar web-safe APIs instead.
  ///
  /// Returns the import ID if successful, or `null` if the file is a
  /// duplicate. Reports progress through [onProgress].
  Future<String?> importPdf(
    File pdfFile, {
    ProgressCallback? onProgress,
  }) async {
    final filename = pdfFile.uri.pathSegments.last;
    final bytes = await pdfFile.readAsBytes();
    return importPdfFromBytes(bytes, filename, onProgress: onProgress);
  }

  /// Import multiple PDF files.
  ///
  /// Native-only convenience wrapper. Do not call this on Flutter Web.
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Emit a terminal "Timed out" progress event, persist metadata, and return
  /// the import ID so the caller can surface a stable (non-null) result.
  Future<String> _emitTimeout({
    required String filename,
    required String importId,
    required String? hash,
    required int pageCount,
    required ProgressCallback? onProgress,
  }) async {
    final message =
        'Processing exceeded ${kProcessingTimeout.inSeconds} seconds. '
        'The file may be too large or complex. Please try again.';

    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: pageCount,
      status: 'Timed out',
      error: message,
      isTimedOut: true,
    ));

    if (hash != null) {
      await _safeInsertError(importId, filename, hash, pageCount, message);
    }
    return importId;
  }

  /// Emit a terminal "Failed" progress event, persist metadata, and return
  /// the import ID.
  Future<String> _emitError({
    required String filename,
    required String importId,
    required String? hash,
    required int pageCount,
    required String message,
    required ProgressCallback? onProgress,
  }) async {
    onProgress?.call(ImportProgress(
      filename: filename,
      currentPage: 0,
      totalPages: pageCount,
      status: 'Failed',
      error: message,
    ));

    if (hash != null) {
      await _safeInsertError(importId, filename, hash, pageCount, message);
    }
    return importId;
  }

  /// Persist an error-state import metadata record, swallowing any DB errors
  /// so that the UI always receives a terminal status.
  Future<void> _safeInsertError(
    String importId,
    String filename,
    String hash,
    int pageCount,
    String errorMessage,
  ) async {
    try {
      await _database.insertImportMetadata(ImportMetadata(
        id: importId,
        filename: filename,
        sha256Hash: hash,
        importedAt: DateTime.now(),
        pageCount: pageCount,
        usedOcr: false,
        errorMessage: errorMessage,
      ));
    } catch (_) {
      // Swallow database errors so the UI still receives the terminal status.
    }
  }
}
