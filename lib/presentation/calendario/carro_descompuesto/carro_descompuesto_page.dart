import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/futures/carga_citas.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';

class DetalleCitasDescompuestoPage extends StatefulWidget {
  final DateTime fecha;
  final int carroID;

  const DetalleCitasDescompuestoPage({
    super.key,
    required this.fecha,
    required this.carroID,
  });

  @override
  State<DetalleCitasDescompuestoPage> createState() =>
      _DetalleCitasDescompuestoPageState();
}

class _DetalleCitasDescompuestoPageState
    extends State<DetalleCitasDescompuestoPage> {
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

                    return estado.carroID == widget.carroID
                        ? SizedBox()
                        : Card(
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
                            title: Text(
                              estado.nombreCarro,
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ocupacionTexto + detalleHoras,
                                  style: const TextStyle(
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                                if (estado.ocupado)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        estado.nombreCliente,
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),

                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: "Total: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
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
                                              text: "Comisión: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '\$${estado.comision}',
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
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
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
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
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
                                        List<dynamic> lCarro = [
                                          estado.carroID,
                                          estado.nombreCarro,
                                          estado.precioTotal,
                                          estado.comision,
                                        ];
                                        Navigator.pop(context, lCarro);
                                      },
                                      child: const Text(
                                        'Seleccionar carro para el cambio',
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
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
