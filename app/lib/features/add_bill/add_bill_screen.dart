import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import 'image_service.dart';
import 'review_screen.dart';
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

    // Reminder before the native crop UI, which cannot show long text.
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.crop),
        title: Text(l.cropTitle),
        content: Text(l.cropReminder),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionContinue)),
        ],
      ),
    );
    if (proceed != true || !mounted) {
      await images.deleteTemp([picked]);
      return;
    }
    final cropped = await images.crop(picked, title: l.cropTitle, toolbarColor: Theme.of(context).colorScheme.primary);
    if (cropped == null || !mounted) {
      await images.deleteTemp([picked]); // crop cancelled: nothing is uploaded
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await images.loadPreparedAndDeleteTemp([picked, cropped]);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => UploadScreen(imageBytes: bytes)));
    } catch (e) {
      if (mounted) showSnack(context, l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _manual() => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ReviewScreen(extraction: null, warnings: [], imageBytes: null, extracted: ExtractedBill.empty)),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.addBillTitle)),
      body: _busy
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(l.preparingImage)]))
          : ListView(padding: const EdgeInsets.all(16), children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: scheme.primaryContainer, child: Icon(Icons.document_scanner_outlined, color: scheme.onPrimaryContainer)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.addBillScanTitle, style: Theme.of(context).textTheme.titleMedium)),
                    ]),
                    const SizedBox(height: 8),
                    Text(l.addBillScanHint),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const Key('add-camera'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: () => _fromImage(camera: true),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l.addBillCamera),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      key: const Key('add-gallery'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: () => _fromImage(camera: false),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l.addBillGallery),
                    ),
                    const SizedBox(height: 12),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.shield_outlined, size: 18, color: scheme.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l.cropReminder, style: Theme.of(context).textTheme.bodySmall)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  key: const Key('add-manual'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(backgroundColor: scheme.secondaryContainer, child: Icon(Icons.edit_note, color: scheme.onSecondaryContainer)),
                  title: Text(l.addBillManual),
                  subtitle: Text(l.addBillManualHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _manual,
                ),
              ),
            ]),
    );
  }
}
