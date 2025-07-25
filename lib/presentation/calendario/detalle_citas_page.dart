import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/futures/carga_citas.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:renta_carros/presentation/agendar/agenda_page.dart';

class DetalleCitasPage extends StatefulWidget {
  final DateTime fecha;

  const DetalleCitasPage({super.key, required this.fecha});

  @override
  State<DetalleCitasPage> createState() => _DetalleCitasPageState();
}

class _DetalleCitasPageState extends State<DetalleCitasPage> {
  bool _mostrarSoloDisponibles = true;
  eliminarCita(int index) async {
    print(index);
    // setState(() => isLoading = true);
    // if (index == indexEditando) {
    //   nombreController.clear();
    //   apellidoController.clear();
    //   celularController.clear();
    //   setState(() {
    //     indexEditando = null;
    //   });
    // }
    // RentaDAO.eliminar(rentaID: index);
    // await cargarUsuarios();
  }
  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
        "${widget.fecha.day}/${widget.fecha.month}/${widget.fecha.year}";

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SwitchListTile(
              title: const Text(
                "Mostrar toda la lista de rentas",
                style: TextStyle(fontFamily: 'Quicksand'),
              ),
              value: _mostrarSoloDisponibles,
              onChanged: (value) {
                setState(() {
                  _mostrarSoloDisponibles = value;
                });
              },
              secondary: const Icon(Icons.filter_alt),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EstadoCarro>>(
              future: compute(obtenerEstadoCarros2Isolate, widget.fecha),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<EstadoCarro> estados = snapshot.data ?? [];

                if (_mostrarSoloDisponibles) {
                  estados =
                      estados.where((e) {
                        if (!e.ocupado) return true;

                        final fechaFinEsHoy =
                            e.fechaFin.year == widget.fecha.year &&
                            e.fechaFin.month == widget.fecha.month &&
                            e.fechaFin.day == widget.fecha.day;

                        return fechaFinEsHoy;
                      }).toList();
                }

                if (estados.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay carros para mostrar en esta fecha.',
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: estados.length,
                  itemBuilder: (context, index) {
                    final estado = estados[index];
                    final agendarPosible =
                        !estado.ocupado ||
                        puedeAgendar(
                          widget.fecha,
                          estado.fechaFin,
                          estado.horaFinOcupacion,
                        );

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
                      widget.fecha,
                      estado.fechaFin,
                      estado.horaFinOcupacion,
                    )) {
                      iconoColor = Colors.orange;
                    } else {
                      iconoColor = Colors.red;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          estado.ocupado
                              ? Icons.directions_car_filled
                              : Icons.directions_car,
                          color: iconoColor,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              estado.nombreCarro,
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                            if (estado.ocupado)
                            Row(
                              children: [
                                IconButton(
                                  iconSize: 18,
                                  splashRadius: 14,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.edit_calendar_outlined,
                                    color: const Color(0xFF204c6c),
                                  ),
                                  onPressed: () {},
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  iconSize: 18,
                                  splashRadius: 14,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.close,
                                    color: const Color(0xFF204c6c),
                                  ),
                                  onPressed: () {
                                    eliminarCita(estado.rentaID);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ocupacionTexto + detalleHoras,
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                            if (estado.ocupado)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Total: ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: '\$${estado.precioTotal}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Anticipo: ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: '\$${estado.precioPagado}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Resto: ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: '\$${estado.resto}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        estado.tipoPago,
                                        style: const TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
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
                                    ],
                                  ),
                                  Text(
                                    estado.observacion.isEmpty
                                        ? "No hubo observación"
                                        : estado.observacion,
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing:
                            agendarPosible
                                ? ElevatedButton(
                                  onPressed: () async {
                                    final resultado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AgendarPage(
                                              carroSeleccionado:
                                                  estado.nombreCarro,
                                              carroID: estado.carroID,
                                            ),
                                      ),
                                    );
                                    if (resultado != null) {
                                      setState(() {
                                        _mostrarSoloDisponibles = true;
                                      });
                                    }
                                    // Esto se ejecuta después de que AgendarPage se cierra
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
          ),
        ],
      ),
    );
  }
}
