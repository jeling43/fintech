import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/financial_record.dart';

/// Service for exporting financial records to CSV format.
///
/// Requirements:
/// - UTF-8 encoding
/// - Proper handling of commas and quotation marks
/// - Dates formatted as YYYY-MM-DD
/// - Currency with two decimal places
/// - Header row included
class CsvExportService {
  /// Default columns for CSV export.
  static const List<String> defaultColumns = [
    'Transaction Date',
    'Posting Date',
    'Description',
    'Merchant or Recipient',
    'Debit',
    'Credit',
    'Amount',
    'Balance',
    'Check Number',
    'Reference Number',
    'Institution',
    'Account Holder',
    'Masked Account Number',
    'Source PDF',
    'Source Page',
    'Original Text',
    'Reviewed',
    'Manually Edited',
  ];

  /// Export records to CSV string.
  ///
  /// [records] - the financial records to export.
  /// [columns] - optional list of columns to include. Defaults to all columns.
  /// [includeHeader] - whether to include the header row (default: true).
  String exportToCsvString(
    List<FinancialRecord> records, {
    List<String>? columns,
    bool includeHeader = true,
  }) {
    final selectedColumns = columns ?? defaultColumns;
    final List<List<dynamic>> rows = [];

    if (includeHeader) {
      rows.add(selectedColumns);
    }

    for (final record in records) {
      final row = <dynamic>[];
      for (final column in selectedColumns) {
        row.add(_getFieldValue(record, column));
      }
      rows.add(row);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export records to a CSV file.
  ///
  /// Returns the path to the created file.
  Future<String> exportToCsvFile(
    List<FinancialRecord> records, {
    String? filename,
    List<String>? columns,
  }) async {
    final csvString = exportToCsvString(records, columns: columns);
    final directory = await getApplicationDocumentsDirectory();
    final exportFilename =
        filename ?? 'financial_records_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(p.join(directory.path, exportFilename));
    await file.writeAsString(csvString, encoding: utf8);
    return file.path;
  }

  /// Get the value of a field for a given column name.
  String _getFieldValue(FinancialRecord record, String column) {
    switch (column) {
      case 'Transaction Date':
        return record.transactionDate ?? '';
      case 'Posting Date':
        return record.postingDate ?? '';
      case 'Description':
        return record.description ?? '';
      case 'Merchant or Recipient':
        return record.merchantOrRecipient ?? '';
      case 'Debit':
        return record.debit != null ? record.debit!.toStringAsFixed(2) : '';
      case 'Credit':
        return record.credit != null ? record.credit!.toStringAsFixed(2) : '';
      case 'Amount':
        return record.amount != null ? record.amount!.toStringAsFixed(2) : '';
      case 'Balance':
        return record.balance != null ? record.balance!.toStringAsFixed(2) : '';
      case 'Check Number':
        return record.checkNumber ?? '';
      case 'Reference Number':
        return record.referenceNumber ?? '';
      case 'Institution':
        return record.institution ?? '';
      case 'Account Holder':
        return record.accountHolder ?? '';
      case 'Masked Account Number':
        return record.maskedAccountNumber ?? '';
      case 'Source PDF':
        return record.sourcePdf;
      case 'Source Page':
        return record.sourcePage.toString();
      case 'Original Text':
        return record.originalText;
      case 'Reviewed':
        return record.reviewed ? 'Yes' : 'No';
      case 'Manually Edited':
        return record.manuallyEdited ? 'Yes' : 'No';
      default:
        return '';
    }
  }
}
