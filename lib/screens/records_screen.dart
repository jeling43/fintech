import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/financial_record.dart';
import '../providers/providers.dart';
import '../widgets/record_edit_dialog.dart';

/// Main records screen with search, filter, and sort capabilities.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(filteredRecordsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortField = ref.watch(sortFieldProvider);
    final ascending = ref.watch(sortAscendingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search descriptions, names, merchants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Sort controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  '${records.length} records',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                const Text('Sort by: '),
                DropdownButton<SortField>(
                  value: sortField,
                  isDense: true,
                  items: SortField.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(sortFieldProvider.notifier).state = value;
                    }
                  },
                ),
                IconButton(
                  icon: Icon(ascending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  iconSize: 18,
                  onPressed: () {
                    ref.read(sortAscendingProvider.notifier).state = !ascending;
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Records list
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Text('No records found.'),
                  )
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _RecordListTile(record: record, ref: ref);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(ref: ref),
    );
  }
}

class _RecordListTile extends StatelessWidget {
  final FinancialRecord record;
  final WidgetRef ref;

  const _RecordListTile({required this.record, required this.ref});

  @override
  Widget build(BuildContext context) {
    final amountStr = record.amount != null
        ? '\$${record.amount!.toStringAsFixed(2)}'
        : record.debit != null
            ? '-\$${record.debit!.toStringAsFixed(2)}'
            : record.credit != null
                ? '+\$${record.credit!.toStringAsFixed(2)}'
                : '';

    return ListTile(
      title: Text(
        record.description ?? '(No description)',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${record.transactionDate ?? ''} • ${record.sourcePdf}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        amountStr,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: (record.amount ?? 0) < 0 ||
                  (record.debit != null && record.debit! > 0)
              ? Colors.red
              : Colors.green,
        ),
      ),
      leading: record.isUncertain
          ? const Icon(Icons.warning_amber, color: Colors.orange, size: 20)
          : record.reviewed
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : null,
      onTap: () => _showRecordDetail(context),
    );
  }

  void _showRecordDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RecordEditDialog(record: record),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final WidgetRef ref;

  const _FilterSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Date range
              Text('Date Range',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Start (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => ref
                          .read(dateStartFilterProvider.notifier)
                          .state = v.isEmpty ? null : v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'End (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => ref
                          .read(dateEndFilterProvider.notifier)
                          .state = v.isEmpty ? null : v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount range
              Text('Amount Range',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => ref
                          .read(minAmountFilterProvider.notifier)
                          .state = double.tryParse(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => ref
                          .read(maxAmountFilterProvider.notifier)
                          .state = double.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Transaction type
              Text('Transaction Type',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<TransactionType?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('All')),
                  ButtonSegment(
                      value: TransactionType.debit, label: Text('Debit')),
                  ButtonSegment(
                      value: TransactionType.credit, label: Text('Credit')),
                ],
                selected: {ref.watch(transactionTypeFilterProvider)},
                onSelectionChanged: (values) {
                  ref.read(transactionTypeFilterProvider.notifier).state =
                      values.first;
                },
              ),

              const SizedBox(height: 24),

              // Clear filters
              OutlinedButton(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(dateStartFilterProvider.notifier).state = null;
                  ref.read(dateEndFilterProvider.notifier).state = null;
                  ref.read(minAmountFilterProvider.notifier).state = null;
                  ref.read(maxAmountFilterProvider.notifier).state = null;
                  ref.read(transactionTypeFilterProvider.notifier).state = null;
                  ref.read(sourcePdfFilterProvider.notifier).state = null;
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}
