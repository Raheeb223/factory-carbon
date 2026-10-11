import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/language_switch.dart';
import '../export/export_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'data_admin.dart';
import 'info_screens.dart';
import 'server_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final keep = ref.watch(keepImagesProvider);
    final synthetic = ref.watch(containsSyntheticProvider);
    final health = ref.watch(healthProvider);
    final server = ref.watch(serverConfigProvider);
    final admin = ref.read(dataAdminProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: Column(children: [
        const SyntheticBanner(),
        Expanded(
          child: ListView(children: [
            header(l.settingsLanguage),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: LanguageSwitch(key: Key('language'))),
            header(l.settingsFactory),
            ListTile(
              leading: const Icon(Icons.factory_outlined),
              title: Text(ref.watch(factoryProvider).value?.name ?? l.settingsFactory),
              subtitle: Text(ref.watch(factoryProvider).value?.location ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final profile = ref.read(factoryProvider).value;
                if (profile != null) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OnboardingScreen(existing: profile)));
              },
            ),
            header(l.settingsServer),
            ListTile(
              key: const Key('server-settings'),
              leading: Icon(
                health.hasError ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
                color: health.hasError ? scheme.error : (health.hasValue ? Colors.green.shade700 : null),
              ),
              title: Text(l.serverSettingsTitle),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(server.apiBaseUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                health.when(
                  loading: () => const Padding(padding: EdgeInsets.only(top: 6), child: LinearProgressIndicator()),
                  error: (e, _) => Text(errorText(l, e), style: TextStyle(color: scheme.error)),
                  data: (h) => Text(h.geminiConfigured ? l.serverStatusOk : '${l.serverStatusOk}. ${l.serverExtractionOff}'),
                ),
              ]),
              isThreeLine: true,
              trailing: IconButton(tooltip: l.actionRetry, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(healthProvider)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ServerScreen())),
            ),
            header(l.privacyTitle),
            SwitchListTile(
              secondary: const Icon(Icons.image_outlined),
              title: Text(l.settingsKeepImages),
              subtitle: Text(l.settingsKeepImagesHint),
              value: keep,
              onChanged: (v) => ref.read(keepImagesProvider.notifier).set(v),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l.settingsDataHandling),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DataHandlingScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.rule_outlined),
              title: Text(l.settingsLimitations),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LimitationsScreen())),
            ),
            header(l.settingsExport),
            ListTile(
              leading: const Icon(Icons.dataset_outlined),
              title: Text(l.exportRaw),
              onTap: () async {
                try {
                  await ref.read(exportServiceProvider).exportRawCsv();
                } catch (e) {
                  if (context.mounted) showSnack(context, errorText(l, e));
                }
              },
            ),
            header(l.settingsLoadDemo),
            ListTile(
              key: const Key('load-demo'),
              leading: const Icon(Icons.science_outlined),
              title: Text(l.settingsLoadDemo),
              subtitle: Text(l.settingsLoadDemoHint),
              onTap: () async {
                final result = await admin.loadDemo();
                if (context.mounted) showSnack(context, result == DemoLoadResult.loaded ? l.demoLoaded : l.demoNeedsEmpty);
              },
            ),
            if (synthetic)
              ListTile(
                key: const Key('remove-demo'),
                leading: const Icon(Icons.layers_clear_outlined),
                title: Text(l.settingsRemoveDemo),
                onTap: () async {
                  await admin.removeDemo();
                  if (context.mounted) showSnack(context, l.demoRemoved);
                },
              ),
            const Divider(height: 32),
            ListTile(
              key: const Key('delete-all'),
              leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
              title: Text(l.settingsDeleteAll, style: TextStyle(color: scheme.error)),
              onTap: () async {
                final ok = await confirmDialog(context, title: l.deleteAllConfirmTitle, body: l.deleteAllConfirmBody, confirm: l.actionDelete, destructive: true);
                if (!ok) return;
                await admin.deleteAll();
                if (context.mounted) showSnack(context, l.deleteAllDone);
              },
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ]),
    );
  }
}
