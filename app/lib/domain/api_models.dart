/// DTOs for the backend /v1 API (contract: docs/openapi.json).
library;

import 'models.dart';

double? _d(Object? v) => v == null ? null : (v as num).toDouble();
List<String> _strings(Object? v) => (v as List<dynamic>? ?? const []).map((e) => e as String).toList();
Map<String, dynamic> _map(Object? v) => (v as Map<dynamic, dynamic>? ?? const {}).cast<String, dynamic>();

// ------------------------------------------------------------------ extraction

class ExtractedBill {
  const ExtractedBill({
    required this.billType,
    this.utilityName,
    this.billingMonth,
    this.periodStart,
    this.periodEnd,
    this.consumedUnits,
    this.unit,
    this.totalAmountBdt,
    this.tariffCode,
    this.sanctionedLoadKw,
    this.fieldConfidence = const {},
    this.notes,
  });

  factory ExtractedBill.fromJson(Map<String, dynamic> j) => ExtractedBill(
        billType: BillType.parse(j['bill_type'] as String?),
        utilityName: j['utility_name'] as String?,
        billingMonth: j['billing_month'] as String?,
        periodStart: j['period_start'] == null ? null : DateTime.parse(j['period_start'] as String),
        periodEnd: j['period_end'] == null ? null : DateTime.parse(j['period_end'] as String),
        consumedUnits: _d(j['consumed_units']),
        unit: EnergyUnit.parse(j['unit'] as String?),
        totalAmountBdt: _d(j['total_amount_bdt']),
        tariffCode: j['tariff_code'] as String?,
        sanctionedLoadKw: _d(j['sanctioned_load_kw']),
        fieldConfidence: _map(j['field_confidence']).map((k, v) => MapEntry(k, v as String)),
        notes: j['notes'] as String?,
      );

  /// An empty bill for manual entry (nothing extracted).
  static const ExtractedBill empty = ExtractedBill(billType: BillType.unknown);

  final BillType billType;
  final String? utilityName;
  final String? billingMonth;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double? consumedUnits;
  final EnergyUnit? unit;
  final double? totalAmountBdt;
  final String? tariffCode;
  final double? sanctionedLoadKw;
  final Map<String, String> fieldConfidence;
  final String? notes;
}

class ExtractionWarning {
  const ExtractionWarning({required this.field, required this.code, required this.message});
  factory ExtractionWarning.fromJson(Map<String, dynamic> j) =>
      ExtractionWarning(field: j['field'] as String?, code: j['code'] as String, message: j['message'] as String);
  final String? field;
  final String code;
  final String message;
}

class ExtractBillResult {
  const ExtractBillResult({required this.bill, required this.warnings, required this.model, required this.promptVersion});
  factory ExtractBillResult.fromJson(Map<String, dynamic> j) => ExtractBillResult(
        bill: ExtractedBill.fromJson(_map(j['bill'])),
        warnings: (j['warnings'] as List<dynamic>).map((e) => ExtractionWarning.fromJson(_map(e))).toList(),
        model: j['model'] as String,
        promptVersion: j['prompt_version'] as String,
      );
  final ExtractedBill bill;
  final List<ExtractionWarning> warnings;
  final String model;
  final String promptVersion;
}

// ------------------------------------------------------------------ shared

class FactorInfo {
  const FactorInfo({required this.name, required this.value, required this.unit, required this.source, required this.year, required this.status, this.notes, this.gases});
  factory FactorInfo.fromJson(Map<String, dynamic> j) => FactorInfo(
        name: j['name'] as String,
        value: _d(j['value']),
        unit: j['unit'] as String,
        source: j['source'] as String? ?? '',
        year: j['year'] as int?,
        status: j['status'] as String,
        notes: j['notes'] as String?,
        gases: j['gases'] as String?,
      );
  final String name;
  final double? value;
  final String unit;
  final String source;
  final int? year;
  final String status;
  final String? notes;

  /// Which gases the factor covers ("CO2 only" or "CO2e ...").
  final String? gases;

  bool get isPlaceholder => status == 'PLACEHOLDER';
}

class DataQualityNote {
  const DataQualityNote({required this.code, required this.message, required this.months});
  factory DataQualityNote.fromJson(Map<String, dynamic> j) =>
      DataQualityNote(code: j['code'] as String, message: j['message'] as String, months: _strings(j['months']));
  final String code;
  final String message;
  final List<String> months;
}

// ------------------------------------------------------------------ carbon

class MonthEmissions {
  const MonthEmissions({
    required this.month,
    this.electricityKwh,
    this.dieselLitres,
    this.gasM3,
    this.scope2ElectricityT,
    this.scope1DieselT,
    this.scope1GasT,
    this.scope1T,
    this.scope2T,
    this.totalT,
    required this.isComplete,
    required this.missing,
    this.productionUnits,
    this.intensity,
  });

  factory MonthEmissions.fromJson(Map<String, dynamic> j) => MonthEmissions(
        month: j['month'] as String,
        electricityKwh: _d(j['electricity_kwh']),
        dieselLitres: _d(j['diesel_litres']),
        gasM3: _d(j['gas_m3']),
        scope2ElectricityT: _d(j['scope2_electricity_t']),
        scope1DieselT: _d(j['scope1_diesel_t']),
        scope1GasT: _d(j['scope1_gas_t']),
        scope1T: _d(j['scope1_t']),
        scope2T: _d(j['scope2_t']),
        totalT: _d(j['total_t']),
        isComplete: j['is_complete'] as bool,
        missing: _strings(j['missing']),
        productionUnits: _d(j['production_units']),
        intensity: _d(j['intensity_t_per_1000_units']),
      );

  final String month;
  final double? electricityKwh;
  final double? dieselLitres;
  final double? gasM3;
  final double? scope2ElectricityT;
  final double? scope1DieselT;
  final double? scope1GasT;
  final double? scope1T;
  final double? scope2T;
  final double? totalT;
  final bool isComplete;
  final List<String> missing;
  final double? productionUnits;
  final double? intensity;
}

class CarbonTotals {
  const CarbonTotals({this.scope1T, this.scope2T, this.totalT, this.productionUnits, this.intensity, required this.monthsInPeriod, required this.monthsWithData, required this.completeMonths});
  factory CarbonTotals.fromJson(Map<String, dynamic> j) => CarbonTotals(
        scope1T: _d(j['scope1_t']),
        scope2T: _d(j['scope2_t']),
        totalT: _d(j['total_t']),
        productionUnits: _d(j['production_units']),
        intensity: _d(j['intensity_t_per_1000_units']),
        monthsInPeriod: j['months_in_period'] as int,
        monthsWithData: j['months_with_data'] as int,
        completeMonths: j['complete_months'] as int,
      );
  final double? scope1T;
  final double? scope2T;
  final double? totalT;
  final double? productionUnits;
  final double? intensity;
  final int monthsInPeriod;
  final int monthsWithData;
  final int completeMonths;
}

class CalculationError {
  const CalculationError({required this.code, required this.factor, required this.message});
  factory CalculationError.fromJson(Map<String, dynamic> j) =>
      CalculationError(code: j['code'] as String, factor: j['factor'] as String, message: j['message'] as String);
  final String code;
  final String factor;
  final String message;
}

class CarbonResult {
  const CarbonResult({
    required this.periodStart,
    required this.periodEnd,
    required this.months,
    required this.totals,
    required this.factors,
    required this.placeholdersInUse,
    required this.errors,
    required this.notes,
    required this.methodology,
  });

  factory CarbonResult.fromJson(Map<String, dynamic> j) => CarbonResult(
        periodStart: j['period_start'] as String?,
        periodEnd: j['period_end'] as String?,
        months: (j['months'] as List<dynamic>).map((e) => MonthEmissions.fromJson(_map(e))).toList(),
        totals: CarbonTotals.fromJson(_map(j['totals'])),
        factors: _map(j['factors']).map((k, v) => MapEntry(k, FactorInfo.fromJson(_map(v)))),
        placeholdersInUse: _strings(j['placeholders_in_use']),
        errors: (j['errors'] as List<dynamic>).map((e) => CalculationError.fromJson(_map(e))).toList(),
        notes: (j['data_quality_notes'] as List<dynamic>).map((e) => DataQualityNote.fromJson(_map(e))).toList(),
        methodology: _strings(j['methodology']),
      );

  final String? periodStart;
  final String? periodEnd;
  final List<MonthEmissions> months;
  final CarbonTotals totals;
  final Map<String, FactorInfo> factors;
  final List<String> placeholdersInUse;
  final List<CalculationError> errors;
  final List<DataQualityNote> notes;
  final List<String> methodology;
}

// ------------------------------------------------------------------ waste

class WasteMonth {
  const WasteMonth({
    required this.month,
    required this.actualKwh,
    this.production,
    this.expectedKwh,
    this.lowerKwh,
    this.upperKwh,
    required this.flagged,
    this.excessKwh,
    this.excessPct,
    this.excessCostBdt,
    this.kwhPerUnit,
    this.expectedKwhPerUnit,
  });
  factory WasteMonth.fromJson(Map<String, dynamic> j) => WasteMonth(
        month: j['month'] as String,
        actualKwh: _d(j['actual_kwh'])!,
        production: _d(j['production']),
        expectedKwh: _d(j['expected_kwh']),
        lowerKwh: _d(j['lower_kwh']),
        upperKwh: _d(j['upper_kwh']),
        flagged: j['flagged'] as bool,
        excessKwh: _d(j['excess_kwh']),
        excessPct: _d(j['excess_pct']),
        excessCostBdt: _d(j['excess_cost_bdt']),
        kwhPerUnit: _d(j['kwh_per_unit']),
        expectedKwhPerUnit: _d(j['expected_kwh_per_unit']),
      );
  final String month;
  final double actualKwh;
  final double? production;
  final double? expectedKwh;
  final double? lowerKwh;
  final double? upperKwh;
  final bool flagged;
  final double? excessKwh;
  final double? excessPct;
  final double? excessCostBdt;

  /// Electricity per unit produced this month, and what was expected for it.
  final double? kwhPerUnit;
  final double? expectedKwhPerUnit;
}

/// A practical check for a flagged month (code is localized by the app).
class Inspection {
  const Inspection({required this.code, required this.title, required this.detail});
  factory Inspection.fromJson(Map<String, dynamic> j) =>
      Inspection(code: j['code'] as String, title: j['title'] as String, detail: j['detail'] as String);
  final String code;
  final String title;
  final String detail;
}

class WasteResult {
  const WasteResult({
    required this.status,
    this.method,
    required this.monthCount,
    required this.requiredMonths,
    required this.months,
    required this.flaggedMonths,
    this.avgBdtPerKwh,
    required this.messages,
    this.baselineKwhPerUnit,
    this.inspections = const [],
  });
  factory WasteResult.fromJson(Map<String, dynamic> j) => WasteResult(
        status: j['status'] as String,
        method: j['method'] as String?,
        monthCount: j['month_count'] as int,
        requiredMonths: j['required_months'] as int,
        months: (j['months'] as List<dynamic>).map((e) => WasteMonth.fromJson(_map(e))).toList(),
        flaggedMonths: _strings(j['flagged_months']),
        avgBdtPerKwh: _d(j['avg_bdt_per_kwh']),
        messages: _strings(j['messages']),
        baselineKwhPerUnit: _d(j['baseline_kwh_per_unit']),
        inspections: ((j['inspections'] as List<dynamic>?) ?? const []).map((e) => Inspection.fromJson(_map(e))).toList(),
      );
  final String status;
  final String? method;
  final int monthCount;
  final int requiredMonths;
  final List<WasteMonth> months;
  final List<String> flaggedMonths;
  final double? avgBdtPerKwh;
  final List<String> messages;

  /// Typical kWh per unit produced in the months that were not flagged.
  final double? baselineKwhPerUnit;
  final List<Inspection> inspections;

  bool get insufficient => status == 'insufficient_data';
  bool get usesProduction => method == 'ols_production';
}

// ------------------------------------------------------------------ solar

class SolarParamUsed {
  const SolarParamUsed({required this.name, required this.value, required this.unit, required this.origin, this.status, required this.source});
  factory SolarParamUsed.fromJson(Map<String, dynamic> j) => SolarParamUsed(
        name: j['name'] as String,
        value: j['value'],
        unit: j['unit'] as String,
        origin: j['origin'] as String,
        status: j['status'] as String?,
        source: j['source'] as String? ?? '',
      );
  final String name;
  final Object? value;
  final String unit;
  final String origin;
  final String? status;
  final String source;

  double? get number => value is num ? (value as num).toDouble() : null;
  bool get isPlaceholder => status == 'PLACEHOLDER';
}

class SolarDefaults {
  const SolarDefaults({required this.params, required this.netMetering, required this.disclaimer});
  factory SolarDefaults.fromJson(Map<String, dynamic> j) => SolarDefaults(
        params: (j['params'] as List<dynamic>).map((e) => SolarParamUsed.fromJson(_map(e))).toList(),
        netMetering: j['net_metering'] as bool,
        disclaimer: j['disclaimer'] as String,
      );
  final List<SolarParamUsed> params;
  final bool netMetering;
  final String disclaimer;

  SolarParamUsed? param(String name) {
    for (final p in params) {
      if (p.name == name) return p;
    }
    return null;
  }
}

class SolarWarning {
  const SolarWarning({required this.code, required this.message, this.value});
  factory SolarWarning.fromJson(Map<String, dynamic> j) =>
      SolarWarning(code: j['code'] as String, message: j['message'] as String, value: _d(j['value']));
  final String code;
  final String message;
  final double? value;
}

class CashFlowYear {
  const CashFlowYear({required this.year, required this.cumulativeBdt, required this.netBdt});
  factory CashFlowYear.fromJson(Map<String, dynamic> j) =>
      CashFlowYear(year: j['year'] as int, cumulativeBdt: _d(j['cumulative_bdt'])!, netBdt: _d(j['net_bdt'])!);
  final int year;
  final double cumulativeBdt;
  final double netBdt;
}

class SolarFinancials {
  const SolarFinancials({required this.capexBdt, required this.priceBdtPerKwh, required this.year1SavingsBdt, required this.year1OmBdt, required this.year1NetBdt, this.paybackYears, required this.cashflow});
  factory SolarFinancials.fromJson(Map<String, dynamic> j) => SolarFinancials(
        capexBdt: _d(j['capex_bdt'])!,
        priceBdtPerKwh: _d(j['electricity_price_bdt_per_kwh'])!,
        year1SavingsBdt: _d(j['year1_savings_bdt'])!,
        year1OmBdt: _d(j['year1_om_bdt'])!,
        year1NetBdt: _d(j['year1_net_bdt'])!,
        paybackYears: _d(j['simple_payback_years']),
        cashflow: (j['cashflow'] as List<dynamic>).map((e) => CashFlowYear.fromJson(_map(e))).toList(),
      );
  final double capexBdt;
  final double priceBdtPerKwh;
  final double year1SavingsBdt;
  final double year1OmBdt;
  final double year1NetBdt;
  final double? paybackYears;
  final List<CashFlowYear> cashflow;
}

class SolarResult {
  const SolarResult({
    required this.raw,
    required this.roofAreaM2,
    required this.usableAreaM2,
    required this.kwp,
    required this.peakSunHoursMonthly,
    required this.peakSunHoursAnnualAvg,
    required this.irradianceSource,
    required this.monthlyGenerationKwh,
    required this.annualGenerationKwh,
    this.annualConsumptionKwh,
    this.selfConsumedKwh,
    this.offsetShare,
    this.co2AvoidedT,
    this.financials,
    required this.params,
    required this.factors,
    required this.warnings,
    required this.disclaimer,
  });

  factory SolarResult.fromJson(Map<String, dynamic> j) => SolarResult(
        raw: j,
        roofAreaM2: _d(j['roof_area_m2'])!,
        usableAreaM2: _d(j['usable_area_m2'])!,
        kwp: _d(j['kwp'])!,
        peakSunHoursMonthly: (j['peak_sun_hours_monthly'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        peakSunHoursAnnualAvg: _d(j['peak_sun_hours_annual_avg'])!,
        irradianceSource: j['irradiance_source'] as String,
        monthlyGenerationKwh: (j['monthly_generation_kwh'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        annualGenerationKwh: _d(j['annual_generation_kwh'])!,
        annualConsumptionKwh: _d(j['annual_consumption_kwh']),
        selfConsumedKwh: _d(j['self_consumed_kwh']),
        offsetShare: _d(j['offset_share']),
        co2AvoidedT: _d(j['co2_avoided_t_per_year']),
        financials: j['financials'] == null ? null : SolarFinancials.fromJson(_map(j['financials'])),
        params: (j['params_used'] as List<dynamic>).map((e) => SolarParamUsed.fromJson(_map(e))).toList(),
        factors: _map(j['factors']).map((k, v) => MapEntry(k, FactorInfo.fromJson(_map(v)))),
        warnings: (j['warnings'] as List<dynamic>).map((e) => e is String ? SolarWarning(code: 'text', message: e) : SolarWarning.fromJson(_map(e))).toList(),
        disclaimer: j['disclaimer'] as String,
      );

  /// Original JSON, kept for persistence and for the PDF report request.
  final Map<String, dynamic> raw;
  final double roofAreaM2;
  final double usableAreaM2;
  final double kwp;
  final List<double> peakSunHoursMonthly;
  final double peakSunHoursAnnualAvg;
  final String irradianceSource;
  final List<double> monthlyGenerationKwh;
  final double annualGenerationKwh;
  final double? annualConsumptionKwh;
  final double? selfConsumedKwh;
  final double? offsetShare;
  final double? co2AvoidedT;
  final SolarFinancials? financials;
  final List<SolarParamUsed> params;
  final Map<String, FactorInfo> factors;
  final List<SolarWarning> warnings;
  final String disclaimer;
}

class HealthInfo {
  const HealthInfo({required this.geminiConfigured, required this.placeholders});
  factory HealthInfo.fromJson(Map<String, dynamic> j) =>
      HealthInfo(geminiConfigured: j['gemini_configured'] as bool, placeholders: _strings(j['placeholders']));
  final bool geminiConfigured;
  final List<String> placeholders;
}
