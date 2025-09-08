import 'dart:io';

import 'package:excel/excel.dart' as excel2;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:renta_carros/core/historial/model/historial_model.dart';

Future<void> exportToExcelWithSummaryAtEnd(
  List<Car> cars,
  BuildContext context,
) async {
  final documentsPath = await getDocumentsDirectoryPath();
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final fileName = 'ReporteAutos_$today.xlsx';
  final filePath = p.join(documentsPath, fileName);

  final excel = excel2.Excel.createExcel();
  final sheet = excel['Servicios'];
  excel.delete('Sheet1');

  final borderedCellStyle = excel2.CellStyle(
    leftBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    rightBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    topBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    bottomBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
  );

  final boldBorderedCellStyle = excel2.CellStyle(
    bold: true,
    leftBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    rightBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    topBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    bottomBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
  );

  int row = 0;

  for (var car in cars) {
    final totalServicios = car.services.fold(0.0, (sum, s) => sum + s.cost);
    final totComiServ = car.totalComision + totalServicios;
    final gananciaNeta = car.totalRenta - totComiServ;

    final modelCell = sheet.cell(
      excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    modelCell.value = excel2.TextCellValue(car.model);
    modelCell.cellStyle = boldBorderedCellStyle;
    row++;

    final labelRentaCell = sheet.cell(
      excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    final valueRentaCell = sheet.cell(
      excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
    );
    labelRentaCell.value = excel2.TextCellValue('Renta');
    labelRentaCell.cellStyle = borderedCellStyle;
    valueRentaCell.value = excel2.DoubleCellValue(car.totalRenta);
    valueRentaCell.cellStyle = borderedCellStyle;
    row++;

    final labelComisionCell = sheet.cell(
      excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    final valueComisionCell = sheet.cell(
      excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
    );
    labelComisionCell.value = excel2.TextCellValue('Comisión');
    labelComisionCell.cellStyle = borderedCellStyle;
    valueComisionCell.value = excel2.DoubleCellValue(car.totalComision);
    valueComisionCell.cellStyle = borderedCellStyle;
    row++;

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
    row++; // fila vacía
  }

  // Abrir automáticamente el archivo
  try {
    final bytes = excel.encode();
    final file = File(filePath);
    await file.writeAsBytes(bytes!);
    await OpenFile.open(filePath);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF204c6c),
          content: Text('📁 Error al abrir el archivo'),
        ),
      );
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF204c6c),
        content: Text('📁 Archivo guardado automáticamente en:\n$filePath'),
      ),
    );
  }
}

Future<String> getDocumentsDirectoryPath() async {
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    return p.join(userProfile!, 'Documents');
  } else if (Platform.isMacOS || Platform.isLinux) {
    final home = Platform.environment['HOME'];
    return p.join(home!, 'Documents');
  } else {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
