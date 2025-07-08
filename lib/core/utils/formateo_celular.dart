import 'package:flutter/services.dart';

class CelularFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Elimina todo lo que no sea un dígito
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a 10 dígitos
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String formatted = '';

    if (digitsOnly.length < 4) {
      // 1 a 3 dígitos: sin formato
      formatted = digitsOnly;
    } else if (digitsOnly.length < 7) {
      // 4 a 6 dígitos: 123-456
      formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    } else {
      // 7 a 10 dígitos: 123-456-7890
      formatted =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
