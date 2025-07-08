import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renta_carros/core/calendario/metods/validacion_detalle_cita.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';

class CitaCarro {
  final String nombreCarro;
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;

  CitaCarro({
    required this.nombreCarro,
    required this.fechaInicio,
    required this.pagoMitad,
    required this.tipoPago,
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
  final int pagoMitad;
  final String tipoPago;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay? horaFinOcupacion;

  EstadoCarro({
    required this.nombreCarro,
    required this.ocupado,
    required this.pagoMitad,
    required this.tipoPago,
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
        pagoMitad: 0,
        tipoPago: "Terminal",
        fechaInicio: DateTime(2025, 7, 1),
        fechaFin: DateTime(2025, 7, 3),
        horaFinOcupacion: const TimeOfDay(hour: 13, minute: 0),
      ),
      CitaCarro(
        nombreCarro: 'Sedán B',
        pagoMitad: 0,
        tipoPago: "Efectivo",
        fechaInicio: DateTime(2025, 7, 5),
        fechaFin: DateTime(2025, 7, 5),
      ),
      CitaCarro(
        nombreCarro: 'SUV X',
        pagoMitad: 1,
        tipoPago: "Transferencia",
        fechaInicio: DateTime(2025, 7, 2),
        fechaFin: DateTime(2025, 7, 4),
        horaFinOcupacion: const TimeOfDay(hour: 17, minute: 30),
      ),
      CitaCarro(
        nombreCarro: 'Hatchback Y',
        pagoMitad: 0,
        tipoPago: "Efectivo",
        fechaInicio: DateTime(2025, 7, 6),
        fechaFin: DateTime(2025, 7, 6),
      ),
    ];

    return todosCarros.map((carro) {
      bool ocupado = carro.estaOcupadoEnDia(dia);
      return EstadoCarro(
        nombreCarro: carro.nombreCarro,
        ocupado: ocupado,
        pagoMitad: carro.pagoMitad,
        tipoPago: carro.tipoPago,
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

  Icon _getIconoMetodoPago(String? metodo) {
    switch (metodo) {
      case 'Efectivo':
        return Icon(Icons.money, color: Colors.green);
      case 'Transferencia':
        return Icon(Icons.account_balance, color: Colors.blue);
      case 'Tarjeta':
        return Icon(Icons.credit_card, color: Colors.purple);
      default:
        return Icon(Icons.payment, color: Colors.grey); // Ícono por defecto
    }
  }

  void _mostrarFormularioAgendar(
    BuildContext context,
    String carroSeleccionado,
  ) {
    final formDetalle = GlobalKey<FormState>();
    final TextEditingController buscarCtrl = TextEditingController();
    final TextEditingController costoCtrl = TextEditingController();
    final TextEditingController anticipoCtrl = TextEditingController();
    String? metodoPago;
    List<String> clientes = [
      'Juan Pérez',
      'María Gómez',
      'Carlos López',
      'Ana Torres',
      'Luis Hernández',
    ];
    String? clienteSeleccionado;
    bool estaVacioAnticipo = true;
    bool estaVacioCosto = true;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Agendar para "$carroSeleccionado"',
            style: TextStyle(fontFamily: 'Quicksand'),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              final resultados =
                  clientes
                      .where(
                        (c) => c.toLowerCase().contains(
                          buscarCtrl.text.toLowerCase(),
                        ),
                      )
                      .toList();
              return SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formDetalle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: buscarCtrl,
                            style: TextStyle(fontFamily: 'Quicksand'),
                            decoration: const InputDecoration(
                              labelText: 'Buscar cliente',
                              prefixIcon: Icon(Icons.search),
                              hintStyle: TextStyle(fontFamily: 'Quicksand'),
                            ),
                            validator: (value) {
                              if (clienteSeleccionado == null) {
                                return "Seleccione un cliente";
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          ...resultados.map(
                            (cliente) => ListTile(
                              title: Text(
                                cliente,
                                style: TextStyle(fontFamily: 'Quicksand'),
                              ),
                              leading: Radio<String>(
                                value: cliente,
                                activeColor:
                                    clienteSeleccionado == cliente
                                        ? Color(0xFF204c6c)
                                        : Colors.red,
                                groupValue: clienteSeleccionado,
                                onChanged: (value) {
                                  setState(() => clienteSeleccionado = value);
                                },
                              ),
                            ),
                          ),
                          const Divider(height: 30),
                          TextFormField(
                            controller: costoCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontFamily: 'Quicksand'),
                            decoration: InputDecoration(
                              labelText: 'Costo del servicio',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color:
                                    estaVacioCosto
                                        ? Colors.redAccent
                                        : Colors.green,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                              ThousandsFormatter(),
                            ],
                            onChanged: (value) {
                              String textoSinComas = value.replaceAll(',', '');
                              bool vacio =
                                  textoSinComas.trim().isEmpty ||
                                  textoSinComas == "0";
                              setState(() {
                                estaVacioCosto = vacio;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Agrega un costo";
                              }
                              String cleanValue = value.replaceAll(',', '');
                              double costo = double.tryParse(cleanValue) ?? 0.0;
                              if (costo <= 0) {
                                return "Agrega un costo válido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: anticipoCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontFamily: 'Quicksand'),
                            decoration: InputDecoration(
                              labelText: 'Anticipo',
                              prefixIcon: Icon(
                                Icons.money_off,
                                color:
                                    estaVacioAnticipo
                                        ? Colors.redAccent
                                        : Colors.green,
                              ),
                            ),
                            onChanged: (value) {
                              String textoSinComas = value.replaceAll(',', '');
                              bool vacio =
                                  textoSinComas.trim().isEmpty ||
                                  textoSinComas == "0";
                              setState(() {
                                estaVacioAnticipo = vacio;
                              });
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                              ThousandsFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Agrega un anticipo";
                              }

                              String cleanValue = value.replaceAll(',', '');
                              double anticipo =
                                  double.tryParse(cleanValue) ?? 0.0;

                              if (anticipo <= 0) {
                                return "Agrega un anticipo válido";
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: metodoPago,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.black,
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Efectivo',
                                child: Text('Efectivo'),
                              ),
                              DropdownMenuItem(
                                value: 'Transferencia',
                                child: Text('Transferencia'),
                              ),
                              DropdownMenuItem(
                                value: 'Tarjeta',
                                child: Text('Tarjeta'),
                              ),
                            ],
                            onChanged:
                                (value) => setState(() => metodoPago = value),
                            decoration: InputDecoration(
                              labelText: 'Método de pago',
                              prefixIcon: _getIconoMetodoPago(metodoPago),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return "Elige un método de pago";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    validacionDetalleCita(
                      context,
                      formDetalle.currentState!.validate(),
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agenda de carros - $fechaFormateada',
          style: TextStyle(fontFamily: 'Quicksand', color: Colors.white),
        ),
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
                  titleTextStyle: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Quicksand',
                    color: Colors.black,
                  ),
                  subtitleTextStyle: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.black,
                  ),
                  leading: Icon(
                    estado.ocupado
                        ? Icons.directions_car_filled
                        : Icons.directions_car,
                    color: iconoColor,
                  ),
                  title: Text(estado.nombreCarro),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ocupacionTexto + detalleHoras),
                      iconoColor == Colors.orange || iconoColor == Colors.red
                          ? Text(
                            "50%",
                            style: TextStyle(
                              color:
                                  estado.pagoMitad == 1
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          )
                          : SizedBox(),

                      iconoColor == Colors.orange || iconoColor == Colors.red
                          ? Text(
                            estado.pagoMitad == 1
                                ? "No hizo el pago"
                                : estado.tipoPago,
                            style: TextStyle(
                              color:
                                  estado.pagoMitad == 1
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          )
                          : SizedBox(),
                    ],
                  ),
                  trailing:
                      agendarPosible
                          ? ElevatedButton(
                            onPressed:
                                () => _mostrarFormularioAgendar(
                                  context,
                                  estado.nombreCarro,
                                ),
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
