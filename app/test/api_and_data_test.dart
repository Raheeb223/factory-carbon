import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:factory_carbon/core/api_client.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('ApiClient', () {
    test('extractBill sends the app token and a multipart JPEG, parses the response', () async {
      final adapter = FakeAdapter((o) => jsonBody({
            'bill': {
              'bill_type': 'electricity',
              'billing_month': '2024-05',
              'period_start': '2024-05-01',
              'period_end': '2024-05-30',
              'consumed_units': 120,
              'unit': 'kWh',
              'total_amount_bdt': 684.0,
              'tariff_code': 'LT-B',
              'sanctioned_load_kw': 2.0,
              'field_confidence': {'consumed_units': 'low'},
              'notes': null,
              'utility_name': null,
            },
            'warnings': [
              {'field': 'consumed_units', 'code': 'low_confidence', 'message': 'check'},
            ],
            'model': 'm',
            'prompt_version': 'v',
          }));
      final r = await fakeApi(adapter).extractBill(Uint8List.fromList([0xff, 0xd8, 0xff]));
      final req = adapter.requests.single;
      expect(req.path, '/v1/extract-bill');
      expect(req.headers['X-App-Token'], 'test-token');
      expect(req.data, isA<FormData>());
      expect(r.bill.consumedUnits, 120);
      expect(r.bill.unit, EnergyUnit.kWh);
      expect(r.bill.periodEnd, DateTime(2024, 5, 30));
      expect(r.bill.fieldConfidence['consumed_units'], 'low');
      expect(r.warnings.single.code, 'low_confidence');
    });

    test('server errors map to typed exceptions with the server message', () async {
      final adapter = FakeAdapter((o) => jsonBody({'error': {'code': 'rate_limited', 'message': 'Too many'}}, status: 429));
      await expectLater(
        fakeApi(adapter).health(),
        throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.rateLimited).having((e) => e.message, 'message', 'Too many')),
      );
      adapter.handler = (o) => jsonBody({'error': {'code': 'unit_mismatch', 'message': 'bad unit'}}, status: 422);
      await expectLater(fakeApi(adapter).calculateCarbonRaw({}), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'unit_mismatch')));
      adapter.handler = (o) => jsonBody({'error': {'code': 'x', 'message': 'y'}}, status: 503);
      await expectLater(fakeApi(adapter).health(), throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.unavailable)));
    });

    test('connection failures become network errors', () async {
      final adapter = FakeAdapter((o) => throw DioException.connectionError(requestOptions: o, reason: 'offline'));
      await expectLater(fakeApi(adapter).health(), throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.network)));
    });

    test('reportPdf returns bytes', () async {
      final adapter = FakeAdapter((o) => ResponseBody.fromBytes([37, 80, 68, 70], 200, headers: {Headers.contentTypeHeader: ['application/pdf']}));
      final bytes = await fakeApi(adapter).reportPdf({'factory': {'name': 'x'}});
      expect(String.fromCharCodes(bytes), '%PDF');
    });
  });

  group('drift repositories', () {
    test('bills: save, list, soft delete, delete by origin', () async {
      final db = memoryDb();
      final repo = DriftBillRepository(db);
      await repo.save(testBill(id: 'a', month: '2024-01', edited: ['consumed_units']));
      await repo.insertAll([testBill(id: 'b', month: '2024-02', origin: DataOrigin.demo), testBill(id: 'c', month: '2024-03', origin: DataOrigin.demo)]);
      var all = await repo.all();
      expect(all.map((b) => b.id), ['c', 'b', 'a']); // newest month first
      expect(all.last.userEditedFields, ['consumed_units']);
      await repo.softDelete('c');
      all = await repo.all();
      expect(all.map((b) => b.id), ['b', 'a']);
      await repo.deleteByOrigin(DataOrigin.demo);
      expect((await repo.all()).map((b) => b.id), ['a']);
      await db.close();
    });

    test('production: one active entry per month', () async {
      final db = memoryDb();
      final repo = DriftProductionRepository(db);
      await repo.upsertMonth('2024-01', 100, DataOrigin.manual);
      await repo.upsertMonth('2024-01', 150, DataOrigin.imported);
      await repo.upsertMonth('2024-02', 90, DataOrigin.manual);
      final all = await repo.all();
      expect(all.map((p) => (p.month, p.unitsProduced, p.origin)), [('2024-02', 90.0, DataOrigin.manual), ('2024-01', 150.0, DataOrigin.imported)]);
      await db.close();
    });

    test('factory profile, solar plans, cache and wipeAll', () async {
      final db = memoryDb();
      await DriftFactoryRepository(db).save(testProfile());
      expect((await DriftFactoryRepository(db).get())?.name, 'Test Garments');
      await DriftSolarPlanRepository(db).save(SolarPlan(id: 's', name: 'Roof A', polygon: const [LatLon(23.8, 90.4)], params: const {'params': <String, dynamic>{}}, resultJson: const {'kwp': 10}, updatedAt: DateTime(2026)));
      final plans = await DriftSolarPlanRepository(db).watchAll().first;
      expect(plans.single.polygon.single.lat, 23.8);
      await DriftResultCacheRepository(db).put('carbon', {'a': 1});
      expect((await DriftResultCacheRepository(db).watch('carbon').first)?.json, {'a': 1});
      await db.wipeAll();
      expect(await DriftFactoryRepository(db).get(), isNull);
      expect(await DriftResultCacheRepository(db).watch('carbon').first, isNull);
      await db.close();
    });
  });
}
