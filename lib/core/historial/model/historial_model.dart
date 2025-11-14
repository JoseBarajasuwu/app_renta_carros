class Car {
  final int carroID;
  final String model;
  final double totalRenta;
  final double totalServicios;
  final double totalComision;
  final List<Service> services;

  Car({
    required this.carroID,
    required this.model,
    required this.totalRenta,
    required this.totalServicios,
    required this.totalComision,
    required this.services,
  });
}

class Service {
  final int mantenimientoID;
  final String tipoServicio;
  final double costo;
  final String descripcion;

  Service(
    this.mantenimientoID,
    this.tipoServicio,
    this.costo,
    this.descripcion,
  );
}
