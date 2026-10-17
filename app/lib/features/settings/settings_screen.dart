import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tutorial/tutorial_screen.dart';
import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/backup.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/language_switch.dart';
import '../../widgets/ui.dart';
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
    final profile = ref.watch(factoryProvider).value;
    final admin = ref.read(dataAdminProvider);
    final scheme = Theme.of(context).colorScheme;
    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

    Widget group(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(title, padding: const EdgeInsets.fromLTRB(6, 18, 6, 8)),
          SoftCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              for (final (i, c) in children.indexed) ...[if (i > 0) const Divider(indent: 70, height: 1), c],
            ]),
          ),
        ]);

    Widget tile({Key? key, required IconData icon, required Color color, required String title, Widget? subtitle, Widget? trailing, VoidCallback? onTap, bool threeLine = false}) =>
        ListTile(
          key: key,
          leading: IconBlob(icon, color: color, size: 40),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitle,
          isThreeLine: threeLine,
          trailing: trailing ?? (onTap == null ? null : Icon(Icons.chevron_right_rounded, color: scheme.outline)),
          onTap: onTap,
        );

    final serverStatus = health.when(
      loading: () => const Padding(padding: EdgeInsets.only(top: 6), child: LinearProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(errorText(l, e), style: TextStyle(color: scheme.error)),
      ),
      data: (h) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: h.geminiConfigured
              ? StatusPill(text: '${l.serverStatusOk} · ${l.connReadingOn}', color: const Color(0xFF16A34A), icon: Icons.check_circle_rounded)
              : StatusPill(text: l.serverExtractionOff, color: Colors.orange.shade800, icon: Icons.info_outline_rounded),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(children: [
          PageHero(title: l.settingsTitle, subtitle: l.settingsSubtitle, icon: Icons.settings_rounded, gradient: BrandGradients.slate),
          const SyntheticBanner(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
              SectionHeader(l.settingsLanguage, padding: const EdgeInsets.fromLTRB(6, 18, 6, 8)),
              SoftCard(margin: EdgeInsets.zero, child: const LanguageSwitch(key: Key('language'))),
              group(l.tutorialTitle, [
                tile(
                  key: const Key('settings-howto'),
                  icon: Icons.school_rounded,
                  color: FeatureColors.bills,
                  title: l.homeHowTo,
                  onTap: () => push(TutorialScreen(onDone: () => Navigator.of(context).pop())),
                ),
              ]),
              group(l.settingsFactory, [
                tile(
                  icon: Icons.factory_rounded,
                  color: FeatureColors.carbon,
                  title: profile?.name ?? l.settingsFactory,
                  subtitle: (profile?.location ?? '').isEmpty ? null : Text(profile!.location),
                  onTap: profile == null ? null : () => push(OnboardingScreen(existing: profile)),
                ),
              ]),
              group(l.settingsServer, [
                tile(
                  key: const Key('server-settings'),
                  icon: health.hasError ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                  color: health.hasError ? scheme.error : FeatureColors.import,
                  title: l.serverSettingsTitle,
                  threeLine: true,
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(server.apiBaseUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                    serverStatus,
                  ]),
                  trailing: IconButton(tooltip: l.actionRetry, icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.invalidate(healthProvider)),
                  onTap: () => push(const ServerScreen()),
                ),
              ]),
              group(l.privacyTitle, [
                SwitchListTile(
                  secondary: const IconBlob(Icons.image_outlined, color: FeatureColors.bills, size: 40),
                  title: Text(l.settingsKeepImages, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l.settingsKeepImagesHint),
                  value: keep,
                  onChanged: (v) => ref.read(keepImagesProvider.notifier).set(v),
                ),
                tile(icon: Icons.privacy_tip_rounded, color: FeatureColors.carbon, title: l.settingsDataHandling, onTap: () => push(const DataHandlingScreen())),
                tile(icon: Icons.rule_rounded, color: FeatureColors.settings, title: l.settingsLimitations, onTap: () => push(const LimitationsScreen())),
              ]),
              group(l.settingsExport, [
                tile(
                  icon: Icons.dataset_rounded,
                  color: FeatureColors.import,
                  title: l.exportRaw,
                  onTap: () async {
                    try {
                      await ref.read(exportServiceProvider).exportRawCsv();
                    } catch (e) {
                      if (context.mounted) showSnack(context, errorText(l, e));
                    }
                  },
                ),
              ]),
              group(l.backupGroup, [
                tile(
                  key: const Key('backup-save'),
                  icon: Icons.backup_rounded,
                  color: FeatureColors.carbon,
                  title: l.backupSave,
                  subtitle: Text(l.backupSaveHint),
                  threeLine: true,
                  onTap: () async {
                    try {
                      final json = await admin.backupJson();
                      final day = DateTime.now().toIso8601String().substring(0, 10);
                      await ref.read(exportServiceProvider).shareText(json, 'billtogreen-backup-$day.json', 'application/json');
                    } catch (e) {
                      if (context.mounted) showSnack(context, errorText(l, e));
                    }
                  },
                ),
                tile(
                  key: const Key('backup-restore'),
                  icon: Icons.settings_backup_restore_rounded,
                  color: FeatureColors.import,
                  title: l.backupRestore,
                  subtitle: Text(l.backupRestoreHint),
                  onTap: () => restoreFromFile(context, ref),
                ),
              ]),
              group(l.settingsLoadDemo, [
                tile(
                  key: const Key('load-demo'),
                  icon: Icons.science_rounded,
                  color: FeatureColors.production,
                  title: l.settingsLoadDemo,
                  subtitle: Text(l.settingsLoadDemoHint),
                  onTap: () async {
                    final result = await admin.loadDemo();
                    if (context.mounted) showSnack(context, result == DemoLoadResult.loaded ? l.demoLoaded : l.demoNeedsEmpty);
                  },
                ),
                if (synthetic)
                  tile(
                    key: const Key('remove-demo'),
                    icon: Icons.layers_clear_rounded,
                    color: FeatureColors.waste,
                    title: l.settingsRemoveDemo,
                    onTap: () async {
                      await admin.removeDemo();
                      if (context.mounted) showSnack(context, l.demoRemoved);
                    },
                  ),
              ]),
              const SizedBox(height: 24),
              SoftCard(
                key: const Key('delete-all'),
                margin: EdgeInsets.zero,
                color: scheme.errorContainer.withValues(alpha: 0.35),
                borderColor: scheme.error.withValues(alpha: 0.3),
                onTap: () async {
                  final ok = await confirmDialog(context, title: l.deleteAllConfirmTitle, body: l.deleteAllConfirmBody, confirm: l.actionDelete, destructive: true);
                  if (!ok) return;
                  await admin.deleteAll();
                  if (context.mounted) showSnack(context, l.deleteAllDone);
                },
                child: Row(children: [
                  IconBlob(Icons.delete_forever_rounded, color: scheme.error, size: 40),
                  const SizedBox(width: 14),
                  Expanded(child: Text(l.settingsDeleteAll, style: TextStyle(color: scheme.error, fontWeight: FontWeight.w700))),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Picks a backup file, shows what it holds and replaces all local data after confirmation.
Future<void> restoreFromFile(BuildContext context, WidgetRef ref, {Future<String?> Function()? readFile}) async {
  final l = AppLocalizations.of(context);
  final String? text;
  try {
    text = readFile != null
        ? await readFile()
        : await () async {
            final files = await FilePicker.pickFiles(type: FileType.any);
            if (files.isEmpty) return null;
            return utf8.decode(await files.first.readAsBytes(), allowMalformed: true);
          }();
  } catch (e) {
    if (context.mounted) showSnack(context, errorText(l, e));
    return;
  }
  if (text == null || !context.mounted) return;
  final ParsedBackup backup;
  try {
    backup = parseBackup(text);
  } on BackupException catch (e) {
    showSnack(context, switch (e.error) {
      BackupError.notABackup => l.backupNotABackup,
      BackupError.newerVersion => l.backupNewer,
      BackupError.damaged => l.backupDamaged,
    });
    return;
  }
  final fmt = Fmt.of(context);
  final ok = await confirmDialog(
    context,
    title: l.backupRestoreConfirmTitle,
    body: l.backupRestoreConfirmBody(
      fmt.date(backup.createdAt),
      backup.factoryName ?? '-',
      backup.bills.length,
      backup.billMonths,
      backup.actions.length,
      backup.solarPlans.length,
    ),
    confirm: l.backupRestore,
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  await ref.read(dataAdminProvider).restore(backup);
  if (context.mounted) showSnack(context, l.backupRestored);
}
