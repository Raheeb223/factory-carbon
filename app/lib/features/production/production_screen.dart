import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/month_picker.dart';

/// Monthly production entry (spec 8.3). One value per month.
class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {ProductionEntry? entry}) async {
    final l = AppLocalizations.of(context);
    final unit = ref.read(factoryProvider).value?.productionUnitLabel ?? 'pieces';
    var month = entry?.month ?? monthOf(DateTime.now());
    final units = TextEditingController(text: entry == null ? '' : entry.unitsProduced.toStringAsFixed(0));
    final form = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.productionAdd),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MonthFormField(
              key: const Key('production-month'),
              label: l.productionMonth,
              initialValue: month,
              onChanged: (v) => month = v ?? month,
              validator: (v) => isValidMonth(v) ? null : l.invalidMonth,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('production-units'),
              controller: units,
              decoration: InputDecoration(labelText: l.productionUnits(unit)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: numberInput,
              validator: (v) {
                final n = parseNumber(v);
                if (n == null) return l.invalidNumber;
                return n < 0 ? l.invalidNonNegative : null;
              },
            ),
            const SizedBox(height: 8),
            Text(l.productionReplaceNote, style: Theme.of(ctx).textTheme.bodySmall),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(
            key: const Key('production-save'),
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (saved == true) {
      await ref.read(productionRepositoryProvider).upsertMonth(month, parseNumber(units.text)!, DataOrigin.manual);
    }
    units.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final unit = ref.watch(factoryProvider).value?.productionUnitLabel ?? 'pieces';
    final entries = ref.watch(productionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.productionTitle)),
      floatingActionButton: FloatingActionButton(
        key: const Key('production-add'),
        tooltip: l.productionAdd,
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        const SyntheticBanner(),
        Expanded(
          child: entries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorPanel(message: l.errorGeneric),
            data: (list) => list.isEmpty
                ? EmptyState(icon: Icons.precision_manufacturing_outlined, message: l.productionEmpty)
                : ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                    for (final p in list)
                      ListTile(
                        title: Text(fmt.month(p.month)),
                        subtitle: Text('${fmt.number(p.unitsProduced)} $unit'),
                        leading: p.isSynthetic ? const SyntheticBadge() : (p.origin == DataOrigin.imported ? Badge2(originLabel(l, p.origin)) : null),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: l.actionDelete,
                          onPressed: () => ref.read(productionRepositoryProvider).softDelete(p.id),
                        ),
                        onTap: () => _edit(context, ref, entry: p),
                      ),
                  ]),
          ),
        ),
      ]),
    );
  }
}
