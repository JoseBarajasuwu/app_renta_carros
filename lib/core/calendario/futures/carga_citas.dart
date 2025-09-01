import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/database/rentas_db.dart';

// Future<List<EstadoCarro>> obtenerEstadoCarros2Isolate(DateTime dia) async {
//   final fechaStr =
//       "${dia.year.toString().padLeft(4, '0')}-"
//       "${dia.month.toString().padLeft(2, '0')}-"
//       "${dia.day.toString().padLeft(2, '0')}";

//   final rows = await RentaDAO.obtenerHistorialCarros(fecha: fechaStr);

//   // Parseamos todas las citas activas en el día en una pasada
//   final List<CitaCarro> citasDelDia = [];
//   final Map<int, String> idNombreMap = {}; // carroID -> nombreCarro

//   final d = DateTime(dia.year, dia.month, dia.day);

//   for (var row in rows) {
//     idNombreMap[row['CarroID']] = row['NombreCarro'];

//     if (row['FechaInicio'] == null || row['FechaFin'] == null) continue;

//     final inicio = DateTime.parse(row['FechaInicio']);
//     final fin = DateTime.parse(row['FechaFin']);

//     final inicioSoloFecha = DateTime(inicio.year, inicio.month, inicio.day);
//     final finSoloFecha = DateTime(fin.year, fin.month, fin.day);

//     if ((d.isAtSameMomentAs(inicioSoloFecha) || d.isAfter(inicioSoloFecha)) &&
//         (d.isAtSameMomentAs(finSoloFecha) || d.isBefore(finSoloFecha))) {
//       citasDelDia.add(
//         CitaCarro(
//           rentaID: row['RentaID'],
//           carroID: row['CarroID'],
//           nombreCliente: row['NombreCompleto'],
//           nombreCarro: row['NombreCarro'],
//           precioTotal: double.tryParse(row['PrecioTotal'].toString()) ?? 0,
//           precioPagado: double.tryParse(row['PrecioPagado'].toString()) ?? 0,
//           pagoMitad:
//               (double.tryParse(row['PrecioPagado'].toString()) ?? 0) <
//                       (double.tryParse(row['PrecioTotal'].toString()) ?? 0) / 2
//                   ? 1
//                   : 0,
//           resto:
//               (double.tryParse(row['PrecioTotal'].toString()) ?? 0) -
//               (double.tryParse(row['PrecioPagado'].toString()) ?? 0),
//           tipoPago: row['TipoPago'] ?? '',
//           fechaInicio: inicio,
//           fechaFin: fin,
//           observacion: row['Observaciones'] ?? '',
//           horaFinOcupacion: TimeOfDay(hour: fin.hour, minute: fin.minute),
//         ),
//       );
//     }
//   }

//   // Agrupar citas por carroID
//   final Map<int, List<CitaCarro>> agrupadasPorID = {};
//   for (var cita in citasDelDia) {
//     agrupadasPorID.putIfAbsent(cita.carroID, () => []);
//     agrupadasPorID[cita.carroID]!.add(cita);
//   }

//   // Construir lista final con un solo ciclo
//   final List<EstadoCarro> resultado = [];

//   for (var entry in idNombreMap.entries) {
//     final carroID = entry.key;
//     final nombreCarro = entry.value;
//     final citas = agrupadasPorID[carroID] ?? [];

//     if (citas.isNotEmpty) {
//       final citaActiva = citas.first;
//       resultado.add(
//         EstadoCarro(
//           rentaID: citaActiva.rentaID,
//           carroID: carroID,
//           nombreCliente: citaActiva.nombreCliente,
//           nombreCarro: nombreCarro,
//           ocupado: true,
//           precioPagado: citaActiva.precioPagado,
//           precioTotal: citaActiva.precioTotal,
//           pagoMitad: citaActiva.pagoMitad,
//           resto: citaActiva.resto,
//           tipoPago: citaActiva.tipoPago,
//           fechaInicio: citaActiva.fechaInicio,
//           fechaFin: citaActiva.fechaFin,
//           observacion: citaActiva.observacion,
//           horaFinOcupacion: citaActiva.horaFinOcupacion,
//         ),
//       );
//     } else {
//       resultado.add(
//         EstadoCarro(
//           rentaID: 0,
//           carroID: carroID,
//           nombreCliente: '',
//           nombreCarro: nombreCarro,
//           ocupado: false,
//           precioPagado: 0,
//           precioTotal: 0,
//           pagoMitad: 0,
//           resto: 0,
//           tipoPago: '',
//           fechaInicio: dia,
//           fechaFin: dia,
//           observacion: '',
//           horaFinOcupacion: null,
//         ),
//       );
//     }
//   }

//   return resultado;
// }
Future<List<EstadoCarro>> obtenerEstadoCarros2Isolate(DateTime dia) async {
  final fechaStr =
      "${dia.year.toString().padLeft(4, '0')}-"
      "${dia.month.toString().padLeft(2, '0')}-"
      "${dia.day.toString().padLeft(2, '0')}";

  final rows = await RentaDAO.obtenerHistorialCarros(fecha: fechaStr);

  final List<CitaCarro> citasDelDia = [];
  final Map<int, String> idNombreMap = {}; // carroID -> nombreCarro
  final Map<int, Map<String, dynamic>> datosCarros =
      {}; // carroID -> datos extras

  final d = DateTime(dia.year, dia.month, dia.day);

  for (var row in rows) {
    final carroID = row['CarroID'];
    idNombreMap[carroID] = row['NombreCarro'];

    // Guardamos datos aunque no esté ocupado ese día
    datosCarros[carroID] = {
      'precioTotal': double.tryParse(row['PrecioTotal'].toString()) ?? 0,
      'precioPagado': double.tryParse(row['PrecioPagado'].toString()) ?? 0,
      'tipoPago': row['TipoPago'] ?? '',
      'comision': double.tryParse(row['Comision'].toString()) ?? 0,
    };

    if (row['FechaInicio'] == null || row['FechaFin'] == null) continue;

    final inicio = DateTime.parse(row['FechaInicio']);
    final fin = DateTime.parse(row['FechaFin']);

    final inicioSoloFecha = DateTime(inicio.year, inicio.month, inicio.day);
    final finSoloFecha = DateTime(fin.year, fin.month, fin.day);

    if ((d.isAtSameMomentAs(inicioSoloFecha) || d.isAfter(inicioSoloFecha)) &&
        (d.isAtSameMomentAs(finSoloFecha) || d.isBefore(finSoloFecha))) {
      citasDelDia.add(
        CitaCarro(
          rentaID: row['RentaID'],
          carroID: carroID,
          nombreCliente: row['NombreCompleto'],
          nombreCarro: row['NombreCarro'],
          precioTotal: double.tryParse(row['PrecioTotal'].toString()) ?? 0,
          precioPagado: double.tryParse(row['PrecioPagado'].toString()) ?? 0,
          pagoMitad:
              (double.tryParse(row['PrecioPagado'].toString()) ?? 0) <
                      (double.tryParse(row['PrecioTotal'].toString()) ?? 0) / 2
                  ? 1
                  : 0,
          resto:
              (double.tryParse(row['PrecioTotal'].toString()) ?? 0) -
              (double.tryParse(row['PrecioPagado'].toString()) ?? 0),
          tipoPago: row['TipoPago'] ?? '',
          fechaInicio: inicio,
          fechaFin: fin,
          observacion: row['Observaciones'] ?? '',
          comision: double.tryParse(row['Comision'].toString()) ?? 0,
          horaFinOcupacion: TimeOfDay(hour: fin.hour, minute: fin.minute),
        ),
      );
    }
  }

  final Map<int, List<CitaCarro>> agrupadasPorID = {};
  for (var cita in citasDelDia) {
    agrupadasPorID.putIfAbsent(cita.carroID, () => []);
    agrupadasPorID[cita.carroID]!.add(cita);
  }

  final List<EstadoCarro> resultado = [];

  for (var entry in idNombreMap.entries) {
    final carroID = entry.key;
    final nombreCarro = entry.value;
    final citas = agrupadasPorID[carroID] ?? [];

    if (citas.isNotEmpty) {
      final citaActiva = citas.first;
      resultado.add(
        EstadoCarro(
          rentaID: citaActiva.rentaID,
          carroID: carroID,
          nombreCliente: citaActiva.nombreCliente,
          nombreCarro: nombreCarro,
          ocupado: true,
          precioPagado: citaActiva.precioPagado,
          precioTotal: citaActiva.precioTotal,
          pagoMitad: citaActiva.pagoMitad,
          resto: citaActiva.resto,
          tipoPago: citaActiva.tipoPago,
          fechaInicio: citaActiva.fechaInicio,
          fechaFin: citaActiva.fechaFin,
          observacion: citaActiva.observacion,
          comision: citaActiva.comision,
          horaFinOcupacion: citaActiva.horaFinOcupacion,
        ),
      );
    } else {
      final datos = datosCarros[carroID] ?? {};
      final precioTotal = datos['precioTotal'] ?? 0.0;
      final precioPagado = datos['precioPagado'] ?? 0.0;
      final comision = datos['comision'] ?? 0.0;
      final tipoPago = datos['tipoPago'] ?? '';
      resultado.add(
        EstadoCarro(
          rentaID: 0,
          carroID: carroID,
          nombreCliente: '',
          nombreCarro: nombreCarro,
          ocupado: false,
          precioPagado: precioPagado,
          precioTotal: precioTotal,
          pagoMitad: 0,
          resto: 0,
          tipoPago: tipoPago,
          fechaInicio: dia,
          fechaFin: dia,
          observacion: '',
          comision: comision,
          horaFinOcupacion: null,
        ),
      );
    }
  }

  return resultado;
}
