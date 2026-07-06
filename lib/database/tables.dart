import 'package:drift/drift.dart';

/// Table for storing imported PDF metadata.
class ImportMetadataTable extends Table {
  TextColumn get id => text()();
  TextColumn get filename => text()();
  TextColumn get sha256Hash => text()();
  DateTimeColumn get importedAt => dateTime()();
  IntColumn get pageCount => integer()();
  BoolColumn get usedOcr => boolean().withDefault(const Constant(false))();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for storing extracted financial records.
class FinancialRecordsTable extends Table {
  TextColumn get id => text()();
  TextColumn get transactionDate => text().nullable()();
  TextColumn get postingDate => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get merchantOrRecipient => text().nullable()();
  RealColumn get debit => real().nullable()();
  RealColumn get credit => real().nullable()();
  RealColumn get amount => real().nullable()();
  RealColumn get balance => real().nullable()();
  TextColumn get checkNumber => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get institution => text().nullable()();
  TextColumn get accountHolder => text().nullable()();
  TextColumn get maskedAccountNumber => text().nullable()();
  TextColumn get sourcePdf => text()();
  IntColumn get sourcePage => integer()();
  TextColumn get originalText => text()();
  BoolColumn get reviewed => boolean().withDefault(const Constant(false))();
  BoolColumn get manuallyEdited =>
      boolean().withDefault(const Constant(false))();
  TextColumn get importId => text()();
  BoolColumn get isUncertain =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
