import '../models/parsed_financial_record.dart';

/// Interface for financial record parsers.
///
/// Implement this interface to add support for additional financial
/// institutions. Each parser should identify whether it can handle a
/// given text block and extract structured transaction data.
abstract interface class FinancialRecordParser {
  /// Human-readable name of this parser (e.g., "Chase Bank Statement").
  String get parserName;

  /// Returns true if this parser can handle the given text.
  ///
  /// Implementations should look for institution-specific identifiers
  /// such as bank names, logos text, or formatting patterns.
  bool canParse(String text);

  /// Parse the text and return structured financial records.
  ///
  /// [text] is the extracted text from the PDF page or document.
  /// [sourceFile] is the filename of the source PDF.
  /// [pageNumber] is the page number within the PDF.
  /// [importId] is the unique ID of this import operation.
  ParsedFinancialRecord parse({
    required String text,
    required String sourceFile,
    required int pageNumber,
    required String importId,
  });
}
