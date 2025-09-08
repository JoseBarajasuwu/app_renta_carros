import 'dart:io';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/carros/carros_model.dart';
import 'package:renta_carros/presentation/historial/utils_historial.dart';
import 'package:excel/excel.dart' as excel2;
import 'package:path/path.dart' as p;

//"Faltan detalles minimos"
String formatoFechaDinamico(dynamic fecha) {
  try {
    final f = fecha is DateTime ? fecha : DateTime.parse(fecha.toString());
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  } catch (e) {
    return 'Fecha inválida';
  }
}

Future<void> exportHistorialDetalladoToExcel(
  CarHistorial car,
  BuildContext context,
) async {
  final documentsPath = await getDocumentsDirectoryPath();
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final fileName = 'Historial_${car.model}_$today.xlsx';
  final filePath = p.join(documentsPath, fileName);

  final excel = excel2.Excel.createExcel();
  final sheet = excel['Historial'];
  excel.delete('Sheet1');

  final boldBorderedCellStyle = excel2.CellStyle(
    bold: true,
    leftBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    rightBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    topBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
    bottomBorder: excel2.Border(borderStyle: excel2.BorderStyle.Thin),
  );

  int row = 1;

  // ======= TÍTULO PRINCIPAL =======
  sheet.merge(
    // excel2.CellIndex.indexByString("A$row"),
    // excel2.CellIndex.indexByString("F$row"),
    excel2.CellIndex.indexByString("A1"),
    excel2.CellIndex.indexByString("F1"),
  );
  sheet.cell(excel2.CellIndex.indexByString("A$row"))
    ..value = excel2.TextCellValue("Historial de ${car.model}")
    ..cellStyle = boldBorderedCellStyle;

  // ======= TOTAL COMISIÓN =======
  row += 1;
  final totalComision = car.rentas.fold(0.0, (sum, r) => sum + r.comision);
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("TOTAL COMISIÓN")
    ..cellStyle = boldBorderedCellStyle;
  sheet
      .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      .value = excel2.DoubleCellValue(totalComision);

  // ======= RENTAS =======
  row += 2;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("Rentas")
    ..cellStyle = boldBorderedCellStyle;

  row++;
  final headersRentas = [
    "Fecha Inicio",
    "Fecha Fin",
    "Precio Total",
    "Precio Pagado",
    "Tipo de Pago",
    "Observaciones",
  ];
  for (int col = 0; col < headersRentas.length; col++) {
    sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      )
      ..value = excel2.TextCellValue(headersRentas[col])
      ..cellStyle = boldBorderedCellStyle;
  }

  for (var r in car.rentas) {
    row++;
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = excel2.TextCellValue(formatoFechaDinamico(r.fechaInicio));
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = excel2.TextCellValue(formatoFechaDinamico(r.fechaFin));
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = excel2.DoubleCellValue(r.precioTotal);
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = excel2.DoubleCellValue(r.precioPagado);
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = excel2.TextCellValue(r.tipoPago ?? '');
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = excel2.TextCellValue(r.observaciones ?? '');
  }

  final totalRentas = car.rentas.fold(0.0, (sum, r) => sum + r.precioTotal);
  row++;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("TOTAL RENTAS")
    ..cellStyle = boldBorderedCellStyle;
  sheet
      .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      .value = excel2.DoubleCellValue(totalRentas);

  // ======= SERVICIOS =======
  row += 2;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("Servicios")
    ..cellStyle = boldBorderedCellStyle;

  row++;
  final headersServicios = ["Fecha", "Tipo", "Costo", "Descripción"];
  for (int col = 0; col < headersServicios.length; col++) {
    sheet.cell(
        excel2.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      )
      ..value = excel2.TextCellValue(headersServicios[col])
      ..cellStyle = boldBorderedCellStyle;
  }

  for (var s in car.serviciosDetalle) {
    row++;
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = excel2.TextCellValue(s.fecha);
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = excel2.TextCellValue(s.tipo);
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = excel2.DoubleCellValue(s.costo);
    sheet
        .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = excel2.TextCellValue(s.descripcion ?? '');
  }

  final totalServicios = car.serviciosDetalle.fold(
    0.0,
    (sum, s) => sum + s.costo,
  );
  row++;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("TOTAL SERVICIOS")
    ..cellStyle = boldBorderedCellStyle;
  sheet
      .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      .value = excel2.DoubleCellValue(totalServicios);

  // ======= TOTAL NETO =======
  final totalNeto = totalRentas - totalComision - totalServicios;
  row += 2;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("TOTAL NETO")
    ..cellStyle = boldBorderedCellStyle;
  sheet
      .cell(excel2.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      .value = excel2.DoubleCellValue(totalNeto);

  // ======= Guardar =======
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
}
