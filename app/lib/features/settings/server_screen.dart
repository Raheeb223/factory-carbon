import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../widgets/common.dart';

/// Lets the user point the app at a backend without rebuilding (e.g. a laptop on
/// the same Wi-Fi during testing, or a deployed HTTPS server).
class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key, this.clientFactory});

  /// Test hook: builds the client used by "Test connection".
  final ApiClient Function(AppConfig config)? clientFactory;

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  final _form = GlobalKey<FormState>();
  late final _url = TextEditingController(text: ref.read(serverConfigProvider).apiBaseUrl);
  late final _token = TextEditingController(text: ref.read(serverConfigProvider).appToken);
  bool _hideToken = true;
  bool _testing = false;
  String? _result;
  bool _ok = false;

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  AppConfig _candidate() => ref.read(serverConfigProvider).withServer(apiBaseUrl: normalizeServerUrl(_url.text), appToken: _token.text.trim());

  Future<void> _test() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _testing = true;
      _result = null;
    });
    final config = _candidate();
    final client = widget.clientFactory?.call(config) ??
        ApiClient(config, dio: Dio(BaseOptions(baseUrl: config.apiBaseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 75))));
    try {
      final h = await client.health();
      _ok = true;
      _result = h.geminiConfigured ? l.serverTestOk : '${l.serverTestOk} ${l.serverExtractionOff}';
    } catch (e) {
      _ok = false;
      _result = errorText(l, e);
    }
    if (mounted) setState(() => _testing = false);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    await ref.read(serverConfigProvider.notifier).save(normalizeServerUrl(_url.text), _token.text.trim());
    ref.invalidate(healthProvider);
    if (!mounted) return;
    showSnack(context, l.serverSaved);
    Navigator.of(context).pop();
  }

  Future<void> _reset() async {
    await ref.read(serverConfigProvider.notifier).save(null, null);
    ref.invalidate(healthProvider);
    final c = ref.read(serverConfigProvider);
    setState(() {
      _url.text = c.apiBaseUrl;
      _token.text = c.appToken;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.serverSettingsTitle)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(l.serverHelp)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('server-url'),
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(labelText: l.serverUrlLabel, hintText: l.serverUrlHint, prefixIcon: const Icon(Icons.dns_outlined)),
            validator: (v) => normalizeServerUrl(v ?? '') == null ? l.serverInvalidUrl : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('server-token'),
            controller: _token,
            obscureText: _hideToken,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l.serverTokenLabel,
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                icon: Icon(_hideToken ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hideToken = !_hideToken),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('server-test'),
            onPressed: _testing ? null : _test,
            icon: _testing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_tethering),
            label: Text(l.serverTest),
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                Icon(_ok ? Icons.check_circle : Icons.error_outline, color: _ok ? Colors.green.shade700 : scheme.error),
                const SizedBox(width: 8),
                Expanded(child: Text(_result!, key: const Key('server-result'))),
              ]),
            ),
          const SizedBox(height: 24),
          FilledButton(key: const Key('server-save'), onPressed: _save, child: Text(l.actionSave)),
          const SizedBox(height: 8),
          TextButton(onPressed: _reset, child: Text(l.serverReset)),
        ]),
      ),
    );
  }
}
