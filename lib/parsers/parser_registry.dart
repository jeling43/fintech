import '../models/parsed_financial_record.dart';
import 'chase_statement_parser.dart';
import 'financial_record_parser.dart';
import 'generic_transaction_parser.dart';

/// Registry that manages all available financial record parsers.
///
/// The registry tries each registered parser in order. The first parser
/// that can handle the text is used. The generic parser is always last
/// as a fallback.
class ParserRegistry {
  final List<FinancialRecordParser> _parsers = [];
  final GenericTransactionParser _fallbackParser = GenericTransactionParser();

  ParserRegistry() {
    // Register institution-specific parsers
    _parsers.add(ChaseStatementParser());
    // Add more parsers here as they are developed:
    // _parsers.add(BankOfAmericaParser());
    // _parsers.add(WellsFargoParser());
  }

  /// Register a custom parser.
  void registerParser(FinancialRecordParser parser) {
    _parsers.add(parser);
  }

  /// Get the list of all registered parser names.
  List<String> get parserNames =>
      [..._parsers.map((p) => p.parserName), _fallbackParser.parserName];

  /// Select the appropriate parser for the given text and parse it.
  ///
  /// Returns the result from the first parser that reports it can handle
  /// the text. Falls back to the generic parser if no specific parser matches.
  ParsedFinancialRecord parseText({
    required String text,
    required String sourceFile,
    required int pageNumber,
    required String importId,
  }) {
    // Try each registered parser in order
    for (final parser in _parsers) {
      if (parser.canParse(text)) {
        return parser.parse(
          text: text,
          sourceFile: sourceFile,
          pageNumber: pageNumber,
          importId: importId,
        );
      }
    }

    // Fall back to generic parser
    return _fallbackParser.parse(
      text: text,
      sourceFile: sourceFile,
      pageNumber: pageNumber,
      importId: importId,
    );
  }

  /// Get the parser that would be selected for the given text.
  FinancialRecordParser getParserFor(String text) {
    for (final parser in _parsers) {
      if (parser.canParse(text)) {
        return parser;
      }
    }
    return _fallbackParser;
  }
}
