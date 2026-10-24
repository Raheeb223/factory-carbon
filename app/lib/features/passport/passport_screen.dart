import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../carbon/carbon_controller.dart';
import '../export/export_service.dart';

/// A fresh signed passport link each time the screen opens (or on "Make a new one").
final passportProvider = FutureProvider.autoDispose<({String url, DateTime issuedOn})>(
  (ref) => ref.read(exportServiceProvider).createPassport(),
);

/// Carbon Passport: a QR code that opens the factory's signed carbon summary on any phone.
class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final hasBills = (ref.watch(billsProvider).value ?? const []).isNotEmpty;
    final profile = ref.watch(factoryProvider).value;
    final carbon = ref.watch(carbonResultProvider);

    Widget body;
    if (!hasBills) {
      body = SoftCard(child: Text(l.passportNeedsData, style: t.bodyLarge));
    } else {
      body = ref.watch(passportProvider).when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(l.passportMaking)]),
            ),
            error: (e, _) => SoftCard(
              color: scheme.error.withValues(alpha: 0.07),
              borderColor: scheme.error.withValues(alpha: 0.3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(errorText(l, e), style: t.bodyMedium),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(passportProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l.actionRetry),
                ),
              ]),
            ),
            data: (p) => _PassportCard(
              url: p.url,
              issued: Fmt.of(context).date(p.issuedOn),
              factory: profile?.name ?? l.appTitle,
              totalT: carbon?.result.totals.totalT,
            ),
          );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.passportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SyntheticBanner(),
          body,
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.verified_outlined, size: 20, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(l.passportWhy, style: t.bodySmall?.copyWith(height: 1.4))),
          ]),
        ],
      ),
    );
  }
}

class _PassportCard extends ConsumerWidget {
  const _PassportCard({required this.url, required this.issued, required this.factory, required this.totalT});
  final String url;
  final String issued;
  final String factory;
  final double? totalT;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GradientSurface(
        gradient: BrandGradients.primary,
        radius: 26,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(children: [
            Text(factory, textAlign: TextAlign.center, style: t.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            if (totalT != null)
              Text(l.tonnesCo2e(Fmt.of(context).tonnes(totalT)), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            // The QR stays black on white in both themes so every camera reads it.
            Container(
              key: const Key('passport-qr'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(data: url, size: 240, backgroundColor: Colors.white, errorCorrectionLevel: QrErrorCorrectLevel.L),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(child: Text(l.passportScanHint, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            Text(l.passportIssued(issued), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('passport-share'),
            onPressed: () => SharePlus.instance.share(ShareParams(text: '$factory · ${l.passportTitle}\n$url')),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(l.passportShare),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) showSnack(context, l.passportCopied);
            },
            icon: const Icon(Icons.link_rounded, size: 18),
            label: Text(l.passportCopy),
          ),
        ),
      ]),
      TextButton.icon(
        onPressed: () => ref.invalidate(passportProvider),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text(l.passportRefresh),
      ),
    ]);
  }
}
