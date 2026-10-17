/// Backup and restore of all local data as one JSON file.
///
/// All user data lives only on the phone, so a lost or reset phone would lose it. The
/// backup holds the factory profile, bills, production, actions and solar plans. It
/// leaves out bill photos, cached results and app settings (including the server token).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

const backupFormat = 'billtogreen-backup';
const backupVersion = 1;

enum BackupError { notABackup, newerVersion, damaged }

class BackupException implements Exception {
  const BackupException(this.error);
  final BackupError error;

  @override
  String toString() => 'BackupException(${error.name})';
}

/// A backup file that was read and checked, ready to restore.
class ParsedBackup {
  const ParsedBackup({
    required this.createdAt,
    required this.profiles,
    required this.bills,
    required this.production,
    required this.actions,
    required this.solarPlans,
  });

  final DateTime createdAt;
  final List<FactoryProfileRow> profiles;
  final List<BillRow> bills;
  final List<ProductionRow> production;
  final List<EnergyActionRow> actions;
  final List<SolarPlanRow> solarPlans;

  String? get factoryName => profiles.isEmpty ? null : profiles.first.name;

  /// Months with at least one bill.
  int get billMonths => bills.map((b) => b.billingMonth).toSet().length;
}

/// The whole local database (active rows only) as backup JSON.
Future<String> buildBackup(AppDatabase db, {DateTime? now}) async {
  Future<List<Map<String, dynamic>>> rows<T extends Table, R extends DataClass>(TableInfo<T, R> table) async {
    final all = await db.select(table).get();
    return [
      for (final r in all)
        if ((r.toJson()['deleted'] as bool?) != true) r.toJson(),
    ];
  }

  final bills = await rows(db.bills);
  for (final b in bills) {
    b['imagePath'] = null; // photos are not in the backup
  }
  return const JsonEncoder.withIndent(' ').convert({
    'format': backupFormat,
    'version': backupVersion,
    'created_at': (now ?? DateTime.now()).toUtc().toIso8601String(),
    'factory_profiles': await rows(db.factoryProfiles),
    'bills': bills,
    'production_entries': await rows(db.productionEntries),
    'energy_actions': await rows(db.energyActions),
    'solar_plans': await rows(db.solarPlans),
  });
}

/// Reads and checks a backup file. Throws [BackupException] if it cannot be restored.
ParsedBackup parseBackup(String text) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text.startsWith('﻿') ? text.substring(1) : text);
  } on FormatException {
    throw const BackupException(BackupError.notABackup);
  }
  if (decoded is! Map<String, dynamic> || decoded['format'] != backupFormat) throw const BackupException(BackupError.notABackup);
  final version = decoded['version'];
  if (version is! int) throw const BackupException(BackupError.damaged);
  if (version > backupVersion) throw const BackupException(BackupError.newerVersion);
  try {
    List<R> list<R>(String key, R Function(Map<String, dynamic>) fromJson) =>
        [for (final e in (decoded as Map<String, dynamic>)[key] as List<dynamic>? ?? const []) fromJson(e as Map<String, dynamic>)];
    final bills = list('bills', BillRow.fromJson);
    for (final b in bills) {
      jsonDecode(b.userEditedFields) as List<dynamic>;
      jsonDecode(b.fieldConfidence) as Map<String, dynamic>;
    }
    return ParsedBackup(
      createdAt: DateTime.parse(decoded['created_at'] as String).toLocal(),
      profiles: list('factory_profiles', FactoryProfileRow.fromJson),
      bills: bills,
      production: list('production_entries', ProductionRow.fromJson),
      actions: list('energy_actions', EnergyActionRow.fromJson),
      solarPlans: list('solar_plans', SolarPlanRow.fromJson),
    );
  } catch (_) {
    throw const BackupException(BackupError.damaged);
  }
}

/// Replaces everything in the database with the backup, in one transaction.
Future<void> restoreBackup(AppDatabase db, ParsedBackup b) => db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
      await db.batch((batch) {
        batch.insertAll(db.factoryProfiles, b.profiles);
        batch.insertAll(db.bills, b.bills);
        batch.insertAll(db.productionEntries, b.production);
        batch.insertAll(db.energyActions, b.actions);
        batch.insertAll(db.solarPlans, b.solarPlans);
      });
    });
