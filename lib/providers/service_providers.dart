import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../parsers/parser_registry.dart';
import '../services/csv_export_service.dart';
import '../services/hash_service.dart';
import '../services/import_service.dart';
import '../services/ocr_service.dart';
import '../services/pdf_extraction_service.dart';

/// Database provider - singleton instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// PDF extraction service provider.
final pdfExtractionServiceProvider = Provider<PdfExtractionService>((ref) {
  return PdfExtractionService();
});

/// OCR service provider.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Hash service provider.
final hashServiceProvider = Provider<HashService>((ref) {
  return HashService();
});

/// CSV export service provider.
final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService();
});

/// Parser registry provider.
final parserRegistryProvider = Provider<ParserRegistry>((ref) {
  return ParserRegistry();
});

/// Import service provider.
final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(
    pdfService: ref.watch(pdfExtractionServiceProvider),
    ocrService: ref.watch(ocrServiceProvider),
    hashService: ref.watch(hashServiceProvider),
    parserRegistry: ref.watch(parserRegistryProvider),
    database: ref.watch(databaseProvider),
  );
});
