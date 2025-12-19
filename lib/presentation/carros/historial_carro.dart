import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/carros/carros_model.dart';
import 'package:renta_carros/database/database.dart';
import 'package:renta_carros/presentation/carros/utils_historial_carro.dart';

class HistorialCarroPage extends StatefulWidget {
  final int carroID;
  final String nombreCarro;
  const HistorialCarroPage({
    super.key,
    required this.carroID,
    required this.nombreCarro,
  });

  @override
  State<HistorialCarroPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialCarroPage> {
  late Future<CarHistorial?> _futureCar;
  final formatter = NumberFormat("#,##0.00", "es_MX");

  @override
  void initState() {
    super.initState();
    final mesActual = DateFormat('yyyy-MM').format(DateTime.now());
    _futureCar = fetchCarDetalles(mesActual);
  }

  Future<CarHistorial?> fetchCarDetalles(String month) async {
    final carroRow = DatabaseHelper().db.select(
      '''
      SELECT CarroID AS id, NombreCarro AS model
      FROM Carro
      WHERE CarroID = ?
      ''',
      [widget.carroID],
    );

    if (carroRow.isEmpty) return null;

    final rentasRows = DatabaseHelper().db.select(
      '''
  SELECT R.FechaInicio, R.FechaFin, R.PrecioTotal, R.PrecioPagado, 
         R.TipoPago, R.Observaciones, C.Comision as comision
  FROM Renta R
  JOIN Carro C ON R.CarroID = C.CarroID
  WHERE substr(R.FechaInicio,1,7)=? AND R.CarroID = ?
  ORDER BY R.FechaInicio;
  ''',
      [month, widget.carroID],
    );

    final serviciosRows = DatabaseHelper().db.select(
      '''
      SELECT FechaRegistro AS fecha, TipoServicio AS tipo, Costo AS costo, Descripcion AS descripcion
      FROM Mantenimiento
      WHERE substr(FechaRegistro,1,7)=? AND CarroID = ?
      ORDER BY FechaRegistro;
      ''',
      [month, widget.carroID],
    );

    final rentas =
        rentasRows.map((r) {
          return Renta(
            fechaInicio: r['FechaInicio'] as String,
            fechaFin: r['FechaFin'] as String,
            precioTotal: (r['PrecioTotal'] as num).toDouble(),
            precioPagado: (r['PrecioPagado'] as num).toDouble(),
            tipoPago: r['TipoPago'] as String?,
            observaciones: r['Observaciones'] as String?,
            comision:
                (r['comision'] as num).toDouble(), // <-- Aquí ya lo tienes
          );
        }).toList();

    final servicios =
        serviciosRows.map((s) {
          return ServicioDetalle(
            s['fecha'] as String,
            s['tipo'] as String,
            (s['costo'] as num).toDouble(),
            s['descripcion'] as String?,
          );
        }).toList();

    return CarHistorial(
      carroID: carroRow.first['id'] as int,
      model: carroRow.first['model'] as String,
      rentas: rentas,
      serviciosDetalle: servicios,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de ${widget.nombreCarro}"),
        backgroundColor: const Color(0xFF204c6c),
      ),
      body: FutureBuilder<CarHistorial?>(
        future: _futureCar,
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

          final car = snapshot.data;
          if (car == null) {
            return const Center(child: Text("No se encontró el carro."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final car = snapshot.data!;
                    await exportHistorialDetalladoToExcel(car, context);
                  },
                  child: const Text(
                    'Exportar historial a Excel',
                    style: TextStyle(fontFamily: 'Quicksand'),
                  ),
                ),
                const Text(
                  "Rentas:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                  ),
                ),
                if (car.rentas.isEmpty) const Text("No hay rentas este mes."),
                ...car.rentas.map(
                  (r) => Card(
                    color: Color(0xFFbcc9d3),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        'Del ${_formatoFechaDinamico(r.fechaInicio)} al ${_formatoFechaDinamico(r.fechaFin)}',
                        style: const TextStyle(fontFamily: 'Quicksand'),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio total: \$${formatter.format(r.precioTotal)}',
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                          Text(
                            'Precio pagado: \$${formatter.format(r.precioPagado)}',
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                          Text(
                            'Comisión: ${r.comision}',
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                          if (r.tipoPago != null && r.tipoPago!.isNotEmpty)
                            Text(
                              "Tipo de pago: ${r.tipoPago}",
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                          if (r.observaciones != null &&
                              r.observaciones!.isNotEmpty)
                            Text(
                              "Observaciones: ${r.observaciones}",
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                const Text(
                  "Servicios:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                  ),
                ),
                if (car.serviciosDetalle.isEmpty)
                  const Text("No hay servicios este mes."),
                ...car.serviciosDetalle.map(
                  (s) => Card(
                    color: Color(0xFFbcc9d3),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        s.tipo,
                        style: const TextStyle(fontFamily: 'Quicksand'),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatoFechaDinamico(s.fecha),
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                          Text(
                            "Costo: \$${formatter.format(s.costo)}",
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                          if (s.descripcion != null &&
                              s.descripcion!.trim().isNotEmpty)
                            Text(
                              "Descripción: ${s.descripcion}",
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //"Faltan detalles minimos"
  String _formatoFechaDinamico(dynamic fecha) {
    try {
      final f = fecha is DateTime ? fecha : DateTime.parse(fecha.toString());
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
