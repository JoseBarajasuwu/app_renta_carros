import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:renta_carros/database/calendario_db.dart';
import 'package:renta_carros/database/carros_db.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/database/mantenimientos_db.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _db;

  DatabaseHelper._internal();

  Future<void> init() async {
    if (_db != null) return;

    final dir = Directory.current;
    final dbPath = p.join(dir.path, 'rentacar.db');
    final exists = File(dbPath).existsSync();

    _db = sqlite3.open(dbPath);

    if (!exists) {
      _crearTablas();
      print('Creando base de datos...');
    } else {
      print('Base de datos ya existente.');
      // runMigrations();
    }
  }

  Database get db {
    if (_db == null) {
      throw Exception(
        'Base de datos no inicializada. Llama primero a init() y espera su resultado.',
      );
    }
    return _db!;
  }

  void _crearTablas() {
    importClientesTabla();
    importCarrosTabla();
    importRentasTabla();
    importMantenimientosTabla();
    importCalendarioTabla();
  }

  void dispose() {
    _db?.dispose();
    _db = null;
  }

  Future<T> useDb<T>(
    T Function(Database db) action, {
    bool autoClose = false,
  }) async {
    await init(); // ✅ ya estás dentro del singleton, no necesitas crear otro
    final result = action(_db!);
    if (autoClose) dispose();
    return result;
  }

  // void runMigrations() {
  //   addColumnIfNotExists('Renta', 'Estatus', 'INTEGER DEFAULT 0');
  //   // addColumnIfNotExists('Carro', 'Comision', 'REAL DEFAULT 0');
  // }

  // void addColumnIfNotExists(String table, String column, String type) {
  //   final result = db.select('PRAGMA table_info($table)');
  //   final exists = result.any((row) => row['name'] == column);

  //   if (!exists) {
  //     db.execute('ALTER TABLE $table ADD COLUMN $column $type');
  //     print('Columna $column agregada en $table');
  //   } else {
  //     print('La columna $column ya existe en $table');
  //   }
  // }
}
