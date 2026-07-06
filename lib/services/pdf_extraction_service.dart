import 'dart:io';
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Callback invoked after each page is extracted.
///
/// [page] is the 1-indexed page number just processed.
/// [total] is the total page count of the document.
typedef PageProgressCallback = void Function(int page, int total);

/// Service for extracting text from PDF files.
///
/// Uses the Syncfusion PDF library to extract embedded text from each page.
/// Returns text per page for accurate source tracking.
class PdfExtractionService {
  /// Extract text from all pages of a PDF given its raw [bytes].
  ///
  /// This is the primary, web-safe extraction method. It works on every
  /// platform because it never touches `dart:io`.
  ///
  /// Returns a map of page number (1-indexed) to extracted text. If a page
  /// has no extractable text it returns an empty string for that page.
  ///
  /// [onPage] is called after each page is processed so callers can emit
  /// per-page progress updates.
  Future<Map<int, String>> extractTextFromBytes(
    Uint8List bytes, {
    PageProgressCallback? onPage,
  }) async {
    final Map<int, String> pageTexts = {};
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      final int pageCount = document.pages.count;

      for (int i = 0; i < pageCount; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String text =
            extractor.extractText(startPageIndex: i, endPageIndex: i);
        pageTexts[i + 1] = text; // 1-indexed page numbers
        onPage?.call(i + 1, pageCount);
      }
    } finally {
      document.dispose();
    }

    return pageTexts;
  }

  /// Extract text from all pages of a PDF [File].
  ///
  /// Native-only convenience wrapper: reads the file bytes then delegates to
  /// [extractTextFromBytes]. Do not call this on Flutter Web.
  Future<Map<int, String>> extractText(
    File pdfFile, {
    PageProgressCallback? onPage,
  }) async {
    final Uint8List bytes = await pdfFile.readAsBytes();
    return extractTextFromBytes(bytes, onPage: onPage);
  }

  /// Get the page count of a PDF given its raw [bytes].
  ///
  /// Web-safe variant of [getPageCount].
  Future<int> getPageCountFromBytes(Uint8List bytes) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final int count = document.pages.count;
    document.dispose();
    return count;
  }

  /// Get the page count of a PDF [File].
  ///
  /// Native-only convenience wrapper. Do not call this on Flutter Web.
  Future<int> getPageCount(File pdfFile) async {
    final Uint8List bytes = await pdfFile.readAsBytes();
    return getPageCountFromBytes(bytes);
  }

  /// Check if a page has extractable text (not a scanned image) from [bytes].
  ///
  /// Web-safe variant of [hasExtractableText].
  Future<bool> hasExtractableTextFromBytes(
      Uint8List bytes, int pageIndex) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText(
          startPageIndex: pageIndex, endPageIndex: pageIndex);
      return text.trim().isNotEmpty;
    } finally {
      document.dispose();
    }
  }

  /// Check if a page has extractable text (not a scanned image).
  ///
  /// Native-only convenience wrapper. Do not call this on Flutter Web.
  Future<bool> hasExtractableText(File pdfFile, int pageIndex) async {
    final Uint8List bytes = await pdfFile.readAsBytes();
    return hasExtractableTextFromBytes(bytes, pageIndex);
  }
}
