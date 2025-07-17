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
  static void insertar({
    required int carroId,
    required String fechaRegistro,
    required String tipo,
    required double costo,
    required String descripcion,}
  ) async{
    DatabaseHelper().db.execute(
      '''
      INSERT INTO Mantenimiento (CarroID, FechaRegistro, TipoServicio, Costo, Descripcion)
      VALUES (?, ?, ?, ?, ?)
    ''',
      [carroId, fechaRegistro, tipo, costo, descripcion],
    );
  }

  static void eliminar(int id) {
    DatabaseHelper().db.execute('DELETE FROM mantenimientos WHERE id = ?', [
      id,
    ]);
  }
}


