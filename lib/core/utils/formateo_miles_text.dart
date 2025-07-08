import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  // final NumberFormat _formatter = NumberFormat("#,###");
  final NumberFormat _formatter = NumberFormat("#,##0.00", "es_MX");
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Quitar comas y ceros a la izquierda
    String rawText = newValue.text
        .replaceAll(',', '')
        .replaceFirst(RegExp(r'^0+'), '');

    // Si está vacío después de limpiar, no hacer nada
    if (rawText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Convertir a número
    final number = int.tryParse(rawText);
    if (number == null) return oldValue;

    // Formatear con comas
    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
