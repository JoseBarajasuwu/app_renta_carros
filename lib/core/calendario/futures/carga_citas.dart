import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/core/utils/parse_double.dart';
import 'package:renta_carros/database/rentas_db.dart';

Future<List<EstadoCarro>> obtenerEstadoCarros2Isolate(DateTime dia) async {
  final String fechaStr =
      "${dia.year.toString().padLeft(4, '0')}-"
      "${dia.month.toString().padLeft(2, '0')}-"
      "${dia.day.toString().padLeft(2, '0')}";

  // Obtener todas las rentas del día
  final rows = await RentaDAO.obtenerHistorialCarros(fecha: fechaStr);

  final List<CitaCarro> citasDelDia = [];
  final Map<int, Map<String, dynamic>> datosCarros =
      {}; // carroID -> datos extras
  final DateTime d = DateTime(dia.year, dia.month, dia.day);

  // Procesar las rentas
  for (var row in rows) {
    final int carroID = row['CarroID'];
    final String nombreCarro = row['NombreCarro'] ?? '';

    // Guardar datos generales del carro
    datosCarros[carroID] = {
      'precioTotal': parseDouble(row['PrecioTotal']),
      'precioPagado': parseDouble(row['PrecioPagado']),
      'tipoPago': row['TipoPago'] ?? '',
      'nombreCarro': nombreCarro,
    };

    if (row['FechaInicio'] == null || row['FechaFin'] == null) continue;

    final DateTime inicio = DateTime.parse(row['FechaInicio']);
    final DateTime fin = DateTime.parse(row['FechaFin']);

    final DateTime inicioSoloFecha = DateTime(
      inicio.year,
      inicio.month,
      inicio.day,
    );
    final DateTime finSoloFecha = DateTime(fin.year, fin.month, fin.day);

    if ((d.isAtSameMomentAs(inicioSoloFecha) || d.isAfter(inicioSoloFecha)) &&
        (d.isAtSameMomentAs(finSoloFecha) || d.isBefore(finSoloFecha))) {
      if (row['NombreCompleto'] != null) {
        citasDelDia.add(
          CitaCarro(
            rentaID: row['RentaID'],
            carroID: carroID,
            nombreCliente: row['NombreCompleto'] ?? "",
            nombreCarro: row['NombreCarro'] ?? "",
            precioTotal: parseDouble(row['PrecioTotal']),
            precioPagado: parseDouble(row['PrecioPagado']),
            pagoMitad:
                (parseDouble(row['PrecioPagado'])) <
                        (parseDouble(row['PrecioTotal'])) / 2
                    ? 1
                    : 0,
            resto:
                (parseDouble(row['PrecioTotal'])) -
                (parseDouble(row['PrecioPagado'])),
            tipoPago: row['TipoPago'] ?? '',
            fechaInicio: inicio,
            fechaFin: fin,
            observacion: row['Observaciones'] ?? '',
            horaFinOcupacion: TimeOfDay(hour: fin.hour, minute: fin.minute),
          ),
        );
      } else {
        if (row['RentaID'] != null && row['RentaID'] != 0) {
          await RentaDAO.eliminarRepetidos(rentaID: row['RentaID']);
        }
      }
    }
  }

  // Construir resultado final
  final List<EstadoCarro> resultado = [];
  final Set<int> carrosConRenta = {}; // Para identificar carros ocupados

  // Agregar todas las rentas activas
  for (var cita in citasDelDia) {
    resultado.add(
      EstadoCarro(
        rentaID: cita.rentaID,
        carroID: cita.carroID,
        nombreCliente: cita.nombreCliente,
        nombreCarro: cita.nombreCarro,
        ocupado: true,
        precioPagado: cita.precioPagado,
        precioTotal: cita.precioTotal,
        pagoMitad: cita.pagoMitad,
        resto: cita.resto,
        tipoPago: cita.tipoPago,
        fechaInicio: cita.fechaInicio,
        fechaFin: cita.fechaFin,
        observacion: cita.observacion,
        horaFinOcupacion: cita.horaFinOcupacion,
      ),
    );
    carrosConRenta.add(cita.carroID);
  }

  // Agregar los carros libres
  for (var carro in rows) {
    final int carroID = carro['CarroID'];
    final String nombreCarro = carro['NombreCarro'] ?? '';
    if (!carrosConRenta.contains(carroID)) {
      final datos = datosCarros[carroID] ?? {};
      resultado.add(
        EstadoCarro(
          rentaID: 0,
          carroID: carroID,
          nombreCliente: '',
          nombreCarro: nombreCarro,
          ocupado: false,
          precioPagado: parseDouble(datos['precioPagado']),
          precioTotal: parseDouble(datos['precioTotal']),
          pagoMitad: 0,
          resto: 0,
          tipoPago: datos['tipoPago'] ?? '',
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
