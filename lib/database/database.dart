import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/financial_record.dart';
import '../models/import_metadata.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [ImportMetadataTable, FinancialRecordsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // === Import Metadata Operations ===

  Future<void> insertImportMetadata(ImportMetadata metadata) async {
    await into(importMetadataTable).insert(ImportMetadataTableCompanion.insert(
      id: metadata.id,
      filename: metadata.filename,
      sha256Hash: metadata.sha256Hash,
      importedAt: metadata.importedAt,
      pageCount: metadata.pageCount,
      usedOcr: Value(metadata.usedOcr),
      errorMessage: Value(metadata.errorMessage),
    ));
  }

  Future<List<ImportMetadataTableData>> getAllImports() async {
    return await select(importMetadataTable).get();
  }

  Future<ImportMetadataTableData?> getImportByHash(String hash) async {
    return await (select(importMetadataTable)
          ..where((t) => t.sha256Hash.equals(hash)))
        .getSingleOrNull();
  }

  Future<void> deleteImport(String importId) async {
    await (delete(financialRecordsTable)
          ..where((t) => t.importId.equals(importId)))
        .go();
    await (delete(importMetadataTable)..where((t) => t.id.equals(importId)))
        .go();
  }

  // === Financial Records Operations ===

  Future<void> insertRecord(FinancialRecord record) async {
    await into(financialRecordsTable)
        .insert(FinancialRecordsTableCompanion.insert(
      id: record.id,
      transactionDate: Value(record.transactionDate),
      postingDate: Value(record.postingDate),
      description: Value(record.description),
      merchantOrRecipient: Value(record.merchantOrRecipient),
      debit: Value(record.debit),
      credit: Value(record.credit),
      amount: Value(record.amount),
      balance: Value(record.balance),
      checkNumber: Value(record.checkNumber),
      referenceNumber: Value(record.referenceNumber),
      institution: Value(record.institution),
      accountHolder: Value(record.accountHolder),
      maskedAccountNumber: Value(record.maskedAccountNumber),
      sourcePdf: record.sourcePdf,
      sourcePage: record.sourcePage,
      originalText: record.originalText,
      reviewed: Value(record.reviewed),
      manuallyEdited: Value(record.manuallyEdited),
      importId: record.importId,
      isUncertain: Value(record.isUncertain),
    ));
  }

  Future<void> insertRecords(List<FinancialRecord> records) async {
    await batch((batch) {
      for (final record in records) {
        batch.insert(
          financialRecordsTable,
          FinancialRecordsTableCompanion.insert(
            id: record.id,
            transactionDate: Value(record.transactionDate),
            postingDate: Value(record.postingDate),
            description: Value(record.description),
            merchantOrRecipient: Value(record.merchantOrRecipient),
            debit: Value(record.debit),
            credit: Value(record.credit),
            amount: Value(record.amount),
            balance: Value(record.balance),
            checkNumber: Value(record.checkNumber),
            referenceNumber: Value(record.referenceNumber),
            institution: Value(record.institution),
            accountHolder: Value(record.accountHolder),
            maskedAccountNumber: Value(record.maskedAccountNumber),
            sourcePdf: record.sourcePdf,
            sourcePage: record.sourcePage,
            originalText: record.originalText,
            reviewed: Value(record.reviewed),
            manuallyEdited: Value(record.manuallyEdited),
            importId: record.importId,
            isUncertain: Value(record.isUncertain),
          ),
        );
      }
    });
  }

  Future<List<FinancialRecordsTableData>> getAllRecords() async {
    return await select(financialRecordsTable).get();
  }

  Future<List<FinancialRecordsTableData>> getRecordsByImport(
      String importId) async {
    return await (select(financialRecordsTable)
          ..where((t) => t.importId.equals(importId)))
        .get();
  }

  Future<void> updateRecord(FinancialRecord record) async {
    await (update(financialRecordsTable)
          ..where((t) => t.id.equals(record.id)))
        .write(FinancialRecordsTableCompanion(
      transactionDate: Value(record.transactionDate),
      postingDate: Value(record.postingDate),
      description: Value(record.description),
      merchantOrRecipient: Value(record.merchantOrRecipient),
      debit: Value(record.debit),
      credit: Value(record.credit),
      amount: Value(record.amount),
      balance: Value(record.balance),
      checkNumber: Value(record.checkNumber),
      referenceNumber: Value(record.referenceNumber),
      institution: Value(record.institution),
      accountHolder: Value(record.accountHolder),
      maskedAccountNumber: Value(record.maskedAccountNumber),
      reviewed: Value(record.reviewed),
      manuallyEdited: Value(record.manuallyEdited),
      isUncertain: Value(record.isUncertain),
    ));
  }

  Future<void> deleteRecord(String recordId) async {
    await (delete(financialRecordsTable)..where((t) => t.id.equals(recordId)))
        .go();
  }

  Future<void> markRecordReviewed(String recordId) async {
    await (update(financialRecordsTable)
          ..where((t) => t.id.equals(recordId)))
        .write(
      const FinancialRecordsTableCompanion(reviewed: Value(true)),
    );
  }

  Stream<List<FinancialRecordsTableData>> watchAllRecords() {
    return select(financialRecordsTable).watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fintech_investigator.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
