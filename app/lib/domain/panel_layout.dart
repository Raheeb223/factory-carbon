import 'dart:math' as math;

import 'models.dart';

const _earthRadiusM = 6371008.8;

/// Typical 144-cell module (450–600 W), portrait, in metres.
const panelWidthM = 1.13;
const panelLengthM = 2.28;

/// Panels laid out in rows inside a roof outline, for the "after solar" picture.
/// Rows run along the roof's longest edge, keep [setbackM] from every edge (access
/// and fire paths) and [rowGapM] between rows. At most [maxPanels] are placed, the
/// ones nearest the roof's middle first. Illustrative: an installer's layout will differ.
List<List<LatLon>> panelLayout(
  List<LatLon> roof, {
  required int maxPanels,
  double setbackM = 1.0,
  double rowGapM = 0.5,
  double colGapM = 0.03,
}) {
  if (roof.length < 3 || maxPanels <= 0) return const [];
  final lat0 = roof.map((p) => p.lat).reduce((a, b) => a + b) / roof.length;
  final lon0 = roof.map((p) => p.lon).reduce((a, b) => a + b) / roof.length;
  final k = _earthRadiusM * math.pi / 180;
  final kx = k * math.cos(lat0 * math.pi / 180);

  // Local metres, rotated so the longest edge lies along x.
  final xy = [for (final p in roof) ((p.lon - lon0) * kx, (p.lat - lat0) * k)];
  var angle = 0.0;
  var longest = 0.0;
  for (var i = 0; i < xy.length; i++) {
    final (x1, y1) = xy[i];
    final (x2, y2) = xy[(i + 1) % xy.length];
    final len = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
    if (len > longest) {
      longest = len;
      angle = math.atan2(y2 - y1, x2 - x1);
    }
  }
  final c = math.cos(-angle), s = math.sin(-angle);
  final poly = [for (final (x, y) in xy) (x * c - y * s, x * s + y * c)];

  final minX = poly.map((p) => p.$1).reduce(math.min), maxX = poly.map((p) => p.$1).reduce(math.max);
  final minY = poly.map((p) => p.$2).reduce(math.min), maxY = poly.map((p) => p.$2).reduce(math.max);

  bool fits(double x, double y) {
    for (final (px, py) in [(x, y), (x + panelWidthM, y), (x, y + panelLengthM), (x + panelWidthM, y + panelLengthM)]) {
      if (!_inside(poly, px, py) || _edgeDistance(poly, px, py) < setbackM - 1e-6) return false; // tolerance for rounding
    }
    return true;
  }

  final placed = <(double, double)>[];
  for (var y = minY + setbackM; y + panelLengthM <= maxY - setbackM; y += panelLengthM + rowGapM) {
    for (var x = minX + setbackM; x + panelWidthM <= maxX - setbackM; x += panelWidthM + colGapM) {
      if (fits(x, y)) placed.add((x, y));
    }
  }
  if (placed.length > maxPanels) {
    double d((double, double) p) => math.pow(p.$1 + panelWidthM / 2, 2) + math.pow(p.$2 + panelLengthM / 2, 2).toDouble();
    placed.sort((a, b) => d(a).compareTo(d(b)));
    placed.removeRange(maxPanels, placed.length);
  }

  // Back to lat/lon: undo the rotation, then the projection.
  final cb = math.cos(angle), sb = math.sin(angle);
  LatLon back(double x, double y) => LatLon(lat0 + (x * sb + y * cb) / k, lon0 + (x * cb - y * sb) / kx);
  return [
    for (final (x, y) in placed)
      [back(x, y), back(x + panelWidthM, y), back(x + panelWidthM, y + panelLengthM), back(x, y + panelLengthM)],
  ];
}

bool _inside(List<(double, double)> poly, double x, double y) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final (xi, yi) = poly[i];
    final (xj, yj) = poly[j];
    if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}

double _edgeDistance(List<(double, double)> poly, double x, double y) {
  var best = double.infinity;
  for (var i = 0; i < poly.length; i++) {
    final (x1, y1) = poly[i];
    final (x2, y2) = poly[(i + 1) % poly.length];
    final dx = x2 - x1, dy = y2 - y1;
    final len2 = dx * dx + dy * dy;
    final t = len2 == 0 ? 0.0 : (((x - x1) * dx + (y - y1) * dy) / len2).clamp(0.0, 1.0);
    final ex = x1 + t * dx - x, ey = y1 + t * dy - y;
    best = math.min(best, math.sqrt(ex * ex + ey * ey));
  }
  return best;
}
