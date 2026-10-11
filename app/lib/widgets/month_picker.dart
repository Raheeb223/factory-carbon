import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../domain/models.dart';

/// Dialog to pick a month (returns `YYYY-MM`), localized month names.
Future<String?> showMonthPicker(BuildContext context, {String? initial}) {
  final now = DateTime.now();
  final init = isValidMonth(initial) ? DateTime(int.parse(initial!.substring(0, 4)), int.parse(initial.substring(5, 7))) : DateTime(now.year, now.month);
  return showDialog<String>(context: context, builder: (_) => _MonthPickerDialog(initial: init, selected: isValidMonth(initial) ? initial : null));
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.initial, required this.selected});
  final DateTime initial;
  final String? selected;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l.pickMonth),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 320,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            IconButton(tooltip: l.previousYear, onPressed: () => setState(() => _year--), icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(DateFormat.y(locale).format(DateTime(_year)), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            ),
            IconButton(
              tooltip: l.nextYear,
              onPressed: _year >= now.year ? null : () => setState(() => _year++),
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            childAspectRatio: 2.1,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var m = 1; m <= 12; m++)
                Builder(builder: (context) {
                  final value = '${_year.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}';
                  final future = DateTime(_year, m).isAfter(DateTime(now.year, now.month));
                  final selected = value == widget.selected;
                  final label = DateFormat.MMM(locale).format(DateTime(_year, m));
                  return selected
                      ? FilledButton(key: Key('month-$value'), onPressed: () => Navigator.pop(context, value), child: Text(label))
                      : OutlinedButton(
                          key: Key('month-$value'),
                          style: OutlinedButton.styleFrom(foregroundColor: scheme.onSurface, padding: EdgeInsets.zero),
                          onPressed: future ? null : () => Navigator.pop(context, value),
                          child: Text(label),
                        );
                }),
            ],
          ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionCancel))],
    );
  }
}

/// Form field showing a month ("May 2024") that opens [showMonthPicker] on tap.
class MonthFormField extends FormField<String> {
  MonthFormField({
    super.key,
    required String label,
    super.initialValue,
    required ValueChanged<String?> onChanged,
    super.validator,
  }) : super(
          builder: (state) {
            final context = state.context;
            final fmt = Fmt.of(context);
            final l = AppLocalizations.of(context);
            final v = state.value;
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showMonthPicker(context, initial: v);
                if (picked != null) {
                  state.didChange(picked);
                  onChanged(picked);
                }
              },
              child: InputDecorator(
                isEmpty: v == null || v.isEmpty,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                ),
                child: Text(v == null || v.isEmpty ? '' : (isValidMonth(v) ? fmt.monthLong(v) : '$v · ${l.invalidMonth}')),
              ),
            );
          },
        );
}
