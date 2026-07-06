// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run build_runner build` to regenerate this file.

part of 'database.dart';

class $ImportMetadataTableTable extends ImportMetadataTable
    with TableInfo<$ImportMetadataTableTable, ImportMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportMetadataTableTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _filenameMeta = VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _sha256HashMeta =
      VerificationMeta('sha256Hash');
  @override
  late final GeneratedColumn<String> sha256Hash = GeneratedColumn<String>(
      'sha256_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _importedAtMeta =
      VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);

  static const VerificationMeta _pageCountMeta =
      VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);

  static const VerificationMeta _usedOcrMeta = VerificationMeta('usedOcr');
  @override
  late final GeneratedColumn<bool> usedOcr = GeneratedColumn<bool>(
      'used_ocr', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("used_ocr" IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _errorMessageMeta =
      VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  @override
  List<GeneratedColumn> get $columns =>
      [id, filename, sha256Hash, importedAt, pageCount, usedOcr, errorMessage];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'import_metadata_table';

  @override
  VerificationContext validateIntegrity(
      Insertable<ImportMetadataTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('sha256_hash')) {
      context.handle(
          _sha256HashMeta,
          sha256Hash.isAcceptableOrUnknown(
              data['sha256_hash']!, _sha256HashMeta));
    } else if (isInserting) {
      context.missing(_sha256HashMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('used_ocr')) {
      context.handle(_usedOcrMeta,
          usedOcr.isAcceptableOrUnknown(data['used_ocr']!, _usedOcrMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  ImportMetadataTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportMetadataTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      sha256Hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256_hash'])!,
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      usedOcr: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}used_ocr'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $ImportMetadataTableTable createAlias(String alias) {
    return $ImportMetadataTableTable(attachedDatabase, alias);
  }
}

class ImportMetadataTableData extends DataClass
    implements Insertable<ImportMetadataTableData> {
  final String id;
  final String filename;
  final String sha256Hash;
  final DateTime importedAt;
  final int pageCount;
  final bool usedOcr;
  final String? errorMessage;

  const ImportMetadataTableData({
    required this.id,
    required this.filename,
    required this.sha256Hash,
    required this.importedAt,
    required this.pageCount,
    required this.usedOcr,
    this.errorMessage,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['filename'] = Variable<String>(filename);
    map['sha256_hash'] = Variable<String>(sha256Hash);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['page_count'] = Variable<int>(pageCount);
    map['used_ocr'] = Variable<bool>(usedOcr);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  ImportMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return ImportMetadataTableCompanion(
      id: Value(id),
      filename: Value(filename),
      sha256Hash: Value(sha256Hash),
      importedAt: Value(importedAt),
      pageCount: Value(pageCount),
      usedOcr: Value(usedOcr),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory ImportMetadataTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportMetadataTableData(
      id: serializer.fromJson<String>(json['id']),
      filename: serializer.fromJson<String>(json['filename']),
      sha256Hash: serializer.fromJson<String>(json['sha256Hash']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      usedOcr: serializer.fromJson<bool>(json['usedOcr']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filename': serializer.toJson<String>(filename),
      'sha256Hash': serializer.toJson<String>(sha256Hash),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'pageCount': serializer.toJson<int>(pageCount),
      'usedOcr': serializer.toJson<bool>(usedOcr),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  ImportMetadataTableData copyWith(
          {String? id,
          String? filename,
          String? sha256Hash,
          DateTime? importedAt,
          int? pageCount,
          bool? usedOcr,
          Value<String?> errorMessage = const Value.absent()}) =>
      ImportMetadataTableData(
        id: id ?? this.id,
        filename: filename ?? this.filename,
        sha256Hash: sha256Hash ?? this.sha256Hash,
        importedAt: importedAt ?? this.importedAt,
        pageCount: pageCount ?? this.pageCount,
        usedOcr: usedOcr ?? this.usedOcr,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );

  @override
  String toString() {
    return (StringBuffer('ImportMetadataTableData(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('sha256Hash: $sha256Hash, ')
          ..write('importedAt: $importedAt, ')
          ..write('pageCount: $pageCount, ')
          ..write('usedOcr: $usedOcr, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, filename, sha256Hash, importedAt, pageCount, usedOcr, errorMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportMetadataTableData &&
          other.id == this.id &&
          other.filename == this.filename &&
          other.sha256Hash == this.sha256Hash &&
          other.importedAt == this.importedAt &&
          other.pageCount == this.pageCount &&
          other.usedOcr == this.usedOcr &&
          other.errorMessage == this.errorMessage);
}

class ImportMetadataTableCompanion
    extends UpdateCompanion<ImportMetadataTableData> {
  final Value<String> id;
  final Value<String> filename;
  final Value<String> sha256Hash;
  final Value<DateTime> importedAt;
  final Value<int> pageCount;
  final Value<bool> usedOcr;
  final Value<String?> errorMessage;

  const ImportMetadataTableCompanion({
    this.id = const Value.absent(),
    this.filename = const Value.absent(),
    this.sha256Hash = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.usedOcr = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });

  ImportMetadataTableCompanion.insert({
    required String id,
    required String filename,
    required String sha256Hash,
    required DateTime importedAt,
    required int pageCount,
    this.usedOcr = const Value.absent(),
    this.errorMessage = const Value.absent(),
  })  : id = Value(id),
        filename = Value(filename),
        sha256Hash = Value(sha256Hash),
        importedAt = Value(importedAt),
        pageCount = Value(pageCount);

  static Insertable<ImportMetadataTableData> custom({
    Expression<String>? id,
    Expression<String>? filename,
    Expression<String>? sha256Hash,
    Expression<DateTime>? importedAt,
    Expression<int>? pageCount,
    Expression<bool>? usedOcr,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filename != null) 'filename': filename,
      if (sha256Hash != null) 'sha256_hash': sha256Hash,
      if (importedAt != null) 'imported_at': importedAt,
      if (pageCount != null) 'page_count': pageCount,
      if (usedOcr != null) 'used_ocr': usedOcr,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  ImportMetadataTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? filename,
      Value<String>? sha256Hash,
      Value<DateTime>? importedAt,
      Value<int>? pageCount,
      Value<bool>? usedOcr,
      Value<String?>? errorMessage}) {
    return ImportMetadataTableCompanion(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      importedAt: importedAt ?? this.importedAt,
      pageCount: pageCount ?? this.pageCount,
      usedOcr: usedOcr ?? this.usedOcr,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (sha256Hash.present) {
      map['sha256_hash'] = Variable<String>(sha256Hash.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (usedOcr.present) {
      map['used_ocr'] = Variable<bool>(usedOcr.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('sha256Hash: $sha256Hash, ')
          ..write('importedAt: $importedAt, ')
          ..write('pageCount: $pageCount, ')
          ..write('usedOcr: $usedOcr, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

// FinancialRecordsTable generated code

class $FinancialRecordsTableTable extends FinancialRecordsTable
    with TableInfo<$FinancialRecordsTableTable, FinancialRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialRecordsTableTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _transactionDateMeta =
      VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<String> transactionDate = GeneratedColumn<String>(
      'transaction_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _postingDateMeta =
      VerificationMeta('postingDate');
  @override
  late final GeneratedColumn<String> postingDate = GeneratedColumn<String>(
      'posting_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _descriptionMeta =
      VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _merchantOrRecipientMeta =
      VerificationMeta('merchantOrRecipient');
  @override
  late final GeneratedColumn<String> merchantOrRecipient =
      GeneratedColumn<String>('merchant_or_recipient', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _debitMeta = VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
      'debit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);

  static const VerificationMeta _creditMeta = VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
      'credit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);

  static const VerificationMeta _amountMeta = VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);

  static const VerificationMeta _balanceMeta = VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);

  static const VerificationMeta _checkNumberMeta =
      VerificationMeta('checkNumber');
  @override
  late final GeneratedColumn<String> checkNumber = GeneratedColumn<String>(
      'check_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _referenceNumberMeta =
      VerificationMeta('referenceNumber');
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
      'reference_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _institutionMeta =
      VerificationMeta('institution');
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
      'institution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _accountHolderMeta =
      VerificationMeta('accountHolder');
  @override
  late final GeneratedColumn<String> accountHolder = GeneratedColumn<String>(
      'account_holder', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _maskedAccountNumberMeta =
      VerificationMeta('maskedAccountNumber');
  @override
  late final GeneratedColumn<String> maskedAccountNumber =
      GeneratedColumn<String>('masked_account_number', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);

  static const VerificationMeta _sourcePdfMeta =
      VerificationMeta('sourcePdf');
  @override
  late final GeneratedColumn<String> sourcePdf = GeneratedColumn<String>(
      'source_pdf', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _sourcePageMeta =
      VerificationMeta('sourcePage');
  @override
  late final GeneratedColumn<int> sourcePage = GeneratedColumn<int>(
      'source_page', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);

  static const VerificationMeta _originalTextMeta =
      VerificationMeta('originalText');
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
      'original_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _reviewedMeta = VerificationMeta('reviewed');
  @override
  late final GeneratedColumn<bool> reviewed = GeneratedColumn<bool>(
      'reviewed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("reviewed" IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _manuallyEditedMeta =
      VerificationMeta('manuallyEdited');
  @override
  late final GeneratedColumn<bool> manuallyEdited = GeneratedColumn<bool>(
      'manually_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("manually_edited" IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _importIdMeta = VerificationMeta('importId');
  @override
  late final GeneratedColumn<String> importId = GeneratedColumn<String>(
      'import_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);

  static const VerificationMeta _isUncertainMeta =
      VerificationMeta('isUncertain');
  @override
  late final GeneratedColumn<bool> isUncertain = GeneratedColumn<bool>(
      'is_uncertain', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_uncertain" IN (0, 1))'),
      defaultValue: const Constant(false));

  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionDate,
        postingDate,
        description,
        merchantOrRecipient,
        debit,
        credit,
        amount,
        balance,
        checkNumber,
        referenceNumber,
        institution,
        accountHolder,
        maskedAccountNumber,
        sourcePdf,
        sourcePage,
        originalText,
        reviewed,
        manuallyEdited,
        importId,
        isUncertain,
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'financial_records_table';

  @override
  VerificationContext validateIntegrity(
      Insertable<FinancialRecordsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  FinancialRecordsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialRecordsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_date']),
      postingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}posting_date']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      merchantOrRecipient: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}merchant_or_recipient']),
      debit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}debit']),
      credit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance']),
      checkNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}check_number']),
      referenceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_number']),
      institution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution']),
      accountHolder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_holder']),
      maskedAccountNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}masked_account_number']),
      sourcePdf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_pdf'])!,
      sourcePage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_page'])!,
      originalText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_text'])!,
      reviewed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reviewed'])!,
      manuallyEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manually_edited'])!,
      importId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}import_id'])!,
      isUncertain: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_uncertain'])!,
    );
  }

  @override
  $FinancialRecordsTableTable createAlias(String alias) {
    return $FinancialRecordsTableTable(attachedDatabase, alias);
  }
}

class FinancialRecordsTableData extends DataClass
    implements Insertable<FinancialRecordsTableData> {
  final String id;
  final String? transactionDate;
  final String? postingDate;
  final String? description;
  final String? merchantOrRecipient;
  final double? debit;
  final double? credit;
  final double? amount;
  final double? balance;
  final String? checkNumber;
  final String? referenceNumber;
  final String? institution;
  final String? accountHolder;
  final String? maskedAccountNumber;
  final String sourcePdf;
  final int sourcePage;
  final String originalText;
  final bool reviewed;
  final bool manuallyEdited;
  final String importId;
  final bool isUncertain;

  const FinancialRecordsTableData({
    required this.id,
    this.transactionDate,
    this.postingDate,
    this.description,
    this.merchantOrRecipient,
    this.debit,
    this.credit,
    this.amount,
    this.balance,
    this.checkNumber,
    this.referenceNumber,
    this.institution,
    this.accountHolder,
    this.maskedAccountNumber,
    required this.sourcePdf,
    required this.sourcePage,
    required this.originalText,
    required this.reviewed,
    required this.manuallyEdited,
    required this.importId,
    required this.isUncertain,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<String>(transactionDate);
    }
    if (!nullToAbsent || postingDate != null) {
      map['posting_date'] = Variable<String>(postingDate);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || merchantOrRecipient != null) {
      map['merchant_or_recipient'] = Variable<String>(merchantOrRecipient);
    }
    if (!nullToAbsent || debit != null) {
      map['debit'] = Variable<double>(debit);
    }
    if (!nullToAbsent || credit != null) {
      map['credit'] = Variable<double>(credit);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<double>(balance);
    }
    if (!nullToAbsent || checkNumber != null) {
      map['check_number'] = Variable<String>(checkNumber);
    }
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    if (!nullToAbsent || accountHolder != null) {
      map['account_holder'] = Variable<String>(accountHolder);
    }
    if (!nullToAbsent || maskedAccountNumber != null) {
      map['masked_account_number'] = Variable<String>(maskedAccountNumber);
    }
    map['source_pdf'] = Variable<String>(sourcePdf);
    map['source_page'] = Variable<int>(sourcePage);
    map['original_text'] = Variable<String>(originalText);
    map['reviewed'] = Variable<bool>(reviewed);
    map['manually_edited'] = Variable<bool>(manuallyEdited);
    map['import_id'] = Variable<String>(importId);
    map['is_uncertain'] = Variable<bool>(isUncertain);
    return map;
  }

  FinancialRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return FinancialRecordsTableCompanion(
      id: Value(id),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      postingDate: postingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(postingDate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      merchantOrRecipient: merchantOrRecipient == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantOrRecipient),
      debit:
          debit == null && nullToAbsent ? const Value.absent() : Value(debit),
      credit:
          credit == null && nullToAbsent ? const Value.absent() : Value(credit),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      checkNumber: checkNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(checkNumber),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      accountHolder: accountHolder == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHolder),
      maskedAccountNumber: maskedAccountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(maskedAccountNumber),
      sourcePdf: Value(sourcePdf),
      sourcePage: Value(sourcePage),
      originalText: Value(originalText),
      reviewed: Value(reviewed),
      manuallyEdited: Value(manuallyEdited),
      importId: Value(importId),
      isUncertain: Value(isUncertain),
    );
  }

  FinancialRecordsTableData copyWith(
      {String? id,
      Value<String?> transactionDate = const Value.absent(),
      Value<String?> postingDate = const Value.absent(),
      Value<String?> description = const Value.absent(),
      Value<String?> merchantOrRecipient = const Value.absent(),
      Value<double?> debit = const Value.absent(),
      Value<double?> credit = const Value.absent(),
      Value<double?> amount = const Value.absent(),
      Value<double?> balance = const Value.absent(),
      Value<String?> checkNumber = const Value.absent(),
      Value<String?> referenceNumber = const Value.absent(),
      Value<String?> institution = const Value.absent(),
      Value<String?> accountHolder = const Value.absent(),
      Value<String?> maskedAccountNumber = const Value.absent(),
      String? sourcePdf,
      int? sourcePage,
      String? originalText,
      bool? reviewed,
      bool? manuallyEdited,
      String? importId,
      bool? isUncertain}) {
    return FinancialRecordsTableData(
      id: id ?? this.id,
      transactionDate:
          transactionDate.present ? transactionDate.value : this.transactionDate,
      postingDate: postingDate.present ? postingDate.value : this.postingDate,
      description: description.present ? description.value : this.description,
      merchantOrRecipient: merchantOrRecipient.present
          ? merchantOrRecipient.value
          : this.merchantOrRecipient,
      debit: debit.present ? debit.value : this.debit,
      credit: credit.present ? credit.value : this.credit,
      amount: amount.present ? amount.value : this.amount,
      balance: balance.present ? balance.value : this.balance,
      checkNumber: checkNumber.present ? checkNumber.value : this.checkNumber,
      referenceNumber:
          referenceNumber.present ? referenceNumber.value : this.referenceNumber,
      institution: institution.present ? institution.value : this.institution,
      accountHolder:
          accountHolder.present ? accountHolder.value : this.accountHolder,
      maskedAccountNumber: maskedAccountNumber.present
          ? maskedAccountNumber.value
          : this.maskedAccountNumber,
      sourcePdf: sourcePdf ?? this.sourcePdf,
      sourcePage: sourcePage ?? this.sourcePage,
      originalText: originalText ?? this.originalText,
      reviewed: reviewed ?? this.reviewed,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      importId: importId ?? this.importId,
      isUncertain: isUncertain ?? this.isUncertain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordsTableData(')
          ..write('id: $id, ')
          ..write('sourcePdf: $sourcePdf, ')
          ..write('sourcePage: $sourcePage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourcePdf, sourcePage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialRecordsTableData && other.id == this.id);
}

class FinancialRecordsTableCompanion
    extends UpdateCompanion<FinancialRecordsTableData> {
  final Value<String> id;
  final Value<String?> transactionDate;
  final Value<String?> postingDate;
  final Value<String?> description;
  final Value<String?> merchantOrRecipient;
  final Value<double?> debit;
  final Value<double?> credit;
  final Value<double?> amount;
  final Value<double?> balance;
  final Value<String?> checkNumber;
  final Value<String?> referenceNumber;
  final Value<String?> institution;
  final Value<String?> accountHolder;
  final Value<String?> maskedAccountNumber;
  final Value<String> sourcePdf;
  final Value<int> sourcePage;
  final Value<String> originalText;
  final Value<bool> reviewed;
  final Value<bool> manuallyEdited;
  final Value<String> importId;
  final Value<bool> isUncertain;

  const FinancialRecordsTableCompanion({
    this.id = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.postingDate = const Value.absent(),
    this.description = const Value.absent(),
    this.merchantOrRecipient = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.amount = const Value.absent(),
    this.balance = const Value.absent(),
    this.checkNumber = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.institution = const Value.absent(),
    this.accountHolder = const Value.absent(),
    this.maskedAccountNumber = const Value.absent(),
    this.sourcePdf = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.originalText = const Value.absent(),
    this.reviewed = const Value.absent(),
    this.manuallyEdited = const Value.absent(),
    this.importId = const Value.absent(),
    this.isUncertain = const Value.absent(),
  });

  FinancialRecordsTableCompanion.insert({
    required String id,
    this.transactionDate = const Value.absent(),
    this.postingDate = const Value.absent(),
    this.description = const Value.absent(),
    this.merchantOrRecipient = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.amount = const Value.absent(),
    this.balance = const Value.absent(),
    this.checkNumber = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.institution = const Value.absent(),
    this.accountHolder = const Value.absent(),
    this.maskedAccountNumber = const Value.absent(),
    required String sourcePdf,
    required int sourcePage,
    required String originalText,
    this.reviewed = const Value.absent(),
    this.manuallyEdited = const Value.absent(),
    required String importId,
    this.isUncertain = const Value.absent(),
  })  : id = Value(id),
        sourcePdf = Value(sourcePdf),
        sourcePage = Value(sourcePage),
        originalText = Value(originalText),
        importId = Value(importId);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<String>(transactionDate.value);
    }
    if (postingDate.present) {
      map['posting_date'] = Variable<String>(postingDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (merchantOrRecipient.present) {
      map['merchant_or_recipient'] =
          Variable<String>(merchantOrRecipient.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (checkNumber.present) {
      map['check_number'] = Variable<String>(checkNumber.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (accountHolder.present) {
      map['account_holder'] = Variable<String>(accountHolder.value);
    }
    if (maskedAccountNumber.present) {
      map['masked_account_number'] =
          Variable<String>(maskedAccountNumber.value);
    }
    if (sourcePdf.present) {
      map['source_pdf'] = Variable<String>(sourcePdf.value);
    }
    if (sourcePage.present) {
      map['source_page'] = Variable<int>(sourcePage.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (reviewed.present) {
      map['reviewed'] = Variable<bool>(reviewed.value);
    }
    if (manuallyEdited.present) {
      map['manually_edited'] = Variable<bool>(manuallyEdited.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<String>(importId.value);
    }
    if (isUncertain.present) {
      map['is_uncertain'] = Variable<bool>(isUncertain.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId')
          ..write(')'))
        .toString();
  }
}

// Database class implementation
class _$AppDatabase extends AppDatabase {
  _$AppDatabase(QueryExecutor e) : super.forTesting(e);

  late final $ImportMetadataTableTable importMetadataTable =
      $ImportMetadataTableTable(this);
  late final $FinancialRecordsTableTable financialRecordsTable =
      $FinancialRecordsTableTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [importMetadataTable, financialRecordsTable];
}
