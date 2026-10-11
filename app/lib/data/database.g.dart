// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FactoryProfilesTable extends FactoryProfiles
    with TableInfo<$FactoryProfilesTable, FactoryProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactoryProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productionUnitLabelMeta =
      const VerificationMeta('productionUnitLabel');
  @override
  late final GeneratedColumn<String> productionUnitLabel =
      GeneratedColumn<String>(
        'production_unit_label',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pieces'),
      );
  static const VerificationMeta _privacyAcknowledgedAtMeta =
      const VerificationMeta('privacyAcknowledgedAt');
  @override
  late final GeneratedColumn<DateTime> privacyAcknowledgedAt =
      GeneratedColumn<DateTime>(
        'privacy_acknowledged_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    location,
    lat,
    lon,
    productionUnitLabel,
    privacyAcknowledgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factory_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactoryProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('production_unit_label')) {
      context.handle(
        _productionUnitLabelMeta,
        productionUnitLabel.isAcceptableOrUnknown(
          data['production_unit_label']!,
          _productionUnitLabelMeta,
        ),
      );
    }
    if (data.containsKey('privacy_acknowledged_at')) {
      context.handle(
        _privacyAcknowledgedAtMeta,
        privacyAcknowledgedAt.isAcceptableOrUnknown(
          data['privacy_acknowledged_at']!,
          _privacyAcknowledgedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyAcknowledgedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactoryProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactoryProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      productionUnitLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}production_unit_label'],
      )!,
      privacyAcknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}privacy_acknowledged_at'],
      )!,
    );
  }

  @override
  $FactoryProfilesTable createAlias(String alias) {
    return $FactoryProfilesTable(attachedDatabase, alias);
  }
}

class FactoryProfileRow extends DataClass
    implements Insertable<FactoryProfileRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String name;
  final String location;
  final double? lat;
  final double? lon;
  final String productionUnitLabel;
  final DateTime privacyAcknowledgedAt;
  const FactoryProfileRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.location,
    this.lat,
    this.lon,
    required this.productionUnitLabel,
    required this.privacyAcknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    map['production_unit_label'] = Variable<String>(productionUnitLabel);
    map['privacy_acknowledged_at'] = Variable<DateTime>(privacyAcknowledgedAt);
    return map;
  }

  FactoryProfilesCompanion toCompanion(bool nullToAbsent) {
    return FactoryProfilesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      location: Value(location),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      productionUnitLabel: Value(productionUnitLabel),
      privacyAcknowledgedAt: Value(privacyAcknowledgedAt),
    );
  }

  factory FactoryProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactoryProfileRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      productionUnitLabel: serializer.fromJson<String>(
        json['productionUnitLabel'],
      ),
      privacyAcknowledgedAt: serializer.fromJson<DateTime>(
        json['privacyAcknowledgedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'productionUnitLabel': serializer.toJson<String>(productionUnitLabel),
      'privacyAcknowledgedAt': serializer.toJson<DateTime>(
        privacyAcknowledgedAt,
      ),
    };
  }

  FactoryProfileRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? name,
    String? location,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    String? productionUnitLabel,
    DateTime? privacyAcknowledgedAt,
  }) => FactoryProfileRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    location: location ?? this.location,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    productionUnitLabel: productionUnitLabel ?? this.productionUnitLabel,
    privacyAcknowledgedAt: privacyAcknowledgedAt ?? this.privacyAcknowledgedAt,
  );
  FactoryProfileRow copyWithCompanion(FactoryProfilesCompanion data) {
    return FactoryProfileRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      productionUnitLabel: data.productionUnitLabel.present
          ? data.productionUnitLabel.value
          : this.productionUnitLabel,
      privacyAcknowledgedAt: data.privacyAcknowledgedAt.present
          ? data.privacyAcknowledgedAt.value
          : this.privacyAcknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactoryProfileRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('productionUnitLabel: $productionUnitLabel, ')
          ..write('privacyAcknowledgedAt: $privacyAcknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    location,
    lat,
    lon,
    productionUnitLabel,
    privacyAcknowledgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactoryProfileRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.location == this.location &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.productionUnitLabel == this.productionUnitLabel &&
          other.privacyAcknowledgedAt == this.privacyAcknowledgedAt);
}

class FactoryProfilesCompanion extends UpdateCompanion<FactoryProfileRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> location;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<String> productionUnitLabel;
  final Value<DateTime> privacyAcknowledgedAt;
  final Value<int> rowid;
  const FactoryProfilesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.productionUnitLabel = const Value.absent(),
    this.privacyAcknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactoryProfilesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.productionUnitLabel = const Value.absent(),
    required DateTime privacyAcknowledgedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       privacyAcknowledgedAt = Value(privacyAcknowledgedAt);
  static Insertable<FactoryProfileRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? location,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? productionUnitLabel,
    Expression<DateTime>? privacyAcknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (productionUnitLabel != null)
        'production_unit_label': productionUnitLabel,
      if (privacyAcknowledgedAt != null)
        'privacy_acknowledged_at': privacyAcknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactoryProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? location,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<String>? productionUnitLabel,
    Value<DateTime>? privacyAcknowledgedAt,
    Value<int>? rowid,
  }) {
    return FactoryProfilesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      productionUnitLabel: productionUnitLabel ?? this.productionUnitLabel,
      privacyAcknowledgedAt:
          privacyAcknowledgedAt ?? this.privacyAcknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (productionUnitLabel.present) {
      map['production_unit_label'] = Variable<String>(
        productionUnitLabel.value,
      );
    }
    if (privacyAcknowledgedAt.present) {
      map['privacy_acknowledged_at'] = Variable<DateTime>(
        privacyAcknowledgedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactoryProfilesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('productionUnitLabel: $productionUnitLabel, ')
          ..write('privacyAcknowledgedAt: $privacyAcknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, BillRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _billTypeMeta = const VerificationMeta(
    'billType',
  );
  @override
  late final GeneratedColumn<String> billType = GeneratedColumn<String>(
    'bill_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billingMonthMeta = const VerificationMeta(
    'billingMonth',
  );
  @override
  late final GeneratedColumn<String> billingMonth = GeneratedColumn<String>(
    'billing_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumedUnitsMeta = const VerificationMeta(
    'consumedUnits',
  );
  @override
  late final GeneratedColumn<double> consumedUnits = GeneratedColumn<double>(
    'consumed_units',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilityNameMeta = const VerificationMeta(
    'utilityName',
  );
  @override
  late final GeneratedColumn<String> utilityName = GeneratedColumn<String>(
    'utility_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountBdtMeta = const VerificationMeta(
    'totalAmountBdt',
  );
  @override
  late final GeneratedColumn<double> totalAmountBdt = GeneratedColumn<double>(
    'total_amount_bdt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tariffCodeMeta = const VerificationMeta(
    'tariffCode',
  );
  @override
  late final GeneratedColumn<String> tariffCode = GeneratedColumn<String>(
    'tariff_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sanctionedLoadKwMeta = const VerificationMeta(
    'sanctionedLoadKw',
  );
  @override
  late final GeneratedColumn<double> sanctionedLoadKw = GeneratedColumn<double>(
    'sanctioned_load_kw',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEditedFieldsMeta = const VerificationMeta(
    'userEditedFields',
  );
  @override
  late final GeneratedColumn<String> userEditedFields = GeneratedColumn<String>(
    'user_edited_fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _fieldConfidenceMeta = const VerificationMeta(
    'fieldConfidence',
  );
  @override
  late final GeneratedColumn<String> fieldConfidence = GeneratedColumn<String>(
    'field_confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _extractionNotesMeta = const VerificationMeta(
    'extractionNotes',
  );
  @override
  late final GeneratedColumn<String> extractionNotes = GeneratedColumn<String>(
    'extraction_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractionModelMeta = const VerificationMeta(
    'extractionModel',
  );
  @override
  late final GeneratedColumn<String> extractionModel = GeneratedColumn<String>(
    'extraction_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    billType,
    billingMonth,
    consumedUnits,
    unit,
    origin,
    confirmedAt,
    utilityName,
    periodStart,
    periodEnd,
    totalAmountBdt,
    tariffCode,
    sanctionedLoadKw,
    userEditedFields,
    fieldConfidence,
    extractionNotes,
    extractionModel,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('bill_type')) {
      context.handle(
        _billTypeMeta,
        billType.isAcceptableOrUnknown(data['bill_type']!, _billTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_billTypeMeta);
    }
    if (data.containsKey('billing_month')) {
      context.handle(
        _billingMonthMeta,
        billingMonth.isAcceptableOrUnknown(
          data['billing_month']!,
          _billingMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_billingMonthMeta);
    }
    if (data.containsKey('consumed_units')) {
      context.handle(
        _consumedUnitsMeta,
        consumedUnits.isAcceptableOrUnknown(
          data['consumed_units']!,
          _consumedUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consumedUnitsMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    if (data.containsKey('utility_name')) {
      context.handle(
        _utilityNameMeta,
        utilityName.isAcceptableOrUnknown(
          data['utility_name']!,
          _utilityNameMeta,
        ),
      );
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    }
    if (data.containsKey('total_amount_bdt')) {
      context.handle(
        _totalAmountBdtMeta,
        totalAmountBdt.isAcceptableOrUnknown(
          data['total_amount_bdt']!,
          _totalAmountBdtMeta,
        ),
      );
    }
    if (data.containsKey('tariff_code')) {
      context.handle(
        _tariffCodeMeta,
        tariffCode.isAcceptableOrUnknown(data['tariff_code']!, _tariffCodeMeta),
      );
    }
    if (data.containsKey('sanctioned_load_kw')) {
      context.handle(
        _sanctionedLoadKwMeta,
        sanctionedLoadKw.isAcceptableOrUnknown(
          data['sanctioned_load_kw']!,
          _sanctionedLoadKwMeta,
        ),
      );
    }
    if (data.containsKey('user_edited_fields')) {
      context.handle(
        _userEditedFieldsMeta,
        userEditedFields.isAcceptableOrUnknown(
          data['user_edited_fields']!,
          _userEditedFieldsMeta,
        ),
      );
    }
    if (data.containsKey('field_confidence')) {
      context.handle(
        _fieldConfidenceMeta,
        fieldConfidence.isAcceptableOrUnknown(
          data['field_confidence']!,
          _fieldConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('extraction_notes')) {
      context.handle(
        _extractionNotesMeta,
        extractionNotes.isAcceptableOrUnknown(
          data['extraction_notes']!,
          _extractionNotesMeta,
        ),
      );
    }
    if (data.containsKey('extraction_model')) {
      context.handle(
        _extractionModelMeta,
        extractionModel.isAcceptableOrUnknown(
          data['extraction_model']!,
          _extractionModelMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      billType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_type'],
      )!,
      billingMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_month'],
      )!,
      consumedUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumed_units'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
      utilityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utility_name'],
      ),
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      ),
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      ),
      totalAmountBdt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount_bdt'],
      ),
      tariffCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tariff_code'],
      ),
      sanctionedLoadKw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sanctioned_load_kw'],
      ),
      userEditedFields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_edited_fields'],
      )!,
      fieldConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_confidence'],
      )!,
      extractionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_notes'],
      ),
      extractionModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_model'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class BillRow extends DataClass implements Insertable<BillRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String billType;
  final String billingMonth;
  final double consumedUnits;
  final String unit;
  final String origin;
  final DateTime confirmedAt;
  final String? utilityName;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double? totalAmountBdt;
  final String? tariffCode;
  final double? sanctionedLoadKw;

  /// JSON list of field names the user changed (vs. extracted or vs. previous save).
  final String userEditedFields;

  /// JSON map field -> high|medium|low from extraction.
  final String fieldConfidence;
  final String? extractionNotes;
  final String? extractionModel;

  /// Local path to the kept bill image; null unless the "keep images" setting is on.
  final String? imagePath;
  const BillRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.billType,
    required this.billingMonth,
    required this.consumedUnits,
    required this.unit,
    required this.origin,
    required this.confirmedAt,
    this.utilityName,
    this.periodStart,
    this.periodEnd,
    this.totalAmountBdt,
    this.tariffCode,
    this.sanctionedLoadKw,
    required this.userEditedFields,
    required this.fieldConfidence,
    this.extractionNotes,
    this.extractionModel,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['bill_type'] = Variable<String>(billType);
    map['billing_month'] = Variable<String>(billingMonth);
    map['consumed_units'] = Variable<double>(consumedUnits);
    map['unit'] = Variable<String>(unit);
    map['origin'] = Variable<String>(origin);
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    if (!nullToAbsent || utilityName != null) {
      map['utility_name'] = Variable<String>(utilityName);
    }
    if (!nullToAbsent || periodStart != null) {
      map['period_start'] = Variable<DateTime>(periodStart);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    if (!nullToAbsent || totalAmountBdt != null) {
      map['total_amount_bdt'] = Variable<double>(totalAmountBdt);
    }
    if (!nullToAbsent || tariffCode != null) {
      map['tariff_code'] = Variable<String>(tariffCode);
    }
    if (!nullToAbsent || sanctionedLoadKw != null) {
      map['sanctioned_load_kw'] = Variable<double>(sanctionedLoadKw);
    }
    map['user_edited_fields'] = Variable<String>(userEditedFields);
    map['field_confidence'] = Variable<String>(fieldConfidence);
    if (!nullToAbsent || extractionNotes != null) {
      map['extraction_notes'] = Variable<String>(extractionNotes);
    }
    if (!nullToAbsent || extractionModel != null) {
      map['extraction_model'] = Variable<String>(extractionModel);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      billType: Value(billType),
      billingMonth: Value(billingMonth),
      consumedUnits: Value(consumedUnits),
      unit: Value(unit),
      origin: Value(origin),
      confirmedAt: Value(confirmedAt),
      utilityName: utilityName == null && nullToAbsent
          ? const Value.absent()
          : Value(utilityName),
      periodStart: periodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(periodStart),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      totalAmountBdt: totalAmountBdt == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmountBdt),
      tariffCode: tariffCode == null && nullToAbsent
          ? const Value.absent()
          : Value(tariffCode),
      sanctionedLoadKw: sanctionedLoadKw == null && nullToAbsent
          ? const Value.absent()
          : Value(sanctionedLoadKw),
      userEditedFields: Value(userEditedFields),
      fieldConfidence: Value(fieldConfidence),
      extractionNotes: extractionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionNotes),
      extractionModel: extractionModel == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionModel),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory BillRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      billType: serializer.fromJson<String>(json['billType']),
      billingMonth: serializer.fromJson<String>(json['billingMonth']),
      consumedUnits: serializer.fromJson<double>(json['consumedUnits']),
      unit: serializer.fromJson<String>(json['unit']),
      origin: serializer.fromJson<String>(json['origin']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      utilityName: serializer.fromJson<String?>(json['utilityName']),
      periodStart: serializer.fromJson<DateTime?>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      totalAmountBdt: serializer.fromJson<double?>(json['totalAmountBdt']),
      tariffCode: serializer.fromJson<String?>(json['tariffCode']),
      sanctionedLoadKw: serializer.fromJson<double?>(json['sanctionedLoadKw']),
      userEditedFields: serializer.fromJson<String>(json['userEditedFields']),
      fieldConfidence: serializer.fromJson<String>(json['fieldConfidence']),
      extractionNotes: serializer.fromJson<String?>(json['extractionNotes']),
      extractionModel: serializer.fromJson<String?>(json['extractionModel']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'billType': serializer.toJson<String>(billType),
      'billingMonth': serializer.toJson<String>(billingMonth),
      'consumedUnits': serializer.toJson<double>(consumedUnits),
      'unit': serializer.toJson<String>(unit),
      'origin': serializer.toJson<String>(origin),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'utilityName': serializer.toJson<String?>(utilityName),
      'periodStart': serializer.toJson<DateTime?>(periodStart),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'totalAmountBdt': serializer.toJson<double?>(totalAmountBdt),
      'tariffCode': serializer.toJson<String?>(tariffCode),
      'sanctionedLoadKw': serializer.toJson<double?>(sanctionedLoadKw),
      'userEditedFields': serializer.toJson<String>(userEditedFields),
      'fieldConfidence': serializer.toJson<String>(fieldConfidence),
      'extractionNotes': serializer.toJson<String?>(extractionNotes),
      'extractionModel': serializer.toJson<String?>(extractionModel),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  BillRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? billType,
    String? billingMonth,
    double? consumedUnits,
    String? unit,
    String? origin,
    DateTime? confirmedAt,
    Value<String?> utilityName = const Value.absent(),
    Value<DateTime?> periodStart = const Value.absent(),
    Value<DateTime?> periodEnd = const Value.absent(),
    Value<double?> totalAmountBdt = const Value.absent(),
    Value<String?> tariffCode = const Value.absent(),
    Value<double?> sanctionedLoadKw = const Value.absent(),
    String? userEditedFields,
    String? fieldConfidence,
    Value<String?> extractionNotes = const Value.absent(),
    Value<String?> extractionModel = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
  }) => BillRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    billType: billType ?? this.billType,
    billingMonth: billingMonth ?? this.billingMonth,
    consumedUnits: consumedUnits ?? this.consumedUnits,
    unit: unit ?? this.unit,
    origin: origin ?? this.origin,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    utilityName: utilityName.present ? utilityName.value : this.utilityName,
    periodStart: periodStart.present ? periodStart.value : this.periodStart,
    periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
    totalAmountBdt: totalAmountBdt.present
        ? totalAmountBdt.value
        : this.totalAmountBdt,
    tariffCode: tariffCode.present ? tariffCode.value : this.tariffCode,
    sanctionedLoadKw: sanctionedLoadKw.present
        ? sanctionedLoadKw.value
        : this.sanctionedLoadKw,
    userEditedFields: userEditedFields ?? this.userEditedFields,
    fieldConfidence: fieldConfidence ?? this.fieldConfidence,
    extractionNotes: extractionNotes.present
        ? extractionNotes.value
        : this.extractionNotes,
    extractionModel: extractionModel.present
        ? extractionModel.value
        : this.extractionModel,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  BillRow copyWithCompanion(BillsCompanion data) {
    return BillRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      billType: data.billType.present ? data.billType.value : this.billType,
      billingMonth: data.billingMonth.present
          ? data.billingMonth.value
          : this.billingMonth,
      consumedUnits: data.consumedUnits.present
          ? data.consumedUnits.value
          : this.consumedUnits,
      unit: data.unit.present ? data.unit.value : this.unit,
      origin: data.origin.present ? data.origin.value : this.origin,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      utilityName: data.utilityName.present
          ? data.utilityName.value
          : this.utilityName,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      totalAmountBdt: data.totalAmountBdt.present
          ? data.totalAmountBdt.value
          : this.totalAmountBdt,
      tariffCode: data.tariffCode.present
          ? data.tariffCode.value
          : this.tariffCode,
      sanctionedLoadKw: data.sanctionedLoadKw.present
          ? data.sanctionedLoadKw.value
          : this.sanctionedLoadKw,
      userEditedFields: data.userEditedFields.present
          ? data.userEditedFields.value
          : this.userEditedFields,
      fieldConfidence: data.fieldConfidence.present
          ? data.fieldConfidence.value
          : this.fieldConfidence,
      extractionNotes: data.extractionNotes.present
          ? data.extractionNotes.value
          : this.extractionNotes,
      extractionModel: data.extractionModel.present
          ? data.extractionModel.value
          : this.extractionModel,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('billType: $billType, ')
          ..write('billingMonth: $billingMonth, ')
          ..write('consumedUnits: $consumedUnits, ')
          ..write('unit: $unit, ')
          ..write('origin: $origin, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('utilityName: $utilityName, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('totalAmountBdt: $totalAmountBdt, ')
          ..write('tariffCode: $tariffCode, ')
          ..write('sanctionedLoadKw: $sanctionedLoadKw, ')
          ..write('userEditedFields: $userEditedFields, ')
          ..write('fieldConfidence: $fieldConfidence, ')
          ..write('extractionNotes: $extractionNotes, ')
          ..write('extractionModel: $extractionModel, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deleted,
    billType,
    billingMonth,
    consumedUnits,
    unit,
    origin,
    confirmedAt,
    utilityName,
    periodStart,
    periodEnd,
    totalAmountBdt,
    tariffCode,
    sanctionedLoadKw,
    userEditedFields,
    fieldConfidence,
    extractionNotes,
    extractionModel,
    imagePath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.billType == this.billType &&
          other.billingMonth == this.billingMonth &&
          other.consumedUnits == this.consumedUnits &&
          other.unit == this.unit &&
          other.origin == this.origin &&
          other.confirmedAt == this.confirmedAt &&
          other.utilityName == this.utilityName &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.totalAmountBdt == this.totalAmountBdt &&
          other.tariffCode == this.tariffCode &&
          other.sanctionedLoadKw == this.sanctionedLoadKw &&
          other.userEditedFields == this.userEditedFields &&
          other.fieldConfidence == this.fieldConfidence &&
          other.extractionNotes == this.extractionNotes &&
          other.extractionModel == this.extractionModel &&
          other.imagePath == this.imagePath);
}

class BillsCompanion extends UpdateCompanion<BillRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> billType;
  final Value<String> billingMonth;
  final Value<double> consumedUnits;
  final Value<String> unit;
  final Value<String> origin;
  final Value<DateTime> confirmedAt;
  final Value<String?> utilityName;
  final Value<DateTime?> periodStart;
  final Value<DateTime?> periodEnd;
  final Value<double?> totalAmountBdt;
  final Value<String?> tariffCode;
  final Value<double?> sanctionedLoadKw;
  final Value<String> userEditedFields;
  final Value<String> fieldConfidence;
  final Value<String?> extractionNotes;
  final Value<String?> extractionModel;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.billType = const Value.absent(),
    this.billingMonth = const Value.absent(),
    this.consumedUnits = const Value.absent(),
    this.unit = const Value.absent(),
    this.origin = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.utilityName = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.totalAmountBdt = const Value.absent(),
    this.tariffCode = const Value.absent(),
    this.sanctionedLoadKw = const Value.absent(),
    this.userEditedFields = const Value.absent(),
    this.fieldConfidence = const Value.absent(),
    this.extractionNotes = const Value.absent(),
    this.extractionModel = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String billType,
    required String billingMonth,
    required double consumedUnits,
    required String unit,
    required String origin,
    required DateTime confirmedAt,
    this.utilityName = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.totalAmountBdt = const Value.absent(),
    this.tariffCode = const Value.absent(),
    this.sanctionedLoadKw = const Value.absent(),
    this.userEditedFields = const Value.absent(),
    this.fieldConfidence = const Value.absent(),
    this.extractionNotes = const Value.absent(),
    this.extractionModel = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       billType = Value(billType),
       billingMonth = Value(billingMonth),
       consumedUnits = Value(consumedUnits),
       unit = Value(unit),
       origin = Value(origin),
       confirmedAt = Value(confirmedAt);
  static Insertable<BillRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? billType,
    Expression<String>? billingMonth,
    Expression<double>? consumedUnits,
    Expression<String>? unit,
    Expression<String>? origin,
    Expression<DateTime>? confirmedAt,
    Expression<String>? utilityName,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<double>? totalAmountBdt,
    Expression<String>? tariffCode,
    Expression<double>? sanctionedLoadKw,
    Expression<String>? userEditedFields,
    Expression<String>? fieldConfidence,
    Expression<String>? extractionNotes,
    Expression<String>? extractionModel,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (billType != null) 'bill_type': billType,
      if (billingMonth != null) 'billing_month': billingMonth,
      if (consumedUnits != null) 'consumed_units': consumedUnits,
      if (unit != null) 'unit': unit,
      if (origin != null) 'origin': origin,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (utilityName != null) 'utility_name': utilityName,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (totalAmountBdt != null) 'total_amount_bdt': totalAmountBdt,
      if (tariffCode != null) 'tariff_code': tariffCode,
      if (sanctionedLoadKw != null) 'sanctioned_load_kw': sanctionedLoadKw,
      if (userEditedFields != null) 'user_edited_fields': userEditedFields,
      if (fieldConfidence != null) 'field_confidence': fieldConfidence,
      if (extractionNotes != null) 'extraction_notes': extractionNotes,
      if (extractionModel != null) 'extraction_model': extractionModel,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? billType,
    Value<String>? billingMonth,
    Value<double>? consumedUnits,
    Value<String>? unit,
    Value<String>? origin,
    Value<DateTime>? confirmedAt,
    Value<String?>? utilityName,
    Value<DateTime?>? periodStart,
    Value<DateTime?>? periodEnd,
    Value<double?>? totalAmountBdt,
    Value<String?>? tariffCode,
    Value<double?>? sanctionedLoadKw,
    Value<String>? userEditedFields,
    Value<String>? fieldConfidence,
    Value<String?>? extractionNotes,
    Value<String?>? extractionModel,
    Value<String?>? imagePath,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      billType: billType ?? this.billType,
      billingMonth: billingMonth ?? this.billingMonth,
      consumedUnits: consumedUnits ?? this.consumedUnits,
      unit: unit ?? this.unit,
      origin: origin ?? this.origin,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      utilityName: utilityName ?? this.utilityName,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalAmountBdt: totalAmountBdt ?? this.totalAmountBdt,
      tariffCode: tariffCode ?? this.tariffCode,
      sanctionedLoadKw: sanctionedLoadKw ?? this.sanctionedLoadKw,
      userEditedFields: userEditedFields ?? this.userEditedFields,
      fieldConfidence: fieldConfidence ?? this.fieldConfidence,
      extractionNotes: extractionNotes ?? this.extractionNotes,
      extractionModel: extractionModel ?? this.extractionModel,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (billType.present) {
      map['bill_type'] = Variable<String>(billType.value);
    }
    if (billingMonth.present) {
      map['billing_month'] = Variable<String>(billingMonth.value);
    }
    if (consumedUnits.present) {
      map['consumed_units'] = Variable<double>(consumedUnits.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (utilityName.present) {
      map['utility_name'] = Variable<String>(utilityName.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (totalAmountBdt.present) {
      map['total_amount_bdt'] = Variable<double>(totalAmountBdt.value);
    }
    if (tariffCode.present) {
      map['tariff_code'] = Variable<String>(tariffCode.value);
    }
    if (sanctionedLoadKw.present) {
      map['sanctioned_load_kw'] = Variable<double>(sanctionedLoadKw.value);
    }
    if (userEditedFields.present) {
      map['user_edited_fields'] = Variable<String>(userEditedFields.value);
    }
    if (fieldConfidence.present) {
      map['field_confidence'] = Variable<String>(fieldConfidence.value);
    }
    if (extractionNotes.present) {
      map['extraction_notes'] = Variable<String>(extractionNotes.value);
    }
    if (extractionModel.present) {
      map['extraction_model'] = Variable<String>(extractionModel.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('billType: $billType, ')
          ..write('billingMonth: $billingMonth, ')
          ..write('consumedUnits: $consumedUnits, ')
          ..write('unit: $unit, ')
          ..write('origin: $origin, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('utilityName: $utilityName, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('totalAmountBdt: $totalAmountBdt, ')
          ..write('tariffCode: $tariffCode, ')
          ..write('sanctionedLoadKw: $sanctionedLoadKw, ')
          ..write('userEditedFields: $userEditedFields, ')
          ..write('fieldConfidence: $fieldConfidence, ')
          ..write('extractionNotes: $extractionNotes, ')
          ..write('extractionModel: $extractionModel, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductionEntriesTable extends ProductionEntries
    with TableInfo<$ProductionEntriesTable, ProductionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsProducedMeta = const VerificationMeta(
    'unitsProduced',
  );
  @override
  late final GeneratedColumn<double> unitsProduced = GeneratedColumn<double>(
    'units_produced',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    month,
    unitsProduced,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'production_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('units_produced')) {
      context.handle(
        _unitsProducedMeta,
        unitsProduced.isAcceptableOrUnknown(
          data['units_produced']!,
          _unitsProducedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitsProducedMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      unitsProduced: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}units_produced'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
    );
  }

  @override
  $ProductionEntriesTable createAlias(String alias) {
    return $ProductionEntriesTable(attachedDatabase, alias);
  }
}

class ProductionRow extends DataClass implements Insertable<ProductionRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String month;
  final double unitsProduced;
  final String origin;
  const ProductionRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.month,
    required this.unitsProduced,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['month'] = Variable<String>(month);
    map['units_produced'] = Variable<double>(unitsProduced);
    map['origin'] = Variable<String>(origin);
    return map;
  }

  ProductionEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProductionEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      month: Value(month),
      unitsProduced: Value(unitsProduced),
      origin: Value(origin),
    );
  }

  factory ProductionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductionRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      month: serializer.fromJson<String>(json['month']),
      unitsProduced: serializer.fromJson<double>(json['unitsProduced']),
      origin: serializer.fromJson<String>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'month': serializer.toJson<String>(month),
      'unitsProduced': serializer.toJson<double>(unitsProduced),
      'origin': serializer.toJson<String>(origin),
    };
  }

  ProductionRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? month,
    double? unitsProduced,
    String? origin,
  }) => ProductionRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    month: month ?? this.month,
    unitsProduced: unitsProduced ?? this.unitsProduced,
    origin: origin ?? this.origin,
  );
  ProductionRow copyWithCompanion(ProductionEntriesCompanion data) {
    return ProductionRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      month: data.month.present ? data.month.value : this.month,
      unitsProduced: data.unitsProduced.present
          ? data.unitsProduced.value
          : this.unitsProduced,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductionRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('month: $month, ')
          ..write('unitsProduced: $unitsProduced, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    month,
    unitsProduced,
    origin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductionRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.month == this.month &&
          other.unitsProduced == this.unitsProduced &&
          other.origin == this.origin);
}

class ProductionEntriesCompanion extends UpdateCompanion<ProductionRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> month;
  final Value<double> unitsProduced;
  final Value<String> origin;
  final Value<int> rowid;
  const ProductionEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.month = const Value.absent(),
    this.unitsProduced = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductionEntriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String month,
    required double unitsProduced,
    required String origin,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       month = Value(month),
       unitsProduced = Value(unitsProduced),
       origin = Value(origin);
  static Insertable<ProductionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? month,
    Expression<double>? unitsProduced,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (month != null) 'month': month,
      if (unitsProduced != null) 'units_produced': unitsProduced,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductionEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? month,
    Value<double>? unitsProduced,
    Value<String>? origin,
    Value<int>? rowid,
  }) {
    return ProductionEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      month: month ?? this.month,
      unitsProduced: unitsProduced ?? this.unitsProduced,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (unitsProduced.present) {
      map['units_produced'] = Variable<double>(unitsProduced.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('month: $month, ')
          ..write('unitsProduced: $unitsProduced, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SolarPlansTable extends SolarPlans
    with TableInfo<$SolarPlansTable, SolarPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolarPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polygonJsonMeta = const VerificationMeta(
    'polygonJson',
  );
  @override
  late final GeneratedColumn<String> polygonJson = GeneratedColumn<String>(
    'polygon_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    polygonJson,
    paramsJson,
    resultJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solar_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<SolarPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('polygon_json')) {
      context.handle(
        _polygonJsonMeta,
        polygonJson.isAcceptableOrUnknown(
          data['polygon_json']!,
          _polygonJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polygonJsonMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SolarPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SolarPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      polygonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon_json'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
    );
  }

  @override
  $SolarPlansTable createAlias(String alias) {
    return $SolarPlansTable(attachedDatabase, alias);
  }
}

class SolarPlanRow extends DataClass implements Insertable<SolarPlanRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String name;
  final String polygonJson;
  final String paramsJson;
  final String? resultJson;
  const SolarPlanRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.polygonJson,
    required this.paramsJson,
    this.resultJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['polygon_json'] = Variable<String>(polygonJson);
    map['params_json'] = Variable<String>(paramsJson);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    return map;
  }

  SolarPlansCompanion toCompanion(bool nullToAbsent) {
    return SolarPlansCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      polygonJson: Value(polygonJson),
      paramsJson: Value(paramsJson),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
    );
  }

  factory SolarPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SolarPlanRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      polygonJson: serializer.fromJson<String>(json['polygonJson']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'polygonJson': serializer.toJson<String>(polygonJson),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'resultJson': serializer.toJson<String?>(resultJson),
    };
  }

  SolarPlanRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? name,
    String? polygonJson,
    String? paramsJson,
    Value<String?> resultJson = const Value.absent(),
  }) => SolarPlanRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    polygonJson: polygonJson ?? this.polygonJson,
    paramsJson: paramsJson ?? this.paramsJson,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
  );
  SolarPlanRow copyWithCompanion(SolarPlansCompanion data) {
    return SolarPlanRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      polygonJson: data.polygonJson.present
          ? data.polygonJson.value
          : this.polygonJson,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SolarPlanRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('resultJson: $resultJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    polygonJson,
    paramsJson,
    resultJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolarPlanRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.polygonJson == this.polygonJson &&
          other.paramsJson == this.paramsJson &&
          other.resultJson == this.resultJson);
}

class SolarPlansCompanion extends UpdateCompanion<SolarPlanRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> polygonJson;
  final Value<String> paramsJson;
  final Value<String?> resultJson;
  final Value<int> rowid;
  const SolarPlansCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SolarPlansCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    required String polygonJson,
    required String paramsJson,
    this.resultJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       polygonJson = Value(polygonJson),
       paramsJson = Value(paramsJson);
  static Insertable<SolarPlanRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? polygonJson,
    Expression<String>? paramsJson,
    Expression<String>? resultJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (paramsJson != null) 'params_json': paramsJson,
      if (resultJson != null) 'result_json': resultJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SolarPlansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? polygonJson,
    Value<String>? paramsJson,
    Value<String?>? resultJson,
    Value<int>? rowid,
  }) {
    return SolarPlansCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      polygonJson: polygonJson ?? this.polygonJson,
      paramsJson: paramsJson ?? this.paramsJson,
      resultJson: resultJson ?? this.resultJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (polygonJson.present) {
      map['polygon_json'] = Variable<String>(polygonJson.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolarPlansCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedResultsTable extends CachedResults
    with TableInfo<$CachedResultsTable, CachedResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, json, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CachedResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResultRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedResultsTable createAlias(String alias) {
    return $CachedResultsTable(attachedDatabase, alias);
  }
}

class CachedResultRow extends DataClass implements Insertable<CachedResultRow> {
  final String key;
  final String json;
  final DateTime updatedAt;
  const CachedResultRow({
    required this.key,
    required this.json,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json'] = Variable<String>(json);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedResultsCompanion toCompanion(bool nullToAbsent) {
    return CachedResultsCompanion(
      key: Value(key),
      json: Value(json),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResultRow(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedResultRow copyWith({String? key, String? json, DateTime? updatedAt}) =>
      CachedResultRow(
        key: key ?? this.key,
        json: json ?? this.json,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedResultRow copyWithCompanion(CachedResultsCompanion data) {
    return CachedResultRow(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResultRow(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResultRow &&
          other.key == this.key &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class CachedResultsCompanion extends UpdateCompanion<CachedResultRow> {
  final Value<String> key;
  final Value<String> json;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedResultsCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedResultsCompanion.insert({
    required String key,
    required String json,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       json = Value(json),
       updatedAt = Value(updatedAt);
  static Insertable<CachedResultRow> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedResultsCompanion copyWith({
    Value<String>? key,
    Value<String>? json,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedResultsCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedResultsCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnergyActionsTable extends EnergyActions
    with TableInfo<$EnergyActionsTable, EnergyActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doneMonthMeta = const VerificationMeta(
    'doneMonth',
  );
  @override
  late final GeneratedColumn<String> doneMonth = GeneratedColumn<String>(
    'done_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costBdtMeta = const VerificationMeta(
    'costBdt',
  );
  @override
  late final GeneratedColumn<double> costBdt = GeneratedColumn<double>(
    'cost_bdt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    code,
    title,
    doneMonth,
    costBdt,
    note,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnergyActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('done_month')) {
      context.handle(
        _doneMonthMeta,
        doneMonth.isAcceptableOrUnknown(data['done_month']!, _doneMonthMeta),
      );
    }
    if (data.containsKey('cost_bdt')) {
      context.handle(
        _costBdtMeta,
        costBdt.isAcceptableOrUnknown(data['cost_bdt']!, _costBdtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      doneMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_month'],
      ),
      costBdt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_bdt'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
    );
  }

  @override
  $EnergyActionsTable createAlias(String alias) {
    return $EnergyActionsTable(attachedDatabase, alias);
  }
}

class EnergyActionRow extends DataClass implements Insertable<EnergyActionRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String code;
  final String title;
  final String? doneMonth;
  final double? costBdt;
  final String note;
  final String origin;
  const EnergyActionRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.code,
    required this.title,
    this.doneMonth,
    this.costBdt,
    required this.note,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || doneMonth != null) {
      map['done_month'] = Variable<String>(doneMonth);
    }
    if (!nullToAbsent || costBdt != null) {
      map['cost_bdt'] = Variable<double>(costBdt);
    }
    map['note'] = Variable<String>(note);
    map['origin'] = Variable<String>(origin);
    return map;
  }

  EnergyActionsCompanion toCompanion(bool nullToAbsent) {
    return EnergyActionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      code: Value(code),
      title: Value(title),
      doneMonth: doneMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(doneMonth),
      costBdt: costBdt == null && nullToAbsent
          ? const Value.absent()
          : Value(costBdt),
      note: Value(note),
      origin: Value(origin),
    );
  }

  factory EnergyActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyActionRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      doneMonth: serializer.fromJson<String?>(json['doneMonth']),
      costBdt: serializer.fromJson<double?>(json['costBdt']),
      note: serializer.fromJson<String>(json['note']),
      origin: serializer.fromJson<String>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'doneMonth': serializer.toJson<String?>(doneMonth),
      'costBdt': serializer.toJson<double?>(costBdt),
      'note': serializer.toJson<String>(note),
      'origin': serializer.toJson<String>(origin),
    };
  }

  EnergyActionRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? code,
    String? title,
    Value<String?> doneMonth = const Value.absent(),
    Value<double?> costBdt = const Value.absent(),
    String? note,
    String? origin,
  }) => EnergyActionRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    code: code ?? this.code,
    title: title ?? this.title,
    doneMonth: doneMonth.present ? doneMonth.value : this.doneMonth,
    costBdt: costBdt.present ? costBdt.value : this.costBdt,
    note: note ?? this.note,
    origin: origin ?? this.origin,
  );
  EnergyActionRow copyWithCompanion(EnergyActionsCompanion data) {
    return EnergyActionRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      doneMonth: data.doneMonth.present ? data.doneMonth.value : this.doneMonth,
      costBdt: data.costBdt.present ? data.costBdt.value : this.costBdt,
      note: data.note.present ? data.note.value : this.note,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyActionRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('doneMonth: $doneMonth, ')
          ..write('costBdt: $costBdt, ')
          ..write('note: $note, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    code,
    title,
    doneMonth,
    costBdt,
    note,
    origin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyActionRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.code == this.code &&
          other.title == this.title &&
          other.doneMonth == this.doneMonth &&
          other.costBdt == this.costBdt &&
          other.note == this.note &&
          other.origin == this.origin);
}

class EnergyActionsCompanion extends UpdateCompanion<EnergyActionRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> doneMonth;
  final Value<double?> costBdt;
  final Value<String> note;
  final Value<String> origin;
  final Value<int> rowid;
  const EnergyActionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.doneMonth = const Value.absent(),
    this.costBdt = const Value.absent(),
    this.note = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnergyActionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String code,
    this.title = const Value.absent(),
    this.doneMonth = const Value.absent(),
    this.costBdt = const Value.absent(),
    this.note = const Value.absent(),
    required String origin,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       code = Value(code),
       origin = Value(origin);
  static Insertable<EnergyActionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? doneMonth,
    Expression<double>? costBdt,
    Expression<String>? note,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (doneMonth != null) 'done_month': doneMonth,
      if (costBdt != null) 'cost_bdt': costBdt,
      if (note != null) 'note': note,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnergyActionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? code,
    Value<String>? title,
    Value<String?>? doneMonth,
    Value<double?>? costBdt,
    Value<String>? note,
    Value<String>? origin,
    Value<int>? rowid,
  }) {
    return EnergyActionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      code: code ?? this.code,
      title: title ?? this.title,
      doneMonth: doneMonth ?? this.doneMonth,
      costBdt: costBdt ?? this.costBdt,
      note: note ?? this.note,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (doneMonth.present) {
      map['done_month'] = Variable<String>(doneMonth.value);
    }
    if (costBdt.present) {
      map['cost_bdt'] = Variable<double>(costBdt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyActionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('doneMonth: $doneMonth, ')
          ..write('costBdt: $costBdt, ')
          ..write('note: $note, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FactoryProfilesTable factoryProfiles = $FactoryProfilesTable(
    this,
  );
  late final $BillsTable bills = $BillsTable(this);
  late final $ProductionEntriesTable productionEntries =
      $ProductionEntriesTable(this);
  late final $SolarPlansTable solarPlans = $SolarPlansTable(this);
  late final $CachedResultsTable cachedResults = $CachedResultsTable(this);
  late final $EnergyActionsTable energyActions = $EnergyActionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    factoryProfiles,
    bills,
    productionEntries,
    solarPlans,
    cachedResults,
    energyActions,
  ];
}

typedef $$FactoryProfilesTableCreateCompanionBuilder =
    FactoryProfilesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String name,
      Value<String> location,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> productionUnitLabel,
      required DateTime privacyAcknowledgedAt,
      Value<int> rowid,
    });
typedef $$FactoryProfilesTableUpdateCompanionBuilder =
    FactoryProfilesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<String> location,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> productionUnitLabel,
      Value<DateTime> privacyAcknowledgedAt,
      Value<int> rowid,
    });

class $$FactoryProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $FactoryProfilesTable> {
  $$FactoryProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productionUnitLabel => $composableBuilder(
    column: $table.productionUnitLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get privacyAcknowledgedAt => $composableBuilder(
    column: $table.privacyAcknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FactoryProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $FactoryProfilesTable> {
  $$FactoryProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productionUnitLabel => $composableBuilder(
    column: $table.productionUnitLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get privacyAcknowledgedAt => $composableBuilder(
    column: $table.privacyAcknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FactoryProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactoryProfilesTable> {
  $$FactoryProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get productionUnitLabel => $composableBuilder(
    column: $table.productionUnitLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get privacyAcknowledgedAt => $composableBuilder(
    column: $table.privacyAcknowledgedAt,
    builder: (column) => column,
  );
}

class $$FactoryProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactoryProfilesTable,
          FactoryProfileRow,
          $$FactoryProfilesTableFilterComposer,
          $$FactoryProfilesTableOrderingComposer,
          $$FactoryProfilesTableAnnotationComposer,
          $$FactoryProfilesTableCreateCompanionBuilder,
          $$FactoryProfilesTableUpdateCompanionBuilder,
          (
            FactoryProfileRow,
            BaseReferences<
              _$AppDatabase,
              $FactoryProfilesTable,
              FactoryProfileRow
            >,
          ),
          FactoryProfileRow,
          PrefetchHooks Function()
        > {
  $$FactoryProfilesTableTableManager(
    _$AppDatabase db,
    $FactoryProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactoryProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactoryProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactoryProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> productionUnitLabel = const Value.absent(),
                Value<DateTime> privacyAcknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactoryProfilesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                location: location,
                lat: lat,
                lon: lon,
                productionUnitLabel: productionUnitLabel,
                privacyAcknowledgedAt: privacyAcknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> location = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> productionUnitLabel = const Value.absent(),
                required DateTime privacyAcknowledgedAt,
                Value<int> rowid = const Value.absent(),
              }) => FactoryProfilesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                location: location,
                lat: lat,
                lon: lon,
                productionUnitLabel: productionUnitLabel,
                privacyAcknowledgedAt: privacyAcknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FactoryProfilesTable, FactoryProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FactoryProfilesTable,
                    FactoryProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FactoryProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactoryProfilesTable,
      FactoryProfileRow,
      $$FactoryProfilesTableFilterComposer,
      $$FactoryProfilesTableOrderingComposer,
      $$FactoryProfilesTableAnnotationComposer,
      $$FactoryProfilesTableCreateCompanionBuilder,
      $$FactoryProfilesTableUpdateCompanionBuilder,
      (
        FactoryProfileRow,
        BaseReferences<_$AppDatabase, $FactoryProfilesTable, FactoryProfileRow>,
      ),
      FactoryProfileRow,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String billType,
  required String billingMonth,
  required double consumedUnits,
  required String unit,
  required String origin,
  required DateTime confirmedAt,
  Value<String?> utilityName,
  Value<DateTime?> periodStart,
  Value<DateTime?> periodEnd,
  Value<double?> totalAmountBdt,
  Value<String?> tariffCode,
  Value<double?> sanctionedLoadKw,
  Value<String> userEditedFields,
  Value<String> fieldConfidence,
  Value<String?> extractionNotes,
  Value<String?> extractionModel,
  Value<String?> imagePath,
  Value<int> rowid,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> billType,
  Value<String> billingMonth,
  Value<double> consumedUnits,
  Value<String> unit,
  Value<String> origin,
  Value<DateTime> confirmedAt,
  Value<String?> utilityName,
  Value<DateTime?> periodStart,
  Value<DateTime?> periodEnd,
  Value<double?> totalAmountBdt,
  Value<String?> tariffCode,
  Value<double?> sanctionedLoadKw,
  Value<String> userEditedFields,
  Value<String> fieldConfidence,
  Value<String?> extractionNotes,
  Value<String?> extractionModel,
  Value<String?> imagePath,
  Value<int> rowid,
});

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billType => $composableBuilder(
    column: $table.billType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingMonth => $composableBuilder(
    column: $table.billingMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumedUnits => $composableBuilder(
    column: $table.consumedUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilityName => $composableBuilder(
    column: $table.utilityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmountBdt => $composableBuilder(
    column: $table.totalAmountBdt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tariffCode => $composableBuilder(
    column: $table.tariffCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sanctionedLoadKw => $composableBuilder(
    column: $table.sanctionedLoadKw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEditedFields => $composableBuilder(
    column: $table.userEditedFields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldConfidence => $composableBuilder(
    column: $table.fieldConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionNotes => $composableBuilder(
    column: $table.extractionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billType => $composableBuilder(
    column: $table.billType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingMonth => $composableBuilder(
    column: $table.billingMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumedUnits => $composableBuilder(
    column: $table.consumedUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilityName => $composableBuilder(
    column: $table.utilityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmountBdt => $composableBuilder(
    column: $table.totalAmountBdt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tariffCode => $composableBuilder(
    column: $table.tariffCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sanctionedLoadKw => $composableBuilder(
    column: $table.sanctionedLoadKw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEditedFields => $composableBuilder(
    column: $table.userEditedFields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldConfidence => $composableBuilder(
    column: $table.fieldConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionNotes => $composableBuilder(
    column: $table.extractionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get billType =>
      $composableBuilder(column: $table.billType, builder: (column) => column);

  GeneratedColumn<String> get billingMonth => $composableBuilder(
    column: $table.billingMonth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consumedUnits => $composableBuilder(
    column: $table.consumedUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get utilityName => $composableBuilder(
    column: $table.utilityName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<double> get totalAmountBdt => $composableBuilder(
    column: $table.totalAmountBdt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tariffCode => $composableBuilder(
    column: $table.tariffCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sanctionedLoadKw => $composableBuilder(
    column: $table.sanctionedLoadKw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userEditedFields => $composableBuilder(
    column: $table.userEditedFields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldConfidence => $composableBuilder(
    column: $table.fieldConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionNotes => $composableBuilder(
    column: $table.extractionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionModel => $composableBuilder(
    column: $table.extractionModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          BillRow,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (BillRow, BaseReferences<_$AppDatabase, $BillsTable, BillRow>),
          BillRow,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> billType = const Value.absent(),
                Value<String> billingMonth = const Value.absent(),
                Value<double> consumedUnits = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<String?> utilityName = const Value.absent(),
                Value<DateTime?> periodStart = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<double?> totalAmountBdt = const Value.absent(),
                Value<String?> tariffCode = const Value.absent(),
                Value<double?> sanctionedLoadKw = const Value.absent(),
                Value<String> userEditedFields = const Value.absent(),
                Value<String> fieldConfidence = const Value.absent(),
                Value<String?> extractionNotes = const Value.absent(),
                Value<String?> extractionModel = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                billType: billType,
                billingMonth: billingMonth,
                consumedUnits: consumedUnits,
                unit: unit,
                origin: origin,
                confirmedAt: confirmedAt,
                utilityName: utilityName,
                periodStart: periodStart,
                periodEnd: periodEnd,
                totalAmountBdt: totalAmountBdt,
                tariffCode: tariffCode,
                sanctionedLoadKw: sanctionedLoadKw,
                userEditedFields: userEditedFields,
                fieldConfidence: fieldConfidence,
                extractionNotes: extractionNotes,
                extractionModel: extractionModel,
                imagePath: imagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String billType,
                required String billingMonth,
                required double consumedUnits,
                required String unit,
                required String origin,
                required DateTime confirmedAt,
                Value<String?> utilityName = const Value.absent(),
                Value<DateTime?> periodStart = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<double?> totalAmountBdt = const Value.absent(),
                Value<String?> tariffCode = const Value.absent(),
                Value<double?> sanctionedLoadKw = const Value.absent(),
                Value<String> userEditedFields = const Value.absent(),
                Value<String> fieldConfidence = const Value.absent(),
                Value<String?> extractionNotes = const Value.absent(),
                Value<String?> extractionModel = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                billType: billType,
                billingMonth: billingMonth,
                consumedUnits: consumedUnits,
                unit: unit,
                origin: origin,
                confirmedAt: confirmedAt,
                utilityName: utilityName,
                periodStart: periodStart,
                periodEnd: periodEnd,
                totalAmountBdt: totalAmountBdt,
                tariffCode: tariffCode,
                sanctionedLoadKw: sanctionedLoadKw,
                userEditedFields: userEditedFields,
                fieldConfidence: fieldConfidence,
                extractionNotes: extractionNotes,
                extractionModel: extractionModel,
                imagePath: imagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BillsTable, BillRow>(table),
                  BaseReferences<_$AppDatabase, $BillsTable, BillRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      BillRow,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (BillRow, BaseReferences<_$AppDatabase, $BillsTable, BillRow>),
      BillRow,
      PrefetchHooks Function()
    >;
typedef $$ProductionEntriesTableCreateCompanionBuilder =
    ProductionEntriesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String month,
      required double unitsProduced,
      required String origin,
      Value<int> rowid,
    });
typedef $$ProductionEntriesTableUpdateCompanionBuilder =
    ProductionEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> month,
      Value<double> unitsProduced,
      Value<String> origin,
      Value<int> rowid,
    });

class $$ProductionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductionEntriesTable> {
  $$ProductionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitsProduced => $composableBuilder(
    column: $table.unitsProduced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductionEntriesTable> {
  $$ProductionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitsProduced => $composableBuilder(
    column: $table.unitsProduced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductionEntriesTable> {
  $$ProductionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<double> get unitsProduced => $composableBuilder(
    column: $table.unitsProduced,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);
}

class $$ProductionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductionEntriesTable,
          ProductionRow,
          $$ProductionEntriesTableFilterComposer,
          $$ProductionEntriesTableOrderingComposer,
          $$ProductionEntriesTableAnnotationComposer,
          $$ProductionEntriesTableCreateCompanionBuilder,
          $$ProductionEntriesTableUpdateCompanionBuilder,
          (
            ProductionRow,
            BaseReferences<
              _$AppDatabase,
              $ProductionEntriesTable,
              ProductionRow
            >,
          ),
          ProductionRow,
          PrefetchHooks Function()
        > {
  $$ProductionEntriesTableTableManager(
    _$AppDatabase db,
    $ProductionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<double> unitsProduced = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductionEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                month: month,
                unitsProduced: unitsProduced,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String month,
                required double unitsProduced,
                required String origin,
                Value<int> rowid = const Value.absent(),
              }) => ProductionEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                month: month,
                unitsProduced: unitsProduced,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductionEntriesTable, ProductionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProductionEntriesTable,
                    ProductionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductionEntriesTable,
      ProductionRow,
      $$ProductionEntriesTableFilterComposer,
      $$ProductionEntriesTableOrderingComposer,
      $$ProductionEntriesTableAnnotationComposer,
      $$ProductionEntriesTableCreateCompanionBuilder,
      $$ProductionEntriesTableUpdateCompanionBuilder,
      (
        ProductionRow,
        BaseReferences<_$AppDatabase, $ProductionEntriesTable, ProductionRow>,
      ),
      ProductionRow,
      PrefetchHooks Function()
    >;
typedef $$SolarPlansTableCreateCompanionBuilder = SolarPlansCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String name,
  required String polygonJson,
  required String paramsJson,
  Value<String?> resultJson,
  Value<int> rowid,
});
typedef $$SolarPlansTableUpdateCompanionBuilder = SolarPlansCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> polygonJson,
  Value<String> paramsJson,
  Value<String?> resultJson,
  Value<int> rowid,
});

class $$SolarPlansTableFilterComposer
    extends Composer<_$AppDatabase, $SolarPlansTable> {
  $$SolarPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SolarPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $SolarPlansTable> {
  $$SolarPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SolarPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolarPlansTable> {
  $$SolarPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );
}

class $$SolarPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SolarPlansTable,
          SolarPlanRow,
          $$SolarPlansTableFilterComposer,
          $$SolarPlansTableOrderingComposer,
          $$SolarPlansTableAnnotationComposer,
          $$SolarPlansTableCreateCompanionBuilder,
          $$SolarPlansTableUpdateCompanionBuilder,
          (
            SolarPlanRow,
            BaseReferences<_$AppDatabase, $SolarPlansTable, SolarPlanRow>,
          ),
          SolarPlanRow,
          PrefetchHooks Function()
        > {
  $$SolarPlansTableTableManager(_$AppDatabase db, $SolarPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SolarPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SolarPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SolarPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> polygonJson = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolarPlansCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                polygonJson: polygonJson,
                paramsJson: paramsJson,
                resultJson: resultJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String polygonJson,
                required String paramsJson,
                Value<String?> resultJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolarPlansCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                polygonJson: polygonJson,
                paramsJson: paramsJson,
                resultJson: resultJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SolarPlansTable, SolarPlanRow>(table),
                  BaseReferences<_$AppDatabase, $SolarPlansTable, SolarPlanRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SolarPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SolarPlansTable,
      SolarPlanRow,
      $$SolarPlansTableFilterComposer,
      $$SolarPlansTableOrderingComposer,
      $$SolarPlansTableAnnotationComposer,
      $$SolarPlansTableCreateCompanionBuilder,
      $$SolarPlansTableUpdateCompanionBuilder,
      (
        SolarPlanRow,
        BaseReferences<_$AppDatabase, $SolarPlansTable, SolarPlanRow>,
      ),
      SolarPlanRow,
      PrefetchHooks Function()
    >;
typedef $$CachedResultsTableCreateCompanionBuilder =
    CachedResultsCompanion Function({
      required String key,
      required String json,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedResultsTableUpdateCompanionBuilder =
    CachedResultsCompanion Function({
      Value<String> key,
      Value<String> json,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedResultsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedResultsTable,
          CachedResultRow,
          $$CachedResultsTableFilterComposer,
          $$CachedResultsTableOrderingComposer,
          $$CachedResultsTableAnnotationComposer,
          $$CachedResultsTableCreateCompanionBuilder,
          $$CachedResultsTableUpdateCompanionBuilder,
          (
            CachedResultRow,
            BaseReferences<_$AppDatabase, $CachedResultsTable, CachedResultRow>,
          ),
          CachedResultRow,
          PrefetchHooks Function()
        > {
  $$CachedResultsTableTableManager(_$AppDatabase db, $CachedResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResultsCompanion(
                key: key,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String json,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedResultsCompanion.insert(
                key: key,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedResultsTable, CachedResultRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedResultsTable,
                    CachedResultRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedResultsTable,
      CachedResultRow,
      $$CachedResultsTableFilterComposer,
      $$CachedResultsTableOrderingComposer,
      $$CachedResultsTableAnnotationComposer,
      $$CachedResultsTableCreateCompanionBuilder,
      $$CachedResultsTableUpdateCompanionBuilder,
      (
        CachedResultRow,
        BaseReferences<_$AppDatabase, $CachedResultsTable, CachedResultRow>,
      ),
      CachedResultRow,
      PrefetchHooks Function()
    >;
typedef $$EnergyActionsTableCreateCompanionBuilder =
    EnergyActionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String code,
      Value<String> title,
      Value<String?> doneMonth,
      Value<double?> costBdt,
      Value<String> note,
      required String origin,
      Value<int> rowid,
    });
typedef $$EnergyActionsTableUpdateCompanionBuilder =
    EnergyActionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> code,
      Value<String> title,
      Value<String?> doneMonth,
      Value<double?> costBdt,
      Value<String> note,
      Value<String> origin,
      Value<int> rowid,
    });

class $$EnergyActionsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyActionsTable> {
  $$EnergyActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneMonth => $composableBuilder(
    column: $table.doneMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costBdt => $composableBuilder(
    column: $table.costBdt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnergyActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyActionsTable> {
  $$EnergyActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneMonth => $composableBuilder(
    column: $table.doneMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costBdt => $composableBuilder(
    column: $table.costBdt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnergyActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyActionsTable> {
  $$EnergyActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get doneMonth =>
      $composableBuilder(column: $table.doneMonth, builder: (column) => column);

  GeneratedColumn<double> get costBdt =>
      $composableBuilder(column: $table.costBdt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);
}

class $$EnergyActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyActionsTable,
          EnergyActionRow,
          $$EnergyActionsTableFilterComposer,
          $$EnergyActionsTableOrderingComposer,
          $$EnergyActionsTableAnnotationComposer,
          $$EnergyActionsTableCreateCompanionBuilder,
          $$EnergyActionsTableUpdateCompanionBuilder,
          (
            EnergyActionRow,
            BaseReferences<_$AppDatabase, $EnergyActionsTable, EnergyActionRow>,
          ),
          EnergyActionRow,
          PrefetchHooks Function()
        > {
  $$EnergyActionsTableTableManager(_$AppDatabase db, $EnergyActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> doneMonth = const Value.absent(),
                Value<double?> costBdt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnergyActionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                code: code,
                title: title,
                doneMonth: doneMonth,
                costBdt: costBdt,
                note: note,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String code,
                Value<String> title = const Value.absent(),
                Value<String?> doneMonth = const Value.absent(),
                Value<double?> costBdt = const Value.absent(),
                Value<String> note = const Value.absent(),
                required String origin,
                Value<int> rowid = const Value.absent(),
              }) => EnergyActionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                code: code,
                title: title,
                doneMonth: doneMonth,
                costBdt: costBdt,
                note: note,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnergyActionsTable, EnergyActionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EnergyActionsTable,
                    EnergyActionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnergyActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyActionsTable,
      EnergyActionRow,
      $$EnergyActionsTableFilterComposer,
      $$EnergyActionsTableOrderingComposer,
      $$EnergyActionsTableAnnotationComposer,
      $$EnergyActionsTableCreateCompanionBuilder,
      $$EnergyActionsTableUpdateCompanionBuilder,
      (
        EnergyActionRow,
        BaseReferences<_$AppDatabase, $EnergyActionsTable, EnergyActionRow>,
      ),
      EnergyActionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FactoryProfilesTableTableManager get factoryProfiles =>
      $$FactoryProfilesTableTableManager(_db, _db.factoryProfiles);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$ProductionEntriesTableTableManager get productionEntries =>
      $$ProductionEntriesTableTableManager(_db, _db.productionEntries);
  $$SolarPlansTableTableManager get solarPlans =>
      $$SolarPlansTableTableManager(_db, _db.solarPlans);
  $$CachedResultsTableTableManager get cachedResults =>
      $$CachedResultsTableTableManager(_db, _db.cachedResults);
  $$EnergyActionsTableTableManager get energyActions =>
      $$EnergyActionsTableTableManager(_db, _db.energyActions);
}
