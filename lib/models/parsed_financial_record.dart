import 'financial_record.dart';

/// Result from parsing a financial document.
class ParsedFinancialRecord {
  final String? institution;
  final String? accountHolder;
  final String? maskedAccountNumber;
  final String? statementStartDate;
  final String? statementEndDate;
  final List<FinancialRecord> transactions;
  final List<String> warnings;
  final bool hasUncertainData;

  const ParsedFinancialRecord({
    this.institution,
    this.accountHolder,
    this.maskedAccountNumber,
    this.statementStartDate,
    this.statementEndDate,
    this.transactions = const [],
    this.warnings = const [],
    this.hasUncertainData = false,
  });
}
