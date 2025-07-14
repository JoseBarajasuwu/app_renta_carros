import 'database.dart';

void importCalendarioTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS CalendarioRenta (
      CalendarioRentaID INTEGER PRIMARY KEY AUTOINCREMENT,
      CarroID INTEGER NOT NULL,
      ClienteID INTEGER NOT NULL,
      FechaInicio TEXT NOT NULL,
      FechaFin TEXT NOT NULL,
      FOREIGN KEY (CarroID) REFERENCES Carro(CarroID),
      FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
    );
  ''');
}

class CalendarioDAO {
  static void insertar(int carroId, int clienteId, String inicio, String fin) {
    DatabaseHelper().db.execute(
      '''
      INSERT INTO calendario_renta (carro_id, cliente_id, fecha_inicio, fecha_fin)
      VALUES (?, ?, ?, ?)
    ''',
      [carroId, clienteId, inicio, fin],
    );
  }

  // static List<Map<String, dynamic>> obtenerRentasPorCarro(int carroId) {
  //   final result = DatabaseHelper().db.select(
  //     '''
  //     SELECT * FROM calendario_renta WHERE carro_id = ?
  //   ''',
  //     [carroId],
  //   );
  //   return result.map((row) => row.toMap()).toList();
  // }

  // static List<Map<String, dynamic>> obtenerDisponibles(
  //   String fechaInicio,
  //   String fechaFin,
  // ) {
  //   final result = DatabaseHelper().db.select(
  //     '''
  //     SELECT * FROM carros
  //     WHERE id NOT IN (
  //       SELECT carro_id
  //       FROM calendario_renta
  //       WHERE fecha_inicio <= ? AND fecha_fin >= ?
  //     )
  //     AND estado = 'Disponible'
  //   ''',
  //     [fechaFin, fechaInicio],
  //   );

  //   return result.map((row) => row.toMap()).toList();
  // }
}
