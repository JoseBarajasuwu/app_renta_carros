import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/database/rentas_db.dart';

Future<List<EstadoCarro>> obtenerEstadoCarros2Isolate(DateTime dia) async {
  final fechaStr =
      "${dia.year.toString().padLeft(4, '0')}-"
      "${dia.month.toString().padLeft(2, '0')}-"
      "${dia.day.toString().padLeft(2, '0')}";

  final rows = await RentaDAO.obtenerHistorialCarros(fecha: fechaStr);

  // Parseamos todas las citas activas en el día en una pasada
  final List<CitaCarro> citasDelDia = [];
  final Map<int, String> idNombreMap = {}; // carroID -> nombreCarro

  final d = DateTime(dia.year, dia.month, dia.day);

  for (var row in rows) {
    idNombreMap[row['CarroID']] = row['NombreCarro'];

    if (row['FechaInicio'] == null || row['FechaFin'] == null) continue;

    final inicio = DateTime.parse(row['FechaInicio']);
    final fin = DateTime.parse(row['FechaFin']);

    final inicioSoloFecha = DateTime(inicio.year, inicio.month, inicio.day);
    final finSoloFecha = DateTime(fin.year, fin.month, fin.day);

    if ((d.isAtSameMomentAs(inicioSoloFecha) || d.isAfter(inicioSoloFecha)) &&
        (d.isAtSameMomentAs(finSoloFecha) || d.isBefore(finSoloFecha))) {
      citasDelDia.add(
        CitaCarro(
          carroID: row['CarroID'],
          nombreCliente: row['NombreCompleto'],
          nombreCarro: row['NombreCarro'],
          precioTotal: double.tryParse(row['PrecioTotal'].toString()) ?? 0,
          precioPagado: double.tryParse(row['PrecioPagado'].toString()) ?? 0,
          pagoMitad:
              (double.tryParse(row['PrecioPagado'].toString()) ?? 0) <
                      (double.tryParse(row['PrecioTotal'].toString()) ?? 0) / 2
                  ? 1
                  : 0,
          tipoPago: row['TipoPago'] ?? '',
          fechaInicio: inicio,
          fechaFin: fin,
          observacion: row['Observaciones'] ?? '',
          horaFinOcupacion: TimeOfDay(hour: fin.hour, minute: fin.minute),
        ),
      );
    }
  }

  // Agrupar citas por carroID
  final Map<int, List<CitaCarro>> agrupadasPorID = {};
  for (var cita in citasDelDia) {
    agrupadasPorID.putIfAbsent(cita.carroID, () => []);
    agrupadasPorID[cita.carroID]!.add(cita);
  }

  // Construir lista final con un solo ciclo
  final List<EstadoCarro> resultado = [];

  for (var entry in idNombreMap.entries) {
    final carroID = entry.key;
    final nombreCarro = entry.value;
    final citas = agrupadasPorID[carroID] ?? [];

    if (citas.isNotEmpty) {
      final citaActiva = citas.first;
      resultado.add(
        EstadoCarro(
          carroID: carroID,
          nombreCliente: citaActiva.nombreCliente,
          nombreCarro: nombreCarro,
          ocupado: true,
          precioPagado: citaActiva.precioPagado,
          precioTotal: citaActiva.precioTotal,
          pagoMitad: citaActiva.pagoMitad,
          tipoPago: citaActiva.tipoPago,
          fechaInicio: citaActiva.fechaInicio,
          fechaFin: citaActiva.fechaFin,
          observacion: citaActiva.observacion,
          horaFinOcupacion: citaActiva.horaFinOcupacion,
        ),
      );
    } else {
      resultado.add(
        EstadoCarro(
          carroID: carroID,
          nombreCliente: '',
          nombreCarro: nombreCarro,
          ocupado: false,
          precioPagado: 0,
          precioTotal: 0,
          pagoMitad: 0,
          tipoPago: '',
          fechaInicio: dia,
          fechaFin: dia,
          observacion: '',
          horaFinOcupacion: null,
        ),
      );
    }
  }

  return resultado;
}
