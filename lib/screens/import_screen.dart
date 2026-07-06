import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/import_service.dart';
import 'processing_screen.dart';

/// Screen for importing PDF files.
///
/// Allows the user to select one or more PDFs and start extraction.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final List<XFile> _selectedFiles = [];
  bool _isImporting = false;

  Future<void> _selectFiles() async {
    const typeGroup = XTypeGroup(
      label: 'PDF Files',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );

    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _startImport() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isImporting = true;
    });

    final files = _selectedFiles.map((f) => File(f.path)).toList();

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(files: files),
        ),
      );
    }

    setState(() {
      _isImporting = false;
      _selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import PDFs'),
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all',
              onPressed: _clearFiles,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Import Financial Records',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select one or more bank statement PDF files to extract '
                      'transaction records. The app will attempt to extract text '
                      'directly, and use OCR for scanned documents.',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: All processing is done locally. PDFs are not '
                      'uploaded to any external server.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // File selection button
            FilledButton.icon(
              onPressed: _isImporting ? null : _selectFiles,
              icon: const Icon(Icons.add),
              label: const Text('Select PDF Files'),
            ),
            const SizedBox(height: 16),

            // Selected files list
            if (_selectedFiles.isNotEmpty) ...[
              Text(
                '${_selectedFiles.length} file(s) selected',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: Text(file.name),
                        subtitle: Text(file.path),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeFile(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isImporting ? null : _startImport,
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                    _isImporting ? 'Processing...' : 'Start Extraction'),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No files selected',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap "Select PDF Files" to choose bank statements',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
