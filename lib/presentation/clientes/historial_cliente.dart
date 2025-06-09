import 'package:flutter/material.dart';
import 'package:renta_carros/presentation/clientes/clientes_page.dart';

class HistorialClientePage extends StatelessWidget {
  final Cliente cliente;

  const HistorialClientePage({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Historial de ${cliente.nombre}',

      //   ),
      //   backgroundColor: Color(0xFF204c6c),
      // ),
      appBar: AppBar(
        title: Text(
          'Historial de ${cliente.nombre}',
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
          cliente.historial.isEmpty
              ? const Center(child: Text('No hay rentas registradas'))
              : ListView.builder(
                itemCount: cliente.historial.length,
                itemBuilder: (context, index) {
                  final renta = cliente.historial[index];
                  return Card(
                    color: Color(0xFFbcc9d3),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(renta.auto),
                      subtitle: Text(
                        'Del ${_formatoFecha(renta.fechaInicio)} al ${_formatoFecha(renta.fechaFin)}',
                        style: const TextStyle(fontFamily: 'Quicksand'),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatoFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
