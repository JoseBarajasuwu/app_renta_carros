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
          c.NombreCarro,
          c.Anio,
          c.Placas,
          r.FechaInicio,
          r.FechaFin,
          r.PrecioTotal,
          r.PrecioPagado
     FROM Renta r
     JOIN Carro c ON r.CarroID = c.CarroID
    WHERE r.ClienteID = ?
      ''',
      [clienteID],
    );
    return result.map((row) {
      return {
        'NombreCarro': row['NombreCarro'],
        'Anio': row['Anio'],
        'Placas': row['Placas'],
        'FechaInicio': row['FechaInicio'],
        'FechaFin': row['FechaFin'],
        'PrecioTotal': row['PrecioTotal'],
        'PrecioPagado': row['PrecioPagado'],
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

  static void eliminar({required int clienteID}) {
    DatabaseHelper().db.execute('DELETE FROM Cliente WHERE ClienteID = ?', [
      clienteID,
    ]);
  }
}
