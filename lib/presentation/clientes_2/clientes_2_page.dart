import 'package:flutter/material.dart';
import 'package:renta_carros/core/widgets_personalizados/app_bar_widget.dart';
import 'package:renta_carros/presentation/agregar_clientes/agregar_cliente_page.dart';

class ListaConBuscador extends StatefulWidget {
  const ListaConBuscador({super.key});

  @override
  State<ListaConBuscador> createState() => _ListaConBuscadorState();
}

class _ListaConBuscadorState extends State<ListaConBuscador> {
  // Datos de ejemplo: fruta, número y estado booleano
  final List<Map<String, dynamic>> _items = [
    {'nombre': 'Manzana', 'numero': 5, 'activo': true},
    {'nombre': 'Banana', 'numero': 2, 'activo': false},
    {'nombre': 'Pera', 'numero': 8, 'activo': true},
    {'nombre': 'Uva', 'numero': 4, 'activo': false},
    {'nombre': 'Sandía', 'numero': 1, 'activo': true},
    {'nombre': 'Naranja', 'numero': 6, 'activo': false},
    {'nombre': 'Kiwi', 'numero': 9, 'activo': true},
    {'nombre': 'Durazno', 'numero': 3, 'activo': false},
  ];

  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = _items;
    _searchController.addListener(_filtrarLista);
  }

  void _filtrarLista() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredItems =
          _items
              .where((item) => item['nombre'].toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para navegar a otra pantalla
  void _abrirDetalle(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleFrutaScreen(item: item)),
    );
  }

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
                Align(alignment: Alignment.topLeft, child: Text("Clientes")),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),

                // 👉 ListView con altura fija y padding para el FAB
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 72,
                    ), // EXACTO para el FAB
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final bool activo = item['activo'];
                      final Color color = activo ? Colors.green : Colors.grey;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 12,
                        ),
                        title: Text(item['nombre']),
                        subtitle: Text('Cantidad: ${item['numero']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.menu, size: 16),
                          onPressed: () => _abrirDetalle(context, item),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AgregarClientePage()),
            );
          },
          child: Text('Agregar Cliente'),
        ),
      ),
    );
  }
}

class DetalleFrutaScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetalleFrutaScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['nombre'])),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['activo'] ? Icons.check_circle : Icons.cancel,
              color: item['activo'] ? Colors.green : Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Cantidad: ${item['numero']}',
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
