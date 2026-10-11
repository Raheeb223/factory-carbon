import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../impact/impact_screen.dart';
import '../waste/waste_screen.dart';
import 'carbon_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    Widget tab(IconData icon, String text) => Tab(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
          ]),
        );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(children: [
            PageHero(
              title: l.navReports,
              subtitle: l.reportsSubtitle,
              icon: Icons.insights_rounded,
              bottom: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
                child: TabBar(
                  indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                  labelColor: primary,
                  unselectedLabelColor: Colors.white,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabs: [tab(Icons.co2_rounded, l.tabCarbon), tab(Icons.bolt_rounded, l.tabUnusual), tab(Icons.savings_rounded, l.tabImpact)],
                ),
              ),
            ),
            const SyntheticBanner(),
            const Expanded(child: TabBarView(children: [CarbonView(), WasteView(), ImpactView()])),
          ]),
        ),
      ),
    );
  }
}
