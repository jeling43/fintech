import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/financial_record.dart';
import '../providers/providers.dart';
import '../widgets/record_edit_dialog.dart';

/// Review screen for verifying and correcting extracted records.
///
/// Highlights incomplete or uncertain records, allows editing,
/// and shows original extracted text beside parsed data.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final records = ref.watch(filteredRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add record manually',
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: records.isEmpty
          ? const Center(
              child: Text('No records to review.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _RecordReviewCard(
                  record: record,
                  onEdit: () => _editRecord(context, record),
                  onDelete: () => _deleteRecord(context, record),
                  onMarkReviewed: () => _markReviewed(record),
                );
              },
            ),
    );
  }

  Future<void> _showAddRecordDialog(BuildContext context) async {
    final result = await showDialog<FinancialRecord>(
      context: context,
      builder: (context) => const RecordEditDialog(isNew: true),
    );

    if (result != null) {
      final db = ref.read(databaseProvider);
      await db.insertRecord(result);
    }
  }

  Future<void> _editRecord(
      BuildContext context, FinancialRecord record) async {
    final result = await showDialog<FinancialRecord>(
      context: context,
      builder: (context) => RecordEditDialog(record: record),
    );

    if (result != null) {
      final db = ref.read(databaseProvider);
      await db.updateRecord(result.copyWith(manuallyEdited: true));
    }
  }

  Future<void> _deleteRecord(
      BuildContext context, FinancialRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this record? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteRecord(record.id);
    }
  }

  Future<void> _markReviewed(FinancialRecord record) async {
    final db = ref.read(databaseProvider);
    await db.markRecordReviewed(record.id);
  }
}

class _RecordReviewCard extends StatelessWidget {
  final FinancialRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkReviewed;

  const _RecordReviewCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final isUncertain = record.isUncertain;
    final isIncomplete = record.transactionDate == null ||
        record.description == null ||
        (record.amount == null && record.debit == null && record.credit == null);

    return Card(
      color: isUncertain
          ? Colors.amber.shade50
          : isIncomplete
              ? Colors.orange.shade50
              : null,
      child: ExpansionTile(
        leading: _buildStatusIcon(isUncertain, isIncomplete),
        title: Text(
          record.description ?? '(No description)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isUncertain ? Colors.orange.shade800 : null,
          ),
        ),
        subtitle: Row(
          children: [
            if (record.transactionDate != null)
              Text(record.transactionDate!),
            const SizedBox(width: 16),
            if (record.amount != null)
              Text(
                '\$${record.amount!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: (record.amount ?? 0) < 0
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const Spacer(),
            if (record.reviewed)
              const Chip(
                label: Text('Reviewed'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            if (record.manuallyEdited)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Chip(
                  label: Text('Edited'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Record details
                _buildDetailRow('Institution', record.institution),
                _buildDetailRow('Account Holder', record.accountHolder),
                _buildDetailRow(
                    'Account Number', record.maskedAccountNumber),
                _buildDetailRow('Posting Date', record.postingDate),
                _buildDetailRow('Merchant', record.merchantOrRecipient),
                _buildDetailRow(
                  'Debit',
                  record.debit != null
                      ? '\$${record.debit!.toStringAsFixed(2)}'
                      : null,
                ),
                _buildDetailRow(
                  'Credit',
                  record.credit != null
                      ? '\$${record.credit!.toStringAsFixed(2)}'
                      : null,
                ),
                _buildDetailRow(
                  'Balance',
                  record.balance != null
                      ? '\$${record.balance!.toStringAsFixed(2)}'
                      : null,
                ),
                _buildDetailRow('Check #', record.checkNumber),
                _buildDetailRow('Reference #', record.referenceNumber),

                const Divider(),

                // Source information
                _buildDetailRow('Source PDF', record.sourcePdf),
                _buildDetailRow(
                    'Source Page', record.sourcePage.toString()),

                const SizedBox(height: 8),
                // Original text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original Text:',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.originalText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    if (!record.reviewed)
                      FilledButton.icon(
                        onPressed: onMarkReviewed,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Mark Reviewed'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isUncertain, bool isIncomplete) {
    if (isUncertain) {
      return const Icon(Icons.warning_amber, color: Colors.orange);
    }
    if (isIncomplete) {
      return const Icon(Icons.help_outline, color: Colors.amber);
    }
    if (record.reviewed) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    return const Icon(Icons.circle_outlined, color: Colors.grey);
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
