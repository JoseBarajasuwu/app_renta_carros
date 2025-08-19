import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:renta_carros/presentation/calendario/carro_descompuesto/carro_descompuesto_page.dart';
import 'package:renta_carros/presentation/calendario/widget/calendario_widget.dart';

class AgendarWidget extends StatefulWidget {
  final int carroID;
  final int rentaID;
  final String nombreCliente;
  final String carroSeleccionado;
  final List<DateTime> diasOcupados;
  final double precioTotal;
  final double precioPagado;
  final String observaciones;
  final String metodoPago;
  final DateTime fecha;
  const AgendarWidget({
    super.key,
    required this.carroID,
    required this.rentaID,
    required this.nombreCliente,
    required this.carroSeleccionado,
    required this.diasOcupados,
    required this.precioTotal,
    required this.precioPagado,
    required this.observaciones,
    required this.metodoPago,
    required this.fecha,
  });

  @override
  State<AgendarWidget> createState() => _AgendarWidgetState();
}
//sdasd

class _AgendarWidgetState extends State<AgendarWidget> {
  final formDetalle = GlobalKey<FormState>();

  TextEditingController costoCtrl = TextEditingController();
  TextEditingController anticipoCtrl = TextEditingController();
  TextEditingController observacionesCtrl = TextEditingController();

  bool estaVacioAnticipo = true;
  bool estaVacioCosto = true;
  Timer? _debounce;
  bool mostrarSoloEditar = false;
  double? costoTotal;
  int? diasCompletos;
  String? fechaHoraInicio;
  String? fechaHoraFin;
  int? carroIDDescompuesto;
  String? nombreCarroDescompuesto;
  double? precioTotalDescompuesto;
  final formKey = GlobalKey<FormState>();

  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd HH:mm');

  _validarYConfirmar({
    required double precioTotal,
    required String precioPagado,
    required String observaciones,
  }) {
    String cPrecioPagado = precioPagado.replaceAll(',', '');
    double iPrecioPagado = double.tryParse(cPrecioPagado) ?? 0.0;
    if (carroIDDescompuesto == null &&
        nombreCarroDescompuesto == null &&
        precioTotalDescompuesto == null) {
      RentaDAO.update(
        rentaID: widget.rentaID,
        fechaInicio: "$fechaHoraInicio",
        fechaFin: "$fechaHoraFin",
        precioTotal: precioTotal,
        precioPagado: iPrecioPagado,
        observaciones: observaciones,
      );
    } else if (carroIDDescompuesto != null &&
        nombreCarroDescompuesto != null &&
        precioTotalDescompuesto != null) {
      RentaDAO.updateCarroRemplazo(
        rentaID: widget.rentaID,
        carroID: widget.carroID,
        fechaInicio: "$fechaHoraInicio",
        fechaFin: "$fechaHoraFin",
        precioTotal: precioTotal,
        precioPagado: iPrecioPagado,
        observaciones: observaciones,
      );
    }

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

  List<DateTime> diasNoDisponibles = [];
  Future<void> cargaDiasOcupados() async {
    int? carroID = carroIDDescompuesto ?? widget.carroID;
    List<Map<String, dynamic>> lFecha = RentaDAO.obtenerFechaOcupadoCarro(
      carroID: carroID,
    );
    diasNoDisponibles = convertirFechasBloqueadas(lFecha);
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

  List<DiaDisponible> diasDisponibles = [];
  List<DateTime> diasOcupados = [];
  Future<void> cargaDias() async {
    int? carroID = carroIDDescompuesto ?? widget.carroID;
    List<DiaDisponible> lFecha = RentaDAO.obtenerDiasDisponibles(
      carroID: carroID,
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

  actualizar({
    required int? carroID,
    required String? nombreCarro,
    required double? precioTotal,
  }) {
    setState(() {
      carroIDDescompuesto = carroID;
      nombreCarroDescompuesto = nombreCarro;
      precioTotalDescompuesto = precioTotal;
    });
    costoCtrl.text = precioTotalDescompuesto.toString();
    cargaDiasOcupados();
    cargaDias();
  }

  @override
  void initState() {
    cargaDiasOcupados();
    cargaDias();
    costoCtrl.text = widget.precioTotal.toString();
    anticipoCtrl.text = widget.precioPagado.toString();
    observacionesCtrl.text = widget.observaciones;
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    costoCtrl.dispose();
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
          nombreCarroDescompuesto == null
              ? 'Agendar para "${widget.carroSeleccionado}"'
              : 'Se remplazara "${widget.carroSeleccionado}" por "$nombreCarroDescompuesto"',
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.nombreCliente,
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    ),
                  ),
                ),
                const Divider(height: 30),
                // DetalleCitasDescompuestoPage
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      showPasswordDialog(context: context);
                    },
                    child: Text("¿El carro se descompuso?"),
                  ),
                ),
                const SizedBox(height: 8),

                if (carroIDDescompuesto != null &&
                    nombreCarroDescompuesto != null &&
                    precioTotalDescompuesto != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Carro nuevo: $nombreCarroDescompuesto',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 8),
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
                                    rentaActualId: widget.rentaID.toString(),
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
                            Icons.edit,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        widget.metodoPago,
                        style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                      ),
                    ],
                  ),
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
                            precioTotal: costoTotal!,
                            precioPagado: anticipoCtrl.text,
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

  void showPasswordDialog({required BuildContext context}) {
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
                'Ingresa tu contraseña para cambiar de carro',
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
                          Navigator.pop(context);
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DetalleCitasDescompuestoPage(
                                    fecha: widget.fecha,
                                    carroID: widget.carroID,
                                  ),
                            ),
                          );
                          if (resultado != null) {
                            actualizar(
                              carroID: resultado[0],
                              nombreCarro: resultado[1],
                              precioTotal: resultado[2],
                            );
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
