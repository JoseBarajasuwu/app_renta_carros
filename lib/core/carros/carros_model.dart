class Renta {
  final String fechaInicio;
  final String fechaFin;
  final double precioTotal;
  final double precioPagado;
  final String? tipoPago;
  final String? observaciones;
  final double comision;

  Renta({
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioTotal,
    required this.precioPagado,
    required this.comision,
    this.tipoPago,
    this.observaciones,
  });
}

class ServicioDetalle {
  final String fecha;
  final String tipo;
  final double costo;
  final String? descripcion;

  ServicioDetalle(this.fecha, this.tipo, this.costo, [this.descripcion]);
}

class CarHistorial {
  final int carroID;
  final String model;
  final List<Renta> rentas;
  final List<ServicioDetalle> serviciosDetalle;

  CarHistorial({
    required this.carroID,
    required this.model,
    required this.rentas,
    required this.serviciosDetalle,
  });
}
