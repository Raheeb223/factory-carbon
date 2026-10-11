import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'image_service.dart';
import 'redact_screen.dart';
import 'review_screen.dart';
import 'text_finder.dart';
import 'upload_screen.dart';

/// Step 1 of spec 8.2: capture or pick an image (or go manual), then crop.
class AddBillScreen extends ConsumerStatefulWidget {
  const AddBillScreen({super.key});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  bool _busy = false;

  Future<bool> _ensureUploadNotice() async {
    final settings = ref.read(settingsStoreProvider);
    if (settings.uploadNoticeAcknowledged) return true;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.uploadNoticeTitle),
        content: Text(l.uploadNoticeBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(key: const Key('upload-notice-accept'), onPressed: () => Navigator.pop(ctx, true), child: Text(l.uploadNoticeAccept)),
        ],
      ),
    );
    if (ok == true) await settings.setUploadNoticeAcknowledged(true);
    return ok == true;
  }

  Future<void> _fromImage({required bool camera}) async {
    if (!await _ensureUploadNotice() || !mounted) return;
    final l = AppLocalizations.of(context);
    final images = ref.read(imageServiceProvider);
    final picked = await images.pick(camera: camera);
    if (picked == null || !mounted) return;

    // Cropping is optional: names are hidden automatically in the next step.
    final wantsCrop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.crop),
        title: Text(l.cropTitle),
        content: Text(l.cropReminder),
        actions: [
          TextButton(key: const Key('crop-yes'), onPressed: () => Navigator.pop(ctx, true), child: Text(l.cropYes)),
          FilledButton(key: const Key('crop-skip'), onPressed: () => Navigator.pop(ctx, false), child: Text(l.cropSkip)),
        ],
      ),
    );
    if (wantsCrop == null || !mounted) {
      await images.deleteTemp([picked]); // dialog dismissed: nothing is uploaded
      return;
    }
    String? cropped;
    if (wantsCrop) {
      cropped = await images.crop(picked, title: l.cropTitle, toolbarColor: Theme.of(context).colorScheme.primary);
      if (cropped == null || !mounted) {
        await images.deleteTemp([picked]); // crop cancelled: nothing is uploaded
        return;
      }
    }
    setState(() => _busy = true);
    try {
      final bytes = await images.loadPreparedAndDeleteTemp([picked, ?cropped]);
      if (!mounted) return;
      setState(() => _busy = false);
      // Names/addresses are covered automatically there; the user checks and can cover more.
      final covered = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(builder: (_) => RedactScreen(imageBytes: bytes, finder: ref.read(textFinderProvider))));
      if (covered == null || !mounted) return; // backed out: nothing is uploaded
      await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => UploadScreen(imageBytes: covered)));
    } catch (e) {
      if (mounted) showSnack(context, l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _manual() => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => const ReviewScreen(extraction: null, warnings: [], imageBytes: null, extracted: ExtractedBill.empty),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget option({required Key key, required IconData icon, required String label, required Gradient gradient, required VoidCallback onTap}) => Expanded(
      child: GradientSurface(
        inkKey: key,
        gradient: gradient,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );

    Widget tip(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: t.bodyMedium)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.addBillTitle)),
      body: _busy
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(l.preparingImage)]),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                FadeSlideIn(
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconBlob(Icons.document_scanner_rounded, color: FeatureColors.bills, size: 48),
                            const SizedBox(width: 14),
                            Expanded(child: Text(l.addBillScanTitle, style: t.titleLarge)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(l.addBillScanHint, style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            option(
                              key: const Key('add-camera'),
                              icon: Icons.photo_camera_rounded,
                              label: l.addBillCamera,
                              gradient: BrandGradients.bills,
                              onTap: () => _fromImage(camera: true),
                            ),
                            const SizedBox(width: 12),
                            option(
                              key: const Key('add-gallery'),
                              icon: Icons.photo_library_rounded,
                              label: l.addBillGallery,
                              gradient: BrandGradients.primary,
                              onTap: () => _fromImage(camera: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l.addBillOr, style: t.labelLarge?.copyWith(color: scheme.outline)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                SoftCard(
                  key: const Key('add-manual'),
                  onTap: _manual,
                  child: Row(
                    children: [
                      const IconBlob(Icons.edit_note_rounded, color: FeatureColors.production, size: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.addBillManual, style: t.titleSmall),
                            const SizedBox(height: 2),
                            Text(l.addBillManualHint, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: scheme.outline),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SoftCard(
                  color: scheme.primary.withValues(alpha: 0.05),
                  borderColor: scheme.primary.withValues(alpha: 0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.addBillTipsTitle, style: t.titleSmall),
                      const SizedBox(height: 6),
                      tip(Icons.wb_sunny_outlined, l.addBillTip1),
                      tip(Icons.crop_free_rounded, l.addBillTip2),
                      tip(Icons.shield_outlined, l.addBillTip3),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
