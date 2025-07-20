import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';
import 'package:renta_carros/database/carros_db.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/database/rentas_db.dart';

class AgendarPage extends StatefulWidget {
  final String carroSeleccionado;
  final int carroID;
  const AgendarPage({
    super.key,
    required this.carroSeleccionado,
    required this.carroID,
  });

  @override
  State<AgendarPage> createState() => _AgendarPageState();
}

class _AgendarPageState extends State<AgendarPage> {
  final formDetalle = GlobalKey<FormState>();
  TextEditingController buscarCtrl = TextEditingController();
  TextEditingController costoCtrl = TextEditingController();
  TextEditingController anticipoCtrl = TextEditingController();
  TextEditingController observacionesCtrl = TextEditingController();
  String? metodoPago;
  String? clienteSeleccionado;

  bool estaVacioAnticipo = true;
  bool estaVacioCosto = true;
  Timer? _debounce;
  bool mostrarSoloEditar = false;

  List<Map<String, dynamic>> lUsuarios = [];
  List<Map<String, dynamic>> lPrecio = [];
  String? fechaHoraInicio;
  String? fechaHoraFin;
  DateTimeRange? _selectedDateRange;
  final formKey = GlobalKey<FormState>();
  final List<DateTime> diasNoDisponibles = [
    DateTime(2025, 12, 25),
    DateTime(2025, 1, 1),
  ];

  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd HH:mm');
  Future<void> _selectDateTimeRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      cancelText: "Cancelar",
      errorFormatText: "Formato invalido",
      fieldStartLabelText: "Fecha inicio",
      fieldEndLabelText: "Fecha final",
      confirmText: "Aceptar",
      saveText: "Guardar",

      lastDate: DateTime(2026),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      final TimeOfDay? startHour = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        cancelText: "Cancelar",
        confirmText: "Aceptar",
        hourLabelText: "Hora",
        minuteLabelText: "Minuto",
        helpText: "Hora incio",
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (startHour == null) return;

      final TimeOfDay? endHour = await showTimePicker(
        cancelText: "Cancelar",
        confirmText: "Aceptar",
        hourLabelText: "Hora",
        minuteLabelText: "Minuto",
        helpText: "Hora final",

        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (endHour == null) return;

      final startDateTime = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
        startHour.hour,
        startHour.minute,
      );

      final endDateTime = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        endHour.hour,
        endHour.minute,
      );

      setState(() {
        _selectedDateRange = DateTimeRange(
          start: startDateTime,
          end: endDateTime,
        );
        fechaHoraInicio = formatoFechaHora.format(startDateTime);
        fechaHoraFin = formatoFechaHora.format(endDateTime);
      });
    }
  }

  _validarYConfirmar({
    required String clienteID,
    required int carroID,
    required String precioTotal,
    required String precioPagado,
    required String pagoMetodo,
    required String observaciones,
  }) {
    int iClienteID = int.tryParse(clienteID) ?? 0;
    String cPrecioTotal = precioTotal.replaceAll(',', '');
    double iPrecioTotal = double.tryParse(cPrecioTotal) ?? 0;
    String cPrecioPagado = precioPagado.replaceAll(',', '');
    double iPrecioPagado = double.tryParse(cPrecioPagado) ?? 0.0;
    RentaDAO.insertar(
      clienteID: iClienteID,
      carroID: carroID,
      fechaInicio: "$fechaHoraInicio",
      fechaFin: "$fechaHoraFin",
      precioTotal: iPrecioTotal,
      precioPagado: iPrecioPagado,
      tipoPago: pagoMetodo,
      observaciones: observaciones,
    );
    Navigator.pop(context, true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF204c6c),
          content: Text('Renta guardada exitosamente'),
        ),
      );
    }
  }

  Future<void> cargarUsuarios() async {
    final lista = ClienteDAO.obtenerClienteAgenda();
    setState(() {
      lUsuarios = lista;
      print(lUsuarios);
    });
  }

  Future<void> cargaPrecio() async {
    final lista = CarroDAO.obtenerPrecioCarro(carroID: widget.carroID);
    lPrecio = lista;
    costoCtrl.text = lPrecio[0]["Costo"].toString();
    print(lPrecio);
  }

  List<Map<String, dynamic>> get clientesFiltrados {
    String query = buscarCtrl.text.toLowerCase();
    if (query.isEmpty) return lUsuarios;

    return lUsuarios
        .where((elemento) {
          String nombre = (elemento["Nombre"] ?? '').toString().toLowerCase();

          return nombre.contains(query);
        })
        .take(5)
        .toList();
  }

  @override
  void initState() {
    cargarUsuarios();
    cargaPrecio();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    buscarCtrl.dispose();
    costoCtrl.dispose();
    anticipoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double resta =
        (double.tryParse(costoCtrl.text.replaceAll(',', '')) ?? 0) -
        (double.tryParse(anticipoCtrl.text.replaceAll(',', '')) ?? 0);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar para "${widget.carroSeleccionado}"',
          style: const TextStyle(fontFamily: 'Quicksand', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF204c6c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formDetalle,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextFormField(
                  controller: buscarCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Buscar cliente',
                    prefixIcon: Icon(Icons.search),
                  ),
                  style: const TextStyle(fontFamily: 'Quicksand'),
                  onChanged: (value) {
                    setState(() {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();

                      _debounce = Timer(
                        const Duration(milliseconds: 500),
                        () {},
                      );
                    });
                  },
                  validator: (_) {
                    if (clienteSeleccionado == null) {
                      return "Seleccione un cliente";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                ...clientesFiltrados.map(
                  (cliente) => ListTile(
                    title: Text(
                      cliente['Nombre'],
                      style: const TextStyle(fontFamily: 'Quicksand'),
                    ),
                    leading: Radio<String>(
                      value: cliente['ClienteID'].toString(),
                      groupValue: clienteSeleccionado,
                      activeColor:
                          clienteSeleccionado == cliente['ClienteID'].toString()
                              ? const Color(0xFF204c6c)
                              : Colors.red,
                      onChanged: (value) {
                        setState(() => clienteSeleccionado = value);
                      },
                    ),
                  ),
                ),

                if (clientesFiltrados.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mostrando solo los primeros 5 resultados',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                const Divider(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: costoCtrl,
                        enabled: mostrarSoloEditar,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Quicksand'),
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
                          String clean = value.replaceAll(',', '');
                          setState(
                            () =>
                                estaVacioCosto = clean.isEmpty || clean == "0",
                          );
                        },
                        validator: (value) {
                          if (mostrarSoloEditar == false) {
                            return null;
                          } else {
                            if (value == null || value.trim().isEmpty) {
                              return "Agrega un costo";
                            }
                            final double costo =
                                double.tryParse(value.replaceAll(',', '')) ??
                                0.0;
                            if (costo <= 0) return "Agrega un costo válido";
                            return null;
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 35,
                        width: 35,
                        child: IconButton(
                          iconSize: 18,
                          splashRadius: 14,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: const Color(0xFF204c6c),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarSoloEditar = !mostrarSoloEditar;
                              if (mostrarSoloEditar == false) {
                                estaVacioCosto = false;
                              } else {
                                estaVacioCosto = true;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: anticipoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Quicksand'),
                  decoration: InputDecoration(
                    labelText: 'Anticipo',
                    prefixIcon: Icon(
                      Icons.money_off,
                      color:
                          estaVacioAnticipo ? Colors.redAccent : Colors.green,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                    ThousandsFormatter(),
                  ],
                  onChanged: (value) {
                    String clean = value.replaceAll(',', '');
                    setState(
                      () => estaVacioAnticipo = clean.isEmpty || clean == "0",
                    );
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Agrega un anticipo";
                    }
                    final double anticipo =
                        double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                    if (anticipo <= 0) return "Agrega un anticipo válido";
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Resta: $resta",
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: metodoPago,
                  isExpanded: true,

                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.black,
                  ),
                  hint: const Text(
                    'Selecciona un método de pago',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Efectivo',
                      child: Text(
                        'Efectivo',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Transferencia',
                      child: Text(
                        'Transferencia',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Tarjeta',
                      child: Text(
                        'Tarjeta',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Método de pago',
                    labelStyle: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.black,
                    ),
                    prefixIcon: getIconoMetodoPago(metodoPago),
                  ),
                  onChanged: (value) => setState(() => metodoPago = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Elige un método de pago";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 16),
                //   child: _buildFechaHoraSelector(
                //     label: 'Fecha y hora de inicio',
                //     fecha: fechaHoraInicio,
                //     onTap: () => _selectDateTimeRange(context),
                //   ),
                // ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () => _selectDateTimeRange(context),
                    child: Text(
                      'Seleccionar Rango de Fecha y Hora',
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Inicio: $fechaHoraInicio\nFin: $fechaHoraFin',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    ),
                  ),

                // _buildFechaHoraSelector(
                //   label: 'Fecha y hora final',
                //   fecha: fechaHoraFin,
                //   onTap: () => _selectDateTimeRange(context),
                // ),
                _selectedDateRange == null
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Te falta seleccionar fecha",
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                    : fechaHoraInicio == fechaHoraFin
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "La fecha inicio y fecha fin, no pueden ser iguales",
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                    : SizedBox(),

                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: observacionesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      hintText: 'Agrega observaciones adicionales...',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Quicksand'),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        bool diferentes =
                            fechaHoraInicio == fechaHoraFin ? false : true;
                        if (formDetalle.currentState!.validate() &&
                            diferentes) {
                          _validarYConfirmar(
                            clienteID: clienteSeleccionado!,
                            carroID: widget.carroID,
                            precioTotal: costoCtrl.text,
                            precioPagado: anticipoCtrl.text,
                            pagoMetodo: metodoPago!,
                            observaciones: observacionesCtrl.text,
                          );
                        }
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
