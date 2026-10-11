import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'review_screen.dart';

enum _Phase { uploading, reading, failed }

/// Uploads the prepared image to /v1/extract-bill. The cropped image stays in
/// memory (never on disk) until the flow ends, so "Try again" needs no re-capture.
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key, required this.imageBytes});
  final Uint8List imageBytes;

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  _Phase _phase = _Phase.uploading;
  double _progress = 0;
  Object? _error;
  CancelToken? _cancel;

  @override
  void initState() {
    super.initState();
    _upload();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Future<void> _upload() async {
    setState(() {
      _phase = _Phase.uploading;
      _progress = 0;
      _error = null;
    });
    _cancel = CancelToken();
    try {
      final result = await ref.read(apiClientProvider).extractBill(
            widget.imageBytes,
            cancelToken: _cancel,
            onSendProgress: (p) {
              if (!mounted) return;
              setState(() {
                _progress = p;
                if (p >= 1) _phase = _Phase.reading;
              });
            },
          );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => ReviewScreen(extraction: result, warnings: result.warnings, imageBytes: widget.imageBytes, extracted: result.bill),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = e;
      });
    }
  }

  void _manual() => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => ReviewScreen(extraction: null, warnings: const [], imageBytes: widget.imageBytes, extracted: ExtractedBill.empty),
      ));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final failed = _phase == _Phase.failed;
    final reading = _phase == _Phase.reading;

    Widget step(int n, String label, {required bool done, required bool active, Widget? extra}) {
      final color = done ? const Color(0xFF16A34A) : (active ? scheme.primary : scheme.outline);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 30,
            height: 30,
            child: done
                ? const CircleAvatar(backgroundColor: Color(0xFF16A34A), child: Icon(Icons.check_rounded, color: Colors.white, size: 18))
                : active && !failed
                    ? CircularProgressIndicator(strokeWidth: 3, color: color)
                    : CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Text('$n', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(label, style: t.titleSmall?.copyWith(color: active || done ? null : scheme.outline)),
              ),
              ?extra,
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.addBillTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 240,
            color: const Color(0xFF0B1220),
            child: Stack(fit: StackFit.expand, children: [
              Image.memory(widget.imageBytes, fit: BoxFit.contain),
              if (!failed) _ScanLine(color: scheme.primary),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            step(
              1,
              l.uploadStepSend,
              done: reading,
              active: _phase == _Phase.uploading,
              extra: _phase == _Phase.uploading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 6, borderRadius: BorderRadius.circular(6)),
                        const SizedBox(height: 4),
                        Text(l.uploadProgress((_progress * 100).clamp(0, 100).toStringAsFixed(0)), style: t.bodySmall),
                      ]),
                    )
                  : null,
            ),
            step(
              2,
              l.uploadStepRead,
              done: false,
              active: reading,
              extra: reading ? Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.uploadReading, style: t.bodySmall)) : null,
            ),
            step(3, l.uploadStepReview, done: false, active: false),
          ]),
        ),
        if (failed) ...[
          const SizedBox(height: 8),
          Text(l.uploadFailedTitle, style: t.titleMedium),
          ErrorPanel(
            message: errorText(l, _error ?? ''),
            onRetry: _upload,
            extra: OutlinedButton.icon(
              key: const Key('upload-manual'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: _manual,
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(l.uploadEnterManually),
            ),
          ),
        ],
      ]),
    );
  }
}

/// A glowing line sweeping over the photo while it is being read.
class _ScanLine extends StatefulWidget {
  const _ScanLine({required this.color});
  final Color color;

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => LayoutBuilder(builder: (context, box) {
            final y = Curves.easeInOut.transform(_c.value) * (box.maxHeight - 60);
            return Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: y,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.color.withValues(alpha: 0), widget.color.withValues(alpha: 0.35), widget.color.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              Positioned(left: 12, right: 12, top: y + 29, height: 2, child: ColoredBox(color: Colors.white.withValues(alpha: 0.9))),
            ]);
          }),
        ),
      );
}
