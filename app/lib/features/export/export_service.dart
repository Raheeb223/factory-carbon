import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/csv_export.dart';
import '../../domain/loan.dart';
import '../carbon/carbon_controller.dart';

/// Builds export files and hands them to the system share sheet (spec 6.5, 8.8).
/// Files go to a temp "exports" folder that is cleared before each export.
class ExportService {
  ExportService(this._ref);
  final Ref _ref;

  Future<Directory> _exportDir() async {
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'exports'));
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> shareBytes(Uint8List bytes, String filename, String mime) async {
    final file = File(p.join((await _exportDir()).path, filename));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mime)], title: filename));
  }

  Future<void> shareText(String text, String filename, String mime) => shareBytes(Uint8List.fromList(utf8.encode(text)), filename, mime);

  /// Request body for /v1/report/pdf from local data (+ the latest solar plan result, if any).
  Future<Map<String, dynamic>> pdfRequest() async {
    final bills = await _ref.read(billRepositoryProvider).all();
    final production = await _ref.read(productionRepositoryProvider).all();
    final profile = await _ref.read(factoryRepositoryProvider).get();
    final plans = _ref.read(solarPlansProvider).value ?? const [];
    final withResult = plans.where((p) => p.resultJson != null).toList();
    return {
      'factory': {
        'name': profile?.name ?? 'Factory',
        'location': (profile?.location.isEmpty ?? true) ? null : profile!.location,
        if (profile?.facilityType != null) 'facility_type': profile!.facilityType,
        // English district name: the report is in English for buyers.
        if (profile?.district != null && profile!.district != 'other') 'district': profile.district![0].toUpperCase() + profile.district!.substring(1),
        if (profile?.workers != null) 'workers': profile!.workers,
        if (profile?.shiftsPerDay != null) 'shifts_per_day': profile!.shiftsPerDay,
      },
      'carbon': carbonRequests(
        bills: bills,
        production: production,
        productionUnitLabel: profile?.productionUnitLabel,
        period: _ref.read(reportPeriodProvider),
      ).current,
      'solar': withResult.isEmpty ? null : withResult.first.resultJson,
      'contains_synthetic_data': bills.any((b) => b.isSynthetic) || production.any((p) => p.isSynthetic),
    };
  }

  Future<void> exportPdf() async {
    final bytes = await _ref.read(apiClientProvider).reportPdf(await pdfRequest());
    await shareBytes(bytes, 'ghg-report.pdf', 'application/pdf');
  }

  /// Bank summary for [solar] (a solar plan result) financed on [terms].
  Future<void> exportLoanPdf(Map<String, dynamic> solar, LoanTerms terms) async {
    final body = {...await pdfRequest(), 'solar': solar, 'loan': terms.toJson()};
    final bytes = await _ref.read(apiClientProvider).loanPdf(body);
    await shareBytes(bytes, 'green-loan-summary.pdf', 'application/pdf');
  }

  Future<({String url, DateTime issuedOn})> createPassport() async => _ref.read(apiClientProvider).passport(await pdfRequest());

  Future<void> exportEmissionsCsv(CarbonResult result) =>
      shareText(emissionsCsv(result, containsSynthetic: _ref.read(containsSyntheticProvider)), 'ghg-monthly.csv', 'text/csv');

  Future<void> exportRawCsv() async {
    final bills = await _ref.read(billRepositoryProvider).all();
    final production = await _ref.read(productionRepositoryProvider).all();
    await shareText(rawDataCsv(bills, production), 'factory-energy-data.csv', 'text/csv');
  }
}

final exportServiceProvider = Provider<ExportService>(ExportService.new);
