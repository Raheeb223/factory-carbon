import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';

/// Reads text aloud with the phone's own text-to-speech voice (works offline once the
/// voice is installed), so people who find reading hard can listen instead.
class Speech {
  Speech._();
  static final instance = Speech._();

  FlutterTts? _tts;

  /// The text being spoken right now, or null.
  final speaking = ValueNotifier<String?>(null);

  FlutterTts _engine() {
    final existing = _tts;
    if (existing != null) return existing;
    final tts = FlutterTts()
      ..setCompletionHandler(() => speaking.value = null)
      ..setCancelHandler(() => speaking.value = null)
      ..setErrorHandler((_) => speaking.value = null);
    return _tts = tts;
  }

  /// Speaks [text] in the app's language. False when the phone has no voice for it.
  Future<bool> speak(String text, Locale locale) async {
    try {
      final tts = _engine();
      await tts.stop();
      final candidates = locale.languageCode == 'bn' ? const ['bn-BD', 'bn-IN', 'bn'] : const ['en-US', 'en-GB', 'en'];
      String? language;
      for (final c in candidates) {
        if (await tts.isLanguageAvailable(c) == true) {
          language = c;
          break;
        }
      }
      if (language == null) return false;
      await tts.setLanguage(language);
      await tts.setSpeechRate(0.42); // a little slower than normal, easier to follow
      speaking.value = text;
      // "CO₂" with a subscript is read oddly by some voices; bullets are not read at all.
      await tts.speak(text.replaceAll('₂', '2').replaceAll('•', ''));
      return true;
    } catch (e) {
      debugPrint('Text-to-speech failed: $e');
      speaking.value = null;
      return false;
    }
  }

  Future<void> stop() async {
    speaking.value = null;
    try {
      await _tts?.stop();
    } catch (_) {
      // Nothing to stop.
    }
  }
}

/// "Listen" / "Stop" button that reads [text] aloud.
class ListenButton extends StatefulWidget {
  const ListenButton({super.key, required this.text, this.onDark = false, this.onStarted});
  final String text;
  final bool onDark;

  /// Called after speaking started (the tutorial uses it to keep reading the next pages).
  final VoidCallback? onStarted;

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  final _speech = Speech.instance;

  @override
  void dispose() {
    if (_speech.speaking.value == widget.text) _speech.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speech.speaking.value == widget.text) {
      await _speech.stop();
      return;
    }
    final l = AppLocalizations.of(context);
    final ok = await _speech.speak(widget.text, Localizations.localeOf(context));
    if (!mounted) return;
    if (ok) {
      widget.onStarted?.call();
    } else {
      showSnack(context, l.tutorialNoVoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: _speech.speaking,
      builder: (context, now, _) {
        final playing = now == widget.text;
        final icon = Icon(playing ? Icons.stop_circle_rounded : Icons.volume_up_rounded, size: 26);
        final label = Text(playing ? l.tutorialStop : l.tutorialListen, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));
        if (widget.onDark) {
          return OutlinedButton.icon(
            key: const Key('listen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              minimumSize: const Size(170, 52),
              shape: const StadiumBorder(),
            ),
            onPressed: _toggle,
            icon: icon,
            label: label,
          );
        }
        return FilledButton.tonalIcon(
          key: const Key('listen'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: _toggle,
          icon: icon,
          label: label,
        );
      },
    );
  }
}
