import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../add_bill/add_bill_screen.dart';
import '../add_bill/image_service.dart';
import '../add_bill/review_screen.dart';
import '../import_history/import_screen.dart';
import '../production/production_screen.dart';

IconData billIcon(BillType t) => switch (t) {
      BillType.electricity => Icons.bolt,
      BillType.gas => Icons.local_fire_department_outlined,
      BillType.diesel => Icons.local_gas_station_outlined,
      BillType.unknown => Icons.help_outline,
    };

Color billColor(BillType t) => switch (t) {
      BillType.electricity => SeriesColors.electricity,
      BillType.gas => SeriesColors.gas,
      BillType.diesel => SeriesColors.diesel,
      BillType.unknown => Colors.grey,
    };

/// Confirmed bills grouped by month, filterable by type (spec 8.3).
class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  BillType? _filter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final bills = ref.watch(billsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.billsTitle), actions: [
        IconButton(
          tooltip: l.productionTitle,
          icon: const Icon(Icons.precision_manufacturing_outlined),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductionScreen())),
        ),
        IconButton(
          tooltip: l.importTitle,
          icon: const Icon(Icons.upload_file_outlined),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addBillTitle,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddBillScreen())),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        const SyntheticBanner(),
        Expanded(
          child: bills.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorPanel(message: l.errorGeneric),
            data: (all) {
              if (all.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  message: l.billsEmpty,
                  action: Wrap(spacing: 8, children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddBillScreen())),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(l.addBillTitle),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(l.homeImportHistory),
                    ),
                  ]),
                );
              }
              final list = _filter == null ? all : all.where((b) => b.billType == _filter).toList();
              final rows = <Widget>[];
              String? month;
              for (final b in list) {
                if (b.billingMonth != month) {
                  month = b.billingMonth;
                  rows.add(Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(fmt.monthLong(month), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ));
                }
                rows.add(_BillTile(bill: b));
              }
              return Column(children: [
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      for (final t in <BillType?>[null, BillType.electricity, BillType.gas, BillType.diesel])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            key: Key('filter-${t?.name ?? 'all'}'),
                            avatar: t == null ? null : Icon(billIcon(t), size: 16, color: billColor(t)),
                            label: Text(t == null ? l.filterAll : billTypeLabel(l, t)),
                            selected: _filter == t,
                            onSelected: (_) => setState(() => _filter = t),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: ListView(padding: const EdgeInsets.only(bottom: 88), children: rows)),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _BillTile extends ConsumerWidget {
  const _BillTile({required this.bill});
  final Bill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final b = bill;
    final amount = b.totalAmountBdt == null ? '' : ' · ${l.valueTk(fmt.number(b.totalAmountBdt, decimals: 2))}';
    return Dismissible(
      key: ValueKey(b.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDialog(context, title: l.deleteBillConfirm, body: '${billTypeLabel(l, b.billType)} · ${fmt.month(b.billingMonth)}', confirm: l.actionDelete, destructive: true),
      onDismissed: (_) async {
        await ref.read(billRepositoryProvider).softDelete(b.id);
        await ref.read(imageServiceProvider).deleteKept(b.imagePath);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: billColor(b.billType).withValues(alpha: 0.15),
          child: Icon(billIcon(b.billType), color: billColor(b.billType)),
        ),
        title: Text('${fmt.number(b.consumedUnits, decimals: b.consumedUnits < 100 ? 2 : 0)} ${b.unit.wire}$amount'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(spacing: 6, runSpacing: 4, children: [
            Text(billTypeLabel(l, b.billType)),
            if (b.isSynthetic) const SyntheticBadge() else Badge2(originLabel(l, b.origin)),
            if (b.userEditedFields.isNotEmpty) Badge2(l.billEdited, color: Colors.blueGrey),
          ]),
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ReviewScreen(extraction: null, warnings: const [], imageBytes: null, extracted: ExtractedBill.empty, existing: b),
        )),
      ),
    );
  }
}
