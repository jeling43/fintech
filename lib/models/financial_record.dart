/// Represents a single financial transaction record extracted from a PDF.
class FinancialRecord {
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

  const FinancialRecord({
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
    this.reviewed = false,
    this.manuallyEdited = false,
    required this.importId,
    this.isUncertain = false,
  });

  FinancialRecord copyWith({
    String? id,
    String? transactionDate,
    String? postingDate,
    String? description,
    String? merchantOrRecipient,
    double? debit,
    double? credit,
    double? amount,
    double? balance,
    String? checkNumber,
    String? referenceNumber,
    String? institution,
    String? accountHolder,
    String? maskedAccountNumber,
    String? sourcePdf,
    int? sourcePage,
    String? originalText,
    bool? reviewed,
    bool? manuallyEdited,
    String? importId,
    bool? isUncertain,
  }) {
    return FinancialRecord(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      postingDate: postingDate ?? this.postingDate,
      description: description ?? this.description,
      merchantOrRecipient: merchantOrRecipient ?? this.merchantOrRecipient,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      checkNumber: checkNumber ?? this.checkNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      institution: institution ?? this.institution,
      accountHolder: accountHolder ?? this.accountHolder,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      sourcePdf: sourcePdf ?? this.sourcePdf,
      sourcePage: sourcePage ?? this.sourcePage,
      originalText: originalText ?? this.originalText,
      reviewed: reviewed ?? this.reviewed,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      importId: importId ?? this.importId,
      isUncertain: isUncertain ?? this.isUncertain,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionDate': transactionDate,
      'postingDate': postingDate,
      'description': description,
      'merchantOrRecipient': merchantOrRecipient,
      'debit': debit,
      'credit': credit,
      'amount': amount,
      'balance': balance,
      'checkNumber': checkNumber,
      'referenceNumber': referenceNumber,
      'institution': institution,
      'accountHolder': accountHolder,
      'maskedAccountNumber': maskedAccountNumber,
      'sourcePdf': sourcePdf,
      'sourcePage': sourcePage,
      'originalText': originalText,
      'reviewed': reviewed,
      'manuallyEdited': manuallyEdited,
      'importId': importId,
      'isUncertain': isUncertain,
    };
  }

  factory FinancialRecord.fromMap(Map<String, dynamic> map) {
    return FinancialRecord(
      id: map['id'] as String,
      transactionDate: map['transactionDate'] as String?,
      postingDate: map['postingDate'] as String?,
      description: map['description'] as String?,
      merchantOrRecipient: map['merchantOrRecipient'] as String?,
      debit: map['debit'] as double?,
      credit: map['credit'] as double?,
      amount: map['amount'] as double?,
      balance: map['balance'] as double?,
      checkNumber: map['checkNumber'] as String?,
      referenceNumber: map['referenceNumber'] as String?,
      institution: map['institution'] as String?,
      accountHolder: map['accountHolder'] as String?,
      maskedAccountNumber: map['maskedAccountNumber'] as String?,
      sourcePdf: map['sourcePdf'] as String,
      sourcePage: map['sourcePage'] as int,
      originalText: map['originalText'] as String,
      reviewed: map['reviewed'] as bool? ?? false,
      manuallyEdited: map['manuallyEdited'] as bool? ?? false,
      importId: map['importId'] as String,
      isUncertain: map['isUncertain'] as bool? ?? false,
    );
  }
}
