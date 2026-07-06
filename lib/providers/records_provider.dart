import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/financial_record.dart';
import '../services/import_service.dart';
import 'service_providers.dart';

/// Provider for all financial records from the database.
final recordsProvider =
    StreamProvider<List<FinancialRecordsTableData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllRecords();
});

/// Provider for import metadata list.
final importsProvider =
    FutureProvider<List<ImportMetadataTableData>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllImports();
});

/// State for the current import progress.
final importProgressProvider =
    StateNotifierProvider<ImportProgressNotifier, ImportProgress?>(
  (ref) => ImportProgressNotifier(),
);

class ImportProgressNotifier extends StateNotifier<ImportProgress?> {
  ImportProgressNotifier() : super(null);

  void update(ImportProgress progress) {
    state = progress;
  }

  void clear() {
    state = null;
  }
}

/// Provider for search/filter state.
final searchQueryProvider = StateProvider<String>((ref) => '');
final dateStartFilterProvider = StateProvider<String?>((ref) => null);
final dateEndFilterProvider = StateProvider<String?>((ref) => null);
final minAmountFilterProvider = StateProvider<double?>((ref) => null);
final maxAmountFilterProvider = StateProvider<double?>((ref) => null);
final transactionTypeFilterProvider =
    StateProvider<TransactionType?>((ref) => null);
final sourcePdfFilterProvider = StateProvider<String?>((ref) => null);
final sortFieldProvider = StateProvider<SortField>((ref) => SortField.date);
final sortAscendingProvider = StateProvider<bool>((ref) => false);

enum TransactionType { debit, credit }

enum SortField { date, amount, description, balance }

/// Filtered and sorted records provider.
final filteredRecordsProvider =
    Provider<List<FinancialRecord>>((ref) {
  final recordsAsync = ref.watch(recordsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final dateStart = ref.watch(dateStartFilterProvider);
  final dateEnd = ref.watch(dateEndFilterProvider);
  final minAmount = ref.watch(minAmountFilterProvider);
  final maxAmount = ref.watch(maxAmountFilterProvider);
  final txnType = ref.watch(transactionTypeFilterProvider);
  final sourcePdf = ref.watch(sourcePdfFilterProvider);
  final sortField = ref.watch(sortFieldProvider);
  final ascending = ref.watch(sortAscendingProvider);

  return recordsAsync.when(
    data: (tableRecords) {
      // Convert table data to model
      var records = tableRecords.map((r) => FinancialRecord(
            id: r.id,
            transactionDate: r.transactionDate,
            postingDate: r.postingDate,
            description: r.description,
            merchantOrRecipient: r.merchantOrRecipient,
            debit: r.debit,
            credit: r.credit,
            amount: r.amount,
            balance: r.balance,
            checkNumber: r.checkNumber,
            referenceNumber: r.referenceNumber,
            institution: r.institution,
            accountHolder: r.accountHolder,
            maskedAccountNumber: r.maskedAccountNumber,
            sourcePdf: r.sourcePdf,
            sourcePage: r.sourcePage,
            originalText: r.originalText,
            reviewed: r.reviewed,
            manuallyEdited: r.manuallyEdited,
            importId: r.importId,
            isUncertain: r.isUncertain,
          )).toList();

      // Apply search filter
      if (query.isNotEmpty) {
        records = records.where((r) {
          return (r.description?.toLowerCase().contains(query) ?? false) ||
              (r.merchantOrRecipient?.toLowerCase().contains(query) ?? false) ||
              (r.accountHolder?.toLowerCase().contains(query) ?? false) ||
              (r.maskedAccountNumber?.toLowerCase().contains(query) ?? false) ||
              (r.referenceNumber?.toLowerCase().contains(query) ?? false) ||
              (r.institution?.toLowerCase().contains(query) ?? false) ||
              (r.checkNumber?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      // Apply date filters
      if (dateStart != null) {
        records = records.where((r) {
          if (r.transactionDate == null) return false;
          return r.transactionDate!.compareTo(dateStart) >= 0;
        }).toList();
      }
      if (dateEnd != null) {
        records = records.where((r) {
          if (r.transactionDate == null) return false;
          return r.transactionDate!.compareTo(dateEnd) <= 0;
        }).toList();
      }

      // Apply amount filters
      if (minAmount != null) {
        records = records.where((r) {
          final amt = r.amount?.abs() ?? r.debit ?? r.credit ?? 0;
          return amt >= minAmount;
        }).toList();
      }
      if (maxAmount != null) {
        records = records.where((r) {
          final amt = r.amount?.abs() ?? r.debit ?? r.credit ?? 0;
          return amt <= maxAmount;
        }).toList();
      }

      // Apply transaction type filter
      if (txnType != null) {
        records = records.where((r) {
          if (txnType == TransactionType.debit) {
            return r.debit != null && r.debit! > 0;
          } else {
            return r.credit != null && r.credit! > 0;
          }
        }).toList();
      }

      // Apply source PDF filter
      if (sourcePdf != null) {
        records = records.where((r) => r.sourcePdf == sourcePdf).toList();
      }

      // Sort
      records.sort((a, b) {
        int result;
        switch (sortField) {
          case SortField.date:
            result = (a.transactionDate ?? '')
                .compareTo(b.transactionDate ?? '');
          case SortField.amount:
            final aAmt = a.amount ?? a.debit ?? a.credit ?? 0;
            final bAmt = b.amount ?? b.debit ?? b.credit ?? 0;
            result = aAmt.compareTo(bAmt);
          case SortField.description:
            result = (a.description ?? '')
                .compareTo(b.description ?? '');
          case SortField.balance:
            result = (a.balance ?? 0).compareTo(b.balance ?? 0);
        }
        return ascending ? result : -result;
      });

      return records;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
