import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:renta_carros/core/calendario/futures/carga_citas.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/calendario/model/detalle_citas.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:renta_carros/presentation/agendar/agenda_page.dart';
import 'package:renta_carros/presentation/calendario/agenda_widget/agenda_widget.dart';

class DetalleCitasPage extends StatefulWidget {
  final DateTime fecha;

  const DetalleCitasPage({super.key, required this.fecha});

  @override
  State<DetalleCitasPage> createState() => _DetalleCitasPageState();
}

class _DetalleCitasPageState extends State<DetalleCitasPage> {
  bool mostrarSoloDisponibles = true;
  eliminarCita(int index) async {
    RentaDAO.eliminar(rentaID: index);
    resetear();
  }

  resetear() {
    setState(() {
      mostrarSoloDisponibles = true;
    });
  }

  List<DateTime> convertirFechasBloqueadas(
    List<Map<String, dynamic>> fechasJson,
  ) {
    return fechasJson.map((fechaMap) {
      final fechaParts = fechaMap['Fecha']!.split('-');
      final year = int.parse(fechaParts[0]);
      final month = int.parse(fechaParts[1]);
      final day = int.parse(fechaParts[2]);
      return DateTime.utc(year, month, day);
    }).toList();
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
      body: Row(
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

                // Dividir en dos listas
                List<EstadoCarro> carrosDisponibles =
                    estados.where((estado) {
                      return !estado.ocupado ||
                          puedeAgendar(
                            widget.fecha,
                            estado.fechaFin,
                            estado.horaFinOcupacion,
                          );
                    }).toList();

                List<EstadoCarro> carrosNoDisponibles =
                    estados.where((estado) {
                      return estado.ocupado &&
                          !puedeAgendar(
                            widget.fecha,
                            estado.fechaFin,
                            estado.horaFinOcupacion,
                          );
                    }).toList();
                List<List<EstadoCarro>> lCarros = comparar(
                  carrosDisponibles,
                  carrosNoDisponibles,
                );

                carrosDisponibles = lCarros[0];
                carrosNoDisponibles = lCarros[1];
                return Row(
                  children: [
                    // 🟥 Carros NO disponibles
                    Expanded(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "No disponibles",
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: carrosNoDisponibles.length,
                              itemBuilder: (context, index) {
                                final estado = carrosNoDisponibles[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.directions_car_filled,
                                      color: Colors.red,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          estado.nombreCarro,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                          ),
                                        ),
                                        if (estado.ocupado)
                                          Row(
                                            children: [
                                              IconButton(
                                                iconSize: 18,
                                                splashRadius: 14,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.edit_calendar_outlined,
                                                  color: Color(0xFF204c6c),
                                                ),
                                                onPressed: () {
                                                  List<Map<String, dynamic>>
                                                  lFecha =
                                                      RentaDAO.obtenerFechaOcupadoCarro(
                                                        carroID: estado.carroID,
                                                      );

                                                  List<DateTime> blockedDays =
                                                      convertirFechasBloqueadas(
                                                        lFecha,
                                                      );

                                                  showPasswordDialog(
                                                    context: context,
                                                    carroID: estado.carroID,
                                                    editOrDelite: true,
                                                    rentaID: estado.rentaID,
                                                    nombreCliente:
                                                        estado.nombreCliente,
                                                    carroSeleccionado:
                                                        estado.nombreCarro,
                                                    diasOcupados: blockedDays,
                                                    precioTotal:
                                                        estado.precioTotal,
                                                    precioPagado:
                                                        estado.precioPagado,
                                                    observaciones:
                                                        estado.observacion,
                                                    metodoPago: estado.tipoPago,
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                iconSize: 18,
                                                splashRadius: 14,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Color(0xFF204c6c),
                                                ),
                                                onPressed:
                                                    () => showPasswordDialog(
                                                      context: context,
                                                      rentaID: estado.rentaID,
                                                      editOrDelite: false,
                                                      carroID: 0,
                                                      nombreCliente: '',
                                                      carroSeleccionado: '',
                                                      diasOcupados: [],
                                                      precioTotal: 0,
                                                      precioPagado: 0,
                                                      observaciones: '',
                                                      metodoPago: '',
                                                    ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (estado.ocupado)
                                          Text(
                                            (estado.ocupado
                                                    ? "Ocupado desde ${estado.fechaInicio.day}/${estado.fechaInicio.month} hasta ${estado.fechaFin.day}/${estado.fechaFin.month}"
                                                    : "Disponible") +
                                                (estado.ocupado &&
                                                        estado.horaFinOcupacion !=
                                                            null
                                                    ? " (Se desocupa a las ${estado.horaFinOcupacion!.format(context)})"
                                                    : ""),
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
                                                style: const TextStyle(
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
                                                      text:
                                                          '\$${estado.precioTotal}',
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
                                                      text:
                                                          '\$${estado.precioPagado}',
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(),
                    // 🟩 Carros disponibles para agendar
                    Expanded(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Disponibles para agendar",
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: carrosDisponibles.length,
                              itemBuilder: (context, index) {
                                final estado = carrosDisponibles[index];
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
                                      color:
                                          estado.ocupado
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          estado.nombreCarro,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                          ),
                                        ),
                                        if (estado.ocupado)
                                          Row(
                                            children: [
                                              IconButton(
                                                iconSize: 18,
                                                splashRadius: 14,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.edit_calendar_outlined,
                                                  color: Color(0xFF204c6c),
                                                ),
                                                onPressed: () {
                                                  List<Map<String, dynamic>>
                                                  lFecha =
                                                      RentaDAO.obtenerFechaOcupadoCarro(
                                                        carroID: estado.carroID,
                                                      );

                                                  List<DateTime> blockedDays =
                                                      convertirFechasBloqueadas(
                                                        lFecha,
                                                      );

                                                  showPasswordDialog(
                                                    context: context,
                                                    carroID: estado.carroID,
                                                    editOrDelite: true,
                                                    rentaID: estado.rentaID,
                                                    nombreCliente:
                                                        estado.nombreCliente,
                                                    carroSeleccionado:
                                                        estado.nombreCarro,
                                                    diasOcupados: blockedDays,
                                                    precioTotal:
                                                        estado.precioTotal,
                                                    precioPagado:
                                                        estado.precioPagado,
                                                    observaciones:
                                                        estado.observacion,
                                                    metodoPago: estado.tipoPago,
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                iconSize: 18,
                                                splashRadius: 14,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Color(0xFF204c6c),
                                                ),
                                                onPressed:
                                                    () => showPasswordDialog(
                                                      context: context,
                                                      rentaID: estado.rentaID,
                                                      editOrDelite: false,
                                                      carroID: 0,
                                                      nombreCliente: '',
                                                      carroSeleccionado: '',
                                                      diasOcupados: [],
                                                      precioTotal: 0,
                                                      precioPagado: 0,
                                                      observaciones: '',
                                                      metodoPago: '',
                                                    ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (estado.ocupado
                                                  ? "Ocupado desde ${estado.fechaInicio.day}/${estado.fechaInicio.month} hasta ${estado.fechaFin.day}/${estado.fechaFin.month}"
                                                  : "Disponible") +
                                              (estado.ocupado &&
                                                      estado.horaFinOcupacion !=
                                                          null
                                                  ? " (Se desocupa a las ${estado.horaFinOcupacion!.format(context)})"
                                                  : ""),
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
                                                style: const TextStyle(
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
                                                      text:
                                                          '\$${estado.precioTotal}',
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
                                                      text:
                                                          '\$${estado.precioPagado}',
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
                                    trailing: ElevatedButton(
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
                                            mostrarSoloDisponibles = true;
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'Agendar',
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showPasswordDialog({
    required BuildContext context,
    required int carroID,
    required bool editOrDelite,
    required int rentaID,
    required String nombreCliente,
    required String carroSeleccionado,
    required List<DateTime> diasOcupados,
    required double precioTotal,
    required double precioPagado,
    required String observaciones,
    required String metodoPago,
  }) {
    final TextEditingController passwordController = TextEditingController();
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                editOrDelite
                    ? 'Ingresa tu contraseña para editar'
                    : 'Ingresa tu contraseña para eliminar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: obscureText,
                    style: TextStyle(fontFamily: 'Quicksand'),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      onPressed: () async {
                        if (passwordController.text == "root") {
                          switch (editOrDelite) {
                            case false:
                              eliminarCita(rentaID);
                              Navigator.of(context).pop();
                              setState(() {
                                mostrarSoloDisponibles = false;
                              });
                              break;
                            case true:
                              Navigator.of(context).pop();

                              final resultado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AgendarWidget(
                                        carroID: carroID,
                                        rentaID: rentaID,
                                        nombreCliente: nombreCliente,
                                        carroSeleccionado: carroSeleccionado,
                                        diasOcupados: diasOcupados,
                                        precioTotal: precioTotal,
                                        precioPagado: precioPagado,
                                        observaciones: observaciones,
                                        metodoPago: metodoPago,
                                        fecha: widget.fecha,
                                      ),
                                ),
                              );
                              if (resultado != null) {
                                resetear();
                              }
                              break;
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
