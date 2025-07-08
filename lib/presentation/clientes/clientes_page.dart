import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renta_carros/core/utils/formateo_celular.dart';
import 'package:renta_carros/presentation/clientes/historial_cliente.dart';

class Cliente {
  String nombre;
  String apellido;
  String celular;
  List<Renta> historial;

  Cliente({
    required this.nombre,
    required this.celular,
    required this.apellido,
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
      nombre: "Juan",
      apellido: "Pérez",
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
      nombre: "María",
      apellido: "García",
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

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController buscarController = TextEditingController();
  int? indexEditando;
  final formCliente = GlobalKey<FormState>();
  void guardarCliente() {
    String nombre = nombreController.text.trim();
    String apellido = apellidoController.text.trim();
    String celular = celularController.text.trim();

    if (nombre.isEmpty || celular.isEmpty || apellido.isEmpty) return;

    setState(() {
      if (indexEditando == null) {
        clientes.add(
          Cliente(nombre: nombre, apellido: apellido, celular: celular),
        );
      } else {
        final historialExistente = clientes[indexEditando!].historial;
        clientes[indexEditando!] = Cliente(
          nombre: nombre,
          apellido: apellido,
          celular: celular,
          historial: historialExistente,
        );
        indexEditando = null;
      }

      nombreController.clear();
      apellidoController.clear();
      celularController.clear();
    });
  }

  void editarCliente(int index) {
    setState(() {
      indexEditando = index;
      nombreController.text = clientes[index].nombre;
      apellidoController.text = clientes[index].apellido;
      celularController.text = clientes[index].celular;
    });
  }

  void eliminarCliente(int index) {
    setState(() {
      if (index == indexEditando) {
        nombreController.clear();
        apellidoController.clear();
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
          cliente.apellido.toLowerCase().contains(query) ||
          cliente.celular.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    celularController.dispose();
    super.dispose();
  }

  mostrarDialogoEliminarCliente(
    BuildContext context,
    int index,
    String nombreCliente,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFbcc9d3), // color base claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                '¿Estás seguro de eliminar este cliente?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content: Text(
            nombreCliente,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF204c6c),
              fontFamily: 'Quicksand',
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF204c6c),
              ),

              onPressed: () {
                Navigator.of(context).pop(false); // cancelar
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Quicksand'),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                // eliminarVehiculo(index);
                eliminarCliente(index);
                Navigator.of(context).pop(); // confirmar
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(fontFamily: 'Quicksand'),
              ),
            ),
          ],
        );
      },
    );
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZñÑ\s]'),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
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
                    style: TextStyle(fontFamily: 'Quicksand'),
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
                          title: Text("${cliente.nombre} ${cliente.apellido}"),
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
                                onPressed:
                                    () => mostrarDialogoEliminarCliente(
                                      context,
                                      index,
                                      "${cliente.nombre} ${cliente.apellido}",
                                    ),
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
              child: Form(
                key: formCliente,
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
                    TextFormField(
                      controller: nombreController,
                      style: TextStyle(fontFamily: 'Quicksand'),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZñÑ\s]'),
                        ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega el nombre del cliente";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: apellidoController,
                      style: TextStyle(fontFamily: 'Quicksand'),
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZñÑ\s]'),
                        ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega el apellido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega un celular";
                        }
                        String cleanVlaue = value.replaceAll('-', '');
                        if (cleanVlaue.length != 10) {
                          return "Agrega un celular válido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          indexEditando == null ? Icons.add : Icons.save,
                        ),
                        onPressed: () {
                          if (formCliente.currentState!.validate()) {
                            guardarCliente();
                          }
                        },
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
          ),
        ],
      ),
    );
  }
}
