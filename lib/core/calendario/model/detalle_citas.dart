import 'package:flutter/material.dart';

class CitaCarro {
  final int carroID;
  final String nombreCarro;
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;
  final double precioTotal;
  final double precioPagado;
  final String observacion;
  CitaCarro({
    required this.carroID,
    required this.nombreCarro,
    required this.fechaInicio,
    required this.pagoMitad,
    required this.tipoPago,
    required this.fechaFin,
    required this.precioTotal,
    required this.precioPagado,
    required this.observacion,
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
  final int carroID;
  final String nombreCarro;
  final bool ocupado;
  final double precioTotal;
  final double precioPagado;
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String observacion;
  final TimeOfDay? horaFinOcupacion;

  EstadoCarro({
    required this.carroID,
    required this.nombreCarro,
    required this.ocupado,
    required this.precioTotal,
    required this.precioPagado,
    required this.pagoMitad,
    required this.tipoPago,
    required this.fechaInicio,
    required this.fechaFin,
    required this.observacion,
    this.horaFinOcupacion,
  });
}
