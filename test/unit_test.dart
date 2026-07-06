import 'package:flutter_test/flutter_test.dart';

import 'package:fintech_investigator/parsers/generic_transaction_parser.dart';
import 'package:fintech_investigator/services/csv_export_service.dart';
import 'package:fintech_investigator/services/hash_service.dart';

void main() {
  group('GenericTransactionParser', () {
    late GenericTransactionParser parser;

    setUp(() {
      parser = GenericTransactionParser();
    });

    test('parserName returns correct name', () {
      expect(parser.parserName, 'Generic Transaction Parser');
    });

    test('canParse always returns true for fallback', () {
      expect(parser.canParse('any text'), isTrue);
      expect(parser.canParse(''), isTrue);
    });

    test('parses a line with date and amount', () {
      const text = '01/15/2024 GROCERY STORE PURCHASE \$45.67';
      final result = parser.parse(
        text: text,
        sourceFile: 'test.pdf',
        pageNumber: 1,
        importId: 'test-import-id',
      );

      expect(result.transactions, isNotEmpty);
      expect(result.transactions.first.sourcePdf, 'test.pdf');
      expect(result.transactions.first.sourcePage, 1);
      expect(result.transactions.first.importId, 'test-import-id');
    });

    test('preserves unparseable text for manual review', () {
      const text = 'This text has no recognizable transactions';
      final result = parser.parse(
        text: text,
        sourceFile: 'test.pdf',
        pageNumber: 1,
        importId: 'test-import-id',
      );

      expect(result.transactions, isNotEmpty);
      expect(result.transactions.first.isUncertain, isTrue);
      expect(result.hasUncertainData, isTrue);
      expect(result.warnings, isNotEmpty);
    });

    test('detects institution from text', () {
      const text = 'CHASE BANK\nAccount Statement\n01/15/2024 Purchase \$50.00';
      final result = parser.parse(
        text: text,
        sourceFile: 'test.pdf',
        pageNumber: 1,
        importId: 'test-import-id',
      );

      expect(result.institution, 'CHASE');
    });
  });

  group('HashService', () {
    late HashService hashService;

    setUp(() {
      hashService = HashService();
    });

    test('computeStringHash returns consistent results', () {
      final hash1 = hashService.computeStringHash('test data');
      final hash2 = hashService.computeStringHash('test data');
      expect(hash1, equals(hash2));
    });

    test('computeStringHash returns different hashes for different input', () {
      final hash1 = hashService.computeStringHash('data1');
      final hash2 = hashService.computeStringHash('data2');
      expect(hash1, isNot(equals(hash2)));
    });

    test('hash is 64 characters (SHA-256 hex)', () {
      final hash = hashService.computeStringHash('test');
      expect(hash.length, 64);
    });
  });

  group('CsvExportService', () {
    late CsvExportService csvService;

    setUp(() {
      csvService = CsvExportService();
    });

    test('defaultColumns contains all expected fields', () {
      expect(CsvExportService.defaultColumns, contains('Transaction Date'));
      expect(CsvExportService.defaultColumns, contains('Description'));
      expect(CsvExportService.defaultColumns, contains('Debit'));
      expect(CsvExportService.defaultColumns, contains('Credit'));
      expect(CsvExportService.defaultColumns, contains('Source PDF'));
      expect(CsvExportService.defaultColumns, contains('Reviewed'));
      expect(CsvExportService.defaultColumns, contains('Manually Edited'));
    });

    test('exportToCsvString includes header row', () {
      final csv = csvService.exportToCsvString([]);
      expect(csv, contains('Transaction Date'));
      expect(csv, contains('Description'));
    });

    test('exportToCsvString with no header', () {
      final csv = csvService.exportToCsvString([], includeHeader: false);
      expect(csv, isEmpty);
    });
  });
}
