import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../bills/bills_screen.dart';
import '../carbon/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../solar/solar_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      HomeScreen(onOpenTab: _go),
      const BillsScreen(),
      const ReportsScreen(),
      const SolarScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: l.navBills),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), selectedIcon: const Icon(Icons.insights), label: l.navReports),
          NavigationDestination(icon: const Icon(Icons.solar_power_outlined), selectedIcon: const Icon(Icons.solar_power), label: l.navSolar),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l.navSettings),
        ],
      ),
    );
  }
}

/// Tab indexes used by quick actions.
abstract final class Tabs {
  static const bills = 1;
  static const reports = 2;
  static const solar = 3;
}
