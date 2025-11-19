import 'package:renta_carros/presentation/calendario/widget/calendario_widget.dart';

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
      Comision REAL NOT NULL,
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
      INSERT INTO Renta (ClienteID, CarroID, FechaInicio, FechaFin, PrecioTotal, PrecioPagado, TipoPago, Observaciones )
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

  static void update({
    required int rentaID,
    required String fechaInicio,
    required String fechaFin,
    required double precioTotal,
    required double precioPagado,
    required String observaciones,
  }) {
    DatabaseHelper().db.execute(
      'UPDATE Renta SET FechaInicio = ?, FechaFin = ?, PrecioTotal = ?, PrecioPagado = ?, Observaciones = ? WHERE RentaID = ?',
      [
        fechaInicio,
        fechaFin,
        precioTotal,
        precioPagado,
        observaciones,

        rentaID,
      ],
    );
  }

  static void updateCarroRemplazo({
    required int rentaID,
    required int carroID,
    required String fechaInicio,
    required String fechaFin,
    required double precioTotal,
    required double precioPagado,
    required String observaciones,
  }) {
    DatabaseHelper().db.execute(
      'UPDATE Renta SET FechaInicio = ?, FechaFin = ?, PrecioTotal = ?, PrecioPagado = ?, Observaciones = ?, CarroID = ?  WHERE RentaID = ?',
      [
        fechaInicio,
        fechaFin,
        precioTotal,
        precioPagado,
        observaciones,
        carroID,
        rentaID,
      ],
    );
  }

  static void eliminar({required int rentaID}) {
    DatabaseHelper().db.execute('DELETE FROM Renta WHERE RentaID = ?', [
      rentaID,
    ]);
  }

  static Future<void> eliminarRepetidos({required int rentaID}) async {
    DatabaseHelper().db.execute('DELETE FROM Renta WHERE RentaID = ?', [
      rentaID,
    ]);
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorialCarros({
    required String fecha,
  }) async {
    return await DatabaseHelper().useDb((db) {
      final result = db.select(
        '''
        SELECT
            r.RentaID,
            c.CarroID,
            cl.Nombre || ' ' || cl.Apellido AS NombreCompleto,
            c.NombreCarro || ' ' || c.Anio || ' ' || c.Placas AS NombreCarro,
            r.FechaInicio,
            r.FechaFin,
            r.PrecioTotal,
            r.PrecioPagado,
            r.TipoPago,
            r.Observaciones 
        FROM Carro c
        LEFT JOIN Renta r ON c.CarroID = r.CarroID
        LEFT JOIN Cliente cl ON cl.ClienteID = r.ClienteID
        WHERE DATE(?) BETWEEN DATE(r.FechaInicio) AND DATE(r.FechaFin)
        UNION ALL
        SELECT
            NULL AS RentaID,
            c.CarroID,
            NULL AS NombreCompleto,
            c.NombreCarro || ' ' || c.Anio || ' ' || c.Placas AS NombreCarro,
            NULL AS FechaInicio,
            NULL AS FechaFin,
            NULL AS PrecioTotal,
            NULL AS PrecioPagado,
            NULL AS TipoPago,
            NULL AS Observaciones
        FROM Carro c
        WHERE c.CarroID NOT IN (
            SELECT c2.CarroID
            FROM Carro c2
            LEFT JOIN Renta r2 ON c2.CarroID = r2.CarroID
            WHERE DATE(?) BETWEEN DATE(r2.FechaInicio) AND DATE(r2.FechaFin)
        )
        ORDER BY NombreCarro;
        ''',
        [fecha, fecha],
      );

      return result
          .map(
            (row) => {
              'RentaID': row['RentaID'],
              'CarroID': row['CarroID'],
              'NombreCompleto': row['NombreCompleto'],
              'NombreCarro': row['NombreCarro'],
              'FechaInicio': row['FechaInicio'],
              'FechaFin': row['FechaFin'],
              'PrecioTotal': row['PrecioTotal'],
              'PrecioPagado': row['PrecioPagado'],
              'TipoPago': row['TipoPago'],
              'Observaciones': row['Observaciones'],
            },
          )
          .toList();
    });
  }

  static List<Map<String, dynamic>> obtenerHistorial({required String fecha}) {
    final result = DatabaseHelper().db.select(
      '''
        SELECT 
          r.RentaID,
          c.Nombre || " " || c.Apellido as NombreCompleto,
          ca.NombreCarro,
          ca.Anio,
          ca.Placas,
          r.FechaInicio,
          r.FechaFin
        FROM 
          Renta as r
        LEFT JOIN 
          Cliente as c ON r.ClienteID = c.ClienteID
        LEFT JOIN 
          Carro as ca ON ca.CarroID = r.CarroID
        WHERE 
          date(FechaInicio) = ? OR date(FechaFin) = ?;
    ''',
      [fecha, fecha],
    );
    // Construir lista de mapas
    return result.map((row) {
      return {
        'RentaID': row['RentaID'],
        'NombreCompleto': row['NombreCompleto'],
        'NombreCarro': row['NombreCarro'],
        'Anio': row['Anio'],
        'Placas': row['Placas'],
        'FechaInicio': row['FechaInicio'],
        'FechaFin': row['FechaFin'],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> obtenerFechaOcupadoCarro({
    required int carroID,
  }) {
    final result = DatabaseHelper().db.select(
      '''
        WITH RECURSIVE FechasOcupadas AS (
          SELECT 
            CarroID,
            DATE(FechaInicio, '+1 day') AS Fecha,
            DATE(FechaFin) AS FechaFin
          FROM Renta
          WHERE CarroID = ?

          UNION ALL

          SELECT
            CarroID,
            DATE(Fecha, '+1 day'),
            FechaFin
          FROM FechasOcupadas
          WHERE DATE(Fecha, '+1 day') < FechaFin  -- Excluye FechaFin
        )
        SELECT DISTINCT CarroID, Fecha
        FROM FechasOcupadas
        ORDER BY Fecha;
    ''',
      [carroID],
    );
    // Construir lista de mapas
    return result.map((row) {
      return {'Fecha': row['Fecha']};
    }).toList();
  }

  static List<Map<String, dynamic>> obtenerFechasCarro({required int rentaID}) {
    final result = DatabaseHelper().db.select(
      '''
         WITH RECURSIVE FechasOcupadas AS (
          SELECT
            CarroID,
            DATE(FechaInicio) AS Fecha,
            DATE(FechaFin) AS FechaFin
          FROM Renta
          WHERE RentaID = ?

          UNION ALL

          SELECT
            CarroID,
            DATE(Fecha, '+1 day'),
            FechaFin
          FROM FechasOcupadas
          WHERE DATE(Fecha, '+1 day') <= FechaFin
        )
        SELECT DISTINCT CarroID, Fecha
        FROM FechasOcupadas
        ORDER BY Fecha;
    ''',
      [rentaID],
    );
    // Construir lista de mapas
    return result.map((row) {
      return {'Fecha': row['Fecha']};
    }).toList();
  }

  static List<DiaDisponible> obtenerDiasDisponibles({required int carroID}) {
    final result = DatabaseHelper().db.select(
      '''
        SELECT 
          CarroID,
          RentaID,
          'Inicio' AS Tipo,
          FechaInicio AS FechaIncompleta
        FROM Renta
        WHERE CarroID = ?
          AND DATE(FechaInicio) <> DATE(FechaFin)

        UNION

        SELECT 
          CarroID,
          RentaID,
          'Fin' AS Tipo,
          FechaFin AS FechaIncompleta
        FROM Renta
        WHERE CarroID = ?
          AND DATE(FechaInicio) <> DATE(FechaFin)

    ''',
      [carroID, carroID],
    );

    // Convertir cada fila a instancia de _DiaDisponible
    final diasDisponibles =
        result.map((row) {
          final fechaStr = row['FechaIncompleta'] as String;
          final tipo = row['Tipo'] as String;
          final rentaID = row['RentaID'].toString();
          // Parsear string a DateTime
          final dia = DateTime.parse(fechaStr);

          return DiaDisponible(dia, tipo, rentaID);
        }).toList();

    return diasDisponibles;
  }

  // Future<List<Map<String, dynamic>>> obtenerHistorialRenta({
  //   required String month,
  //   required int carroID,
  // }) async {
  //   final result = DatabaseHelper().db.select(
  //     '''
  //     SELECT
  //       r.FechaInicio,
  //       r.FechaFin,
  //       r.PrecioTotal,
  //       r.PrecioPagado,
  //       r.TipoPago,
  //       r.Observaciones
  //     FROM Carro c
  //     LEFT JOIN Renta r ON c.CarroID = r.CarroID AND substr(r.FechaInicio,1,7)=?
  //     WHERE r.CarroID = ?
  //     GROUP BY c.CarroID, c.NombreCarro;
  //     ''',
  //     [month, carroID],
  //   );
  //   return result
  //       .map(
  //         (row) => {
  //           'CarroID': row['CarroID'],
  //           'NombreCompleto': row['NombreCompleto'],
  //           'NombreCarro': row['NombreCarro'],
  //           'FechaInicio': row['FechaInicio'],
  //           'FechaFin': row['FechaFin'],
  //           'PrecioTotal': row['PrecioTotal'],
  //           'PrecioPagado': row['PrecioPagado'],
  //           'TipoPago': row['TipoPago'],
  //         },
  //       )
  //       .toList();
  // }
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
