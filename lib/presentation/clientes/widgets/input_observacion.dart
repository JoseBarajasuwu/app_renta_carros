import 'package:flutter/material.dart';
import 'package:renta_carros/database/clientes_db.dart';

class InputConCarga extends StatefulWidget {
  final int rentaID;
  final String observacion;
  final String nombreCliente;
  final String nombreCarro;
  final String fechaInicio;
  final String fechaFin;
  final int estatus;
  final String precioTotal;
  final String precioPagado;

  const InputConCarga({
    super.key,
    required this.rentaID,
    required this.observacion,
    required this.nombreCliente,
    required this.nombreCarro,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estatus,
    required this.precioTotal,
    required this.precioPagado,
  });

  @override
  State<InputConCarga> createState() => _InputConCargaState();
}

class _InputConCargaState extends State<InputConCarga> {
  final TextEditingController observacionController = TextEditingController();
  bool _cargando = false;
  bool modificacion = false;

  final formObservacion = GlobalKey<FormState>();
  _aceptar(int rentaID) async {
    setState(() {
      _cargando = true;
    });
    final ok = await ClienteDAO.editObservacion(
      rentaID: rentaID,
      observacion: observacionController.text,
    );
    setState(() {
      _cargando = false;
    });
    confirmacionAgendaExtra(agendaExtra: true, ok: ok);
  }

  confirmacionAgendaExtra({required bool agendaExtra, required bool ok}) async {
    if (ok == true) {
      modificacion = true;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.lightGreen,
            content: Text('Observaición editada correctamente'),
          ),
        );
      }
    } else {
      modificacion = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error al editar la observación'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modificar Observación"),
        backgroundColor: const Color(0xFF204c6c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, modificacion),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            _cargando
                ? Center(
                  child: const CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Color(0xFF204c6c),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: Text(
                        widget.nombreCarro,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                        ),
                      ),

                      trailing: Icon(
                        Icons.directions_car_filled,
                        color: widget.estatus == 0 ? Colors.red : Colors.green,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nombreCliente,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
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
                                  text: "Total: ",
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: widget.precioTotal,
                                  style: const TextStyle(color: Colors.green),
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
                                  text: widget.precioPagado,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontFamily: 'Quicksand',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.observacion.isNotEmpty
                                ? widget.observacion
                                : 'No hubo observación',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Del ',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.fechaInicio,
                                  style: const TextStyle(
                                    color: Color(0xFF204c6c),
                                    fontFamily: 'Quicksand',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' al ',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.fechaFin,
                                  style: const TextStyle(
                                    color: Color(0xFF204c6c),
                                    fontSize: 16,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: formObservacion,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: observacionController,
                          maxLines: 10,
                          minLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Editar Observación...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          style: const TextStyle(fontFamily: 'Quicksand'),
                          enabled: !_cargando,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La observación no puede estar vacía';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed:
                            () => {
                              if (formObservacion.currentState!.validate())
                                {_aceptar(widget.rentaID)}
                              else
                                {modificacion = false},
                            },
                        child: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
