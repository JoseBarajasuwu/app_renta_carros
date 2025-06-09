import 'package:flutter/services.dart';

class CelularFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String formatted = '';
    if (digitsOnly.length >= 3) {
      formatted += digitsOnly.substring(0, 3);
      if (digitsOnly.length >= 6) {
        formatted += '-${digitsOnly.substring(3, 6)}';
        if (digitsOnly.length > 6) {
          formatted += '-${digitsOnly.substring(6)}';
        }
      } else {
        formatted += '-${digitsOnly.substring(3)}';
      }
    } else {
      formatted = digitsOnly;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
