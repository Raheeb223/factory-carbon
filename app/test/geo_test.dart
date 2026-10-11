import 'package:factory_carbon/domain/geo.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// A square of [sideM] metres with its south-west corner at (lat, lon).
List<LatLon> square(double lat, double lon, double sideM) {
  const mPerDegLat = 111195.0;
  final dLat = sideM / mPerDegLat;
  final dLon = sideM / (mPerDegLat * 0.91497); // cos(23.8°)
  return [LatLon(lat, lon), LatLon(lat, lon + dLon), LatLon(lat + dLat, lon + dLon), LatLon(lat + dLat, lon)];
}

void main() {
  group('coordinates typed by the user', () {
    test('decimal pairs, Bangla digits and map links', () {
      final a = parseLatLon('23.8103, 90.4125')!;
      expect((a.lat, a.lon), (23.8103, 90.4125));
      final b = parseLatLon('23.8103 90.4125')!;
      expect((b.lat, b.lon), (23.8103, 90.4125));
      final c = parseLatLon('২৩.৮১০৩, ৯০.৪১২৫')!;
      expect((c.lat, c.lon), (23.8103, 90.4125));
      final d = parseLatLon('https://www.google.com/maps/@23.9084932,90.3980037,17z')!;
      expect((d.lat, d.lon), (23.9084932, 90.3980037));
    });

    test('place names and out-of-range numbers are not coordinates', () {
      expect(parseLatLon('Tongi'), isNull);
      expect(parseLatLon('Road 12, House 5'), isNull);
      expect(parseLatLon('95.1, 90.4'), isNull);
    });
  });

  group('roof outline', () {
    test('area of a 50 m square is about 2,500 m²', () {
      expect(polygonAreaM2(square(23.8, 90.4, 50)), closeTo(2500, 25));
      expect(polygonAreaM2(square(23.8, 90.4, 50).reversed.toList()), closeTo(2500, 25));
      expect(polygonAreaM2(const [LatLon(23.8, 90.4), LatLon(23.81, 90.4)]), 0);
    });

    test('the tapped building is the smallest outline containing the tap', () {
      final big = square(23.8, 90.4, 200);
      final small = square(23.8005, 90.4005, 30);
      final elsewhere = square(23.81, 90.41, 50);
      // OSM ways repeat the first point at the end
      final closed = [...small, small.first];
      final tapInSmall = LatLon(small.first.lat + 0.0001, small.first.lon + 0.0001);
      expect(pickBuilding([big, closed, elsewhere], tapInSmall), hasLength(4));
      expect(polygonAreaM2(pickBuilding([big, closed, elsewhere], tapInSmall)!), closeTo(900, 10));
      final tapInBig = LatLon(23.8001, 90.4001);
      expect(polygonAreaM2(pickBuilding([big, closed, elsewhere], tapInBig)!), closeTo(40000, 400));
      expect(pickBuilding([small, elsewhere], const LatLon(23.0, 90.0)), isNull);
    });
  });
}
