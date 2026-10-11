import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'solar_map_screen.dart';
import 'solar_result_screen.dart';

/// Saved rooftop solar plans (spec 8.7). Plans persist locally.
class SolarScreen extends ConsumerWidget {
  const SolarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final plans = ref.watch(solarPlansProvider);
    void newPlan() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SolarMapScreen()));

    Widget step(int n, IconData icon, String text) => Expanded(
          child: Column(children: [
            Stack(clipBehavior: Clip.none, children: [
              IconBlob(icon, color: FeatureColors.solar, size: 50),
              Positioned(
                right: -6,
                top: -6,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: FeatureColors.solar,
                  child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, maxLines: 3, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        );

    final how = SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.solarHowTitle, style: tt.titleMedium),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          step(1, Icons.draw_rounded, l.solarHow1),
          const SizedBox(width: 8),
          step(2, Icons.tune_rounded, l.solarHow2),
          const SizedBox(width: 8),
          step(3, Icons.savings_rounded, l.solarHow3),
        ]),
      ]),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-solar',
          key: const Key('solar-new'),
          backgroundColor: const Color(0xFFD97706),
          onPressed: newPlan,
          icon: const Icon(Icons.add_location_alt_rounded),
          label: Text(l.solarNewPlan),
        ),
        body: Column(children: [
          PageHero(title: l.solarTitle, subtitle: l.solarSubtitle, icon: Icons.solar_power_rounded, gradient: BrandGradients.solar),
          const SyntheticBanner(),
          Expanded(
            child: plans.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorPanel(message: l.errorGeneric),
              data: (list) => ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 96), children: [
                how,
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: EmptyState(icon: Icons.roofing_rounded, color: FeatureColors.solar, message: l.solarNoPlans),
                  ),
                if (list.isNotEmpty) SectionHeader(l.solarTitle),
                for (final p in list)
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => p.resultJson == null
                          ? SolarMapScreen(plan: p)
                          : SolarResultScreen(result: SolarResult.fromJson(p.resultJson!), polygon: p.polygon, params: p.params, plan: p),
                    )),
                    child: Row(children: [
                      const IconBlob(Icons.roofing_rounded, color: FeatureColors.solar, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: tt.titleSmall),
                          if (p.resultJson != null)
                            Builder(builder: (_) {
                              final r = SolarResult.fromJson(p.resultJson!);
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Wrap(spacing: 6, runSpacing: 4, children: [
                                  Badge2(l.valueKwp(fmt.number(r.kwp, decimals: 1)), color: const Color(0xFFB45309)),
                                  Badge2(l.valueKwhYear(fmt.number(r.annualGenerationKwh)), color: FeatureColors.carbon),
                                ]),
                              );
                            }),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: l.actionDelete,
                        onPressed: () async {
                          if (await confirmDialog(context, title: l.actionDelete, body: p.name, confirm: l.actionDelete, destructive: true)) {
                            await ref.read(solarPlanRepositoryProvider).softDelete(p.id);
                          }
                        },
                      ),
                    ]),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
