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
  static void insertarMantenimiento({
    required int carroId,
    required String fechaRegistro,
    required String tipo,
    required double costo,
    required String descripcion,
  }) async {
    DatabaseHelper().db.execute(
      '''
      INSERT INTO Mantenimiento (CarroID, FechaRegistro, TipoServicio, Costo, Descripcion)
      VALUES (?, ?, ?, ?, ?)
    ''',
      [carroId, fechaRegistro, tipo, costo, descripcion],
    );
  }

  static void eliminarMantenimiento(int mantenimientoID) async {
    DatabaseHelper().db.execute(
      'DELETE FROM Mantenimiento WHERE MantenimientoID = ?',
      [mantenimientoID],
    );
  }

  static void actualizarMantenimiento({
    required int mantenimientoID,
    required String tipo,
    required double costo,
    required String descripcion,
  }) async {
    DatabaseHelper().db.execute(
      '''
      UPDATE Mantenimiento
      SET TipoServicio = ?, Costo = ?, Descripcion = ?
      WHERE MantenimientoID = ?
    ''',
      [tipo, costo, descripcion, mantenimientoID],
    );
  }
}
