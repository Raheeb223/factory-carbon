import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/models.dart';
import 'api_client.dart';
import 'l10n/gen/app_localizations.dart';

/// Locale-aware number and date formatting.
class Fmt {
  Fmt(this.locale);
  factory Fmt.of(BuildContext context) => Fmt(Localizations.localeOf(context).toLanguageTag());

  final String locale;

  String number(double? v, {int decimals = 0, String empty = '–'}) {
    if (v == null) return empty;
    final f = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return f.format(v);
  }

  /// tCO2e with sensible precision for small and large values.
  String tonnes(double? v) => number(v, decimals: v != null && v.abs() < 10 ? 2 : 1);

  String month(String yyyymm) {
    if (!isValidMonth(yyyymm)) return yyyymm;
    return DateFormat.yMMM(locale).format(DateTime(int.parse(yyyymm.substring(0, 4)), int.parse(yyyymm.substring(5, 7))));
  }

  String monthLong(String yyyymm) {
    if (!isValidMonth(yyyymm)) return yyyymm;
    return DateFormat.yMMMM(locale).format(DateTime(int.parse(yyyymm.substring(0, 4)), int.parse(yyyymm.substring(5, 7))));
  }

  String date(DateTime? d) => d == null ? '–' : DateFormat.yMMMd(locale).format(d);
  String dateTime(DateTime d) => DateFormat.yMMMd(locale).add_Hm().format(d);
}

String billTypeLabel(AppLocalizations l, BillType t) => switch (t) {
      BillType.electricity => l.billTypeElectricity,
      BillType.gas => l.billTypeGas,
      BillType.diesel => l.billTypeDiesel,
      BillType.unknown => l.billTypeUnknown,
    };

String originLabel(AppLocalizations l, DataOrigin o) => switch (o) {
      DataOrigin.billImage => l.billOriginImage,
      DataOrigin.manual => l.billOriginManual,
      DataOrigin.imported => l.billOriginImported,
      DataOrigin.demo => l.billOriginDemo,
    };

String factorLabel(AppLocalizations l, String name) => switch (name) {
      'grid_electricity' => l.factorGrid,
      'diesel' => l.factorDiesel,
      'natural_gas' => l.factorGas,
      _ => name,
    };

/// User-facing text for any error thrown by the API client or elsewhere.
/// Known server error codes get a localized message; otherwise the error kind decides.
String errorText(AppLocalizations l, Object error) {
  if (error is ApiException) {
    final byCode = switch (error.code) {
      'invalid_polygon' => l.errInvalidPolygon,
      'polygon_too_small' => l.errPolygonTooSmall,
      'polygon_too_large' => l.errPolygonTooLarge,
      'unit_mismatch' => l.errUnitMismatch,
      'irradiance_unavailable' || 'irradiance_timeout' || 'invalid_peak_sun_hours' => l.errIrradiance,
      'daily_cap_reached' => l.errDailyCap,
      'extraction_failed' => l.errExtractionFailed,
      'file_too_large' || 'request_too_large' => l.errFileTooLarge,
      'unsupported_media_type' || 'empty_file' => l.errUnsupportedFile,
      'invalid_app_token' || 'server_misconfigured' => l.errInvalidToken,
      'extraction_unavailable' => l.errExtractionUnavailable,
      _ => null,
    };
    if (byCode != null) return byCode;
    return switch (error.kind) {
      ApiErrorKind.network => l.errorNetwork,
      ApiErrorKind.timeout => l.errorTimeout,
      ApiErrorKind.rateLimited => l.errorRateLimited,
      ApiErrorKind.unavailable => l.errorUnavailable,
      ApiErrorKind.server => l.errorServer,
      // Other validation errors: the server's (English) message is the most specific.
      ApiErrorKind.client => l.localeName.startsWith('en') ? error.message : l.errorGeneric,
    };
  }
  return l.errorGeneric;
}

/// Parses a user-typed number (accepts Bangla digits and thousands separators).
double? parseNumber(String? text) {
  if (text == null) return null;
  const bangla = '০১২৩৪৫৬৭৮৯';
  final b = StringBuffer();
  for (final ch in text.trim().split('')) {
    final i = bangla.indexOf(ch);
    b.write(i >= 0 ? '$i' : ch);
  }
  final cleaned = b.toString().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  final v = double.tryParse(cleaned);
  return v != null && v.isFinite ? v : null;
}
