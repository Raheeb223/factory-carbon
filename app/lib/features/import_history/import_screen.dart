import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/history_csv.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../export/export_service.dart';

/// Bulk history import from the CSV template (spec 8.4): preview + validation before saving.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportPreview? _preview;
  bool _busy = false;

  Future<void> _shareTemplate() async {
    setState(() => _busy = true);
    String text;
    try {
      text = await ref.read(apiClientProvider).historyTemplate();
    } catch (_) {
      text = await rootBundle.loadString('assets/templates/history_template.csv'); // bundled copy
    }
    try {
      await ref.read(exportServiceProvider).shareText(text, 'history_template.csv', 'text/csv');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['csv']);
    if (files.isEmpty) return;
    final bytes = await files.first.readAsBytes();
    setState(() => _preview = parseHistoryCsv(utf8.decode(bytes, allowMalformed: true)));
  }

  /// Exposed for tests: parse CSV text directly.
  void previewText(String text) => setState(() => _preview = parseHistoryCsv(text));

  Future<void> _import() async {
    final preview = _preview;
    if (preview == null || !preview.canImport) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final data = importRowsToData(preview.rows, newId: newId);
    await ref.read(billRepositoryProvider).insertAll(data.bills);
    final prodRepo = ref.read(productionRepositoryProvider);
    for (final (month, units) in data.production) {
      await prodRepo.upsertMonth(month, units, DataOrigin.imported);
    }
    if (!mounted) return;
    showSnack(context, l.importDone(preview.rows.length));
    Navigator.of(context).pop();
  }

  String _issue(AppLocalizations l, ImportIssue i) {
    final row = '${i.row ?? ''}';
    final v = i.value ?? '';
    final c = i.column ?? '';
    return switch (i.code) {
      ImportIssueCode.missingColumns => l.issueMissingColumns(v),
      ImportIssueCode.noRows => l.issueNoRows,
      ImportIssueCode.badMonth => l.issueBadMonth(row, v),
      ImportIssueCode.badNumber => l.issueBadNumber(row, c, v),
      ImportIssueCode.negativeNumber => l.issueNegative(row, c),
      ImportIssueCode.duplicateMonth => l.issueDuplicateMonth(row, v),
      ImportIssueCode.emptyRow => l.issueEmptyRow(row, v),
      ImportIssueCode.costWithoutKwh => l.issueCostWithoutKwh(row, v),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final p = _preview;
    return Scaffold(
      appBar: AppBar(title: Text(l.importTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(l.importIntro),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(onPressed: _busy ? null : _shareTemplate, icon: const Icon(Icons.download_outlined), label: Text(l.importGetTemplate)),
          FilledButton.icon(key: const Key('import-pick'), onPressed: _busy ? null : _pick, icon: const Icon(Icons.folder_open), label: Text(l.importPickFile)),
        ]),
        const SizedBox(height: 8),
        Text(l.importMarked, style: Theme.of(context).textTheme.bodySmall),
        if (p != null) ...[
          const SizedBox(height: 16),
          if (p.errors.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.importErrors, style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (final e in p.errors) Text('• ${_issue(l, e)}', key: const Key('import-error')),
                ]),
              ),
            ),
          if (p.warnings.isNotEmpty) ...[
            SectionTitle(l.importWarnings),
            for (final w in p.warnings) Text('• ${_issue(l, w)}'),
          ],
          if (p.rows.isNotEmpty) ...[
            SectionTitle(l.importRowsReady(p.rows.length)),
            if (p.rows.length < 12) Text(l.importFewMonths, style: TextStyle(color: Colors.orange.shade800)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(label: Text(l.importColMonth)),
                  DataColumn(label: Text(l.importColKwh), numeric: true),
                  DataColumn(label: Text(l.importColDiesel), numeric: true),
                  DataColumn(label: Text(l.importColGas), numeric: true),
                  DataColumn(label: Text(l.importColProduction), numeric: true),
                ],
                rows: [
                  for (final r in p.rows)
                    DataRow(cells: [
                      DataCell(Text(r.month)),
                      DataCell(Text(fmt.number(r.electricityKwh))),
                      DataCell(Text(fmt.number(r.dieselLitres))),
                      DataCell(Text(fmt.number(r.gasM3))),
                      DataCell(Text(fmt.number(r.productionUnits))),
                    ]),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(key: const Key('import-confirm'), onPressed: (_busy || !p.canImport) ? null : _import, child: Text(l.importConfirm)),
        ],
      ]),
    );
  }
}
