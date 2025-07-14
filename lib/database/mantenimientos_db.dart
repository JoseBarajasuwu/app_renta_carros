import 'database.dart';

void importMantenimientosTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS Mantenimiento (
      MantenimientoID INTEGER PRIMARY KEY AUTOINCREMENT,
      CarroID INTEGER NOT NULL,
      FechaRegistro TEXT NOT NULL,
      TipoServicio TEXT NOT NULL,
      Costo REAL,
      Descripcion TEXT,
      FOREIGN KEY (CarroID) REFERENCES Carro(CarroID)
    );
  ''');
}

class MantenimientoDAO {
  static void insertar(
    int carroId,
    String fecha,
    String tipo,
    double? costo,
    String? descripcion,
  ) {
    DatabaseHelper().db.execute(
      '''
      INSERT INTO mantenimientos (carro_id, fecha, tipo_servicio, costo, descripcion)
      VALUES (?, ?, ?, ?, ?)
    ''',
      [carroId, fecha, tipo, costo, descripcion],
    );
  }

  // static List<Map<String, dynamic>> obtenerTodos() {
  //   final result = DatabaseHelper().db.select('SELECT * FROM mantenimientos');
  //   return result.map((row) => row.toMap()).toList();
  // }

  static void eliminar(int id) {
    DatabaseHelper().db.execute('DELETE FROM mantenimientos WHERE id = ?', [
      id,
    ]);
  }
}
