import 'database.dart';

void importRentasTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS Renta (
      RentaID INTEGER PRIMARY KEY AUTOINCREMENT,
      ClienteID INTEGER NOT NULL,
      CarroID INTEGER NOT NULL,
      FechaInicio TEXT NOT NULL,
      FechaFin TEXT NOT NULL,
      PrecioTotal REAL NOT NULL,
      PrecioPagado INTEGER NOT NULL,
      Observaciones TEXT,
      FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
      FOREIGN KEY (CarroID) REFERENCES Carro(CarroID)
    );
  ''');
}

class RentaDAO {
  static void insertar(
    int clienteId,
    int carroId,
    String inicio,
    String fin,
    double total,
    String? obs,
  ) {
    DatabaseHelper().db.execute(
      '''
      INSERT INTO rentas (cliente_id, carro_id, fecha_inicio, fecha_fin, precio_total, observaciones)
      VALUES (?, ?, ?, ?, ?, ?)
    ''',
      [clienteId, carroId, inicio, fin, total, obs],
    );
  }

  // static List<Map<String, dynamic>> obtenerTodas() {
  //   final result = DatabaseHelper().db.select('SELECT * FROM rentas');
  //   return result.map((row) => row.toMap()).toList();
  // }

  // static List<Map<String, dynamic>> obtenerCarrosRentadosPorCliente(
  //   int clienteId,
  // ) {
  //   final result = DatabaseHelper().db.select(
  //     '''
  //   SELECT r.id AS renta_id,
  //          c.id AS carro_id,
  //          c.marca,
  //          c.modelo,
  //          c.placas,
  //          r.fecha_inicio,
  //          r.fecha_fin,
  //          r.precio_total
  //   FROM rentas r
  //   JOIN carros c ON r.carro_id = c.id
  //   WHERE r.cliente_id = ?
  // ''',
  //     [clienteId],
  //   );

  //   return result.map((row) => row.toMap()).toList();
  // }

  static void eliminar(int id) {
    DatabaseHelper().db.execute('DELETE FROM rentas WHERE id = ?', [id]);
  }
}
