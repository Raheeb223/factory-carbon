import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../domain/image_prep.dart';
import '../../domain/private_text.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'text_finder.dart';

/// Covers names and addresses before the photo is sent. Text on the photo is read on
/// the phone ([finder]) and name/address lines get black boxes automatically; the user
/// checks them, taps a box to remove it, or drags to cover more. The boxes are burned
/// into the pixels on the phone; only the covered photo is returned (and sent).
class RedactScreen extends StatefulWidget {
  const RedactScreen({super.key, required this.imageBytes, this.redactor, this.finder});
  final Uint8List imageBytes;

  /// Finds names/addresses automatically (none when null).
  final TextFinder? finder;

  /// Test hook: burns the boxes in (defaults to a background isolate).
  final Future<Uint8List> Function(Uint8List bytes, List<RedactBox> boxes)? redactor;

  @override
  State<RedactScreen> createState() => _RedactScreenState();
}

class _RedactScreenState extends State<RedactScreen> {
  final _boxes = <RedactBox>[];
  Size? _imageSize;
  Offset? _start;
  Offset? _current;
  bool _busy = false;
  bool _scanning = false;

  /// Boxes added automatically (null until the scan finished or when there is no finder).
  int? _autoCount;

  @override
  void initState() {
    super.initState();
    _readSize();
  }

  Future<void> _readSize() async {
    final ui.Image image = await decodeImageFromList(widget.imageBytes);
    if (!mounted) return;
    final width = image.width;
    final height = image.height;
    setState(() {
      _imageSize = Size(width.toDouble(), height.toDouble());
      _scanning = widget.finder != null;
    });
    image.dispose();
    final finder = widget.finder;
    if (finder == null) return;
    var found = <RedactBox>[];
    try {
      found = privateBoxes(await finder.lines(widget.imageBytes, width: width, height: height));
    } catch (e, st) {
      debugPrint('Finding names failed: $e\n$st'); // the user can still cover them by hand
    }
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _autoCount = found.length;
      _boxes.insertAll(0, found);
    });
  }

  /// A tap on a black box removes it (e.g. one that hides a value we need).
  void _tap(Offset at, Size size) {
    final x = at.dx / size.width;
    final y = at.dy / size.height;
    final i = _boxes.lastIndexWhere((b) => x >= b.left && x <= b.right && y >= b.top && y <= b.bottom);
    if (i >= 0) setState(() => _boxes.removeAt(i));
  }

  /// Normalised (0..1) box from two points inside a [size]-sized drawing area.
  RedactBox _box(Offset a, Offset b, Size size) {
    double nx(double v) => (v / size.width).clamp(0.0, 1.0);
    double ny(double v) => (v / size.height).clamp(0.0, 1.0);
    return RedactBox(nx(a.dx < b.dx ? a.dx : b.dx), ny(a.dy < b.dy ? a.dy : b.dy), nx(a.dx > b.dx ? a.dx : b.dx), ny(a.dy > b.dy ? a.dy : b.dy));
  }

  void _finishDrag(Size size) {
    final a = _start;
    final b = _current;
    setState(() {
      _start = null;
      _current = null;
      if (a == null || b == null) return;
      final box = _box(a, b, size);
      // Ignore accidental taps: a box must be at least ~1.5% of the photo in each direction.
      if (box.right - box.left > 0.015 && box.bottom - box.top > 0.015) _boxes.add(box);
    });
  }

  Future<void> _done() async {
    setState(() => _busy = true);
    final bytes = widget.imageBytes;
    final boxes = List<RedactBox>.of(_boxes);
    try {
      final out = boxes.isEmpty ? bytes : await (widget.redactor ?? _burnIn)(bytes, boxes);
      if (mounted) Navigator.of(context).pop(out);
    } catch (e, st) {
      debugPrint('Redaction failed: $e\n$st');
      if (!mounted) return;
      setState(() => _busy = false);
      showSnack(context, AppLocalizations.of(context).errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final size = _imageSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.redactTitle),
        actions: [
          IconButton(
            key: const Key('redact-undo'),
            tooltip: l.actionUndo,
            onPressed: _boxes.isEmpty || _busy ? null : () => setState(_boxes.removeLast),
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: l.actionClear,
            onPressed: _boxes.isEmpty || _busy ? null : () => setState(_boxes.clear),
            icon: const Icon(Icons.layers_clear_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SoftCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(12),
                color: scheme.primary.withValues(alpha: 0.06),
                borderColor: scheme.primary.withValues(alpha: 0.2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBlob(Icons.draw_rounded, color: scheme.primary, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_scanning)
                            Row(children: [
                              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(l.redactScanning, style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
                            ])
                          else if (_autoCount != null)
                            Text(
                              key: const Key('redact-auto'),
                              _autoCount! > 0 ? l.redactAutoFound(_autoCount!) : l.redactAutoNone,
                              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: _autoCount! > 0 ? const Color(0xFF16A34A) : null),
                            ),
                          if (_scanning || _autoCount != null) const SizedBox(height: 2),
                          Text(l.redactHint, style: t.bodySmall?.copyWith(height: 1.35)),
                          const SizedBox(height: 2),
                          Text(l.redactKeepVisible, style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: size == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: size.width / size.height,
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final area = box.biggest;
                              final live = _start != null && _current != null ? _box(_start!, _current!, area) : null;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  key: const Key('redact-canvas'),
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: _busy ? null : (d) => setState(() => _start = _current = d.localPosition),
                                  onPanUpdate: _busy ? null : (d) => setState(() => _current = d.localPosition),
                                  onPanEnd: _busy ? null : (_) => _finishDrag(area),
                                  onTapUp: _busy ? null : (d) => _tap(d.localPosition, area),
                                  child: CustomPaint(
                                    foregroundPainter: _BoxesPainter(_boxes, live, scheme.primary),
                                    child: Image.memory(widget.imageBytes, fit: BoxFit.fill, gaplessPlayback: true),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      StatusPill(
                        key: const Key('redact-count'),
                        text: l.redactAreas(_boxes.length),
                        color: _boxes.isEmpty ? scheme.outline : const Color(0xFF16A34A),
                        icon: _boxes.isEmpty ? Icons.visibility_outlined : Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 8),
                      if (_boxes.isEmpty) Expanded(child: Text(l.redactNothing, style: t.bodySmall)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    key: const Key('redact-done'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    onPressed: _busy || _scanning || size == null ? null : _done,
                    icon: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.document_scanner_rounded),
                    label: Text(_busy ? l.redactPreparing : l.redactSend),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-level so the isolate closure captures only the bytes and boxes, never the
/// widget state (which cannot be sent to another isolate).
Future<Uint8List> _burnIn(Uint8List bytes, List<RedactBox> boxes) => Isolate.run(() => applyRedactions(bytes, boxes));

class _BoxesPainter extends CustomPainter {
  _BoxesPainter(this.boxes, this.live, this.accent);
  final List<RedactBox> boxes;
  final RedactBox? live;
  final Color accent;

  Rect _rect(RedactBox b, Size s) => Rect.fromLTRB(b.left * s.width, b.top * s.height, b.right * s.width, b.bottom * s.height);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.black;
    for (final b in boxes) {
      canvas.drawRect(_rect(b, size), fill);
    }
    final l = live;
    if (l != null) {
      final r = _rect(l, size);
      canvas.drawRect(r, Paint()..color = Colors.black.withValues(alpha: 0.6));
      canvas.drawRect(
        r,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_BoxesPainter old) => true;
}
