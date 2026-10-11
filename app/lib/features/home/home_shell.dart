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
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))]),
        child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded), label: l.navBills),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), selectedIcon: const Icon(Icons.insights_rounded), label: l.navReports),
          NavigationDestination(icon: const Icon(Icons.solar_power_outlined), selectedIcon: const Icon(Icons.solar_power_rounded), label: l.navSolar),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings_rounded), label: l.navSettings),
        ],
        ),
      ),
    );
  }
}

/// Tab indexes used by quick actions.
abstract final class Tabs {
  static const bills = 1;
  static const reports = 2;
  static const solar = 3;
  static const settings = 4;
}
