import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/calendario/metods/detalle_citas_metods.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';
import 'package:renta_carros/database/carros_db.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:renta_carros/presentation/calendario/widget/calendario_widget.dart';

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
//sdasd

class _AgendarPageState extends State<AgendarPage> {
  final formDetalle = GlobalKey<FormState>();
  TextEditingController buscarCtrl = TextEditingController();
  TextEditingController costoCtrl = TextEditingController();
  TextEditingController comisionCtrl = TextEditingController();
  TextEditingController anticipoCtrl = TextEditingController();
  TextEditingController observacionesCtrl = TextEditingController();
  String? metodoPago;
  String? clienteSeleccionado;

  bool estaVacioAnticipo = true;
  bool estaVacioCosto = true;
  bool estaVacioComision = true;
  Timer? _debounce;
  bool mostrarSoloEditarCosto = false;
  bool mostrarSoloEditarComision = false;
  double? costoTotal;
  int? diasCompletos;
  List<Map<String, dynamic>> lUsuarios = [];
  List<Map<String, dynamic>> lPrecio = [];
  String? fechaHoraInicio;
  String? fechaHoraFin;

  final formKey = GlobalKey<FormState>();
  List<DateTime> diasNoDisponibles = [];

  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd HH:mm');
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

  _validarYConfirmar({
    required String clienteID,
    required int carroID,
    required double precioTotal,
    required String precioPagado,
    required String pagoMetodo,
    required String observaciones,
    required String comision,
  }) {
    int iClienteID = int.tryParse(clienteID) ?? 0;
    String cPrecioPagado = precioPagado.replaceAll(',', '');
    double iPrecioPagado = double.tryParse(cPrecioPagado) ?? 0.0;
    String cleanComision = comision.replaceAll(',', '');
    double dComision = double.tryParse(cleanComision) ?? 0;

    RentaDAO.insertar(
      clienteID: iClienteID,
      carroID: carroID,
      fechaInicio: "$fechaHoraInicio",
      fechaFin: "$fechaHoraFin",
      precioTotal: precioTotal,
      precioPagado: iPrecioPagado,
      tipoPago: pagoMetodo,
      observaciones: observaciones,
      comision: dComision,
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

  List<DiaDisponible> diasDisponibles = [];
  List<DateTime> diasOcupados = [];
  Future<void> cargaDias() async {
    List<DiaDisponible> lFecha = RentaDAO.obtenerDiasDisponibles(
      carroID: widget.carroID,
    );
    diasDisponibles = lFecha;

    diasOcupados = limpiarFechasConTipo(diasNoDisponibles, diasDisponibles);
  }

  List<DateTime> limpiarFechasConTipo(
    List<DateTime> original,
    List<DiaDisponible> fechasAExcluir,
  ) {
    return original.where((fecha) {
      return !fechasAExcluir.any((excluir) => isSameDay(fecha, excluir.dia));
    }).toList();
  }

  Future<void> cargaPrecio() async {
    final lista = CarroDAO.obtenerPrecioCarro(carroID: widget.carroID);
    lPrecio = lista;
    costoCtrl.text = lPrecio[0]["Costo"].toString();
    comisionCtrl.text = lPrecio[0]["Comision"].toString();
    print(lPrecio);
  }

  Future<void> cargaDiasOcupados() async {
    List<Map<String, dynamic>> lFecha = RentaDAO.obtenerFechaOcupadoCarro(
      carroID: widget.carroID,
    );
    diasNoDisponibles = convertirFechasBloqueadas(lFecha);
  }

  List<Map<String, dynamic>> get clientesFiltrados {
    String query = buscarCtrl.text.toLowerCase();
    if (query.isEmpty) return lUsuarios;
    return lUsuarios
        .where((elemento) {
          String nombre = (elemento["Nombre"] ?? '').toString().toLowerCase();
          String apellido =
              (elemento["Apellido"] ?? '').toString().toLowerCase();
          String nombreCompleto = "$nombre $apellido";
          return nombre.contains(query) ||
              apellido.contains(query) ||
              nombreCompleto.contains(query);
        })
        .take(5)
        .toList();
  }

  @override
  void initState() {
    cargarUsuarios();
    cargaPrecio();
    cargaDiasOcupados();
    cargaDias();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    buscarCtrl.dispose();
    costoCtrl.dispose();
    comisionCtrl.dispose();
    anticipoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double resta =
        (costoTotal ?? 0) -
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
                      "${cliente['Nombre']} ${cliente['Apellido']}",
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
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.85,
                                  child: CalendarWithBlockedDays(
                                    costoPorDia:
                                        double.tryParse(
                                          costoCtrl.text.replaceAll(',', ''),
                                        ) ??
                                        0,
                                    diasOcupados: diasOcupados,
                                    diasDisponibles: diasDisponibles,
                                    rentaActualId: "0",
                                  ),
                                ),
                          );
                      if (result != null) {
                        setState(() {
                          fechaHoraInicio = formatoFechaHora.format(
                            result['start'],
                          );
                          fechaHoraFin = formatoFechaHora.format(result['end']);
                          costoTotal = result['total'];
                        });
                        diasCompletos = result['diasCompletos'];
                      }
                    },
                    child: const Text(
                      'Seleccionar fechas',
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                  ),
                ),
                if (fechaHoraInicio != null &&
                    fechaHoraFin != null &&
                    costoTotal != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Inicio: $fechaHoraInicio\nFin: $fechaHoraFin',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: costoCtrl,
                        enabled: mostrarSoloEditarCosto,
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
                          double dClean = double.tryParse(clean) ?? 0;
                          if (diasCompletos != null) {
                            costoTotal = diasCompletos! * dClean;
                          }
                          setState(
                            () =>
                                estaVacioCosto = clean.isEmpty || clean == "0",
                          );
                        },
                        validator: (value) {
                          if (mostrarSoloEditarCosto == false) {
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
                            Icons.edit,
                            color: const Color(0xFF204c6c),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarSoloEditarCosto = !mostrarSoloEditarCosto;
                              if (mostrarSoloEditarCosto == false) {
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: comisionCtrl,
                        enabled: mostrarSoloEditarComision,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Quicksand'),
                        decoration: InputDecoration(
                          labelText: 'Comisión del servicio',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color:
                                estaVacioComision
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
                                estaVacioComision =
                                    clean.isEmpty || clean == "0",
                          );
                        },
                        validator: (value) {
                          if (mostrarSoloEditarComision == false) {
                            return null;
                          } else {
                            if (value == null || value.trim().isEmpty) {
                              return "Agrega la comisión";
                            }
                            double comision =
                                double.tryParse(value.replaceAll(',', '')) ??
                                0.0;
                            if (comision <= 0) {
                              return "Agrega una comisión válida";
                            }
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
                            Icons.edit,
                            color: const Color(0xFF204c6c),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarSoloEditarComision =
                                  !mostrarSoloEditarComision;
                              if (mostrarSoloEditarComision == false) {
                                estaVacioComision = false;
                              } else {
                                estaVacioComision = true;
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
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
                        if (fechaHoraInicio != null &&
                            fechaHoraFin != null &&
                            costoTotal != null)
                          TextSpan(
                            text: '\$$costoTotal',
                            style: const TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(
                            text: "Resta: ",
                            style: TextStyle(color: Colors.black),
                          ),
                          if (fechaHoraInicio != null &&
                              fechaHoraFin != null &&
                              costoTotal != null)
                            TextSpan(
                              text: '\$$resta',
                              style: const TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
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
                            precioTotal: costoTotal!,
                            precioPagado: anticipoCtrl.text,
                            pagoMetodo: metodoPago!,
                            observaciones: observacionesCtrl.text,
                            comision: comisionCtrl.text,
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
