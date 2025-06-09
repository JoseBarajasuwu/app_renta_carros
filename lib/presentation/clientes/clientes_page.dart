import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renta_carros/core/utils/formateo_celularl.dart';
import 'package:renta_carros/presentation/clientes/historial_cliente.dart';

class Cliente {
  String nombre;
  String celular;
  List<Renta> historial;

  Cliente({
    required this.nombre,
    required this.celular,
    this.historial = const [],
  });
}

class Renta {
  final String auto;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  Renta({
    required this.auto,
    required this.fechaInicio,
    required this.fechaFin,
  });
}

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final List<Cliente> clientes = [
    Cliente(
      nombre: "Juan Pérez",
      celular: "3411002810",
      historial: [
        Renta(
          auto: 'Toyota Corolla',
          fechaInicio: DateTime(2023, 5, 1),
          fechaFin: DateTime(2023, 5, 10),
        ),
        Renta(
          auto: 'Nissan Versa',
          fechaInicio: DateTime(2024, 1, 15),
          fechaFin: DateTime(2024, 1, 25),
        ),
      ],
    ),
    Cliente(
      nombre: "María García",
      celular: "maria@mail.com",
      historial: [
        Renta(
          auto: 'Honda Civic',
          fechaInicio: DateTime(2023, 11, 5),
          fechaFin: DateTime(2023, 11, 20),
        ),
      ],
    ),
  ];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController buscarController = TextEditingController();
  int? indexEditando;

  void guardarCliente() {
    String nombre = nombreController.text.trim();
    String celular = celularController.text.trim();

    if (nombre.isEmpty || celular.isEmpty) return;

    setState(() {
      if (indexEditando == null) {
        clientes.add(Cliente(nombre: nombre, celular: celular));
      } else {
        final historialExistente = clientes[indexEditando!].historial;
        clientes[indexEditando!] = Cliente(
          nombre: nombre,
          celular: celular,
          historial: historialExistente,
        );
        indexEditando = null;
      }

      nombreController.clear();
      celularController.clear();
    });
  }

  void editarCliente(int index) {
    setState(() {
      indexEditando = index;
      nombreController.text = clientes[index].nombre;
      celularController.text = clientes[index].celular;
    });
  }

  void eliminarCliente(int index) {
    setState(() {
      if (index == indexEditando) {
        nombreController.clear();
        celularController.clear();
        indexEditando = null;
      }
      clientes.removeAt(index);
    });
  }

  List<Cliente> get clientesFiltrados {
    String query = buscarController.text.toLowerCase();
    if (query.isEmpty) return clientes;
    return clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(query) ||
          cliente.celular.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lista de Clientes
          Expanded(
            flex: 3,
            child: Container(
              // color: Colors.grey.shade100,
              // decoration: fondo(),
              color: Color(0XFF90a6b6),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: buscarController,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Quicksand',
                      ),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: clientesFiltrados.length,
                      separatorBuilder: (_, __) => const Divider(thickness: 1),
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];
                        return ListTile(
                          titleTextStyle: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Quicksand',
                            color: Colors.black,
                          ),
                          subtitleTextStyle: TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.black,
                          ),
                          title: Text(cliente.nombre),
                          subtitle: Text(
                            cliente.celular,
                            style: TextStyle(fontFamily: 'Quicksand'),
                          ),

                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF204c6c),
                                ),
                                onPressed: () => editarCliente(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => eliminarCliente(index),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        HistorialClientePage(cliente: cliente),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Formulario
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFFbcc9d3),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    indexEditando == null
                        ? "Agregar Cliente"
                        : "Editar Cliente",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nombreController,
                    style: TextStyle(fontFamily: 'Quicksand'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: celularController,
                    style: TextStyle(fontFamily: 'Quicksand'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CelularFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Celular',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        indexEditando == null ? Icons.add : Icons.save,
                      ),
                      onPressed: guardarCliente,
                      label: Text(
                        indexEditando == null ? 'Agregar' : 'Guardar',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
