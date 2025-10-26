import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###", "es_MX");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Quitar comas y ceros a la izquierda (sin eliminar si es solo "0")
    final validNumber = RegExp(r'^(0|[1-9][0-9]*)$');
    String rawText = "";
    if (validNumber.hasMatch(newValue.text)) {
      rawText = newValue.text.replaceAll(',', '');
      // es válido
    } else {
      // no es válido
      rawText = "";
    }

    if (rawText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(rawText);
    if (number == null) return oldValue;

    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
