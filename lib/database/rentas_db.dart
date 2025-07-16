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
      TipoPago TEXT,
      Observaciones TEXT,
      FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
      FOREIGN KEY (CarroID) REFERENCES Carro(CarroID)
    );
  ''');
}

class RentaDAO {
  // static void insertar(
  //   int clienteId,
  //   int carroId,
  //   String inicio,
  //   String fin,
  //   double total,
  //   String? obs,
  // ) {
  //   DatabaseHelper().db.execute(
  //     '''
  //     INSERT INTO rentas (cliente_id, carro_id, fecha_inicio, fecha_fin, precio_total, observaciones)
  //     VALUES (?, ?, ?, ?, ?, ?)
  //   ''',
  //     [clienteId, carroId, inicio, fin, total, obs],
  //   );
  // }

  static void insertar({
    required clienteID,
    required int carroID,
    required String fechaInicio,
    required String fechaFin,
    required int precioTotal,
    required double precioPagado,
    required String tipoPago,
    required String observaciones,
  }) {
    DatabaseHelper().db.execute(
      '''
      INSERT INTO Renta (ClienteID, CarroID, FechaInicio, FechaFin, PrecioTotal, PrecioPagado, TipoPago, Observaciones)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        clienteID,
        carroID,
        fechaInicio,
        fechaFin,
        precioTotal,
        precioPagado,
        tipoPago,
        observaciones,
      ],
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorialCarros({
    required String fecha,
  }) async {
    return await DatabaseHelper().useDb((db) {
      final result = db.select(
        '''
      SELECT
        c.CarroID,
        c.NombreCarro,
        r.FechaInicio,
        r.FechaFin,
        r.PrecioTotal,
        r.PrecioPagado,
        r.TipoPago
      FROM Carro c
      LEFT JOIN Renta r
        ON c.CarroID = r.CarroID
        AND DATE(?) BETWEEN DATE(r.FechaInicio) AND DATE(r.FechaFin)
      ''',
        [fecha],
      );

      return result
          .map(
            (row) => {
              'CarroID': row['CarroID'],
              'NombreCarro': row['NombreCarro'],
              'FechaInicio': row['FechaInicio'],
              'FechaFin': row['FechaFin'],
              'PrecioTotal': row['PrecioTotal'],
              'PrecioPagado': row['PrecioPagado'],
              'TipoPago': row['TipoPago'],
            },
          )
          .toList();
    });
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
