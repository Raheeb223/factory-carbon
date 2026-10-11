/// Local domain entities. Persisted on the device only (see data/database.dart).
library;

enum BillType {
  electricity,
  gas,
  diesel,
  unknown;

  static BillType parse(String? v) => BillType.values.firstWhere((e) => e.name == v, orElse: () => BillType.unknown);

  /// Canonical unit for this energy source (matches backend CANONICAL_UNIT).
  EnergyUnit? get canonicalUnit => switch (this) {
        BillType.electricity => EnergyUnit.kWh,
        BillType.gas => EnergyUnit.m3,
        BillType.diesel => EnergyUnit.litre,
        BillType.unknown => null,
      };
}

enum EnergyUnit {
  kWh('kWh'),
  m3('m3'),
  litre('litre');

  const EnergyUnit(this.wire);
  final String wire;

  static EnergyUnit? parse(String? v) {
    for (final u in EnergyUnit.values) {
      if (u.wire == v) return u;
    }
    return null;
  }
}

/// Where a record came from. Mirrors backend `DataOrigin`.
enum DataOrigin {
  billImage('bill_image'),
  manual('manual'),
  imported('imported'),
  demo('demo');

  const DataOrigin(this.wire);
  final String wire;

  static DataOrigin parse(String v) => DataOrigin.values.firstWhere((e) => e.wire == v, orElse: () => DataOrigin.manual);
}

class FactoryProfile {
  const FactoryProfile({
    required this.id,
    required this.name,
    required this.location,
    required this.lat,
    required this.lon,
    required this.productionUnitLabel,
    required this.privacyAcknowledgedAt,
  });

  final String id;
  final String name;
  final String location;
  final double? lat;
  final double? lon;
  final String productionUnitLabel;
  final DateTime privacyAcknowledgedAt;
}

/// A confirmed bill (or manual / imported / demo entry). Only confirmed data is stored.
class Bill {
  const Bill({
    required this.id,
    required this.billType,
    required this.billingMonth,
    required this.consumedUnits,
    required this.unit,
    required this.origin,
    required this.confirmedAt,
    required this.createdAt,
    required this.updatedAt,
    this.utilityName,
    this.periodStart,
    this.periodEnd,
    this.totalAmountBdt,
    this.tariffCode,
    this.sanctionedLoadKw,
    this.userEditedFields = const [],
    this.fieldConfidence = const {},
    this.extractionNotes,
    this.extractionModel,
    this.imagePath,
  });

  final String id;
  final BillType billType;
  final String billingMonth; // YYYY-MM
  final double consumedUnits;
  final EnergyUnit unit;
  final DataOrigin origin;
  final DateTime confirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? utilityName;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double? totalAmountBdt;
  final String? tariffCode;
  final double? sanctionedLoadKw;
  final List<String> userEditedFields;
  final Map<String, String> fieldConfidence;
  final String? extractionNotes;
  final String? extractionModel;
  final String? imagePath;

  bool get isSynthetic => origin == DataOrigin.demo;

  Bill copyWith({
    BillType? billType,
    String? billingMonth,
    double? consumedUnits,
    EnergyUnit? unit,
    DateTime? updatedAt,
    String? utilityName,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalAmountBdt,
    String? tariffCode,
    double? sanctionedLoadKw,
    List<String>? userEditedFields,
    String? imagePath,
    bool clearOptional = false,
  }) =>
      Bill(
        id: id,
        billType: billType ?? this.billType,
        billingMonth: billingMonth ?? this.billingMonth,
        consumedUnits: consumedUnits ?? this.consumedUnits,
        unit: unit ?? this.unit,
        origin: origin,
        confirmedAt: confirmedAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        utilityName: clearOptional ? utilityName : (utilityName ?? this.utilityName),
        periodStart: clearOptional ? periodStart : (periodStart ?? this.periodStart),
        periodEnd: clearOptional ? periodEnd : (periodEnd ?? this.periodEnd),
        totalAmountBdt: clearOptional ? totalAmountBdt : (totalAmountBdt ?? this.totalAmountBdt),
        tariffCode: clearOptional ? tariffCode : (tariffCode ?? this.tariffCode),
        sanctionedLoadKw: clearOptional ? sanctionedLoadKw : (sanctionedLoadKw ?? this.sanctionedLoadKw),
        userEditedFields: userEditedFields ?? this.userEditedFields,
        fieldConfidence: fieldConfidence,
        extractionNotes: extractionNotes,
        extractionModel: extractionModel,
        imagePath: imagePath ?? this.imagePath,
      );
}

class ProductionEntry {
  const ProductionEntry({
    required this.id,
    required this.month,
    required this.unitsProduced,
    required this.origin,
    required this.updatedAt,
  });

  final String id;
  final String month; // YYYY-MM
  final double unitsProduced;
  final DataOrigin origin;
  final DateTime updatedAt;

  bool get isSynthetic => origin == DataOrigin.demo;
}

/// An energy-saving action from the action plan: planned (no [doneMonth]) or done.
class EnergyAction {
  const EnergyAction({
    required this.id,
    required this.code,
    this.title = '',
    this.doneMonth,
    this.costBdt,
    this.note = '',
    required this.origin,
    required this.updatedAt,
  });

  final String id;

  /// Catalog code (e.g. fix_air_leaks), or 'custom' with a typed [title].
  final String code;
  final String title;

  /// Month the action was completed (YYYY-MM); null while it is only planned.
  final String? doneMonth;
  final double? costBdt;
  final String note;
  final DataOrigin origin;
  final DateTime updatedAt;

  bool get done => doneMonth != null;
  bool get isSynthetic => origin == DataOrigin.demo;

  EnergyAction copyWith({String? doneMonth, bool clearDone = false, double? costBdt, String? note}) => EnergyAction(
        id: id,
        code: code,
        title: title,
        doneMonth: clearDone ? null : (doneMonth ?? this.doneMonth),
        costBdt: costBdt ?? this.costBdt,
        note: note ?? this.note,
        origin: origin,
        updatedAt: DateTime.now(),
      );
}

class LatLon {
  const LatLon(this.lat, this.lon);
  final double lat;
  final double lon;

  Map<String, double> toJson() => {'lat': lat, 'lon': lon};
  factory LatLon.fromJson(Map<String, dynamic> j) => LatLon((j['lat'] as num).toDouble(), (j['lon'] as num).toDouble());
}

class SolarPlan {
  const SolarPlan({
    required this.id,
    required this.name,
    required this.polygon,
    required this.params,
    required this.resultJson,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<LatLon> polygon;
  final Map<String, dynamic> params;
  final Map<String, dynamic>? resultJson;
  final DateTime updatedAt;
}

/// Month helpers for `YYYY-MM` strings.
final RegExp monthPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

bool isValidMonth(String? v) => v != null && monthPattern.hasMatch(v);

String monthOf(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
