import 'package:flutter/material.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/presentation/clientes/widgets/agregar_quitar_dias_widget.dart';
import 'package:renta_carros/presentation/clientes/widgets/input_observacion.dart';

class HistorialClientePage extends StatefulWidget {
  final int clienteID;
  final String nombreCliente;
  const HistorialClientePage({
    super.key,
    required this.clienteID,
    required this.nombreCliente,
  });
  @override
  State<HistorialClientePage> createState() => _HistorialClientePageState();
}

class _HistorialClientePageState extends State<HistorialClientePage> {
  List<Map<String, dynamic>> lCliente = [];
  int? editingIndex; // índice que se está editando
  int diasSeleccionados = 0;
  int resetCounter = 0;
  bool _cargando = false;
  void cargaHistorialCliente() {
    setState(() {
      _cargando = true;
    });
    try {
      final lista = ClienteDAO.obtenerHistorialCliente(
        clienteID: widget.clienteID,
      );
      setState(() {
        lCliente = lista;
      });
    } catch (e) {
      setState(() {
        lCliente = [];
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  agendarDiaExtra(rentaID, dias) async {
    final ok = await ClienteDAO.obtenerRentaDisponibles(
      rentaID: rentaID,
      diasExtra: dias,
    );
    confirmacionAgendaExtra(agendaExtra: true, ok: ok);
  }

  confirmacionAgendaExtra({required bool agendaExtra, required bool ok}) async {
    if (ok == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.lightGreen,
            content: Text('Día extra agendado correctamente'),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error al agendar día extra'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    cargaHistorialCliente();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de ${widget.nombreCliente}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Color(0xFF204c6c),
      ),
      body:
          _cargando
              ? Center(
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Color(0xFF204c6c),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child:
                        lCliente.isEmpty
                            ? const Center(
                              child: Text('No hay rentas registradas'),
                            )
                            : ListView.builder(
                              itemCount: lCliente.length,
                              itemBuilder: (context, index) {
                                final bloqueado =
                                    editingIndex != null &&
                                    editingIndex != index;

                                return Opacity(
                                  opacity: bloqueado ? 0.4 : 1,
                                  child: IgnorePointer(
                                    ignoring: bloqueado,
                                    child: Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.all(8),
                                      elevation: 3,
                                      child: ListTile(
                                        title: Text(
                                          lCliente[index]["NombreCarro"],
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 16,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.directions_car_filled,
                                          color:
                                              lCliente[index]["Estatus"] == 0
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 16,
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
                                                        '\$${lCliente[index]["PrecioTotal"]}',
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
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: "Abonado: ",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '\$${lCliente[index]["PrecioPagado"]}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    final guardado = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => InputConCarga(
                                                              rentaID:
                                                                  lCliente[index]["RentaID"],
                                                              observacion:
                                                                  lCliente[index]["Observaciones"],
                                                              nombreCliente:
                                                                  widget
                                                                      .nombreCliente,
                                                              nombreCarro:
                                                                  lCliente[index]["NombreCarro"],
                                                              fechaInicio:
                                                                  lCliente[index]["FechaInicio"],
                                                              fechaFin:
                                                                  lCliente[index]["FechaFin"],
                                                              estatus:
                                                                  lCliente[index]["Estatus"],
                                                              precioTotal:
                                                                  '\$${lCliente[index]["PrecioTotal"]}',
                                                              precioPagado:
                                                                  '\$${lCliente[index]["PrecioPagado"]}',
                                                            ),
                                                      ),
                                                    );
                                                    if (guardado == true) {
                                                      cargaHistorialCliente();
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.edit_note,
                                                    color: const Color(
                                                      0xFF204c6c,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  (lCliente[index]["Observaciones"] ??
                                                              '')
                                                          .isNotEmpty
                                                      ? lCliente[index]["Observaciones"]
                                                      : 'No hubo observación',
                                                  style: TextStyle(
                                                    fontFamily: 'Quicksand',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Del ',
                                                    style: TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        lCliente[index]["FechaInicio"],
                                                    style: const TextStyle(
                                                      color: Color(0xFF204c6c),
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' al ',
                                                    style: TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        lCliente[index]["FechaFin"],
                                                    style: const TextStyle(
                                                      color: Color(0xFF204c6c),
                                                      fontSize: 16,
                                                      fontFamily: 'Quicksand',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            lCliente[index]["TieneRentaDespues"] ==
                                                    0
                                                ? DiasSelector(
                                                  key: ValueKey(
                                                    '$index-$resetCounter',
                                                  ),
                                                  initialValue:
                                                      editingIndex == index
                                                          ? diasSeleccionados
                                                          : 0,
                                                  onChanged: (dias) {
                                                    setState(() {
                                                      editingIndex ??= index;
                                                      diasSeleccionados = dias;
                                                    });
                                                  },
                                                )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  if (editingIndex != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: const Border(
                          top: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                editingIndex = null;
                                diasSeleccionados = 0;
                                resetCounter++;
                              });
                            },
                            child: const Text('Cancelar'),
                          ),

                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                diasSeleccionados != 0
                                    ? () async {
                                      final index = editingIndex!;
                                      final cliente = lCliente[index];

                                      // final precioPagado = cliente["PrecioPagado"];
                                      // final precioTotal = cliente["PrecioTotal"];
                                      // final nombreCarro = cliente["NombreCarro"];
                                      // final fechaFin = cliente["FechaFin"];
                                      final rentaID = cliente["RentaID"];

                                      // print('Carro: $nombreCarro');
                                      // print('Precio pagado: $precioPagado');
                                      // print('Precio total: $precioTotal');
                                      print('Días extra: $diasSeleccionados');
                                      // print('FechaFin: $fechaFin');
                                      print('RentaID: $rentaID');

                                      await agendarDiaExtra(
                                        rentaID,
                                        diasSeleccionados,
                                      );

                                      setState(() {
                                        editingIndex = null;
                                        diasSeleccionados = 0;
                                        resetCounter++;
                                      });
                                    }
                                    : null,
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
    );
  }
}
