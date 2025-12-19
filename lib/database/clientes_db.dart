import 'database.dart';

void importClientesTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS Cliente ( 
      ClienteID INTEGER PRIMARY KEY AUTOINCREMENT,
      Nombre TEXT NOT NULL,
      Apellido TEXT NOT NULL,
      Telefono TEXT NOT NULL,
      FechaRegistro TEXT NOT NULL
    );
  ''');
}

class ClienteDAO {
  static void insertar({
    required String nombre,
    required String apellido,
    required String telefono,
    required String fechaRegistro,
  }) {
    DatabaseHelper().db.execute(
      'INSERT INTO Cliente (Nombre, Apellido, Telefono, FechaRegistro) VALUES (?, ?, ?, ?)',
      [nombre, apellido, telefono, fechaRegistro],
    );
  }

  static List<Map<String, dynamic>> obtenerTodos() {
    final result = DatabaseHelper().db.select('SELECT * FROM Cliente');
    // Construir lista de mapas
    return result.map((row) {
      return {
        'ClienteID': row['ClienteID'],
        'Nombre': row['Nombre'],
        'Apellido': row['Apellido'],
        'Telefono': row['Telefono'],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> obtenerClienteAgenda() {
    final result = DatabaseHelper().db.select(
      'SELECT ClienteID, Nombre, Apellido FROM Cliente',
    );
    return result.map((row) {
      return {
        'ClienteID': row['ClienteID'],
        'Nombre': row['Nombre'],
        'Apellido': row['Apellido'],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> obtenerHistorialCliente({
    required int clienteID,
  }) {
    final result = DatabaseHelper().db.select(
      '''
          SELECT
            r.RentaID,
            c.NombreCarro || ' ' || c.Anio || ' ' || c.Placas AS NombreCarro,
            r.FechaInicio,
            r.FechaFin,
            r.PrecioTotal,
            r.PrecioPagado,
            r.Observaciones,
            r.Estatus,
            EXISTS (
                SELECT 1 FROM Renta r3
                WHERE r3.CarroID = r.CarroID
                  AND r3.RentaID <> r.RentaID
                  AND (
                      DATE(r3.FechaInicio) = DATE(r.FechaFin)
                    OR DATE(r3.FechaInicio) = DATE(r.FechaFin, '+1 day')
                  )
            ) AS TieneRentaDespues
          FROM Renta r
          JOIN Carro c ON r.CarroID = c.CarroID
          WHERE r.ClienteID = ?
          ORDER BY FechaInicio DESC
      ''',
      [clienteID],
    );
    return result.map((row) {
      return {
        'RentaID': row['RentaID'],
        'NombreCarro': row['NombreCarro'],
        'FechaInicio': row['FechaInicio'],
        'FechaFin': row['FechaFin'],
        'PrecioTotal': row['PrecioTotal'],
        'PrecioPagado': row['PrecioPagado'],
        'Observaciones': row['Observaciones'],
        'Estatus': row['Estatus'],
        'TieneRentaDespues': row['TieneRentaDespues'],
      };
    }).toList();
  }

  static void actualizar({
    required int clienteID,
    required String nombre,
    required String apellido,
    required String telefono,
  }) {
    DatabaseHelper().db.execute(
      'UPDATE Cliente SET Nombre = ?, Apellido = ?, Telefono = ? WHERE ClienteID = ?',
      [nombre, apellido, telefono, clienteID],
    );
  }

  static Future<bool> editObservacion({
    required int rentaID,
    required String observacion,
  }) async {
    try {
      DatabaseHelper().db.execute(
        'UPDATE Renta SET Observaciones = ? WHERE RentaID = ?',
        [observacion, rentaID],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static void eliminar({required int clienteID}) {
    DatabaseHelper().db.execute('DELETE FROM Renta WHERE ClienteID = ?', [
      clienteID,
    ]);
    DatabaseHelper().db.execute('DELETE FROM Cliente WHERE ClienteID = ?', [
      clienteID,
    ]);
  }

  static Future<bool> obtenerRentaDisponibles({
    required int rentaID,
    required int diasExtra,
  }) async {
    final db = DatabaseHelper().db;
    try {
      final verificacionAgendar = db.select(
        '''
        SELECT
            r.RentaID,
            EXISTS (
                SELECT 1
                FROM Renta r3
                WHERE r3.CarroID = r.CarroID
                  AND r3.RentaID <> r.RentaID
                  AND DATE(r3.FechaInicio)
                      BETWEEN DATE(r.FechaFin, '+1 day')
                          AND DATE(r.FechaFin, '+' || ? || ' day')
            ) AS TieneRentaDespues
        FROM  Renta r
        WHERE r.RentaID = ?;
        ''',
        [diasExtra, rentaID],
      );
      if (verificacionAgendar.isEmpty) return false;

      final tieneRenta = verificacionAgendar.first['TieneRentaDespues'] == 1;
      if (tieneRenta) return false;
      final datosAgendar = db.select(
        '''
          SELECT
              -CAST(
                  -(
                      (
                          r.PrecioTotal /
                          CAST((JULIANDAY(r.FechaFin) - JULIANDAY(r.FechaInicio)) AS INTEGER)
                      )
                      *
                      (CAST((JULIANDAY(r.FechaFin) - JULIANDAY(r.FechaInicio)) AS INTEGER) + $diasExtra)
                  ) AS INTEGER
              ) AS PrecioTotalNuevo,
              strftime(
                  '%Y-%m-%d %H:%M',
                  DATETIME(
                      r.FechaInicio,
                      '+' || (CAST((JULIANDAY(r.FechaFin) - JULIANDAY(r.FechaInicio)) AS INTEGER) + $diasExtra) || ' days'
                  )
              ) AS NuevaFechaFin
          FROM Renta r
          WHERE r.RentaID = ?
    ''',
        [rentaID],
      );
      if (datosAgendar.isEmpty) return false;
      final nuevaFechaFin = datosAgendar.first['NuevaFechaFin'];
      final precioTotalNuevo = datosAgendar.first['PrecioTotalNuevo'];
      db.execute(
        'UPDATE Renta SET FechaFin = ?, PrecioTotal = ? WHERE RentaID = ?',
        [nuevaFechaFin, precioTotalNuevo, rentaID],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
