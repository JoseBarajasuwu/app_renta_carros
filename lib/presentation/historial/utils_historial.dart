import 'dart:io';

import 'package:excel/excel.dart' as excel2;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:renta_carros/presentation/historial/historial_page.dart';

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
    // ignore: use_build_context_synchronously
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

Future<String> getDownloadPath() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final directory = Directory("${Directory.current.path}/");
    return "${directory.path}ReporteAutos.xlsx";
  } else {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/ReporteAutos.xlsx";
  }
}
