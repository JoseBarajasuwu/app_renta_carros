import 'database.dart';

void importCarrosTabla() {
  DatabaseHelper().db.execute('''
    CREATE TABLE IF NOT EXISTS Carro (
      CarroID INTEGER PRIMARY KEY AUTOINCREMENT,
      NombreCarro TEXT NOT NULL,
      Anio INTEGER NOT NULL,
      Placas TEXT NOT NULL,
      Costo REAL NOT NULL
    );
  ''');
}

class CarroDAO {
  static void insertar({
    required String nombreCarro,
    required int anio,
    required String placas,
    required double costo,
  }) {
    DatabaseHelper().db.execute(
      'INSERT INTO Carro (NombreCarro, Anio, Placas, Costo) VALUES (?, ?, ?, ?)',
      [nombreCarro, anio, placas, costo],
    );
  }

  static List<Map<String, dynamic>> obtenerTodos() {
    final result = DatabaseHelper().db.select('''
    SELECT 
      CarroID,
      NombreCarro,
      Anio,
      Placas,
      Costo
     FROM Carro
''');
    // Construir lista de mapas
    return result.map((row) {
      return {
        'CarroID': row['CarroID'],
        'NombreCarro': row['NombreCarro'],
        'Anio': row['Anio'],
        'Placas': row['Placas'],
        'Costo': row['Costo'],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> obtenerPrecioCarro({required int carroID}) {
    final result = DatabaseHelper().db.select(
      '''
    SELECT
      Costo
     FROM Carro
     WHERE
      CarroID = ?
    ''',
      [carroID],
    );
    return result.map((row) {
      return {'Costo': row['Costo']};
    }).toList();
  }

  static void actualizar({
    required int carroID,
    required String nombreCarro,
    required int anio,
    required String placas,
    required double costo,
  }) {
    DatabaseHelper().db.execute(
      'UPDATE Carro SET NombreCarro = ?, Anio = ?, Placas = ?, Costo = ? WHERE CarroID = ?',
      [nombreCarro, anio, placas, costo, carroID],
    );
  }

  static void eliminar({required int carroID}) {
    DatabaseHelper().db.execute('DELETE FROM Carro WHERE CarroID = ?', [
      carroID,
    ]);
  }
}
