import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/historial/model/historial_model.dart';
import 'package:renta_carros/core/utils/formateo_miles_text.dart';
import 'package:renta_carros/database/database.dart';
import 'package:renta_carros/database/mantenimientos_db.dart';
import 'package:renta_carros/presentation/carros/historial_carro.dart';
import 'package:renta_carros/presentation/historial/utils_historial.dart';
import 'package:renta_carros/presentation/historial/widgets/info_rows.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});
  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late Future<List<Car>> _futureCars;
  final NumberFormat _formatter = NumberFormat("#,##0.00", "es_MX");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Control del formulario visible
  int _formCarroID = -1;
  int mantenimientoID = 0;
  TextEditingController tipoController = TextEditingController();
  TextEditingController costoController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  String fechaDeHoy = "";
  bool isSaving = false;
  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    final mes = DateFormat('yyyy-MM').format(hoy);
    fechaDeHoy = mes;
    _futureCars = fetchCarData(mes);
  }

  @override
  void dispose() {
    tipoController.dispose();
    costoController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  void eliminarServicio(int carroMantenimientoId) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Eliminar servicio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            content: const Text(
              '¿Estás seguro de eliminar este servicio?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      MantenimientoDAO.eliminarMantenimiento(
                        carroMantenimientoId,
                      );
                      Navigator.pop(context);
                      final mes = DateFormat('yyyy-MM').format(DateTime.now());
                      setState(() {
                        _futureCars = fetchCarData(mes);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF204c6c),
                          content: Text('Servicio eliminado'),
                        ),
                      );
                    },
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  guardarServicio(int carroID, int mantenimientoId) async {
    setState(() => isSaving = true);
    String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double costo =
        double.tryParse(costoController.text.trim().replaceAll(',', '.')) ??
        0.0;
    if (mantenimientoId == 0) {
      MantenimientoDAO.insertarMantenimiento(
        carroId: carroID,
        fechaRegistro: fecha,
        tipo: tipoController.text.trim(),
        costo: costo,
        descripcion: descripcionController.text.trim(),
      );
    } else {
      MantenimientoDAO.actualizarMantenimiento(
        mantenimientoID: mantenimientoId,
        tipo: tipoController.text.trim(),
        costo: costo,
        descripcion: descripcionController.text.trim(),
      );
    }
    mantenimientoID = 0;
    tipoController.clear();
    costoController.clear();
    descripcionController.clear();
    final mes = DateFormat('yyyy-MM').format(DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF204c6c),
        content: Text('Servicio guardado'),
      ),
    );
    setState(() {
      _formCarroID = -1;
      isSaving = false;
      _futureCars = fetchCarData(mes);
    });
  }

  Future<List<Car>> fetchCarData(String month) async {
    final resumenRows = DatabaseHelper().db.select(
      '''
SELECT 
  C.CarroID AS id,
  C.NombreCarro AS model,
  IFNULL(R.totalRenta, 0) AS totalRenta,
  IFNULL(R.numRentas, 0) * C.Comision AS totalComision,
  IFNULL(M.totalServicios, 0) AS totalServicios
FROM Carro C
LEFT JOIN (
    SELECT 
      CarroID,
      SUM(PrecioTotal) AS totalRenta,
      COUNT(*) AS numRentas
    FROM Renta
    WHERE substr(FechaInicio,1,7) = ?
    GROUP BY CarroID
) R ON C.CarroID = R.CarroID
LEFT JOIN (
    SELECT 
      CarroID,
      SUM(Costo) AS totalServicios
    FROM Mantenimiento
    WHERE substr(FechaRegistro,1,7) = ?
    GROUP BY CarroID
) M ON C.CarroID = M.CarroID;


      // SELECT 
      //   C.CarroID AS id,
      //   C.NombreCarro AS model,
      //   IFNULL(SUM(R.PrecioTotal), 0) AS totalRenta,
      //   IFNULL(SUM(R.Comision), 0) AS totalComision,
      //   IFNULL(SUM(M.Costo), 0) AS totalServicios
      // FROM Carro C
      // LEFT JOIN Renta R ON C.CarroID = R.CarroID AND substr(R.FechaInicio,1,7)=?
      // LEFT JOIN Mantenimiento M ON C.CarroID = M.CarroID AND substr(M.FechaRegistro,1,7)=?
      // GROUP BY C.CarroID, C.NombreCarro;
      ''',
      [month, month],
    );

    final serviciosRows = DatabaseHelper().db.select(
      '''
      SELECT MantenimientoID, CarroID, TipoServicio, Costo, Descripcion
      FROM Mantenimiento
      WHERE substr(FechaRegistro,1,7)=?
      ORDER BY CarroID, FechaRegistro;
      ''',
      [month],
    );

    final Map<int, List<Service>> serviciosMap = {};
    for (var row in serviciosRows) {
      final int carroID = row['CarroID'] as int;
      serviciosMap
          .putIfAbsent(carroID, () => [])
          .add(
            Service(
              row['MantenimientoID'] as int,
              row['TipoServicio'] as String,
              (row['Costo'] as num).toDouble(),
              row['Descripcion'] as String,
            ),
          );
    }

    return resumenRows.map((row) {
      final int id = row['id'] as int;
      return Car(
        carroID: id,
        model: row['model'] as String,
        totalRenta: (row['totalRenta'] as num).toDouble(),
        totalComision:
            (row['totalComision'] as num).toDouble(), // <--- nuevo campo
        totalServicios: (row['totalServicios'] as num).toDouble(),
        services: serviciosMap[id] ?? [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Car>>(
        future: _futureCars,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color(0xFF204c6c),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final cars = snapshot.data!;
          final totRenta = cars.fold(0.0, (s, c) => s + c.totalRenta);
          final totServ = cars.fold(0.0, (s, c) => s + c.totalServicios);
          final totComision = cars.fold(0.0, (s, c) => s + c.totalComision);
          final totComiServ = totServ + totComision;
          final totNet = totRenta - totComiServ;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Fecha del historial: $fechaDeHoy",
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        exportToExcelWithSummaryAtEnd(cars, context);
                      },
                      child: Text("Exportar a Excel"),
                    ),
                  ],
                ),
                Card(
                  color: const Color(0xFFbcc9d3),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InfoRow(
                          label: "Total rentas:",
                          value: "\$${_formatter.format(totRenta)}",
                        ),
                        InfoRow(
                          label: "Total servicios:",
                          value: "- \$${_formatter.format(totServ)}",
                        ),
                        InfoRow(
                          label: "Total comisiones:",
                          value: "- \$${_formatter.format(totComision)}",
                        ),
                        const Divider(),
                        InfoRow(
                          label: "Ganancia neta:",
                          value: "\$${_formatter.format(totNet)}",
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      final isFormVisible = _formCarroID == car.carroID;
                      final ganancia = car.totalRenta - car.totalServicios;

                      return Card(
                        elevation: 3,
                        color: const Color(0xFFbcc9d3),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    car.model,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand',
                                      color: Color(0xFF204c6c),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => HistorialCarroPage(
                                                carroID: car.carroID,
                                                nombreCarro: car.model,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text("Historial"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (!isFormVisible) ...[
                                InfoRow(
                                  label: "Renta:",
                                  value:
                                      "\$${_formatter.format(car.totalRenta)}",
                                ),
                                InfoRow(
                                  label: "Comisión:",
                                  value:
                                      "- \$${_formatter.format(car.totalComision)}",
                                ),
                                InfoRow(
                                  label: "Total servicios:",
                                  value:
                                      "- \$${_formatter.format(car.totalServicios)}",
                                ),
                              ],

                              // Servicios + botón
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: IconButton(
                                      iconSize: 18,
                                      splashRadius: 14,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        isFormVisible
                                            ? Icons.close
                                            : Icons.add_circle_outline,
                                        color: const Color(0xFF204c6c),
                                      ),
                                      onPressed: () {
                                        mantenimientoID = 0;
                                        setState(() {
                                          if (isFormVisible) {
                                            tipoController.clear();
                                            costoController.clear();
                                            descripcionController.clear();
                                            _formCarroID = -1;
                                          } else {
                                            _formCarroID = car.carroID;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const Text(
                                    "Servicios:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ],
                              ),
                              if (isFormVisible)
                                // 🧾 FORMULARIO DE NUEVO SERVICIO
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: tipoController,
                                        decoration: const InputDecoration(
                                          labelText: "Nombre del Servicio",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                (value == null ||
                                                        value.trim().isEmpty)
                                                    ? 'Agrega el nombre del servicio'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: costoController,
                                        decoration: const InputDecoration(
                                          labelText: "Costo",
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                          ThousandsFormatter(),
                                        ],
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Agrega un costo";
                                          }
                                          final double costo =
                                              double.tryParse(
                                                value.replaceAll(',', ''),
                                              ) ??
                                              0.0;
                                          if (costo <= 0) {
                                            return "Agrega un costo válido";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: descripcionController,
                                        decoration: const InputDecoration(
                                          labelText: "Descripción (opcional)",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              isSaving
                                                  ? null
                                                  : () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      guardarServicio(
                                                        car.carroID,
                                                        mantenimientoID,
                                                      );
                                                    }
                                                  },
                                          child:
                                              isSaving
                                                  ? const CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    color: Color(0xFF204c6c),
                                                  )
                                                  : const Text(
                                                    "Guardar servicio",
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                // LISTA DE SERVICIOS (visible solo cuando no está el formulario)
                                ...car.services.map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Servicio: ${s.tipoServicio}",
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (s.descripcion.isNotEmpty)
                                                Text(
                                                  "Descripción: ${s.descripcion}",
                                                  style: const TextStyle(
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "\$${_formatter.format(s.costo)}",
                                              style: const TextStyle(
                                                fontFamily: 'Quicksand',
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    tipoController.text =
                                                        s.tipoServicio;
                                                    costoController.text = s
                                                        .costo
                                                        .toStringAsFixed(2);
                                                    descripcionController.text =
                                                        s.descripcion;
                                                    mantenimientoID =
                                                        s.mantenimientoID;
                                                    setState(() {
                                                      _formCarroID =
                                                          car.carroID;
                                                    });
                                                  },
                                                  child: Text("Editar"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    eliminarServicio(
                                                      s.mantenimientoID,
                                                    );
                                                  },
                                                  child: Text("Eliminar"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                // InfoRow(
                                //   label: "Total servicios:",
                                //   value: "\$${_formatter.format(car.totalServicios)}",
                                // ),
                                InfoRow(
                                  label: "Ganancia neta:",
                                  value: "\$${_formatter.format(ganancia)}",
                                  bold: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
