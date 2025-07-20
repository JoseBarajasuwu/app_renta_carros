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
      PrecioPagado REAL NOT NULL,
      TipoPago TEXT,
      Observaciones TEXT,
      FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
      FOREIGN KEY (CarroID) REFERENCES Carro(CarroID)
    );
  ''');
}

class RentaDAO {
  static void insertar({
    required clienteID,
    required int carroID,
    required String fechaInicio,
    required String fechaFin,
    required double precioTotal,
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
        cl.Nombre || ' ' || cl.Apellido AS NombreCompleto,
        c.NombreCarro,
        r.FechaInicio,
        r.FechaFin,
        r.PrecioTotal,
        r.PrecioPagado,
        r.TipoPago
      FROM
        Carro c
      LEFT JOIN
        Renta r ON c.CarroID = r.CarroID
      LEFT JOIN Cliente cl ON cl.ClienteID = r.ClienteID
        AND DATE(?) BETWEEN DATE(r.FechaInicio) AND DATE(r.FechaFin)
      ''',
        [fecha],
      );

      return result
          .map(
            (row) => {
              'CarroID': row['CarroID'],
              'NombreCompleto': row['NombreCompleto'],
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

  Future<List<Map<String, dynamic>>> obtenerHistorialRenta({
    required String month,
    required int carroID,
  }) async {
    final result = DatabaseHelper().db.select(
      '''
      SELECT 
        r.FechaInicio,
        r.FechaFin,
        r.PrecioTotal,
        r.PrecioPagado,
        r.TipoPago,
        r.Observaciones
      FROM Carro c
      LEFT JOIN Renta r ON c.CarroID = r.CarroID AND substr(r.FechaInicio,1,7)=?
      WHERE r.CarroID = ?
      GROUP BY c.CarroID, c.NombreCarro;
      ''',
      [month, carroID],
    );
    return result
        .map(
          (row) => {
            'CarroID': row['CarroID'],
            'NombreCompleto': row['NombreCompleto'],
            'NombreCarro': row['NombreCarro'],
            'FechaInicio': row['FechaInicio'],
            'FechaFin': row['FechaFin'],
            'PrecioTotal': row['PrecioTotal'],
            'PrecioPagado': row['PrecioPagado'],
            'TipoPago': row['TipoPago'],
          },
        )
        .toList();
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

  // Modelos

  // Future<List<Car>> fetchCarData(String month) async {
  //   // Totales por carro
  //   final resumenRows =  DatabaseHelper().db.select('''
  //     SELECT
  //       C.CarroID AS id,
  //       C.Modelo AS model,
  //       IFNULL(SUM(R.PrecioTotal), 0) AS totalRenta,
  //       IFNULL(SUM(M.Costo), 0) AS totalServicios
  //     FROM Carro C
  //     LEFT JOIN Renta R ON C.CarroID = R.CarroID AND substr(R.FechaInicio,1,7)=?
  //     LEFT JOIN Mantenimiento M ON C.CarroID = M.CarroID AND substr(M.FechaRegistro,1,7)=?
  //     GROUP BY C.CarroID, C.Modelo;
  //   ''', [month, month]);

  //   // Servicios detallados
  //   final serviciosRows = DatabaseHelper().db.select('''
  //     SELECT CarroID AS id, TipoServicio AS name, Costo AS cost
  //     FROM Mantenimiento
  //     WHERE substr(FechaRegistro,1,7)=?
  //     ORDER BY CarroID, FechaRegistro;
  //   ''', [month]);

  //   // Mapear lista de servicios
  //   final Map<int, List<Service>> serviciosMap = {};
  //   for (var row in serviciosRows) {
  //     final int id = row['id'] as int;
  //     serviciosMap.putIfAbsent(id, () => [])
  //       .add(Service(row['name'] as String, (row['cost'] as num).toDouble()));
  //   }

  //   // Construir modelos
  //   return resumenRows.map((row) {
  //     final int id = row['id'] as int;
  //     return Car(
  //       carroID: id,
  //       model: row['model'] as String,
  //       totalRenta: (row['totalRenta'] as num).toDouble(),
  //       totalServicios: (row['totalServicios'] as num).toDouble(),
  //       services: serviciosMap[id] ?? [],
  //     );
  //   }).toList();
  // }
}
