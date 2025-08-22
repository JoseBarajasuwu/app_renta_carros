import 'package:renta_carros/database/database.dart';

void importCalendarioTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS Calendario (
      CalendarioID INTEGER PRIMARY KEY AUTOINCREMENT,
      Descripcion TEXT NOT NULL,
      FechaRegistro TEXT NOT NULL,
      CarroID INTEGER,
      Estatus INTEGER
    );
  ''');
}

class CalendarioDAO {
  static Future<List<Map<String, dynamic>>> obtenerEventos() async {
    final result = DatabaseHelper().db.select("SELECT * FROM Calendario");
    return result.map((row) {
      return {
        'CalendarioID': row['CalendarioID'],
        'Descripcion': row['Descripcion'],
        'FechaRegistro': row['FechaRegistro'],
        'Estatus': row['Estatus'],
      };
    }).toList();
  }

  static void insentarEvento({
    required String descripcion,
    required String fechaRegistro,
    required int? estatus,
  }) {
    DatabaseHelper().db.execute(
      'INSERT INTO Calendario (Descripcion, FechaRegistro, Estatus) VALUES (?,?,?)',
      [descripcion, fechaRegistro, estatus],
    );
  }

  static void actualizarEvento({
    required int calendarioID,
    required String descripcion,
    required String fechaRegistro,
    required int? estatus,
  }) {
    DatabaseHelper().db.execute(
      'UPDATE Calendario SET Descripcion = ?, FechaRegistro = ?, Estatus = ? WHERE CalendarioID = ?',
      [descripcion, fechaRegistro, estatus, calendarioID],
    );
  }

  static void eliminarEvento({required int calendarioID}) {
    DatabaseHelper().db.execute(
      'DELETE FROM Calendario WHERE CalendarioID = ? ',
      [calendarioID],
    );
  }
}
