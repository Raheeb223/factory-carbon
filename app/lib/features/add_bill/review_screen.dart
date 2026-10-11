import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/month_picker.dart';
import 'image_service.dart';

/// Mandatory human review (spec 3, 8.2). Extracted values are only stored after the
/// user ticks the confirmation box. Also used for manual entry and for editing.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({
    super.key,
    required this.extraction,
    required this.warnings,
    required this.imageBytes,
    required this.extracted,
    this.existing,
  });

  final ExtractBillResult? extraction;
  final List<ExtractionWarning> warnings;
  final Uint8List? imageBytes;
  final ExtractedBill extracted;

  /// Non-null when editing an already confirmed bill.
  final Bill? existing;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _form = GlobalKey<FormState>();
  late BillType _type;
  late EnergyUnit? _unit;
  late final TextEditingController _utility;
  String? _month;
  late final TextEditingController _units;
  late final TextEditingController _amount;
  late final TextEditingController _tariff;
  late final TextEditingController _load;
  DateTime? _start;
  DateTime? _end;
  bool _checked = false;
  bool _checkError = false;
  bool _saving = false;

  /// Values as first shown, to detect user edits.
  late final Map<String, Object?> _initial;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final x = widget.extracted;
    _type = e?.billType ?? x.billType;
    _unit = e?.unit ?? x.unit ?? _type.canonicalUnit;
    String num(double? v) => v == null ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());
    _utility = TextEditingController(text: e?.utilityName ?? x.utilityName ?? '');
    _month = e?.billingMonth ?? x.billingMonth;
    _units = TextEditingController(text: num(e?.consumedUnits ?? x.consumedUnits));
    _amount = TextEditingController(text: num(e?.totalAmountBdt ?? x.totalAmountBdt));
    _tariff = TextEditingController(text: e?.tariffCode ?? x.tariffCode ?? '');
    _load = TextEditingController(text: num(e?.sanctionedLoadKw ?? x.sanctionedLoadKw));
    _start = e?.periodStart ?? x.periodStart;
    _end = e?.periodEnd ?? x.periodEnd;
    _initial = _values();
  }

  @override
  void dispose() {
    for (final c in [_utility, _units, _amount, _tariff, _load]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _iso(DateTime? d) => d?.toIso8601String().substring(0, 10);
  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Map<String, Object?> _values() => {
        'bill_type': _type.name,
        'utility_name': _text(_utility),
        'billing_month': _month,
        'period_start': _iso(_start),
        'period_end': _iso(_end),
        'consumed_units': parseNumber(_units.text),
        'unit': _unit?.wire,
        'total_amount_bdt': parseNumber(_amount.text),
        'tariff_code': _text(_tariff),
        'sanctioned_load_kw': parseNumber(_load.text),
      };

  bool _lowConfidence(String field) =>
      (widget.existing?.fieldConfidence ?? widget.extracted.fieldConfidence)[field] == 'low';

  List<String> _warningsFor(AppLocalizations l, String field) => [
        for (final w in widget.warnings.where((w) => w.field == field)) _warningText(l, w),
      ];

  String _warningText(AppLocalizations l, ExtractionWarning w) {
    if (l.localeName.startsWith('en')) return w.message; // server text carries specific numbers
    return switch (w.code) {
      'unknown_bill_type' => l.warnUnknownBillType,
      'period_end_before_start' => l.warnPeriodEndBeforeStart,
      'unusual_period_length' => l.warnUnusualPeriodLength,
      'month_period_mismatch' => l.warnMonthPeriodMismatch,
      'units_not_positive' => l.warnUnitsNotPositive,
      'units_above_ceiling' => l.warnUnitsAboveCeiling,
      'unit_type_mismatch' => l.warnUnitTypeMismatch,
      'price_per_unit_out_of_band' => l.warnPriceOutOfBand,
      'low_confidence' => l.warnLowConfidence,
      _ => w.message,
    };
  }

  /// Expand "More details" when one of its fields was flagged by the reader.
  bool _detailsNeedAttention() {
    const details = {'utility_name', 'period_start', 'period_end', 'tariff_code', 'sanctioned_load_kw'};
    return widget.warnings.any((w) => details.contains(w.field)) || details.any(_lowConfidence);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final valid = _form.currentState!.validate();
    setState(() => _checkError = !_checked);
    if (!valid || !_checked) {
      if (valid && !_checked) showSnack(context, l.reviewMustConfirm);
      return;
    }
    final month = _month!;
    final existingBills = ref.read(billsProvider).value ?? await ref.read(billRepositoryProvider).all();
    if (!mounted) return;
    final dup = findDuplicate(existingBills, type: _type, month: month, excludeId: widget.existing?.id);
    if (dup != null) {
      final ok = await confirmDialog(
        context,
        title: l.duplicateTitle,
        body: l.duplicateBody(billTypeLabel(l, _type), Fmt.of(context).month(month)),
        confirm: l.duplicateSaveAnyway,
      );
      if (!ok || !mounted) return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final values = _values();
    final existing = widget.existing;
    final images = ref.read(imageServiceProvider);
    final List<String> edited;
    if (existing != null) {
      edited = {...existing.userEditedFields, ...editedFields(_initial, values)}.toList();
    } else if (widget.extraction != null) {
      edited = editedFields(_initial, values);
    } else {
      edited = const [];
    }
    final id = existing?.id ?? newId();
    String? imagePath = existing?.imagePath;
    if (existing == null && widget.imageBytes != null && ref.read(keepImagesProvider)) {
      imagePath = await images.keep(id, widget.imageBytes!);
    }
    final bill = Bill(
      id: id,
      billType: _type,
      billingMonth: month,
      consumedUnits: parseNumber(_units.text)!,
      unit: _unit!,
      origin: existing?.origin ?? (widget.extraction != null ? DataOrigin.billImage : DataOrigin.manual),
      confirmedAt: now,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      utilityName: _text(_utility),
      periodStart: _start,
      periodEnd: _end,
      totalAmountBdt: parseNumber(_amount.text),
      tariffCode: _text(_tariff),
      sanctionedLoadKw: parseNumber(_load.text),
      userEditedFields: edited,
      fieldConfidence: existing?.fieldConfidence ?? widget.extracted.fieldConfidence,
      extractionNotes: existing?.extractionNotes ?? widget.extracted.notes,
      extractionModel: existing?.extractionModel ?? widget.extraction?.model,
      imagePath: imagePath,
    );
    await ref.read(billRepositoryProvider).save(bill);
    if (!mounted) return;
    showSnack(context, l.billSaved);
    Navigator.of(context).pop();
  }

  Widget _wrap(String field, Widget child) {
    final l = AppLocalizations.of(context);
    final warnings = _warningsFor(l, field);
    final low = _lowConfidence(field);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        key: Key('field-$field'),
        decoration: low
            ? BoxDecoration(color: Colors.amber.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.shade700))
            : null,
        padding: low ? const EdgeInsets.all(6) : EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          child,
          if (low)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Icon(Icons.visibility_outlined, size: 14, color: Colors.amber.shade900),
                const SizedBox(width: 4),
                Expanded(child: Text(l.lowConfidence, key: Key('low-$field'), style: TextStyle(fontSize: 12, color: Colors.amber.shade900))),
              ]),
            ),
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
                const SizedBox(width: 4),
                Expanded(child: Text(w, key: Key('warn-$field'), style: TextStyle(fontSize: 12, color: scheme.error))),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _dateField(String field, String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    final fmt = Fmt.of(context);
    final l = AppLocalizations.of(context);
    return _wrap(
      field,
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 366)),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: value == null ? const Icon(Icons.calendar_today, size: 18) : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onChanged(null)),
          ),
          child: Text(value == null ? l.notSet : fmt.date(value)),
        ),
      ),
    );
  }

  Widget? _image() {
    final bytes = widget.imageBytes;
    final path = widget.existing?.imagePath;
    final Widget? img = bytes != null
        ? Image.memory(bytes, fit: BoxFit.contain)
        : (path != null && File(path).existsSync() ? Image.file(File(path), fit: BoxFit.contain) : null);
    if (img == null) return null;
    return Container(
      height: 280,
      color: Colors.black,
      child: Stack(children: [
        Positioned.fill(child: InteractiveViewer(minScale: 1, maxScale: 6, child: Center(child: img))),
        Positioned(
          right: 8,
          bottom: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.pinch_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(AppLocalizations.of(context).reviewImageHint, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final keep = ref.watch(keepImagesProvider);
    final isEdit = widget.existing != null;
    final image = _image();
    String? required(String? v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null;
    String? optionalNumber(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      final n = parseNumber(v);
      if (n == null) return l.invalidNumber;
      return n < 0 ? l.invalidNonNegative : null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editBillTitle : l.reviewTitle)),
      body: Form(
        key: _form,
        child: ListView(children: [
          ?image,
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(widget.extraction != null ? l.reviewIntro : l.reviewManualIntro),
              const SizedBox(height: 16),
              Text(l.reviewMainSection, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _wrap(
                'bill_type',
                DropdownButtonFormField<BillType>(
                  key: const Key('input-bill_type'),
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l.fieldBillType),
                  items: [for (final t in BillType.values) DropdownMenuItem(value: t, child: Text(billTypeLabel(l, t)))],
                  validator: (v) => v == null || v == BillType.unknown ? l.selectBillType : null,
                  onChanged: (v) => setState(() {
                    _type = v ?? BillType.unknown;
                    _unit = _type.canonicalUnit ?? _unit;
                  }),
                ),
              ),
              _wrap(
                'billing_month',
                MonthFormField(
                  key: const Key('input-billing_month'),
                  label: l.fieldBillingMonth,
                  initialValue: _month,
                  onChanged: (v) => setState(() => _month = v),
                  validator: (v) => isValidMonth(v) ? null : l.invalidMonth,
                ),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  flex: 3,
                  child: _wrap(
                    'consumed_units',
                    TextFormField(
                      key: const Key('input-consumed_units'),
                      controller: _units,
                      decoration: InputDecoration(labelText: l.fieldConsumedUnits),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberInput,
                      validator: (v) => required(v) ?? optionalNumber(v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _wrap(
                    'unit',
                    DropdownButtonFormField<EnergyUnit>(
                      key: const Key('input-unit'),
                      initialValue: _unit,
                      decoration: InputDecoration(labelText: l.fieldUnit),
                      items: [for (final u in EnergyUnit.values) DropdownMenuItem(value: u, child: Text(u.wire))],
                      validator: (v) {
                        if (v == null) return l.fieldRequired;
                        final expected = _type.canonicalUnit;
                        return expected != null && v != expected ? l.unitMismatch(expected.wire) : null;
                      },
                      onChanged: (v) => setState(() => _unit = v),
                    ),
                  ),
                ),
              ]),
              _wrap(
                'total_amount_bdt',
                TextFormField(
                  key: const Key('input-total_amount_bdt'),
                  controller: _amount,
                  decoration: InputDecoration(labelText: l.fieldTotalAmount, prefixText: '৳ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: numberInput,
                  validator: optionalNumber,
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  key: const Key('more-details'),
                  maintainState: true,
                  initiallyExpanded: _detailsNeedAttention(),
                  title: Text(l.reviewMoreDetails),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  children: [
                    _wrap('utility_name', TextFormField(controller: _utility, decoration: InputDecoration(labelText: l.fieldUtilityName))),
                    _dateField('period_start', l.fieldPeriodStart, _start, (d) => setState(() => _start = d)),
                    _dateField('period_end', l.fieldPeriodEnd, _end, (d) => setState(() => _end = d)),
                    _wrap('tariff_code', TextFormField(controller: _tariff, decoration: InputDecoration(labelText: l.fieldTariffCode))),
                    _wrap(
                      'sanctioned_load_kw',
                      TextFormField(
                        controller: _load,
                        decoration: InputDecoration(labelText: l.fieldSanctionedLoad),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: numberInput,
                        validator: optionalNumber,
                      ),
                    ),
                  ],
                ),
              ),
              if ((widget.existing?.extractionNotes ?? widget.extracted.notes) != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notes),
                    title: Text(l.fieldNotes),
                    subtitle: Text(widget.existing?.extractionNotes ?? widget.extracted.notes!),
                  ),
                ),
              for (final w in widget.warnings.where((w) => w.field == null))
                ListTile(leading: const Icon(Icons.warning_amber_rounded), title: Text(_warningText(l, w))),
              const SizedBox(height: 8),
              CheckboxListTile(
                key: const Key('review-confirm'),
                value: _checked,
                onChanged: (v) => setState(() {
                  _checked = v ?? false;
                  _checkError = false;
                }),
                title: Text(l.reviewConfirm),
                subtitle: _checkError ? Text(l.reviewMustConfirm, style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (!isEdit && widget.imageBytes != null)
                Text(keep ? l.imageWillBeKept : l.imageWillBeDeleted, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('review-save'),
                onPressed: (_saving || !_checked) ? null : _save,
                child: Text(l.actionSave),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ]),
      ),
    );
  }
}
