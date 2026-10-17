import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../domain/target.dart';
import '../../widgets/auto_run.dart';
import '../../widgets/ui.dart';
import 'target_controller.dart';

/// The factory's CO2 reduction target and progress, or an invitation to set one.
class TargetCard extends ConsumerWidget {
  const TargetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(factoryProvider).value;
    final bills = ref.watch(billsProvider).value ?? const [];
    if (profile == null || bills.isEmpty) return const SizedBox.shrink();
    final target = profile.target;
    final unit = unitLabel(l, profile.productionUnitLabel);
    final control = ref.watch(targetControllerProvider);
    final hash = ref.watch(targetInputHashProvider);
    final shown = ref.watch(targetProgressProvider);

    if (target == null) {
      return SoftCard(
        key: const Key('target-card'),
        color: FeatureColors.carbon.withValues(alpha: 0.06),
        borderColor: FeatureColors.carbon.withValues(alpha: 0.25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const IconBlob(Icons.flag_circle_rounded, color: FeatureColors.carbon, size: 38),
            const SizedBox(width: 12),
            Expanded(child: Text(l.targetSetTitle, style: tt.titleMedium)),
          ]),
          const SizedBox(height: 8),
          Text(l.targetSetBody(fmt.number(sbtiAnnualPct, decimals: 1)), style: tt.bodyMedium),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const Key('target-set'),
            onPressed: () => showTargetSheet(context, ref),
            icon: const Icon(Icons.flag_rounded),
            label: Text(l.targetSetButton),
          ),
        ]),
      );
    }

    final p = shown?.progress;
    final (statusText, statusColor, statusIcon) = switch (p?.status) {
      TargetStatus.onTrack => (l.targetOnTrack, const Color(0xFF16A34A), Icons.check_circle_rounded),
      TargetStatus.behind => (l.targetBehind, const Color(0xFFDC2626), Icons.warning_rounded),
      _ => (l.targetNoData, scheme.outline, Icons.hourglass_empty_rounded),
    };
    String pct(double v) => v >= 0 ? l.compareDown(fmt.number(v)) : l.compareUp(fmt.number(-v));

    return AutoRun(
      trigger: hash,
      enabled: hash.isNotEmpty && (shown == null || shown.stale) && !control.isLoading,
      run: ref.read(targetControllerProvider.notifier).refresh,
      child: SoftCard(
        key: const Key('target-card'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const IconBlob(Icons.flag_circle_rounded, color: FeatureColors.carbon, size: 38),
            const SizedBox(width: 12),
            Expanded(child: Text(l.targetTitle, style: tt.titleMedium)),
            IconButton(key: const Key('target-edit'), tooltip: l.targetEdit, onPressed: () => showTargetSheet(context, ref), icon: const Icon(Icons.edit_rounded)),
          ]),
          Text(
            l.targetLine(fmt.number(target.pct), target.perUnit ? l.targetMetricPerUnit(unit) : l.targetMetricTotal, '${target.year}', '${target.baselineYear}'),
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (control.isLoading && p == null) const LinearProgressIndicator(),
          if (control.hasError && !control.isLoading) Text(errorText(l, control.error!), style: TextStyle(color: scheme.error)),
          if (p != null) ...[
            StatusPill(key: const Key('target-status'), text: statusText, color: statusColor, icon: statusIcon),
            const SizedBox(height: 10),
            if (p.achievedPct != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: target.pct <= 0 ? 1 : (p.achievedPct! / target.pct).clamp(0.0, 1.0),
                  minHeight: 10,
                  color: statusColor,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 8),
              Text(p.achievedPct!.abs() < 0.5 ? l.targetNowSame : l.targetNow(pct(p.achievedPct!)), key: const Key('target-now'), style: tt.bodyMedium),
              Text(l.targetNeeded(fmt.number(p.neededNowPct)), style: tt.bodySmall),
            ] else
              Text(l.targetNoDataHint('${target.baselineYear}'), style: tt.bodySmall),
            if (p.incompleteData) ...[
              const SizedBox(height: 4),
              Text(l.compareGaps, style: tt.bodySmall?.copyWith(color: Colors.orange.shade900)),
            ],
          ],
        ]),
      ),
    );
  }
}

/// Bottom sheet to set, change or remove the reduction target.
Future<void> showTargetSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _TargetSheet(),
    );

class _TargetSheet extends ConsumerStatefulWidget {
  const _TargetSheet();

  @override
  ConsumerState<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends ConsumerState<_TargetSheet> {
  late final ReductionTarget? _old = ref.read(factoryProvider).value?.target;
  late final List<int> _years = baselineYears([for (final b in ref.read(billsProvider).value ?? const <Bill>[]) b.billingMonth]);
  late String _metric = _old?.metric ?? (ref.read(productionProvider).value?.isNotEmpty ?? false ? 'intensity' : 'total');
  late int _baseline = _old?.baselineYear ?? (_years.length > 1 ? _years[1] : _years.first);
  late int _year = _old?.year ?? (_baseline + 5);
  late final _pct = TextEditingController(text: _old == null ? '' : Fmt('en').number(_old.pct));

  @override
  void dispose() {
    _pct.dispose();
    super.dispose();
  }

  double? get _pctValue {
    final v = parseNumber(_pct.text);
    return v == null || v <= 0 || v > 100 ? null : v;
  }

  Future<void> _save() async {
    final pct = _pctValue;
    if (pct == null) return;
    await ref.read(targetControllerProvider.notifier).setTarget(ReductionTarget(metric: _metric, pct: pct, baselineYear: _baseline, year: _year));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final unit = unitLabel(l, ref.watch(factoryProvider).value?.productionUnitLabel);
    final targetYears = [for (var y = _baseline + 1; y <= _baseline + 15; y++) y];
    if (!targetYears.contains(_year)) _year = targetYears[4];
    final sbti = sbtiPct(_baseline, _year);
    final pctOptions = {10.0, 20.0, 30.0, sbti.roundToDouble()}.toList()..sort();

    Widget label(String t) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(t, style: tt.titleSmall));

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(l.targetSheetTitle, style: tt.titleLarge),
          label(l.targetWhat),
          SegmentedButton<String>(
            key: const Key('target-metric'),
            segments: [
              ButtonSegment(value: 'intensity', label: Text(l.targetPerUnitShort(unit))),
              ButtonSegment(value: 'total', label: Text(l.targetTotalShort)),
            ],
            selected: {_metric},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _metric = s.first),
          ),
          if (_metric == 'intensity')
            Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.targetPerUnitHint(unit), style: tt.bodySmall)),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                label(l.targetBaseline),
                DropdownButtonFormField<int>(
                  key: const Key('target-baseline'),
                  initialValue: _baseline,
                  items: [for (final y in _years) DropdownMenuItem(value: y, child: Text('$y'))],
                  onChanged: (v) => setState(() => _baseline = v ?? _baseline),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                label(l.targetBy),
                DropdownButtonFormField<int>(
                  key: ValueKey('target-year-$_baseline'),
                  initialValue: _year,
                  items: [for (final y in targetYears) DropdownMenuItem(value: y, child: Text('$y'))],
                  onChanged: (v) => setState(() => _year = v ?? _year),
                ),
              ]),
            ),
          ]),
          label(l.targetHowMuch),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final v in pctOptions)
              ChoiceChip(
                key: Key('target-pct-${v.round()}'),
                label: Text(v == sbti.roundToDouble() ? l.targetSbtiChip(fmt.number(v)) : '${fmt.number(v)}%'),
                selected: _pctValue == v,
                onSelected: (_) => setState(() => _pct.text = Fmt('en').number(v)),
              ),
          ]),
          const SizedBox(height: 10),
          TextField(
            key: const Key('target-pct'),
            controller: _pct,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.০-৯]'))],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l.targetPctLabel, suffixText: '%'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.targetSbtiHint(fmt.number(sbtiAnnualPct, decimals: 1), fmt.number(sbti)), style: tt.bodySmall),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('target-save'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: _pctValue == null ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(l.actionSave),
          ),
          if (_old != null)
            TextButton(
              key: const Key('target-remove'),
              onPressed: () async {
                await ref.read(targetControllerProvider.notifier).setTarget(null);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l.targetRemove),
            ),
        ]),
      ),
    );
  }
}
