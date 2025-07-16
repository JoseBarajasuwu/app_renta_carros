import 'package:flutter/material.dart';
import 'package:renta_carros/database/clientes_db.dart';

class HistorialClientePage extends StatefulWidget {
  final int clienteID;
  final String nombreCliente;
  const HistorialClientePage({
    super.key,
    required this.clienteID,
    required this.nombreCliente,
  });
  @override
  State<HistorialClientePage> createState() => _HistorialClientePageState();
}

class _HistorialClientePageState extends State<HistorialClientePage> {
  List<Map<String, dynamic>> lCliente = [];
  void cargaHistorialCliente() {
    final lista = ClienteDAO.obtenerHistorialCliente(
      clienteID: widget.clienteID,
    );
    setState(() {
      lCliente = lista;
    });
  }

  @override
  void initState() {
    cargaHistorialCliente();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de ${widget.nombreCliente}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Color(0xFF204c6c),
      ),
      body:
          lCliente.isEmpty
              ? const Center(child: Text('No hay rentas registradas'))
              : ListView.builder(
                itemCount: lCliente.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color(0xFFbcc9d3),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        lCliente[index]["NombreCarro"],
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Color(0xFF204c6c),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lCliente[index]["Anio"]}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '${lCliente[index]["Placas"]}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Total: \$${lCliente[index]["PrecioTotal"]}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Abonado: \$${lCliente[index]["PrecioPagado"]}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Del ${_formatoFechaDinamico(lCliente[index]["FechaInicio"])} al ${_formatoFechaDinamico(lCliente[index]["FechaFin"])}',
                            style: const TextStyle(fontFamily: 'Quicksand'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  //"Faltan detalles minimos"
  String _formatoFechaDinamico(dynamic fecha) {
    try {
      final f = fecha is DateTime ? fecha : DateTime.parse(fecha.toString());
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
