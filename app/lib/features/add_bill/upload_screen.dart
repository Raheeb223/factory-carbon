import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(l.addBillTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(height: 200, child: Image.memory(widget.imageBytes, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 24),
          switch (_phase) {
            _Phase.uploading => Column(children: [
                LinearProgressIndicator(value: _progress == 0 ? null : _progress),
                const SizedBox(height: 8),
                Text(l.uploadProgress((_progress * 100).clamp(0, 100).toStringAsFixed(0))),
              ]),
            _Phase.reading => Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(l.uploadReading, textAlign: TextAlign.center),
              ]),
            _Phase.failed => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(l.uploadFailedTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ErrorPanel(
                  message: errorText(l, _error ?? ''),
                  onRetry: _upload,
                  extra: OutlinedButton(key: const Key('upload-manual'), onPressed: _manual, child: Text(l.uploadEnterManually)),
                ),
              ]),
          },
        ]),
      ),
    );
  }
}
