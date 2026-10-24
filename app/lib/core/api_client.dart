import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/api_models.dart';
import '../domain/models.dart' show LatLon;
import 'config.dart';

enum ApiErrorKind { network, timeout, server, client, rateLimited, unavailable }

/// A failed API call with a user-presentable message (never a stack trace).
class ApiException implements Exception {
  const ApiException(this.kind, this.code, this.message, {this.statusCode});
  final ApiErrorKind kind;
  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}

/// Thin typed wrapper over the backend /v1 API.
class ApiClient {
  ApiClient(AppConfig config, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: config.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 130),
            )) {
    _dio.options.headers['X-App-Token'] = config.appToken;
  }

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  static ApiException _map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(ApiErrorKind.timeout, 'timeout', 'The server took too long to respond.');
      case DioExceptionType.connectionError:
        return const ApiException(ApiErrorKind.network, 'network', 'Could not reach the server. Check your internet connection.');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        var code = 'http_$status';
        var message = 'The server returned an error ($status).';
        final data = e.response?.data;
        if (data is Map && data['error'] is Map) {
          final err = data['error'] as Map;
          code = err['code'] as String? ?? code;
          message = err['message'] as String? ?? message;
        }
        final kind = status == 429
            ? ApiErrorKind.rateLimited
            : status == 503
                ? ApiErrorKind.unavailable
                : status >= 500
                    ? ApiErrorKind.server
                    : ApiErrorKind.client;
        return ApiException(kind, code, message, statusCode: status);
      default:
        return const ApiException(ApiErrorKind.network, 'network', 'The request could not be completed.');
    }
  }

  Map<String, dynamic> _json(Object? data) => (data as Map<dynamic, dynamic>).cast<String, dynamic>();

  /// Short timeouts so a request that stalls while the server wakes fails fast and is retried.
  Future<HealthInfo> health() => _guard(() async => HealthInfo.fromJson(_json((await _dio.get<dynamic>(
        '/v1/health',
        options: Options(sendTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 12)),
      ))
          .data)));

  Future<ExtractBillResult> extractBill(
    Uint8List jpegBytes, {
    void Function(double progress)? onSendProgress,
    CancelToken? cancelToken,
  }) =>
      _guard(() async {
        final form = FormData.fromMap({
          'file': MultipartFile.fromBytes(jpegBytes, filename: 'bill.jpg', contentType: DioMediaType('image', 'jpeg')),
        });
        final res = await _dio.post<dynamic>(
          '/v1/extract-bill',
          data: form,
          cancelToken: cancelToken,
          onSendProgress: (sent, total) {
            if (total > 0) onSendProgress?.call(sent / total);
          },
        );
        return ExtractBillResult.fromJson(_json(res.data));
      });

  Future<Map<String, dynamic>> calculateCarbonRaw(Map<String, dynamic> body) =>
      _guard(() async => _json((await _dio.post<dynamic>('/v1/carbon/calculate', data: body)).data));

  Future<Map<String, dynamic>> analyzeWasteRaw(Map<String, dynamic> body) =>
      _guard(() async => _json((await _dio.post<dynamic>('/v1/waste/analyze', data: body)).data));

  Future<SolarDefaults> solarDefaults() =>
      _guard(() async => SolarDefaults.fromJson(_json((await _dio.get<dynamic>('/v1/solar/defaults')).data)));

  Future<SolarResult> solarEstimate(Map<String, dynamic> body) =>
      _guard(() async => SolarResult.fromJson(_json((await _dio.post<dynamic>('/v1/solar/estimate', data: body)).data)));

  Future<Uint8List> reportPdf(Map<String, dynamic> body) => _guard(() async {
        final res = await _dio.post<List<int>>('/v1/report/pdf', data: body, options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList(res.data ?? const []);
      });

  /// Green finance readiness summary for a bank (needs a solar plan with financials).
  Future<Uint8List> loanPdf(Map<String, dynamic> body) => _guard(() async {
        final res = await _dio.post<List<int>>('/v1/report/loan-pdf', data: body, options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList(res.data ?? const []);
      });

  /// Signs a one-page carbon summary on the server; returns its public link (for a QR code).
  Future<({String url, DateTime issuedOn})> passport(Map<String, dynamic> body) => _guard(() async {
        final j = _json((await _dio.post<dynamic>('/v1/passport', data: body)).data);
        return (url: j['url'] as String, issuedOn: DateTime.parse(j['issued_on'] as String));
      });

  /// Building outlines around [at] (Overture Maps: OpenStreetMap + Google/Microsoft footprints),
  /// the building containing the point first.
  Future<List<List<LatLon>>> buildingsNear(LatLon at, {Duration? timeout}) => _guard(() async {
        final res = await _dio.get<dynamic>(
          '/v1/solar/buildings',
          queryParameters: {'lat': at.lat, 'lon': at.lon, 'radius_m': 60},
          options: timeout == null ? null : Options(receiveTimeout: timeout),
        );
        return [
          for (final b in (_json(res.data)['buildings'] as List<dynamic>).cast<Map<String, dynamic>>())
            [for (final p in (b['polygon'] as List<dynamic>).cast<Map<String, dynamic>>()) LatLon.fromJson(p)],
        ];
      });

  Future<String> historyTemplate() => _guard(() async {
        final res = await _dio.get<String>('/v1/templates/history.csv', options: Options(responseType: ResponseType.plain));
        return res.data ?? '';
      });
}
