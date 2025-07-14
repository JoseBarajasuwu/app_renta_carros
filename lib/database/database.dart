import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:renta_carros/database/calendario_renta_db.dart';
import 'package:renta_carros/database/carros_db.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/database/mantenimientos_db.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  late final Database db;

  DatabaseHelper._internal();

  Future<void> init() async {
    final dir = Directory.current;
    // final dir = await getApplicationDocumentsDirectory();
    print(dir);
    final dbPath = p.join(dir.path, 'rentacar.db');
    final exists = File(dbPath).existsSync();

    db = sqlite3.open(dbPath);

    if (!exists) {
      print('Creando base de datos...');
      _crearTablas();
    } else {
      print('Base de datos ya existente.');
    }
  }

  void _crearTablas() {
    importClientesTabla();
    importCarrosTabla();
    importRentasTabla();
    importMantenimientosTabla();
    importCalendarioTabla();
  }

  void dispose() {
    DatabaseHelper().db.dispose();
  }
}
