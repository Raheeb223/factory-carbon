/// Decides which lines of text found on a bill photo are private (people's names,
/// addresses) so they can be covered automatically before the photo leaves the phone.
/// Pure Dart so it is unit tested without a device.
library;

import 'image_prep.dart';

/// One line of text found on the photo, with its box in fractions (0..1) of the photo.
class FoundText {
  const FoundText(this.text, this.left, this.top, this.right, this.bottom);
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
}

// Words that mark a person or their address. A line with one of these is covered
// even if it also has numbers ("Consumer Name: ...", "House 12, Road 5").
final _personWords = RegExp(
  r'\b(name|father|husband|s/o|d/o|w/o|mr|mrs|ms|md|mst|mosammat|mohammad|mohammed|muhammad|begum|khatun|uddin|ahmed|ahmad|hossain|hussain|rahman|islam|alam|chowdhury|sarker|akter|akhter)\b',
  caseSensitive: false,
);
final _addressWords = RegExp(
  r'\b(address|addr|road|rd|flat|house|holding|lane|garden|sector|block|avenue|ave|village|vill|para|bazar|nagar|union|upazila|thana|p\.?o|post|ward|floor|apt|apartment|street|st)\b',
  caseSensitive: false,
);
// Words on the parts of a bill we need to read. Such a line is never covered.
final _billWords = RegExp(
  r'(unit|kwh|\bkw\b|reading|amount|total|bill|month|date|\bdue\b|vat|tariff|charge|demand|taka|\btk\b|bdt|energy|consum|payable|previous|present|current|meter|usage|used|period|rate|\bnet\b|\bgas\b|diesel|lit(re|er)|ltr|\bm3\b|fuel|\blpg\b|cylinder|furnace|\boil\b|\bkg\b|factor|peak|load|arrear|surcharge|principal|paid|payment|issue|industrial|commercial|domestic|residential|category|class|sanction)',
  caseSensitive: false,
);
final _digit = RegExp(r'[0-9০-৯]');
final _latinLetter = RegExp(r'[A-Za-z]');

/// True when [text] looks like a name or address rather than a value we need.
bool looksPrivate(String text) {
  final t = text.trim();
  if (_personWords.hasMatch(t) || _addressWords.hasMatch(t)) return true;
  final letters = _latinLetter.allMatches(t).length;
  if (letters < 3 || _billWords.hasMatch(t) || _digit.hasMatch(t)) return false;
  // Only words left: a name, an area or a bank branch. Bills print these in capitals
  // (or Title Case). Bangla text misread as Latin comes out as lowercase gibberish
  // ("faer", "jsteto"), and is left alone so labels next to the values stay readable.
  final visible = t.replaceAll(RegExp(r'\s'), '').length;
  if (letters / visible < 0.7) return false;
  final upper = RegExp(r'[A-Z]').allMatches(t).length;
  final words = t.split(RegExp(r'\s+')).where((w) => _latinLetter.hasMatch(w)).toList();
  // Title Case counts only for plain words ("Rahima Begum"), not codes like "LT-E (Industrial)".
  final titleCase = words.length >= 2 && words.every((w) => RegExp(r"^[A-Z][A-Za-z.']*,?$").hasMatch(w));
  return upper / letters >= 0.6 || titleCase;
}

// A value we must keep readable: a bill word, or a number.
bool _isValue(String text) => _billWords.hasMatch(text) || _digit.allMatches(text).length >= 2;

class _Rect {
  _Rect(this.left, this.top, this.right, this.bottom);
  _Rect.of(FoundText t) : this(t.left, t.top, t.right, t.bottom);
  double left, top, right, bottom;
  double get height => bottom - top;
  bool overlaps(_Rect o) => left < o.right && o.left < right && top < o.bottom && o.top < bottom;

  /// Lines of one name/address block: stacked with less than a line of gap, or side
  /// by side on the same row ("MD" + "ROIS UDDIN").
  bool near(_Rect o) {
    final lineH = height > o.height ? height : o.height;
    final gapY = (top > o.bottom ? top - o.bottom : (o.top > bottom ? o.top - bottom : 0.0));
    final gapX = (left > o.right ? left - o.right : (o.left > right ? o.left - right : 0.0));
    return gapY <= lineH * 1.2 && gapX <= 0.03;
  }

  void add(_Rect o) {
    if (o.left < left) left = o.left;
    if (o.top < top) top = o.top;
    if (o.right > right) right = o.right;
    if (o.bottom > bottom) bottom = o.bottom;
  }

  /// Grown a little because text boxes hug the letters; [lineH] is one text line's height.
  _Rect padded(double lineH) =>
      _Rect((left - 0.008).clamp(0.0, 1.0), (top - lineH * 0.15).clamp(0.0, 1.0), (right + 0.008).clamp(0.0, 1.0), (bottom + lineH * 0.15).clamp(0.0, 1.0));

  RedactBox get box => RedactBox(left, top, right, bottom);
}

/// Black boxes for the private lines. Lines of one name/address block become one box,
/// which also covers the bits the reader missed ("20," or "FLAT NO-B/3" between two
/// covered lines). A box never covers a number or bill label we need: when the block
/// box would, each line is boxed on its own, and a line without a name or address
/// word (a stamp, a bank branch) is skipped if it touches a value.
List<RedactBox> privateBoxes(List<FoundText> lines) {
  final private = [
    for (final l in lines)
      if (looksPrivate(l.text)) l,
  ];
  final values = [
    for (final l in lines)
      if (!private.contains(l) && _isValue(l.text)) _Rect.of(l),
  ];
  bool hidesValue(_Rect r) => values.any(r.overlaps);

  final groups = <List<FoundText>>[];
  for (final l in private) {
    final r = _Rect.of(l);
    final touching = groups.where((g) => g.any((m) => _Rect.of(m).near(r))).toList();
    final merged = [l, for (final g in touching) ...g];
    groups
      ..removeWhere(touching.contains)
      ..add(merged);
  }
  final out = <RedactBox>[];
  for (final g in groups) {
    final union = _Rect.of(g.first);
    for (final m in g.skip(1)) {
      union.add(_Rect.of(m));
    }
    final lineH = g.map((m) => _Rect.of(m).height).reduce((a, b) => a + b) / g.length;
    final block = union.padded(lineH);
    if (!hidesValue(block)) {
      out.add(block.box);
      continue;
    }
    for (final m in g) {
      final r = _Rect.of(m).padded(_Rect.of(m).height);
      final strong = _personWords.hasMatch(m.text) || _addressWords.hasMatch(m.text);
      if (strong || !hidesValue(r)) out.add(r.box);
    }
  }
  return out;
}
