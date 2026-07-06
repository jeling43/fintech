import 'package:uuid/uuid.dart';

import '../models/financial_record.dart';
import '../models/parsed_financial_record.dart';
import 'financial_record_parser.dart';

/// Generic transaction parser that attempts to identify transactions
/// from any bank statement format using common patterns.
class GenericTransactionParser implements FinancialRecordParser {
  static const _uuid = Uuid();

  @override
  String get parserName => 'Generic Transaction Parser';

  @override
  bool canParse(String text) {
    // The generic parser is a fallback; it always returns true.
    return true;
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

    // Try to extract institution info from the header
    final institution = _extractInstitution(text);
    final accountHolder = _extractAccountHolder(text);
    final maskedAccountNumber = _extractMaskedAccountNumber(text);

    // Split text into lines and look for transaction patterns
    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final transaction = _tryParseTransactionLine(
        line: line,
        sourceFile: sourceFile,
        pageNumber: pageNumber,
        importId: importId,
        institution: institution,
        accountHolder: accountHolder,
        maskedAccountNumber: maskedAccountNumber,
      );

      if (transaction != null) {
        transactions.add(transaction);
        if (transaction.isUncertain) {
          hasUncertainData = true;
        }
      }
    }

    // If no transactions were parsed, preserve entire text as a single
    // uncertain record for manual review
    if (transactions.isEmpty && text.trim().isNotEmpty) {
      transactions.add(FinancialRecord(
        id: _uuid.v4(),
        originalText: text.trim(),
        sourcePdf: sourceFile,
        sourcePage: pageNumber,
        importId: importId,
        institution: institution,
        accountHolder: accountHolder,
        maskedAccountNumber: maskedAccountNumber,
        isUncertain: true,
      ));
      hasUncertainData = true;
      warnings.add(
          'Could not parse individual transactions from page $pageNumber. '
          'Text preserved for manual review.');
    }

    return ParsedFinancialRecord(
      institution: institution,
      accountHolder: accountHolder,
      maskedAccountNumber: maskedAccountNumber,
      transactions: transactions,
      warnings: warnings,
      hasUncertainData: hasUncertainData,
    );
  }

  FinancialRecord? _tryParseTransactionLine({
    required String line,
    required String sourceFile,
    required int pageNumber,
    required String importId,
    String? institution,
    String? accountHolder,
    String? maskedAccountNumber,
  }) {
    // Common date patterns: MM/DD/YYYY, MM-DD-YYYY, YYYY-MM-DD, MM/DD
    final datePattern = RegExp(
      r'(\d{1,2}[/-]\d{1,2}[/-]?\d{0,4}|\d{4}-\d{2}-\d{2})',
    );

    // Amount patterns: $1,234.56 or 1234.56 or -1234.56
    final amountPattern = RegExp(
      r'[-]?\$?\s*[\d,]+\.\d{2}',
    );

    final dateMatch = datePattern.firstMatch(line);
    if (dateMatch == null) return null;

    final amounts = amountPattern.allMatches(line).toList();
    if (amounts.isEmpty) return null;

    // Extract the date
    final dateStr = _normalizeDate(dateMatch.group(0)!);

    // Extract amounts
    double? debit;
    double? credit;
    double? amount;
    double? balance;

    final parsedAmounts =
        amounts.map((m) => _parseAmount(m.group(0)!)).toList();

    if (parsedAmounts.length == 1) {
      amount = parsedAmounts[0];
      if (amount < 0) {
        debit = amount.abs();
      } else {
        credit = amount;
      }
    } else if (parsedAmounts.length >= 2) {
      // First amount is typically transaction amount, last may be balance
      amount = parsedAmounts[0];
      if (amount < 0) {
        debit = amount.abs();
      } else {
        credit = amount;
      }
      balance = parsedAmounts.last;
    }

    // Extract description: text between date and first amount
    final dateEnd = dateMatch.end;
    final firstAmountStart = amounts.first.start;
    String description = '';
    if (firstAmountStart > dateEnd) {
      description = line.substring(dateEnd, firstAmountStart).trim();
    }

    // Check for check number pattern
    final checkPattern = RegExp(r'(?:CHK|CHECK|CK)\s*#?\s*(\d+)', caseSensitive: false);
    final checkMatch = checkPattern.firstMatch(line);
    final checkNumber = checkMatch?.group(1);

    // Check for reference number
    final refPattern = RegExp(r'(?:REF|REFERENCE)\s*#?\s*:?\s*(\w+)', caseSensitive: false);
    final refMatch = refPattern.firstMatch(line);
    final referenceNumber = refMatch?.group(1);

    // Determine if this is uncertain
    final isUncertain = description.isEmpty && amount == null;

    return FinancialRecord(
      id: _uuid.v4(),
      transactionDate: dateStr,
      description: description.isNotEmpty ? description : null,
      debit: debit,
      credit: credit,
      amount: amount,
      balance: balance,
      checkNumber: checkNumber,
      referenceNumber: referenceNumber,
      institution: institution,
      accountHolder: accountHolder,
      maskedAccountNumber: maskedAccountNumber,
      sourcePdf: sourceFile,
      sourcePage: pageNumber,
      originalText: line,
      importId: importId,
      isUncertain: isUncertain,
    );
  }

  String? _normalizeDate(String dateStr) {
    // Try to convert to YYYY-MM-DD format
    final parts = dateStr.split(RegExp(r'[/-]'));
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        // Already YYYY-MM-DD
        return dateStr;
      }
      final month = parts[0].padLeft(2, '0');
      final day = parts[1].padLeft(2, '0');
      String year = parts[2];
      if (year.length == 2) {
        year = '20$year';
      }
      return '$year-$month-$day';
    } else if (parts.length == 2) {
      // MM/DD format - year is unknown
      final month = parts[0].padLeft(2, '0');
      final day = parts[1].padLeft(2, '0');
      return '$month-$day';
    }
    return dateStr;
  }

  double _parseAmount(String amountStr) {
    // Remove $ sign, spaces, and commas
    final cleaned =
        amountStr.replaceAll(RegExp(r'[\$\s,]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String? _extractInstitution(String text) {
    // Look for common bank identifiers in the first few lines
    final firstLines = text.split('\n').take(10).join(' ').toUpperCase();
    final banks = [
      'CHASE',
      'BANK OF AMERICA',
      'WELLS FARGO',
      'CITIBANK',
      'US BANK',
      'PNC BANK',
      'CAPITAL ONE',
      'TD BANK',
      'REGIONS',
      'SUNTRUST',
      'BB&T',
      'FIFTH THIRD',
      'ALLY BANK',
    ];
    for (final bank in banks) {
      if (firstLines.contains(bank)) return bank;
    }
    return null;
  }

  String? _extractAccountHolder(String text) {
    // Look for name patterns near the top
    final namePattern = RegExp(
      r'(?:ACCOUNT\s+HOLDER|NAME|CUSTOMER)\s*:?\s*([A-Z][A-Za-z\s]+)',
      caseSensitive: false,
    );
    final match = namePattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractMaskedAccountNumber(String text) {
    // Look for masked account numbers like ****1234 or XXXX-XXXX-1234
    final accountPattern = RegExp(
      r'(?:ACCOUNT|ACCT)\s*#?\s*:?\s*([\*xX]+[\-\s]?[\*xX\d\-\s]*\d{4})',
      caseSensitive: false,
    );
    final match = accountPattern.firstMatch(text);
    return match?.group(1)?.trim();
  }
}
