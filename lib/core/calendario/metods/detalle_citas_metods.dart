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

  if (d.isBefore(fin)) {
    // Día antes del fin, carro ocupado → no disponible
    return false;
  }

  if (d.isAtSameMomentAs(fin)) {
    if (horaFinOcupacion == null) {
      // Sin hora fin, ocupa todo el día → no disponible
      return false;
    }
    // Aquí permitimos agendar si la hora actual es antes que la hora fin
    // porque se libera durante el día y puede usarse para lo que quede
    return true;
  }

  // Día después del fin → disponible
  if (d.isAfter(fin)) {
    return true;
  }

  // Caso por defecto (seguridad)
  return true;
}
