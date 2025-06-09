import 'dart:io';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel2;
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

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

  Future<void> exportToExcelWithSummaryAtEnd(
    List<Car> cars,
    BuildContext context,
  ) async {
    final rootPath =
        (await getDownloadsDirectory())?.path ??
        (await getApplicationDocumentsDirectory()).path;

    // Elegir carpeta y archivo
    final selectedPath = await FilesystemPicker.open(
      title: 'Guardar como',
      context: context,
      rootDirectory: Directory(rootPath),
      fsType: FilesystemType.file,
      pickText: 'Guardar aquí',
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      allowedExtensions: ['.xlsx'],
      requestPermission: () async => true,
    );
    if (selectedPath == null) return; // Usuario canceló
    final excel = excel2.Excel.createExcel();
    final sheet = excel['Servicios'];
    excel.delete('Sheet1');

    final borderedCellStyle = excel2.CellStyle(
      leftBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
      rightBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
      topBorder: excel2.Border(
        borderStyle: excel2.BorderStyle.Thin,
        borderColorHex: excel2.ExcelColor.black,
      ),
      bottomBorder: excel2.Border(
        borderStyle: excel2.BorderStyle.Thin,
        borderColorHex: excel2.ExcelColor.black,
      ),
    );
    final boldBorderedCellStyle = excel2.CellStyle(bold: true);

    int row = 0;

    for (var car in cars) {
      final totalServicios = car.services.fold(0.0, (sum, s) => sum + s.cost);
      final gananciaNeta = car.renta - totalServicios;

      // Título modelo carro (negrita + borde)
      final modelCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      );
      modelCell.value = excel2.TextCellValue(car.model);
      modelCell.cellStyle = boldBorderedCellStyle;
      row++;

      // Renta
      final labelRentaCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      );
      final valueRentaCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      labelRentaCell.value = excel2.TextCellValue('Renta');
      labelRentaCell.cellStyle = borderedCellStyle;
      valueRentaCell.value = excel2.DoubleCellValue(car.renta);
      valueRentaCell.cellStyle = borderedCellStyle;
      row++;

      // Servicios con renta en cada fila
      for (var service in car.services) {
        final serviceNameCell = sheet.cell(
          excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
        );
        final serviceCostCell = sheet.cell(
          excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
        );
        serviceNameCell.value = excel2.TextCellValue(service.name);
        serviceNameCell.cellStyle = borderedCellStyle;
        serviceCostCell.value = excel2.DoubleCellValue(service.cost);
        serviceCostCell.cellStyle = borderedCellStyle;
        row++;
      }

      // Total Servicios y Ganancia Neta al final
      final totalLabelCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      );
      final totalValueCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      totalLabelCell.value = excel2.TextCellValue('Total Servicios');
      totalLabelCell.cellStyle = borderedCellStyle;
      totalValueCell.value = excel2.DoubleCellValue(totalServicios);
      totalValueCell.cellStyle = borderedCellStyle;
      row++;

      final gananciaLabelCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      );
      final gananciaValueCell = sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      gananciaLabelCell.value = excel2.TextCellValue('Ganancia Neta');
      gananciaLabelCell.cellStyle = borderedCellStyle;
      gananciaValueCell.value = excel2.DoubleCellValue(gananciaNeta);
      gananciaValueCell.cellStyle = borderedCellStyle;
      row++;

      // Fila vacía para separar carros
      row++;
    }
    // Guardar archivo
    final bytes = excel.encode();
    final file = File(
      selectedPath.endsWith('.xlsx') ? selectedPath : '$selectedPath.xlsx',
    );
    await file.writeAsBytes(bytes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📁 Archivo Excel guardado en:\n${file.path}')),
    );
  }
  // 🟢 NUEVO: Cuadro para elegir dónde guardar el archivo
  //   final filePath = await getSavePath(suggestedName: 'reporte.xlsx');
  //   if (filePath == null) return; // El usuario canceló

  //   final bytes = excel.encode();
  //   final path = await getDownloadPath();
  //   final file = File(path);
  //   await file.writeAsBytes(bytes!);

  //   if (Platform.isWindows) {
  //     await Process.run('start', [file.path], runInShell: true);
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('📊 Archivo Excel guardado en:\n$path')),
  //   );
  // }

  Future<String> getDownloadPath() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = Directory("${Directory.current.path}/");
      return "${directory.path}ReporteAutos.xlsx";
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return "${dir.path}/ReporteAutos.xlsx";
    }
  }

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
      appBar: AppBar(
        title: Text('Resumen de Autos'),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.teal[50],
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
                              color: Colors.teal[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          InfoRow(
                            label: "Renta:",
                            value: "\$${car.renta.toStringAsFixed(2)}",
                          ),
                          Text(
                            "Servicios:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...car.services.map((service) {
                            return Row(
                              children: [
                                Expanded(child: Text("• ${service.name}")),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "\$${service.cost.toStringAsFixed(2)}",
                                    textAlign: TextAlign.right,
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
        label: Text("Exportar Excel"),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

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

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? TextStyle(fontWeight: FontWeight.bold) : null,
            ),
          ),
          Text(
            value,
            style:
                bold
                    ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    )
                    : TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
