import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../data/providers.dart';
import '../features/settings/server_screen.dart';
import 'ui.dart';

/// Explains, in plain words, when the server cannot be reached (or cannot read
/// bills), with one-tap retry and a shortcut to the server settings. Hidden when all is well.
class ConnectionCard extends ConsumerWidget {
  const ConnectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final health = ref.watch(healthProvider);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget card({required Color color, required IconData icon, required String title, required String body}) => SoftCard(
          key: const Key('connection-card'),
          color: color.withValues(alpha: 0.07),
          borderColor: color.withValues(alpha: 0.3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconBlob(icon, color: color, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: t.titleSmall?.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(body, style: t.bodySmall?.copyWith(height: 1.35)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              FilledButton.tonalIcon(
                key: const Key('connection-retry'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                onPressed: () => ref.invalidate(healthProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l.actionRetry),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ServerScreen())),
                  icon: const Icon(Icons.dns_outlined, size: 18),
                  label: Text(l.serverSettingsTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ]),
          ]),
        );

    return health.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => card(color: scheme.error, icon: Icons.cloud_off_rounded, title: l.connOfflineTitle, body: '${l.connOfflineBody}\n${errorText(l, e)}'),
      data: (h) => h.geminiConfigured
          ? const SizedBox.shrink()
          : card(color: const Color(0xFFB45309), icon: Icons.document_scanner_outlined, title: l.connOnline, body: l.serverExtractionOff),
    );
  }
}
