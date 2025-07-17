import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';
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
  List<String> clientes = [
    'Juan Pérez',
    'María Gómez',
    'Carlos López',
    'Ana Torres',
    'Luis Hernández',
    'Luis Hernández',
  ];
  List<Map<String, dynamic>> lUsuarios = [];
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;

  final formKey = GlobalKey<FormState>();

  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd HH:mm');

  Future<DateTime?> _selectDateTime(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null) return null;
    final hora = await showTimePicker(

      context: context,
      initialTime:
          initialDate != null
              ? TimeOfDay(hour: initialDate.hour, minute: initialDate.minute)
              : TimeOfDay.now(),
    );
    if (hora == null) return null;

    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  Future<void> _seleccionarFechaHoraInicio(BuildContext context) async {
    final seleccionado = await _selectDateTime(context, fechaHoraInicio);
    if (seleccionado != null) {
      setState(() {
        fechaHoraInicio = seleccionado;
        // Si fechaHoraFin es anterior a inicio, la igualamos
        if (fechaHoraFin != null && fechaHoraFin!.isBefore(fechaHoraInicio!)) {
          fechaHoraFin = fechaHoraInicio;
        }
      });
    }
  }

  Future<void> _seleccionarFechaHoraFin(BuildContext context) async {
    final seleccionado = await _selectDateTime(context, fechaHoraFin);
    if (seleccionado != null) {
      setState(() {
        fechaHoraFin = seleccionado;
        // Si fechaHoraFin es anterior a inicio, la igualamos
        if (fechaHoraFin != null && fechaHoraFin!.isBefore(fechaHoraInicio!)) {
          fechaHoraFin = fechaHoraInicio;
        }
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
    int iPrecioTotal = int.tryParse(cPrecioTotal) ?? 0;
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
  }

  bool isLoading = false;
  Future<void> cargarUsuarios() async {
    setState(() => isLoading = true);

    final lista = ClienteDAO.obtenerClienteAgenda();
    setState(() {
      lUsuarios = lista;
      print(lUsuarios);
      isLoading = false;
    });
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
    // final coincidencias =
    //     clientes
    //         .where(
    //           (c) => c.toLowerCase().contains(buscarCtrl.text.toLowerCase()),
    //         )
    //         .toList();
    // final resultados = coincidencias.take(5).toList();

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
                TextFormField(
                  controller: costoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Quicksand'),
                  decoration: InputDecoration(
                    labelText: 'Costo del servicio',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: estaVacioCosto ? Colors.redAccent : Colors.green,
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
                      () => estaVacioCosto = clean.isEmpty || clean == "0",
                    );
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Agrega un costo";
                    }
                    final double costo =
                        double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                    if (costo <= 0) return "Agrega un costo válido";
                    return null;
                  },
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFechaHoraSelector(
                    label: 'Fecha y hora de inicio',
                    fecha: fechaHoraInicio,
                    onTap: () => _seleccionarFechaHoraInicio(context),
                  ),
                ),
                _buildFechaHoraSelector(
                  label: 'Fecha y hora final',
                  fecha: fechaHoraFin,
                  onTap: () => _seleccionarFechaHoraFin(context),
                ),

                fechaHoraInicio == null || fechaHoraFin == null
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

  Widget _buildFechaHoraSelector({
    required String label,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fecha != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(fecha)
                          : 'Selecciona...',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            fecha != null ? Colors.black : Colors.grey.shade600,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
