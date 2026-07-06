import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/import_service.dart';
import 'review_screen.dart';

/// Screen showing extraction progress during PDF import.
///
/// Displays which file and page are being processed and reports errors.
/// When processing times out the screen shows a clear "Timed out" message
/// so the user is never left wondering what happened.
class ProcessingScreen extends ConsumerStatefulWidget {
  final List<File> files;

  const ProcessingScreen({super.key, required this.files});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final List<ImportProgress> _progressHistory = [];
  bool _isComplete = false;
  bool _hasErrors = false;
  bool _hasTimeout = false;
  final List<String> _importIds = [];

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    final importService = ref.read(importServiceProvider);

    for (final file in widget.files) {
      final importId = await importService.importPdf(
        file,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progressHistory.add(progress);
              if (progress.error != null) {
                _hasErrors = true;
              }
              if (progress.isTimedOut) {
                _hasTimeout = true;
              }
            });
          }
        },
      );

      if (importId != null) {
        _importIds.add(importId);
      }
    }

    if (mounted) {
      setState(() {
        _isComplete = true;
      });
    }
  }

  ImportProgress? get _currentProgress =>
      _progressHistory.isNotEmpty ? _progressHistory.last : null;

  /// Returns the icon to show for the current overall state.
  IconData get _statusIcon {
    if (!_isComplete) return Icons.hourglass_top;
    if (_hasTimeout) return Icons.timer_off;
    if (_hasErrors) return Icons.warning_amber;
    return Icons.check_circle;
  }

  /// Returns the color to use for the current overall state.
  Color _statusColor(BuildContext context) {
    if (!_isComplete) return Theme.of(context).colorScheme.primary;
    if (_hasTimeout) return Colors.orange;
    if (_hasErrors) return Colors.orange;
    return Colors.green;
  }

  /// Returns a human-readable title for the current overall state.
  String get _statusTitle {
    if (!_isComplete) return 'Processing…';
    if (_hasTimeout) return 'Processing Timed Out';
    if (_hasErrors) return 'Processing Complete (with errors)';
    return 'Processing Complete';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing PDFs'),
        automaticallyImplyLeading: _isComplete,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            if (!_isComplete) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 24),
            ],

            // Current status card
            if (progress != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _statusIcon,
                            color: _statusColor(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('File: ${progress.filename}'),
                      if (progress.totalPages > 0)
                        Text(
                            'Page: ${progress.currentPage} / ${progress.totalPages}'),
                      Text('Status: ${progress.status}'),
                      if (progress.totalPages > 0) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress.percentage,
                        ),
                      ],
                      if (progress.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          progress.error!,
                          style: TextStyle(
                            color: progress.isTimedOut
                                ? Colors.orange
                                : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Progress history
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _progressHistory.length,
                  itemBuilder: (context, index) {
                    final item = _progressHistory[index];
                    final isError = item.error != null;
                    final isTimeout = item.isTimedOut;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isTimeout
                            ? Icons.timer_off
                            : isError
                                ? Icons.error_outline
                                : Icons.check,
                        color: isTimeout
                            ? Colors.orange
                            : isError
                                ? Colors.red
                                : Colors.green,
                        size: 20,
                      ),
                      title: Text(
                        item.status,
                        style: TextStyle(
                          color: isTimeout
                              ? Colors.orange
                              : isError
                                  ? Colors.red
                                  : null,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: isError ? Text(item.error!) : null,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            if (_isComplete) ...[
              if (_hasTimeout) ...[
                Text(
                  'The operation timed out after '
                  '${kProcessingTimeout.inSeconds} seconds. '
                  'You can try again with a smaller file, or check that the '
                  'PDF is not password-protected or corrupt.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Import'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _importIds.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const ReviewScreen(),
                                ),
                              );
                            },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Review Records'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
