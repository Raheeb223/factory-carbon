import 'package:flutter/widgets.dart';

/// Runs [run] once after the frame whenever [trigger] changes while [enabled], so a
/// screen brings its result up to date by itself instead of waiting for a button.
/// A failed run is not repeated for the same [trigger]; the screen shows its retry button.
class AutoRun extends StatefulWidget {
  const AutoRun({super.key, required this.trigger, required this.enabled, required this.run, required this.child});

  /// Identifies the input (e.g. a hash of the request); a new value allows a new run.
  final String trigger;
  final bool enabled;
  final Future<void> Function() run;
  final Widget child;

  @override
  State<AutoRun> createState() => _AutoRunState();
}

class _AutoRunState extends State<AutoRun> {
  String? _ranFor;

  void _maybeRun() {
    if (!widget.enabled || _ranFor == widget.trigger) return;
    _ranFor = widget.trigger;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.run();
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeRun();
    return widget.child;
  }
}
