import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../waste/waste_screen.dart';
import 'carbon_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navReports),
          bottom: TabBar(tabs: [Tab(text: l.carbonTitle), Tab(text: l.wasteTitle)]),
        ),
        body: const Column(children: [
          SyntheticBanner(),
          Expanded(child: TabBarView(children: [CarbonView(), WasteView()])),
        ]),
      ),
    );
  }
}
