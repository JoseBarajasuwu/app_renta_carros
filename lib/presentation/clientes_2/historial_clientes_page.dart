import 'package:flutter/material.dart';
import 'package:renta_carros/core/widgets_personalizados/app_bar_widget.dart';

class HistorialClientePage extends StatefulWidget {
  final Map<String, dynamic> item;
  const HistorialClientePage({super.key, required this.item});

  @override
  State<HistorialClientePage> createState() => _HistorialClientePageState();
}

class _HistorialClientePageState extends State<HistorialClientePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSucursalAppBar('Sucursal Sonora'),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Historial cliente: ${widget.item['nombre']}",
                    style: TextStyle(fontFamily: 'Quicksand-Bold'),
                  ),
                ),

                //  ListView con altura fija y padding para el FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}
