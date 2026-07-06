import 'package:flutter_test/flutter_test.dart';

import 'package:fintech_investigator/parsers/generic_transaction_parser.dart';
import 'package:fintech_investigator/services/csv_export_service.dart';
import 'package:fintech_investigator/services/hash_service.dart';
import 'package:fintech_investigator/services/import_service.dart';

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

  // ---------------------------------------------------------------------------
  // ImportProgress
  // ---------------------------------------------------------------------------
  group('ImportProgress', () {
    test('percentage is 0 when totalPages is 0', () {
      const p = ImportProgress(
        filename: 'test.pdf',
        currentPage: 0,
        totalPages: 0,
        status: 'Queued',
      );
      expect(p.percentage, 0.0);
    });

    test('percentage is computed correctly when totalPages > 0', () {
      const p = ImportProgress(
        filename: 'test.pdf',
        currentPage: 1,
        totalPages: 4,
        status: 'Extracting text from page 1 of 4...',
      );
      expect(p.percentage, closeTo(0.25, 0.001));
    });

    test('isTimedOut defaults to false', () {
      const p = ImportProgress(
        filename: 'test.pdf',
        currentPage: 0,
        totalPages: 0,
        status: 'Queued',
      );
      expect(p.isTimedOut, isFalse);
    });

    test('isTimedOut can be set to true', () {
      const p = ImportProgress(
        filename: 'test.pdf',
        currentPage: 0,
        totalPages: 0,
        status: 'Timed out',
        error: 'Processing exceeded 60 seconds.',
        isTimedOut: true,
      );
      expect(p.isTimedOut, isTrue);
      expect(p.error, isNotNull);
    });

    test('error is null by default', () {
      const p = ImportProgress(
        filename: 'test.pdf',
        currentPage: 0,
        totalPages: 0,
        status: 'Loading file...',
      );
      expect(p.error, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // kProcessingTimeout constant
  // ---------------------------------------------------------------------------
  group('kProcessingTimeout', () {
    test('is 60 seconds', () {
      expect(kProcessingTimeout, const Duration(seconds: 60));
    });

    test('inSeconds is 60', () {
      expect(kProcessingTimeout.inSeconds, 60);
    });
  });

  // ---------------------------------------------------------------------------
  // Status transition ordering
  // ---------------------------------------------------------------------------
  group('ImportProgress status labels', () {
    // Verify the expected status strings exist so we can check log entries.
    const filename = 'statement.pdf';

    test('Queued status is constructable', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Queued',
      );
      expect(p.status, 'Queued');
    });

    test('Loading file status is constructable', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Loading file...',
      );
      expect(p.status, 'Loading file...');
    });

    test('Extracting text per-page status contains page numbers', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 2,
        totalPages: 4,
        status: 'Extracting text from page 2 of 4...',
      );
      expect(p.status, contains('2'));
      expect(p.status, contains('4'));
    });

    test('OCR status contains page number', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 1,
        totalPages: 2,
        status: 'Running OCR on page 1...',
      );
      expect(p.status, contains('OCR'));
      expect(p.status, contains('1'));
    });

    test('Parsing status contains page numbers', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 1,
        totalPages: 2,
        status: 'Parsing page 1 of 2...',
      );
      expect(p.status, contains('Parsing'));
      expect(p.status, contains('1'));
      expect(p.status, contains('2'));
    });

    test('Saving records status is constructable', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 2,
        totalPages: 2,
        status: 'Saving records...',
      );
      expect(p.status, 'Saving records...');
    });

    test('Complete status includes record count', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 2,
        totalPages: 2,
        status: 'Complete — 5 record(s) extracted',
      );
      expect(p.status, contains('Complete'));
      expect(p.status, contains('5'));
    });

    test('Timed out status has error and isTimedOut flag', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Timed out',
        error: 'Processing exceeded 60 seconds. The file may be too large or '
            'complex. Please try again.',
        isTimedOut: true,
      );
      expect(p.status, 'Timed out');
      expect(p.isTimedOut, isTrue);
      expect(p.error, contains('60 seconds'));
    });

    test('Failed status has error message', () {
      const p = ImportProgress(
        filename: filename,
        currentPage: 0,
        totalPages: 0,
        status: 'Failed',
        error: 'Failed to extract text: FormatException',
      );
      expect(p.status, 'Failed');
      expect(p.error, isNotNull);
      expect(p.isTimedOut, isFalse);
    });
  });
}

