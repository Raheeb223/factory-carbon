import 'package:flutter/services.dart';

/// Digits (Western or Bangla), decimal point and thousands separators only.
final List<TextInputFormatter> numberInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,]'))];

/// As [numberInput] plus a minus sign (coordinates).
final List<TextInputFormatter> signedNumberInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\-]'))];
