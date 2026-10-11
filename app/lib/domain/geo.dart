import 'dart:math' as math;

import 'models.dart';

const _earthRadiusM = 6371008.8;
const _banglaDigits = '০১২৩৪৫৬৭৮৯';

/// Reads coordinates typed or pasted by the user: "23.8103, 90.4125", "23.8103 90.4125",
/// Bangla digits, or a Google Maps link containing "@23.81,90.41,17z". Null if none found.
LatLon? parseLatLon(String text) {
  final b = StringBuffer();
  for (final ch in text.split('')) {
    final i = _banglaDigits.indexOf(ch);
    b.write(i >= 0 ? '$i' : ch);
  }
  final m = RegExp(r'(-?\d{1,2}\.\d+)\s*[,\s]\s*(-?\d{1,3}\.\d+)').firstMatch(b.toString());
  if (m == null) return null;
  final lat = double.parse(m.group(1)!);
  final lon = double.parse(m.group(2)!);
  if (lat.abs() > 90 || lon.abs() > 180) return null;
  return LatLon(lat, lon);
}

/// Projects onto a local flat plane in metres around the polygon's first point.
/// Accurate enough for a factory roof (well under 1% error at a few hundred metres).
List<(double, double)> _toMetres(List<LatLon> poly) {
  final lat0 = poly.first.lat * math.pi / 180;
  final k = _earthRadiusM * math.pi / 180;
  return [for (final p in poly) ((p.lon - poly.first.lon) * k * math.cos(lat0), (p.lat - poly.first.lat) * k)];
}

/// Area of a roof outline in square metres (shoelace formula on a local projection).
double polygonAreaM2(List<LatLon> poly) {
  if (poly.length < 3) return 0;
  final xy = _toMetres(poly);
  var sum = 0.0;
  for (var i = 0; i < xy.length; i++) {
    final (x1, y1) = xy[i];
    final (x2, y2) = xy[(i + 1) % xy.length];
    sum += x1 * y2 - x2 * y1;
  }
  return sum.abs() / 2;
}

/// Ray casting point-in-polygon test (lon = x, lat = y).
bool containsPoint(List<LatLon> poly, LatLon p) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final a = poly[i];
    final b = poly[j];
    if ((a.lat > p.lat) != (b.lat > p.lat) && p.lon < (b.lon - a.lon) * (p.lat - a.lat) / (b.lat - a.lat) + a.lon) {
      inside = !inside;
    }
  }
  return inside;
}

/// The building outline the user tapped: the smallest outline that contains the point
/// (a small shed inside a big shed wins). The repeated closing point is removed.
List<LatLon>? pickBuilding(List<List<LatLon>> outlines, LatLon tap) {
  List<LatLon>? best;
  var bestArea = double.infinity;
  for (var o in outlines) {
    if (o.length > 3 && o.first.lat == o.last.lat && o.first.lon == o.last.lon) o = o.sublist(0, o.length - 1);
    if (o.length < 3 || !containsPoint(o, tap)) continue;
    final area = polygonAreaM2(o);
    if (area < bestArea) {
      best = o;
      bestArea = area;
    }
  }
  return best;
}
