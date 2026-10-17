/// Bulk history import (spec 8.4): parse + validate a filled-in CSV template.
library;

import 'package:csv/csv.dart';

import 'models.dart';

const historyColumns = ['month', 'electricity_kwh', 'diesel_litres', 'gas_m3', 'production_units', 'electricity_cost_bdt', 'lpg_kg', 'furnace_oil_litres'];

/// Only these are required; the others (cost, LPG, furnace oil) are read when present,
/// so files made from older templates still import.
const _requiredColumns = ['month', 'electricity_kwh', 'diesel_litres', 'gas_m3', 'production_units'];

enum ImportIssueCode { missingColumns, noRows, badMonth, badNumber, negativeNumber, duplicateMonth, emptyRow, costWithoutKwh }

class ImportIssue {
  const ImportIssue(this.code, {this.row, this.column, this.value});
  final ImportIssueCode code;

  /// 1-based line number in the file (header = 1).
  final int? row;
  final String? column;
  final String? value;
}

class ImportRow {
  const ImportRow({
    required this.month,
    this.electricityKwh,
    this.dieselLitres,
    this.gasM3,
    this.productionUnits,
    this.electricityCostBdt,
    this.lpgKg,
    this.furnaceOilLitres,
  });
  final String month;
  final double? electricityKwh;
  final double? dieselLitres;
  final double? gasM3;
  final double? productionUnits;
  final double? electricityCostBdt;
  final double? lpgKg;
  final double? furnaceOilLitres;
}

class ImportPreview {
  const ImportPreview({required this.rows, required this.errors, required this.warnings});
  final List<ImportRow> rows;
  final List<ImportIssue> errors;
  final List<ImportIssue> warnings;

  bool get canImport => errors.isEmpty && rows.isNotEmpty;
}

const _banglaDigits = '০১২৩৪৫৬৭৮৯';

String normalizeDigits(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = _banglaDigits.indexOf(ch);
    b.write(i >= 0 ? '$i' : ch);
  }
  return b.toString();
}

ImportPreview parseHistoryCsv(String text) {
  final errors = <ImportIssue>[];
  final warnings = <ImportIssue>[];
  final rows = <ImportRow>[];
  final cleaned = text.startsWith('﻿') ? text.substring(1) : text;
  final table = Csv(skipEmptyLines: true).decode(cleaned);
  if (table.isEmpty) {
    return const ImportPreview(rows: [], errors: [ImportIssue(ImportIssueCode.noRows)], warnings: []);
  }
  final header = table.first.map((h) => h.toString().trim().toLowerCase()).toList();
  final missing = _requiredColumns.where((c) => !header.contains(c)).toList();
  if (missing.isNotEmpty) {
    return ImportPreview(rows: const [], errors: [ImportIssue(ImportIssueCode.missingColumns, row: 1, value: missing.join(', '))], warnings: const []);
  }
  final idx = {for (final c in historyColumns) c: header.indexOf(c)};
  final seen = <String>{};

  for (var r = 1; r < table.length; r++) {
    final line = r + 1;
    final cells = table[r];
    String cell(String col) {
      final i = idx[col]!;
      return i >= 0 && i < cells.length ? normalizeDigits(cells[i].toString().trim()) : '';
    }

    if (cells.every((c) => c.toString().trim().isEmpty)) continue;
    final month = cell('month');
    if (!isValidMonth(month)) {
      errors.add(ImportIssue(ImportIssueCode.badMonth, row: line, column: 'month', value: month));
      continue;
    }
    if (!seen.add(month)) {
      errors.add(ImportIssue(ImportIssueCode.duplicateMonth, row: line, column: 'month', value: month));
      continue;
    }
    var rowOk = true;
    double? number(String col) {
      final raw = cell(col).replaceAll(',', '');
      if (raw.isEmpty) return null;
      final v = double.tryParse(raw);
      if (v == null || !v.isFinite) {
        errors.add(ImportIssue(ImportIssueCode.badNumber, row: line, column: col, value: raw));
        rowOk = false;
        return null;
      }
      if (v < 0) {
        errors.add(ImportIssue(ImportIssueCode.negativeNumber, row: line, column: col, value: raw));
        rowOk = false;
        return null;
      }
      return v;
    }

    double? optional(String col) => idx[col]! >= 0 ? number(col) : null;

    final row = ImportRow(
      month: month,
      electricityKwh: number('electricity_kwh'),
      dieselLitres: number('diesel_litres'),
      gasM3: number('gas_m3'),
      productionUnits: number('production_units'),
      electricityCostBdt: optional('electricity_cost_bdt'),
      lpgKg: optional('lpg_kg'),
      furnaceOilLitres: optional('furnace_oil_litres'),
    );
    if (!rowOk) continue;
    if ([row.electricityKwh, row.dieselLitres, row.gasM3, row.lpgKg, row.furnaceOilLitres, row.productionUnits].every((v) => v == null)) {
      warnings.add(ImportIssue(ImportIssueCode.emptyRow, row: line, value: month));
      continue;
    }
    if (row.electricityCostBdt != null && row.electricityKwh == null) {
      warnings.add(ImportIssue(ImportIssueCode.costWithoutKwh, row: line, column: 'electricity_cost_bdt', value: month));
    }
    rows.add(row);
  }
  if (rows.isEmpty && errors.isEmpty) errors.add(const ImportIssue(ImportIssueCode.noRows));
  rows.sort((a, b) => a.month.compareTo(b.month));
  return ImportPreview(rows: rows, errors: errors, warnings: warnings);
}

/// Converts validated rows into bills + production entries marked as imported.
({List<Bill> bills, List<(String, double)> production}) importRowsToData(List<ImportRow> rows, {required String Function() newId, DateTime? now}) {
  final t = now ?? DateTime.now();
  final bills = <Bill>[];
  final production = <(String, double)>[];
  Bill make(String month, BillType type, double qty, EnergyUnit unit, double? amount) => Bill(
        id: newId(),
        billType: type,
        billingMonth: month,
        consumedUnits: qty,
        unit: unit,
        origin: DataOrigin.imported,
        confirmedAt: t,
        createdAt: t,
        updatedAt: t,
        totalAmountBdt: amount,
      );
  for (final r in rows) {
    if (r.electricityKwh != null) bills.add(make(r.month, BillType.electricity, r.electricityKwh!, EnergyUnit.kWh, r.electricityCostBdt));
    if (r.dieselLitres != null) bills.add(make(r.month, BillType.diesel, r.dieselLitres!, EnergyUnit.litre, null));
    if (r.gasM3 != null) bills.add(make(r.month, BillType.gas, r.gasM3!, EnergyUnit.m3, null));
    if (r.lpgKg != null) bills.add(make(r.month, BillType.lpg, r.lpgKg!, EnergyUnit.kg, null));
    if (r.furnaceOilLitres != null) bills.add(make(r.month, BillType.furnaceOil, r.furnaceOilLitres!, EnergyUnit.litre, null));
    if (r.productionUnits != null) production.add((r.month, r.productionUnits!));
  }
  return (bills: bills, production: production);
}

/// A value in the file that is already on the phone for the same month.
/// [kind] is a [BillType] name or 'production'.
typedef ImportOverlap = ({String month, String kind});

/// What an import will do, given the data already on the phone.
///
/// Entries the user made from a bill photo or typed in are never overwritten: the
/// file's value for that month and type is skipped. Earlier imported (or demo) values
/// are replaced, so importing the same file twice does not double the totals.
class ImportPlan {
  const ImportPlan({required this.bills, required this.production, required this.replaceBillIds, required this.skipped, required this.replaced});
  final List<Bill> bills;
  final List<(String, double)> production;

  /// Existing bills to remove because the file replaces them.
  final List<String> replaceBillIds;
  final List<ImportOverlap> skipped;
  final List<ImportOverlap> replaced;
}

bool _replaceable(DataOrigin o) => o == DataOrigin.imported || o == DataOrigin.demo;

ImportPlan planImport(
  List<ImportRow> rows, {
  required List<Bill> existingBills,
  required List<ProductionEntry> existingProduction,
  required String Function() newId,
  DateTime? now,
}) {
  final data = importRowsToData(rows, newId: newId, now: now);
  final bills = <Bill>[];
  final replaceIds = <String>[];
  final skipped = <ImportOverlap>[];
  final replaced = <ImportOverlap>[];
  for (final b in data.bills) {
    final same = existingBills.where((e) => e.billType == b.billType && e.billingMonth == b.billingMonth).toList();
    final overlap = (month: b.billingMonth, kind: b.billType.wire);
    if (same.any((e) => !_replaceable(e.origin))) {
      skipped.add(overlap);
      continue;
    }
    if (same.isNotEmpty) {
      replaced.add(overlap);
      replaceIds.addAll(same.map((e) => e.id));
    }
    bills.add(b);
  }
  final production = <(String, double)>[];
  for (final (month, units) in data.production) {
    final same = existingProduction.where((p) => p.month == month).toList();
    final overlap = (month: month, kind: 'production');
    if (same.any((p) => !_replaceable(p.origin))) {
      skipped.add(overlap);
      continue;
    }
    if (same.isNotEmpty) replaced.add(overlap);
    production.add((month, units));
  }
  return ImportPlan(bills: bills, production: production, replaceBillIds: replaceIds, skipped: skipped, replaced: replaced);
}
