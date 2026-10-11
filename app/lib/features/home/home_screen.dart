import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/language_switch.dart';
import '../add_bill/add_bill_screen.dart';
import '../carbon/carbon_controller.dart';
import '../import_history/import_screen.dart';
import '../production/production_screen.dart';
import '../settings/data_admin.dart';
import '../waste/waste_controller.dart';
import 'home_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onOpenTab});
  final void Function(int tab) onOpenTab;

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(factoryProvider).value;
    final bills = ref.watch(billsProvider).value ?? const [];
    final production = ref.watch(productionProvider).value ?? const [];
    final carbon = ref.watch(carbonResultProvider);
    final waste = ref.watch(wasteResultProvider);
    final months = {for (final b in bills) b.billingMonth}.toList()..sort();

    final steps = [
      (done: bills.isNotEmpty, label: l.stepAddData, icon: Icons.receipt_long_outlined, onTap: () => _push(context, const AddBillScreen())),
      (done: production.isNotEmpty, label: l.stepProduction, icon: Icons.precision_manufacturing_outlined, onTap: () => _push(context, const ProductionScreen())),
      (done: carbon != null, label: l.stepReport, icon: Icons.co2_outlined, onTap: () => onOpenTab(Tabs.reports)),
      (done: waste != null, label: l.stepWaste, icon: Icons.bolt_outlined, onTap: () => onOpenTab(Tabs.reports)),
    ];
    final doneCount = steps.where((s) => s.done).length;

    return Scaffold(
      appBar: AppBar(title: Text(profile?.name ?? l.appTitle), actions: const [LanguageToggleAction(), SizedBox(width: 8)]),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-bill-fab'),
        onPressed: () => _push(context, const AddBillScreen()),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l.addBillTitle),
      ),
      body: Column(children: [
        const SyntheticBanner(),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
            if (doneCount < steps.length)
              Card(
                key: const Key('getting-started'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(l.homeGettingStarted, style: Theme.of(context).textTheme.titleMedium)),
                      Text('$doneCount/${steps.length}', style: Theme.of(context).textTheme.labelLarge),
                    ]),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: doneCount / steps.length, borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 4),
                    for (final s in steps)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(s.done ? Icons.check_circle : Icons.radio_button_unchecked, color: s.done ? Colors.green.shade700 : scheme.outline),
                        title: Text(s.label, style: s.done ? TextStyle(color: scheme.outline, decoration: TextDecoration.lineThrough) : null),
                        trailing: s.done ? null : Icon(s.icon, color: scheme.primary),
                        onTap: s.done ? null : s.onTap,
                      ),
                    if (bills.isEmpty && production.isEmpty) ...[
                      const Divider(),
                      Row(children: [
                        Expanded(child: Text(l.homeTryDemo, style: Theme.of(context).textTheme.bodySmall)),
                        TextButton(
                          key: const Key('home-load-demo'),
                          onPressed: () async {
                            final r = await ref.read(dataAdminProvider).loadDemo();
                            if (context.mounted) showSnack(context, r == DemoLoadResult.loaded ? l.demoLoaded : l.demoNeedsEmpty);
                          },
                          child: Text(l.homeLoadDemo),
                        ),
                      ]),
                    ],
                  ]),
                ),
              ),
            Row(children: [
              _Stat(label: l.navBills, value: fmt.number(bills.length.toDouble()), icon: Icons.receipt_long_outlined, onTap: () => onOpenTab(Tabs.bills)),
              const SizedBox(width: 8),
              _Stat(label: l.homeStatMonths, value: fmt.number(months.length.toDouble()), icon: Icons.date_range_outlined, onTap: () => onOpenTab(Tabs.bills)),
              const SizedBox(width: 8),
              _Stat(label: l.homeStatLatest, value: months.isEmpty ? '–' : fmt.month(months.last), icon: Icons.event_outlined, onTap: () => onOpenTab(Tabs.bills)),
            ]),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onOpenTab(Tabs.reports),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.co2_outlined, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l.homeLatestReport, style: Theme.of(context).textTheme.titleMedium)),
                      if (carbon != null && carbon.result.placeholdersInUse.isNotEmpty) const UnverifiedBadge(),
                    ]),
                    const SizedBox(height: 8),
                    if (carbon == null)
                      Text(l.homeNoReport)
                    else ...[
                      Text('${fmt.month(carbon.result.periodStart ?? '')} – ${fmt.month(carbon.result.periodEnd ?? '')}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        carbon.result.totals.totalT == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(carbon.result.totals.totalT)),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary),
                      ),
                      LabeledValue(l.carbonScope1, carbon.result.totals.scope1T == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(carbon.result.totals.scope1T))),
                      LabeledValue(l.carbonScope2, carbon.result.totals.scope2T == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(carbon.result.totals.scope2T))),
                      Text(l.lastUpdated(fmt.dateTime(carbon.updatedAt)), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ]),
                ),
              ),
            ),
            if (waste != null && !waste.result.insufficient && waste.result.flaggedMonths.isNotEmpty)
              Card(
                color: scheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.bolt, color: scheme.onErrorContainer),
                  title: Text(l.wasteTitle),
                  subtitle: Text(l.wasteFlaggedCount(waste.result.flaggedMonths.length)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpenTab(Tabs.reports),
                ),
              ),
            SectionTitle(l.homeQuickActions),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: [
                _Action(icon: Icons.add_a_photo_outlined, label: l.addBillTitle, onTap: () => _push(context, const AddBillScreen())),
                _Action(icon: Icons.upload_file_outlined, label: l.homeImportHistory, onTap: () => _push(context, const ImportScreen())),
                _Action(icon: Icons.precision_manufacturing_outlined, label: l.homeProduction, onTap: () => _push(context, const ProductionScreen())),
                _Action(icon: Icons.co2_outlined, label: l.homeCarbon, onTap: () => onOpenTab(Tabs.reports)),
                _Action(icon: Icons.bolt_outlined, label: l.homeWaste, onTap: () => onOpenTab(Tabs.reports)),
                _Action(icon: Icons.solar_power_outlined, label: l.solarTitle, onTap: () => onOpenTab(Tabs.solar)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, required this.onTap});
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 6),
                FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      );
}
