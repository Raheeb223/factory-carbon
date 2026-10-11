import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/gen/app_localizations.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

class FactoryCarbonApp extends ConsumerWidget {
  const FactoryCarbonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RootGate(),
    );
  }
}

/// Shows onboarding until a factory profile (with privacy acknowledgement) exists.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(factoryProvider);
    return profile.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(AppLocalizations.of(context).errorGeneric))),
      data: (p) => p == null ? const OnboardingScreen() : const HomeShell(),
    );
  }
}
