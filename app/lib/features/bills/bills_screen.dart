import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../add_bill/add_bill_screen.dart';
import '../add_bill/image_service.dart';
import '../add_bill/review_screen.dart';
import '../import_history/import_screen.dart';
import '../production/production_screen.dart';

IconData billIcon(BillType t) => switch (t) {
  BillType.electricity => Icons.bolt,
  BillType.gas => Icons.local_fire_department_outlined,
  BillType.diesel => Icons.local_gas_station_outlined,
  BillType.lpg => Icons.propane_tank_outlined,
  BillType.furnaceOil => Icons.oil_barrel_outlined,
  BillType.unknown => Icons.help_outline,
};

Color billColor(BillType t) => switch (t) {
  BillType.electricity => const Color(0xFF3B82F6), // brighter than the chart blue, readable in dark mode
  BillType.gas => SeriesColors.gas,
  BillType.diesel => SeriesColors.diesel,
  BillType.lpg => SeriesColors.lpg,
  BillType.furnaceOil => SeriesColors.furnaceOil,
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

    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    Widget heroAction(IconData icon, String tooltip, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-bills',
          tooltip: l.addBillTitle,
          onPressed: () => push(const AddBillScreen()),
          icon: const Icon(Icons.add_a_photo_rounded),
          label: Text(l.addBillTitle),
        ),
        body: Column(
          children: [
            PageHero(
              title: l.billsTitle,
              subtitle: l.billsSubtitle,
              icon: Icons.receipt_long_rounded,
              gradient: BrandGradients.bills,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  heroAction(Icons.precision_manufacturing_outlined, l.productionTitle, () => push(const ProductionScreen())),
                  heroAction(Icons.upload_file_outlined, l.importTitle, () => push(const ImportScreen())),
                ],
              ),
            ),
            const SyntheticBanner(),
            Expanded(
              child: bills.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorPanel(message: l.errorGeneric),
                data: (all) {
                  if (all.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_rounded,
                      color: FeatureColors.bills,
                      message: l.billsEmpty,
                      action: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => push(const AddBillScreen()),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: Text(l.addBillTitle),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => push(const ImportScreen()),
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(l.homeImportHistory),
                          ),
                        ],
                      ),
                    );
                  }
                  final list = _filter == null ? all : all.where((b) => b.billType == _filter).toList();
                  final rows = <Widget>[];
                  String? month;
                  for (final b in list) {
                    if (b.billingMonth != month) {
                      month = b.billingMonth;
                      rows.add(
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                          child: Text(
                            fmt.monthLong(month),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.3),
                          ),
                        ),
                      );
                    }
                    rows.add(_BillTile(bill: b));
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          children: [
                            for (final t in <BillType?>[
                              null,
                              BillType.electricity,
                              BillType.gas,
                              BillType.diesel,
                              // LPG and furnace oil only when the factory has such bills.
                              for (final extra in const [BillType.lpg, BillType.furnaceOil])
                                if (all.any((b) => b.billType == extra)) extra,
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  key: Key('filter-${t?.name ?? 'all'}'),
                                  avatar: t == null ? null : Icon(billIcon(t), size: 16, color: _filter == t ? Colors.white : billColor(t)),
                                  label: Text(t == null ? l.filterAll : billTypeLabel(l, t)),
                                  selected: _filter == t,
                                  showCheckmark: false,
                                  selectedColor: t == null ? Theme.of(context).colorScheme.primary : billColor(t),
                                  labelStyle: TextStyle(fontWeight: FontWeight.w700, color: _filter == t ? Colors.white : null),
                                  onSelected: (_) => setState(() => _filter = t),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(padding: const EdgeInsets.only(bottom: 96), children: rows),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(22)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDialog(
        context,
        title: l.deleteBillConfirm,
        body: '${billTypeLabel(l, b.billType)} · ${fmt.month(b.billingMonth)}',
        confirm: l.actionDelete,
        destructive: true,
      ),
      onDismissed: (_) async {
        await ref.read(billRepositoryProvider).softDelete(b.id);
        await ref.read(imageServiceProvider).deleteKept(b.imagePath);
      },
      child: SoftCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReviewScreen(extraction: null, warnings: const [], imageBytes: null, extracted: ExtractedBill.empty, existing: b),
          ),
        ),
        child: Row(
          children: [
            IconBlob(billIcon(b.billType), color: billColor(b.billType), size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${fmt.number(b.consumedUnits, decimals: b.consumedUnits < 100 ? 2 : 0)} ${b.unit.wire}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (amount.isNotEmpty)
                    Text(amount.substring(3), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Badge2(billTypeLabel(l, b.billType), color: billColor(b.billType)),
                      if (b.isSynthetic) const SyntheticBadge() else Badge2(originLabel(l, b.origin)),
                      if (b.userEditedFields.isNotEmpty) Badge2(l.billEdited, color: Colors.blueGrey),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
