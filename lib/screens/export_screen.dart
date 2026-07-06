import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/providers.dart';
import '../services/csv_export_service.dart';

/// Export screen for exporting records as CSV.
///
/// Allows selecting which fields to include and whether to export
/// all records or only the current filtered set.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final Set<String> _selectedColumns =
      Set.from(CsvExportService.defaultColumns);
  bool _exportFiltered = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(filteredRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Export options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Options',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Export filtered records only'),
                      subtitle: Text(
                        _exportFiltered
                            ? '${records.length} records will be exported'
                            : 'All records will be exported',
                      ),
                      value: _exportFiltered,
                      onChanged: (value) {
                        setState(() {
                          _exportFiltered = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Column selection
            Text(
              'Select Columns',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            // Select/deselect all
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedColumns
                          .addAll(CsvExportService.defaultColumns);
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedColumns.clear();
                    });
                  },
                  child: const Text('Deselect All'),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                children: CsvExportService.defaultColumns.map((column) {
                  return CheckboxListTile(
                    title: Text(column, style: const TextStyle(fontSize: 14)),
                    value: _selectedColumns.contains(column),
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedColumns.add(column);
                        } else {
                          _selectedColumns.remove(column);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Export button
            FilledButton.icon(
              onPressed: _selectedColumns.isEmpty || _isExporting
                  ? null
                  : () => _exportCsv(context),
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final csvService = ref.read(csvExportServiceProvider);
      final records = ref.read(filteredRecordsProvider);

      final columns =
          CsvExportService.defaultColumns
              .where((c) => _selectedColumns.contains(c))
              .toList();

      final filePath = await csvService.exportToCsvFile(
        records,
        columns: columns,
      );

      if (mounted) {
        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Financial Records Export',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: $filePath'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
