import 'package:flutter/material.dart';

Icon getIconoMetodoPago(String? metodo) {
  switch (metodo) {
    case 'Efectivo':
      return Icon(Icons.money, color: Colors.green);
    case 'Transferencia':
      return Icon(Icons.account_balance, color: Colors.blue);
    case 'Tarjeta':
      return Icon(Icons.credit_card, color: Colors.purple);
    default:
      return Icon(Icons.payment, color: Colors.grey); // Ícono por defecto
  }
}

bool puedeAgendar(
  DateTime dia,
  DateTime fechaFin,
  TimeOfDay? horaFinOcupacion,
) {
  final d = DateTime(dia.year, dia.month, dia.day);
  final fin = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);

  // Si el día está antes del último día ocupado, no puede agendar
  if (d.isBefore(fin)) {
    return false;
  }

  // Si el día es el último día ocupado
  if (d.isAtSameMomentAs(fin)) {
    if (horaFinOcupacion == null) {
      // Sin hora de liberación: ocupado todo el día, no puede agendar
      return false;
    }

    // Si es el último día, la hora de liberación importa
    final ahora = TimeOfDay.now();
    final ahoraMinutos = ahora.hour * 60 + ahora.minute;
    final finMinutos = horaFinOcupacion.hour * 60 + horaFinOcupacion.minute;

    // Solo puede agendar si la hora actual es igual o mayor que la hora de liberación
    return ahoraMinutos >= finMinutos;
  }

  // Si está después del último día ocupado, puede agendar
  if (d.isAfter(fin)) {
    return true;
  }

  // Caso por defecto (no debería pasar)
  return true;
}
