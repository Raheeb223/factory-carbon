import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/inputs.dart';
import '../../widgets/month_picker.dart';

/// Monthly production entry (spec 8.3). One value per month.
class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {ProductionEntry? entry}) async {
    final unit = unitLabel(AppLocalizations.of(context), ref.read(factoryProvider).value?.productionUnitLabel);
    final result = await showDialog<(String, double)>(
      context: context,
      builder: (_) => _ProductionDialog(entry: entry, unit: unit),
    );
    if (result != null) {
      await ref.read(productionRepositoryProvider).upsertMonth(result.$1, result.$2, DataOrigin.manual);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final unit = unitLabel(l, ref.watch(factoryProvider).value?.productionUnitLabel);
    final entries = ref.watch(productionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.productionTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-production',
        key: const Key('production-add'),
        tooltip: l.productionAdd,
        backgroundColor: FeatureColors.production,
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.productionAdd),
      ),
      body: Column(
        children: [
          const SyntheticBanner(),
          Expanded(
            child: entries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorPanel(message: l.errorGeneric),
              data: (list) => list.isEmpty
                  ? EmptyState(icon: Icons.precision_manufacturing_rounded, color: FeatureColors.production, message: l.productionEmpty)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      children: [
                        for (final p in list)
                          SoftCard(
                            padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                            onTap: () => _edit(context, ref, entry: p),
                            child: Row(
                              children: [
                                const IconBlob(Icons.precision_manufacturing_rounded, color: FeatureColors.production, size: 44),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fmt.month(p.month),
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                      Text(
                                        '${fmt.number(p.unitsProduced)} $unit',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      if (p.isSynthetic)
                                        const Padding(padding: EdgeInsets.only(top: 4), child: SyntheticBadge())
                                      else if (p.origin == DataOrigin.imported)
                                        Padding(padding: const EdgeInsets.only(top: 4), child: Badge2(originLabel(l, p.origin))),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  tooltip: l.actionDelete,
                                  onPressed: () => ref.read(productionRepositoryProvider).softDelete(p.id),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Month + units form. Owns its controller so it outlives the closing animation.
class _ProductionDialog extends StatefulWidget {
  const _ProductionDialog({required this.entry, required this.unit});
  final ProductionEntry? entry;
  final String unit;

  @override
  State<_ProductionDialog> createState() => _ProductionDialogState();
}

class _ProductionDialogState extends State<_ProductionDialog> {
  final _form = GlobalKey<FormState>();
  late String _month = widget.entry?.month ?? monthOf(DateTime.now());
  late final _units = TextEditingController(text: widget.entry == null ? '' : widget.entry!.unitsProduced.toStringAsFixed(0));

  @override
  void dispose() {
    _units.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.productionAdd),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MonthFormField(
              key: const Key('production-month'),
              label: l.productionMonth,
              initialValue: _month,
              onChanged: (v) => _month = v ?? _month,
              validator: (v) => isValidMonth(v) ? null : l.invalidMonth,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('production-units'),
              controller: _units,
              decoration: InputDecoration(labelText: l.productionUnits(widget.unit)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: numberInput,
              validator: (v) {
                final n = parseNumber(v);
                if (n == null) return l.invalidNumber;
                return n < 0 ? l.invalidNonNegative : null;
              },
            ),
            const SizedBox(height: 8),
            Text(l.productionReplaceNote, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionCancel)),
        FilledButton(
          key: const Key('production-save'),
          onPressed: () {
            if (_form.currentState!.validate()) Navigator.pop(context, (_month, parseNumber(_units.text)!));
          },
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}
