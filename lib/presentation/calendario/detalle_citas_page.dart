import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/futures/carga_citas.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/presentation/agendar/agenda_page.dart';

class DetalleCitasPage extends StatelessWidget {
  final DateTime fecha;

  const DetalleCitasPage({super.key, required this.fecha});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agenda de carros - $fechaFormateada',
          style: const TextStyle(fontFamily: 'Quicksand', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF204c6c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<EstadoCarro>>(
        future: compute(obtenerEstadoCarros2Isolate, fecha),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.blueAccent,
              ),
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final estados = snapshot.data ?? [];

          if (estados.isEmpty) {
            return const Center(
              child: Text(
                'No hay carros registrados para esta fecha.',
                style: TextStyle(fontFamily: 'Quicksand'),
              ),
            );
          }

          return ListView.builder(
            key: const PageStorageKey('estadoCarrosList'),
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
                iconoColor = Colors.green;
              } else if (puedeAgendar(
                fecha,
                estado.fechaFin,
                estado.horaFinOcupacion,
              )) {
                iconoColor = Colors.orange;
              } else {
                iconoColor = Colors.red;
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
                  title: Text(
                    estado.nombreCarro,
                    style: TextStyle(fontFamily: 'Quicksand'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ocupacionTexto + detalleHoras,
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      if (iconoColor == Colors.orange ||
                          iconoColor == Colors.red)
                        Text(
                          estado.precioTotal.toString(),
                          style: TextStyle(fontFamily: 'Quicksand'),
                        ),
                      if (iconoColor == Colors.orange ||
                          iconoColor == Colors.red)
                        Text(
                          estado.precioPagado.toString(),
                          style: TextStyle(fontFamily: 'Quicksand'),
                        ),
                      if (iconoColor == Colors.orange ||
                          iconoColor == Colors.red)
                        Text(
                          "50%",
                          style: TextStyle(
                            color:
                                estado.pagoMitad == 1
                                    ? Colors.red
                                    : Colors.green,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      if (iconoColor == Colors.orange ||
                          iconoColor == Colors.red)
                        Text(
                          estado.tipoPago,
                          style: TextStyle(fontFamily: 'Quicksand'),
                        ),
                    ],
                  ),
                  trailing:
                      agendarPosible
                          ? ElevatedButton(
                            onPressed:
                            // () => _mostrarFormularioAgendar(
                            //   context,
                            //   estado.nombreCarro,
                            // ),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AgendarPage(
                                        carroSeleccionado: estado.nombreCarro,
                                        carroID: estado.carroID,
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              'Agendar',
                              style: TextStyle(fontFamily: 'Quicksand'),
                            ),
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
