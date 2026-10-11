import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';

/// What is stored on the phone, sent to the backend, and sent to Google (spec 8.8).
class DataHandlingScreen extends StatelessWidget {
  const DataHandlingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget section(IconData icon, String title, String body) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(icon), const SizedBox(width: 8), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium))]),
              const SizedBox(height: 8),
              Text(body),
            ]),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.dataHandlingTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        section(Icons.phone_android, l.dataHandlingPhoneTitle, l.dataHandlingPhoneBody),
        section(Icons.dns_outlined, l.dataHandlingServerTitle, l.dataHandlingServerBody),
        section(Icons.auto_awesome_outlined, l.dataHandlingGoogleTitle, l.dataHandlingGoogleBody),
        section(Icons.wb_sunny_outlined, l.dataHandlingNasaTitle, l.dataHandlingNasaBody),
      ]),
    );
  }
}

/// Known limitations (spec 11), also listed in the README.
class LimitationsScreen extends StatelessWidget {
  const LimitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.limitationsTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [Text(l.limitationsBody)]),
    );
  }
}
