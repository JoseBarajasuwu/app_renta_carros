import 'package:flutter/material.dart';
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
        Service("Cambio de aceite", 50),
        Service("Alineación", 30),
        Service("Frenos", 120),
      ],
    ),
    Car(
      model: "Honda Civic",
      renta: 600,
      services: [Service("Cambio de batería", 100), Service("Lavado", 25)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double totalRenta = 0;
    double totalCostos = 0;
    double totalGananciaNeta = 0;

    for (final car in cars) {
      final costo = car.services.fold(0.0, (sum, s) => sum + s.cost);
      totalRenta += car.renta;
      totalCostos += costo;
      totalGananciaNeta += car.renta - costo;
    }

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
                    InfoRow(
                      label: "Total en rentas:",
                      value: "\$${totalRenta.toStringAsFixed(2)}",
                    ),
                    InfoRow(
                      label: "Total en servicios:",
                      value: "- \$${totalCostos.toStringAsFixed(2)}",
                    ),
                    Divider(),
                    InfoRow(
                      label: "Ganancia neta total:",
                      value: "\$${totalGananciaNeta.toStringAsFixed(2)}",
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
                  final gananciaNeta = car.renta - totalServicios;

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
                                    "\$${service.cost.toStringAsFixed(2)}",
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
                            value: "- \$${totalServicios.toStringAsFixed(2)}",
                          ),
                          InfoRow(
                            label: "Ganancia neta:",
                            value: "\$${gananciaNeta.toStringAsFixed(2)}",
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
