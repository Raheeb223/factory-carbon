/// Bulk history import (spec 8.4): parse + validate a filled-in CSV template.
library;

import 'package:csv/csv.dart';

import 'models.dart';

const historyColumns = ['month', 'electricity_kwh', 'diesel_litres', 'gas_m3', 'production_units', 'electricity_cost_bdt'];
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
  const ImportRow({required this.month, this.electricityKwh, this.dieselLitres, this.gasM3, this.productionUnits, this.electricityCostBdt});
  final String month;
  final double? electricityKwh;
  final double? dieselLitres;
  final double? gasM3;
  final double? productionUnits;
  final double? electricityCostBdt;
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

    final row = ImportRow(
      month: month,
      electricityKwh: number('electricity_kwh'),
      dieselLitres: number('diesel_litres'),
      gasM3: number('gas_m3'),
      productionUnits: number('production_units'),
      electricityCostBdt: idx['electricity_cost_bdt']! >= 0 ? number('electricity_cost_bdt') : null,
    );
    if (!rowOk) continue;
    if ([row.electricityKwh, row.dieselLitres, row.gasM3, row.productionUnits].every((v) => v == null)) {
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
    if (r.productionUnits != null) production.add((r.month, r.productionUnits!));
  }
  return (bills: bills, production: production);
}
