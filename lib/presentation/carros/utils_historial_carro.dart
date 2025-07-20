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

  int row = 0;

  // Título principal
  sheet.merge(
    excel2.CellIndex.indexByString("A1"),
    excel2.CellIndex.indexByString("F1"),
  );
  sheet.cell(excel2.CellIndex.indexByString("A1"))
    ..value = excel2.TextCellValue("Historial de ${car.model}")
    ..cellStyle = boldBorderedCellStyle;
  row++;

  // Rentas
  row++;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("Rentas")
    ..cellStyle = boldBorderedCellStyle;
  row++;

  sheet.appendRow([
    excel2.TextCellValue("FechaInicio"),
    excel2.TextCellValue("FechaFin"),
    excel2.TextCellValue("Precio Total"),
    excel2.TextCellValue("Precio Pagado"),
    excel2.TextCellValue("Tipo de Pago"),
    excel2.TextCellValue("Observaciones"),
  ]);

  for (var r in car.rentas) {
    row++;
    sheet.appendRow([
      excel2.TextCellValue(formatoFechaDinamico(r.fechaInicio)),
      excel2.TextCellValue(formatoFechaDinamico(r.fechaFin)),
      excel2.DoubleCellValue(r.precioTotal),
      excel2.DoubleCellValue(r.precioPagado),
      excel2.TextCellValue(r.tipoPago ?? ''),
      excel2.TextCellValue(r.observaciones ?? ''),
    ]);
  }

  // Totales de renta
  final totalRentas = car.rentas.fold(0.0, (sum, r) => sum + r.precioTotal);
  row++;
  sheet.appendRow([
    excel2.TextCellValue("TOTAL RENTAS"),
    excel2.TextCellValue(""),
    excel2.DoubleCellValue(totalRentas),
    excel2.TextCellValue(""),
    excel2.TextCellValue(""),
    excel2.TextCellValue(""),
  ]);

  // Servicios
  row += 2;
  sheet.cell(excel2.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
    ..value = excel2.TextCellValue("Servicios")
    ..cellStyle = boldBorderedCellStyle;
  row++;

  sheet.appendRow([
    excel2.TextCellValue("Fecha"),
    excel2.TextCellValue("Tipo"),
    excel2.TextCellValue("Costo"),
    excel2.TextCellValue("Descripción"),
  ]);

  for (var s in car.serviciosDetalle) {
    row++;
    sheet.appendRow([
      excel2.TextCellValue(s.fecha),
      excel2.TextCellValue(s.tipo),
      excel2.DoubleCellValue(s.costo),
      excel2.TextCellValue(s.descripcion ?? ''),
    ]);
  }

  // Totales de servicios
  final totalServicios = car.serviciosDetalle.fold(
    0.0,
    (sum, s) => sum + s.costo,
  );
  row++;
  sheet.appendRow([
    excel2.TextCellValue("TOTAL SERVICIOS"),
    excel2.TextCellValue(""),
    excel2.DoubleCellValue(totalServicios),
    excel2.TextCellValue(""),
  ]);

  final bytes = excel.encode();
  final file = File(filePath);
  await file.writeAsBytes(bytes!);
  // Abrir automáticamente el archivo
  await OpenFile.open(filePath);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF204c6c),
        content: Text('📁 Historial guardado en:\n$filePath'),
      ),
    );
  }
}
