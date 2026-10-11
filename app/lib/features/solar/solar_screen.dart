import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import 'solar_map_screen.dart';
import 'solar_result_screen.dart';

/// Saved rooftop solar plans (spec 8.7). Plans persist locally.
class SolarScreen extends ConsumerWidget {
  const SolarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final plans = ref.watch(solarPlansProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.solarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('solar-new'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SolarMapScreen())),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l.solarNewPlan),
      ),
      body: Column(children: [
        const SyntheticBanner(),
        Expanded(
          child: plans.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorPanel(message: l.errorGeneric),
            data: (list) => list.isEmpty
                ? EmptyState(icon: Icons.solar_power_outlined, message: l.solarNoPlans)
                : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                    for (final p in list)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.roofing),
                          title: Text(p.name),
                          subtitle: p.resultJson == null
                              ? null
                              : Builder(builder: (_) {
                                  final r = SolarResult.fromJson(p.resultJson!);
                                  return Text('${l.valueKwp(fmt.number(r.kwp, decimals: 1))} · ${l.valueKwhYear(fmt.number(r.annualGenerationKwh))}');
                                }),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l.actionDelete,
                            onPressed: () async {
                              if (await confirmDialog(context, title: l.actionDelete, body: p.name, confirm: l.actionDelete, destructive: true)) {
                                await ref.read(solarPlanRepositoryProvider).softDelete(p.id);
                              }
                            },
                          ),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => p.resultJson == null
                                ? SolarMapScreen(plan: p)
                                : SolarResultScreen(result: SolarResult.fromJson(p.resultJson!), polygon: p.polygon, params: p.params, plan: p),
                          )),
                        ),
                      ),
                  ]),
          ),
        ),
      ]),
    );
  }
}
