import 'package:flutter/material.dart';

class CitaCarro {
  final int rentaID;
  final int carroID;
  final String nombreCliente;
  final String nombreCarro;
  final double precioTotal;
  final double precioPagado;
  final double resto;
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;
  final double comision;
  final String observacion;
  CitaCarro({
    required this.rentaID,
    required this.carroID,
    required this.nombreCliente,
    required this.nombreCarro,
    required this.fechaInicio,
    required this.pagoMitad,
    required this.tipoPago,
    required this.resto,
    required this.fechaFin,
    required this.precioTotal,
    required this.precioPagado,
    required this.observacion,
    required this.comision,
    this.horaFinOcupacion,
  });

  bool estaOcupadoEnDia(DateTime dia) {
    final d = DateTime(dia.year, dia.month, dia.day);
    final inicio = DateTime(
      fechaInicio.year,
      fechaInicio.month,
      fechaInicio.day,
    );
    final fin = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    return (d.isAtSameMomentAs(inicio) || d.isAfter(inicio)) &&
        (d.isAtSameMomentAs(fin) || d.isBefore(fin));
  }
}

class EstadoCarro {
  final int rentaID;
  final int carroID;
  final String nombreCliente;
  final String nombreCarro;
  final bool ocupado;
  final double precioTotal;
  final double precioPagado;
  final double resto;
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String observacion;
  final double comision;
  final TimeOfDay? horaFinOcupacion;

  EstadoCarro({
    required this.rentaID,
    required this.carroID,
    required this.nombreCliente,
    required this.nombreCarro,
    required this.ocupado,
    required this.precioTotal,
    required this.precioPagado,
    required this.resto,
    required this.pagoMitad,
    required this.tipoPago,
    required this.fechaInicio,
    required this.fechaFin,
    required this.observacion,
    required this.comision,
    this.horaFinOcupacion,
  });
}
