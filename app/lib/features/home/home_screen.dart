import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/connection_card.dart';
import '../../widgets/language_switch.dart';
import '../../widgets/ui.dart';
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

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.homeGreetingMorning;
    if (h < 17) return l.homeGreetingAfternoon;
    return l.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(factoryProvider).value;
    final bills = ref.watch(billsProvider).value ?? const [];
    final production = ref.watch(productionProvider).value ?? const [];
    final carbon = ref.watch(carbonResultProvider);
    final waste = ref.watch(wasteResultProvider);
    final months = {for (final b in bills) b.billingMonth}.toList()..sort();

    final steps = [
      (done: bills.isNotEmpty, label: l.stepAddData, icon: Icons.receipt_long_outlined, onTap: () => _push(context, const AddBillScreen())),
      (
        done: production.isNotEmpty,
        label: l.stepProduction,
        icon: Icons.precision_manufacturing_outlined,
        onTap: () => _push(context, const ProductionScreen()),
      ),
      (done: carbon != null, label: l.stepReport, icon: Icons.co2_outlined, onTap: () => onOpenTab(Tabs.reports)),
      (done: waste != null, label: l.stepWaste, icon: Icons.bolt_outlined, onTap: () => onOpenTab(Tabs.reports)),
    ];
    final doneCount = steps.where((s) => s.done).length;
    final totals = carbon?.result.totals;

    final hero = HeroHeader(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.eco_rounded, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(l), style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    Text(
                      profile?.name ?? l.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const LanguagePill(),
            ],
          ),
          const SizedBox(height: 20),
          if (totals?.totalT != null) ...[
            Row(
              children: [
                Flexible(
                  child: Text(
                    l.homeFootprint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                if (carbon!.result.placeholdersInUse.isNotEmpty)
                  Flexible(child: StatusPill(text: l.unverifiedFactorBadge, color: Colors.white, icon: Icons.warning_amber_rounded, onDark: true)),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l.tonnesCo2e(fmt.tonnes(totals!.totalT)),
                style: t.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${fmt.month(carbon.result.periodStart ?? '')} – ${fmt.month(carbon.result.periodEnd ?? '')}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5),
            ),
            if ((totals.scope1T ?? 0) + (totals.scope2T ?? 0) > 0) ...[
              const SizedBox(height: 12),
              SplitBar(parts: [(totals.scope2T ?? 0, const Color(0xFFBAE6FD)), (totals.scope1T ?? 0, const Color(0xFFFDE68A))], height: 8),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _HeroLegend(color: const Color(0xFFBAE6FD), text: '${l.carbonScope2}: ${fmt.tonnes(totals.scope2T)} t'),
                  _HeroLegend(color: const Color(0xFFFDE68A), text: '${l.carbonScope1}: ${fmt.tonnes(totals.scope1T)} t'),
                ],
              ),
            ],
          ] else
            Text(
              l.homeHeroEmpty,
              style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.25),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              GlassStat(label: l.navBills, value: fmt.number(bills.length.toDouble()), onTap: () => onOpenTab(Tabs.bills)),
              const SizedBox(width: 8),
              GlassStat(label: l.homeStatMonths, value: fmt.number(months.length.toDouble()), onTap: () => onOpenTab(Tabs.bills)),
              const SizedBox(width: 8),
              GlassStat(label: l.homeStatLatest, value: months.isEmpty ? '–' : fmt.month(months.last), onTap: () => onOpenTab(Tabs.bills)),
            ],
          ),
        ],
      ),
    );

    final checklist = SoftCard(
      key: const Key('getting-started'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBlob(Icons.flag_rounded, color: scheme.primary, size: 38),
              const SizedBox(width: 12),
              Expanded(child: Text(l.homeGettingStarted, style: t.titleMedium)),
              StatusPill(text: '$doneCount/${steps.length}', color: scheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: doneCount / steps.length, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 6),
          for (final (i, s) in steps.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: s.done
                  ? const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF16A34A),
                      child: Icon(Icons.check_rounded, size: 18, color: Colors.white),
                    )
                  : CircleAvatar(
                      radius: 14,
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary, fontSize: 13),
                      ),
                    ),
              title: Text(
                s.label,
                style: s.done ? TextStyle(color: scheme.outline, decoration: TextDecoration.lineThrough) : const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: s.done ? null : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.primary),
              onTap: s.done ? null : s.onTap,
            ),
          if (bills.isEmpty && production.isEmpty) ...[
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.science_outlined, size: 18, color: FeatureColors.production),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.homeTryDemo, style: t.bodySmall)),
                ]),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  key: const Key('home-load-demo'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), foregroundColor: FeatureColors.production),
                  onPressed: () async {
                    final r = await ref.read(dataAdminProvider).loadDemo();
                    if (context.mounted) showSnack(context, r == DemoLoadResult.loaded ? l.demoLoaded : l.demoNeedsEmpty);
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                  label: Text(l.homeLoadDemo),
                ),
              ]),
            ),
          ],
        ],
      ),
    );

    final tiles = [
      FeatureTile(
        icon: Icons.receipt_long_rounded,
        color: FeatureColors.bills,
        title: l.navBills,
        subtitle: l.tileBillsSub,
        onTap: () => onOpenTab(Tabs.bills),
      ),
      FeatureTile(icon: Icons.co2_rounded, color: FeatureColors.carbon, title: l.homeCarbon, subtitle: l.tileCarbonSub, onTap: () => onOpenTab(Tabs.reports)),
      FeatureTile(icon: Icons.bolt_rounded, color: FeatureColors.waste, title: l.homeWaste, subtitle: l.tileWasteSub, onTap: () => onOpenTab(Tabs.reports)),
      FeatureTile(
        icon: Icons.solar_power_rounded,
        color: FeatureColors.solar,
        title: l.solarTitle,
        subtitle: l.tileSolarSub,
        onTap: () => onOpenTab(Tabs.solar),
      ),
      FeatureTile(
        icon: Icons.precision_manufacturing_rounded,
        color: FeatureColors.production,
        title: l.homeProduction,
        subtitle: l.tileProductionSub,
        onTap: () => _push(context, const ProductionScreen()),
      ),
      FeatureTile(
        icon: Icons.upload_file_rounded,
        color: FeatureColors.import,
        title: l.homeImportHistory,
        subtitle: l.tileImportSub,
        onTap: () => _push(context, const ImportScreen()),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            hero,
            const SyntheticBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ConnectionCard(),
                  FadeSlideIn(
                    child: ActionBanner(
                      key: const Key('add-bill-fab'),
                      icon: Icons.document_scanner_rounded,
                      title: l.homeScanTitle,
                      subtitle: l.homeScanSubtitle,
                      onTap: () => _push(context, const AddBillScreen()),
                    ),
                  ),
                  if (waste != null && !waste.result.insufficient && waste.result.flaggedMonths.isNotEmpty)
                    SoftCard(
                      color: FeatureColors.waste.withValues(alpha: 0.07),
                      borderColor: FeatureColors.waste.withValues(alpha: 0.3),
                      onTap: () => onOpenTab(Tabs.reports),
                      child: Row(
                        children: [
                          const IconBlob(Icons.bolt_rounded, color: FeatureColors.waste, filled: true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.wasteTitle, style: t.titleSmall),
                                Text(l.wasteFlaggedCount(waste.result.flaggedMonths.length), style: t.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  if (doneCount < steps.length) checklist,
                  SectionHeader(l.homeExplore),
                  // Rows of two tiles sized to their content, so long (Bangla) labels never clip.
                  for (var i = 0; i < tiles.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: tiles[i]),
                          const SizedBox(width: 12),
                          Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox.shrink()),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroLegend extends StatelessWidget {
  const _HeroLegend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
