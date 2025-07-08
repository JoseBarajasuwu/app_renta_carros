import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/presentation/historial/utils_historial.dart';
import 'package:renta_carros/presentation/historial/widgets/info_rows.dart';

class Car {
  final String model;
  final double renta;
  final List<Service> services;

  Car({required this.model, required this.renta, required this.services});
}

class Service {
  final String name;
  final double cost;

  Service(this.name, this.cost);
}

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final List<Car> cars = [
    Car(
      model: "Toyota Corolla",
      renta: 800,
      services: [
        Service("Cambio de aceite", 5000),
        Service("Alineación", 30),
        Service("Frenos", 120),
      ],
    ),
    Car(
      model: "Honda Civic",
      renta: 900,
      services: [Service("Cambio de batería", 5000), Service("Lavado", 25)],
    ),
  ];
  double dtotalRenta = 0;
  double dtotalCostos = 0;
  double dtotalGananciaNeta = 0;

  String stotalRenta = "";
  String stotalCostos = "";
  String stotalGananciaNeta = "";

  // Puedes usar esta si quieres sin símbolo pero con separadores decimales y miles
  final NumberFormat _formatter = NumberFormat("#,##0.00", "es_MX");

  // O esta si quieres que incluya el símbolo "$"
  // final NumberFormat _formatter = NumberFormat.currency(locale: "es_MX", symbol: "\$");

  void cargaRentas() {
    // Acumular los valores de cada carro
    for (final car in cars) {
      final costo = car.services.fold(0.0, (sum, s) => sum + s.cost);
      dtotalRenta += car.renta;
      dtotalCostos += costo;
      dtotalGananciaNeta += car.renta - costo;
    }

    // Formatear correctamente los resultados (pasando `double`, no `String`)
    stotalRenta = _formatter.format(dtotalRenta);
    stotalCostos = _formatter.format(dtotalCostos);
    stotalGananciaNeta = _formatter.format(dtotalGananciaNeta);
  }

  @override
  void initState() {
    cargaRentas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Color(0xFFbcc9d3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    InfoRow(label: "Total en rentas:", value: "\$$stotalRenta"),
                    InfoRow(
                      label: "Total en servicios:",
                      value: "- \$$stotalCostos",
                    ),
                    Divider(),
                    InfoRow(
                      label: "Ganancia neta total:",
                      value: "\$$stotalGananciaNeta",
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  final totalServicios = car.services.fold(
                    0.0,
                    (sum, s) => sum + s.cost,
                  );

                  final ganacia = car.renta - totalServicios;
                  final gananciaNeta = _formatter.format(ganacia);
                  final totalServicio = _formatter.format(totalServicios);
                  return Card(
                    elevation: 3,
                    color: Color(0xFFbcc9d3),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.model,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF204c6c),
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          SizedBox(height: 8),
                          InfoRow(
                            label: "Renta:",
                            value: "\$${car.renta.toStringAsFixed(2)}",
                          ),
                          Text(
                            "Servicios:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          ...car.services.map((service) {
                            final serviceCost = _formatter.format(service.cost);
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "• ${service.name}",
                                    style: TextStyle(fontFamily: 'Quicksand'),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "\$$serviceCost",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontFamily: 'Quicksand'),
                                  ),
                                ),
                              ],
                            );
                          }),
                          Divider(),
                          InfoRow(
                            label: "Total servicios:",
                            value: "\$$totalServicio",
                          ),
                          InfoRow(
                            label: "Ganancia neta:",
                            value: "\$$gananciaNeta",
                            bold: true,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => exportToExcelWithSummaryAtEnd(cars, context),
        icon: Icon(Icons.download),
        label: Text(
          "Exportar Excel",
          style: TextStyle(fontFamily: 'Quicksand'),
        ),
        backgroundColor: Color(0xFF204c6c),
      ),
    );
  }
}
