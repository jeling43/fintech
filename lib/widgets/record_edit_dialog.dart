import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/financial_record.dart';

/// Dialog for editing or creating a financial record.
class RecordEditDialog extends StatefulWidget {
  final FinancialRecord? record;
  final bool isNew;

  const RecordEditDialog({
    super.key,
    this.record,
    this.isNew = false,
  });

  @override
  State<RecordEditDialog> createState() => _RecordEditDialogState();
}

class _RecordEditDialogState extends State<RecordEditDialog> {
  late final TextEditingController _transactionDateCtl;
  late final TextEditingController _postingDateCtl;
  late final TextEditingController _descriptionCtl;
  late final TextEditingController _merchantCtl;
  late final TextEditingController _debitCtl;
  late final TextEditingController _creditCtl;
  late final TextEditingController _amountCtl;
  late final TextEditingController _balanceCtl;
  late final TextEditingController _checkNumberCtl;
  late final TextEditingController _referenceNumberCtl;
  late final TextEditingController _institutionCtl;
  late final TextEditingController _accountHolderCtl;
  late final TextEditingController _maskedAccountCtl;
  late final TextEditingController _sourcePdfCtl;
  late final TextEditingController _sourcePageCtl;
  late final TextEditingController _originalTextCtl;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _transactionDateCtl =
        TextEditingController(text: r?.transactionDate ?? '');
    _postingDateCtl = TextEditingController(text: r?.postingDate ?? '');
    _descriptionCtl = TextEditingController(text: r?.description ?? '');
    _merchantCtl =
        TextEditingController(text: r?.merchantOrRecipient ?? '');
    _debitCtl = TextEditingController(
        text: r?.debit != null ? r!.debit!.toStringAsFixed(2) : '');
    _creditCtl = TextEditingController(
        text: r?.credit != null ? r!.credit!.toStringAsFixed(2) : '');
    _amountCtl = TextEditingController(
        text: r?.amount != null ? r!.amount!.toStringAsFixed(2) : '');
    _balanceCtl = TextEditingController(
        text: r?.balance != null ? r!.balance!.toStringAsFixed(2) : '');
    _checkNumberCtl = TextEditingController(text: r?.checkNumber ?? '');
    _referenceNumberCtl =
        TextEditingController(text: r?.referenceNumber ?? '');
    _institutionCtl = TextEditingController(text: r?.institution ?? '');
    _accountHolderCtl =
        TextEditingController(text: r?.accountHolder ?? '');
    _maskedAccountCtl =
        TextEditingController(text: r?.maskedAccountNumber ?? '');
    _sourcePdfCtl = TextEditingController(text: r?.sourcePdf ?? '');
    _sourcePageCtl =
        TextEditingController(text: r?.sourcePage.toString() ?? '1');
    _originalTextCtl =
        TextEditingController(text: r?.originalText ?? '');
  }

  @override
  void dispose() {
    _transactionDateCtl.dispose();
    _postingDateCtl.dispose();
    _descriptionCtl.dispose();
    _merchantCtl.dispose();
    _debitCtl.dispose();
    _creditCtl.dispose();
    _amountCtl.dispose();
    _balanceCtl.dispose();
    _checkNumberCtl.dispose();
    _referenceNumberCtl.dispose();
    _institutionCtl.dispose();
    _accountHolderCtl.dispose();
    _maskedAccountCtl.dispose();
    _sourcePdfCtl.dispose();
    _sourcePageCtl.dispose();
    _originalTextCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Add Record' : 'Edit Record'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Transaction Date (YYYY-MM-DD)', _transactionDateCtl),
              _buildField('Posting Date (YYYY-MM-DD)', _postingDateCtl),
              _buildField('Description', _descriptionCtl),
              _buildField('Merchant or Recipient', _merchantCtl),
              Row(
                children: [
                  Expanded(child: _buildField('Debit', _debitCtl)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildField('Credit', _creditCtl)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField('Amount', _amountCtl)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildField('Balance', _balanceCtl)),
                ],
              ),
              _buildField('Check Number', _checkNumberCtl),
              _buildField('Reference Number', _referenceNumberCtl),
              _buildField('Institution', _institutionCtl),
              _buildField('Account Holder', _accountHolderCtl),
              _buildField('Masked Account Number', _maskedAccountCtl),
              if (widget.isNew) ...[
                _buildField('Source PDF', _sourcePdfCtl),
                _buildField('Source Page', _sourcePageCtl),
              ],
              _buildField('Original Text', _originalTextCtl, maxLines: 3),
              if (!widget.isNew && widget.record != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Source: ${widget.record!.sourcePdf}, '
                        'Page ${widget.record!.sourcePage}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _save() {
    final record = FinancialRecord(
      id: widget.record?.id ?? const Uuid().v4(),
      transactionDate: _transactionDateCtl.text.isEmpty
          ? null
          : _transactionDateCtl.text,
      postingDate:
          _postingDateCtl.text.isEmpty ? null : _postingDateCtl.text,
      description:
          _descriptionCtl.text.isEmpty ? null : _descriptionCtl.text,
      merchantOrRecipient:
          _merchantCtl.text.isEmpty ? null : _merchantCtl.text,
      debit: double.tryParse(_debitCtl.text),
      credit: double.tryParse(_creditCtl.text),
      amount: double.tryParse(_amountCtl.text),
      balance: double.tryParse(_balanceCtl.text),
      checkNumber:
          _checkNumberCtl.text.isEmpty ? null : _checkNumberCtl.text,
      referenceNumber: _referenceNumberCtl.text.isEmpty
          ? null
          : _referenceNumberCtl.text,
      institution:
          _institutionCtl.text.isEmpty ? null : _institutionCtl.text,
      accountHolder:
          _accountHolderCtl.text.isEmpty ? null : _accountHolderCtl.text,
      maskedAccountNumber:
          _maskedAccountCtl.text.isEmpty ? null : _maskedAccountCtl.text,
      sourcePdf: widget.record?.sourcePdf ??
          (_sourcePdfCtl.text.isEmpty ? 'manual_entry' : _sourcePdfCtl.text),
      sourcePage: widget.record?.sourcePage ??
          (int.tryParse(_sourcePageCtl.text) ?? 0),
      originalText: _originalTextCtl.text.isEmpty
          ? 'Manually entered record'
          : _originalTextCtl.text,
      importId: widget.record?.importId ?? 'manual',
      reviewed: widget.record?.reviewed ?? false,
      manuallyEdited: true,
      isUncertain: false,
    );

    Navigator.of(context).pop(record);
  }
}
