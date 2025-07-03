import 'package:flutter/material.dart';

class CitaCarro {
  final String nombreCarro;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;

  CitaCarro({
    required this.nombreCarro,
    required this.fechaInicio,
    required this.fechaFin,
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
  final String nombreCarro;
  final bool ocupado;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;

  EstadoCarro({
    required this.nombreCarro,
    required this.ocupado,
    required this.fechaInicio,
    required this.fechaFin,
    this.horaFinOcupacion,
  });
}

class DetalleCitasPage extends StatelessWidget {
  final DateTime fecha;

  const DetalleCitasPage({super.key, required this.fecha});

  Future<List<EstadoCarro>> obtenerEstadoCarros(DateTime dia) async {
    await Future.delayed(const Duration(milliseconds: 200));

    List<CitaCarro> todosCarros = [
      CitaCarro(
        nombreCarro: 'Camioneta A',
        fechaInicio: DateTime(2025, 7, 1),
        fechaFin: DateTime(2025, 7, 3),
        horaFinOcupacion: const TimeOfDay(hour: 13, minute: 0),
      ),
      CitaCarro(
        nombreCarro: 'Sedán B',
        fechaInicio: DateTime(2025, 7, 5),
        fechaFin: DateTime(2025, 7, 5),
      ),
      CitaCarro(
        nombreCarro: 'SUV X',
        fechaInicio: DateTime(2025, 7, 2),
        fechaFin: DateTime(2025, 7, 4),
        horaFinOcupacion: const TimeOfDay(hour: 17, minute: 30),
      ),
      CitaCarro(
        nombreCarro: 'Hatchback Y',
        fechaInicio: DateTime(2025, 7, 6),
        fechaFin: DateTime(2025, 7, 6),
      ),
    ];

    return todosCarros.map((carro) {
      bool ocupado = carro.estaOcupadoEnDia(dia);
      return EstadoCarro(
        nombreCarro: carro.nombreCarro,
        ocupado: ocupado,
        fechaInicio: carro.fechaInicio,
        fechaFin: carro.fechaFin,
        horaFinOcupacion: carro.horaFinOcupacion,
      );
    }).toList();
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

  void _agendarCita(BuildContext context, String nombreCarro) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Agendar cita'),
            content: Text('Agendando cita para el carro "$nombreCarro".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Carros - $fechaFormateada'),
        backgroundColor: Color(0xFF204c6c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<EstadoCarro>>(
        future: obtenerEstadoCarros(fecha),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final estados = snapshot.data ?? [];

          if (estados.isEmpty) {
            return const Center(
              child: Text('No hay carros registrados para esta fecha.'),
            );
          }

          return ListView.builder(
            itemCount: estados.length,
            itemBuilder: (context, index) {
              final estado = estados[index];
              final agendarPosible =
                  !estado.ocupado ||
                  puedeAgendar(fecha, estado.fechaFin, estado.horaFinOcupacion);
              final ocupacionTexto =
                  estado.ocupado
                      ? "Ocupado desde ${estado.fechaInicio.day}/${estado.fechaInicio.month} hasta ${estado.fechaFin.day}/${estado.fechaFin.month}"
                      : "Disponible";

              final detalleHoras =
                  estado.ocupado && estado.horaFinOcupacion != null
                      ? " (Se desocupa a las ${estado.horaFinOcupacion!.format(context)})"
                      : "";
              Color iconoColor;

              if (!estado.ocupado) {
                iconoColor = Colors.green; // disponible todo el día
              } else if (puedeAgendar(
                fecha,
                estado.fechaFin,
                estado.horaFinOcupacion,
              )) {
                iconoColor =
                    Colors.orange; // ocupado pero se puede agendar más tarde
              } else {
                iconoColor = Colors.red; // ocupado y no se puede agendar
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    estado.ocupado
                        ? Icons.directions_car_filled
                        : Icons.directions_car,
                    color: iconoColor,
                  ),
                  title: Text(estado.nombreCarro),
                  subtitle: Text(ocupacionTexto + detalleHoras),
                  trailing:
                      agendarPosible
                          ? ElevatedButton(
                            onPressed:
                                () => _agendarCita(context, estado.nombreCarro),
                            child: const Text('Agendar'),
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
