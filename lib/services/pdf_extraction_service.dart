import 'dart:io';
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service for extracting text from PDF files.
///
/// Uses the Syncfusion PDF library to extract embedded text from each page.
/// Returns text per page for accurate source tracking.
class PdfExtractionService {
  /// Extract text from all pages of a PDF file.
  ///
  /// Returns a map of page number (1-indexed) to extracted text.
  /// If a page has no extractable text, it returns an empty string for that page.
  Future<Map<int, String>> extractText(File pdfFile) async {
    final Map<int, String> pageTexts = {};

    final Uint8List bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      final int pageCount = document.pages.count;

      for (int i = 0; i < pageCount; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        pageTexts[i + 1] = text; // 1-indexed page numbers
      }
    } finally {
      document.dispose();
    }

    return pageTexts;
  }

  /// Get the page count of a PDF file.
  Future<int> getPageCount(File pdfFile) async {
    final Uint8List bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final int count = document.pages.count;
    document.dispose();
    return count;
  }

  /// Check if a page has extractable text (not a scanned image).
  Future<bool> hasExtractableText(File pdfFile, int pageIndex) async {
    final Uint8List bytes = await pdfFile.readAsBytes();
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
}
