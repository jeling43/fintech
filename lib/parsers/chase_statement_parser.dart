import 'package:uuid/uuid.dart';

import '../models/financial_record.dart';
import '../models/parsed_financial_record.dart';
import 'financial_record_parser.dart';

/// Example institution-specific parser for Chase Bank statements.
///
/// This demonstrates how to create a parser for a specific financial
/// institution by looking for institution-specific formatting patterns.
class ChaseStatementParser implements FinancialRecordParser {
  static const _uuid = Uuid();

  @override
  String get parserName => 'Chase Bank Statement Parser';

  @override
  bool canParse(String text) {
    final upperText = text.toUpperCase();
    return upperText.contains('JPMORGAN CHASE') ||
        upperText.contains('CHASE BANK') ||
        (upperText.contains('CHASE') &&
            upperText.contains('CHECKING') &&
            upperText.contains('STATEMENT'));
  }

  @override
  ParsedFinancialRecord parse({
    required String text,
    required String sourceFile,
    required int pageNumber,
    required String importId,
  }) {
    final transactions = <FinancialRecord>[];
    final warnings = <String>[];
    bool hasUncertainData = false;

    final accountHolder = _extractAccountHolder(text);
    final maskedAccount = _extractMaskedAccount(text);
    final statementDates = _extractStatementDates(text);

    final lines = text.split('\n');
    bool inTransactionSection = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Detect transaction section headers
      if (_isTransactionSectionHeader(line)) {
        inTransactionSection = true;
        continue;
      }

      // Detect end of transaction section
      if (inTransactionSection && _isEndOfSection(line)) {
        inTransactionSection = false;
        continue;
      }

      if (!inTransactionSection) continue;

      final transaction = _parseChaseTransactionLine(
        line: line,
        sourceFile: sourceFile,
        pageNumber: pageNumber,
        importId: importId,
        accountHolder: accountHolder,
        maskedAccount: maskedAccount,
      );

      if (transaction != null) {
        transactions.add(transaction);
        if (transaction.isUncertain) {
          hasUncertainData = true;
        }
      }
    }

    return ParsedFinancialRecord(
      institution: 'Chase',
      accountHolder: accountHolder,
      maskedAccountNumber: maskedAccount,
      statementStartDate: statementDates.$1,
      statementEndDate: statementDates.$2,
      transactions: transactions,
      warnings: warnings,
      hasUncertainData: hasUncertainData,
    );
  }

  bool _isTransactionSectionHeader(String line) {
    final upper = line.toUpperCase();
    return upper.contains('TRANSACTION DETAIL') ||
        upper.contains('CHECKING ACTIVITY') ||
        upper.contains('SAVINGS ACTIVITY') ||
        upper.contains('PAYMENT ACTIVITY');
  }

  bool _isEndOfSection(String line) {
    final upper = line.toUpperCase();
    return upper.contains('TOTAL') ||
        upper.contains('ENDING BALANCE') ||
        upper.contains('SERVICE CHARGE SUMMARY');
  }

  FinancialRecord? _parseChaseTransactionLine({
    required String line,
    required String sourceFile,
    required int pageNumber,
    required String importId,
    String? accountHolder,
    String? maskedAccount,
  }) {
    // Chase format: MM/DD  Description  Amount
    final pattern = RegExp(
      r'^(\d{2}/\d{2})\s+(.+?)\s+([-]?\$?[\d,]+\.\d{2})\s*$',
    );
    final match = pattern.firstMatch(line);
    if (match == null) return null;

    final dateStr = match.group(1)!;
    final description = match.group(2)!.trim();
    final amountStr = match.group(3)!.replaceAll(RegExp(r'[\$,]'), '');
    final amount = double.tryParse(amountStr);

    if (amount == null) return null;

    return FinancialRecord(
      id: _uuid.v4(),
      transactionDate: dateStr,
      description: description,
      debit: amount < 0 ? amount.abs() : null,
      credit: amount > 0 ? amount : null,
      amount: amount,
      institution: 'Chase',
      accountHolder: accountHolder,
      maskedAccountNumber: maskedAccount,
      sourcePdf: sourceFile,
      sourcePage: pageNumber,
      originalText: line,
      importId: importId,
      isUncertain: false,
    );
  }

  String? _extractAccountHolder(String text) {
    final pattern = RegExp(
      r'(?:^|\n)\s*([A-Z][A-Z\s]+)\s*\n.*(?:CHECKING|SAVINGS)',
      multiLine: true,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractMaskedAccount(String text) {
    final pattern = RegExp(
      r'(?:Account|Acct)\s*(?:#|Number)?\s*:?\s*\.{0,4}\s*(\d{4})',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    if (match != null) {
      return '****${match.group(1)}';
    }
    return null;
  }

  (String?, String?) _extractStatementDates(String text) {
    final pattern = RegExp(
      r'(\w+\s+\d{1,2},?\s*\d{4})\s*(?:through|to|-)\s*(\w+\s+\d{1,2},?\s*\d{4})',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    if (match != null) {
      return (match.group(1), match.group(2));
    }
    return (null, null);
  }
}
