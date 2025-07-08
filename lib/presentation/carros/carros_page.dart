import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vehiculo {
  String nombre;
  String sobrenombre;
  int anio;
  List<double> rentas;
  List<double> servicios;

  Vehiculo({
    required this.nombre,
    required this.sobrenombre,
    required this.anio,
    List<double> rentas = const [],
    List<double> servicios = const [],
  }) : rentas = List.from(rentas),
       servicios = List.from(servicios);

  double get totalRentas => rentas.fold(0, (a, b) => a + b);
  double get totalServicios => servicios.fold(0, (a, b) => a + b);
  double get ganancia => totalRentas - totalServicios;
}

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  final List<Vehiculo> vehiculos = [];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController sobrenombreController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController buscarController = TextEditingController();

  int? indexEditando;
  int? indexSeleccionado;
  final formCarro = GlobalKey<FormState>();
  void guardarVehiculo() {
    String nombre = nombreController.text.trim();
    String sobrenombre = sobrenombreController.text.trim();
    int? anio = int.tryParse(anioController.text.trim());

    if (nombre.isEmpty || sobrenombre.isEmpty || anio == null) return;

    setState(() {
      if (indexEditando == null) {
        vehiculos.add(
          Vehiculo(nombre: nombre, sobrenombre: sobrenombre, anio: anio),
        );
      } else {
        final v = vehiculos[indexEditando!];
        vehiculos[indexEditando!] = Vehiculo(
          nombre: nombre,
          sobrenombre: sobrenombre,
          anio: anio,
          rentas: v.rentas,
          servicios: v.servicios,
        );
        indexEditando = null;
      }

      nombreController.clear();
      sobrenombreController.clear();
      anioController.clear();
    });
  }

  void editarVehiculo(int index) {
    indexSeleccionado = index;
    final v = vehiculos[index];
    nombreController.text = v.nombre;
    sobrenombreController.text = v.sobrenombre;
    anioController.text = v.anio.toString();
    setState(() => indexEditando = index);
  }

  void eliminarVehiculo(int index) {
    setState(() {
      if (index == indexEditando) {
        nombreController.clear();
        sobrenombreController.clear();
        anioController.clear();
        indexEditando = null;
      }
      vehiculos.removeAt(index);
    });
  }

  mostrarDialogoEliminarCarro(
    BuildContext context,
    int index,
    String nombreCarro,
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
                '¿Estás seguro de eliminar este carro?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content: Text(
            nombreCarro,
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
                eliminarVehiculo(index);

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

  List<Vehiculo> get vehiculosFiltrados {
    final query = buscarController.text.toLowerCase();
    if (query.isEmpty) return vehiculos;
    return vehiculos.where((v) {
      return v.nombre.toLowerCase().contains(query) ||
          v.sobrenombre.toLowerCase().contains(query) ||
          v.anio.toString().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    nombreController.dispose();
    sobrenombreController.dispose();
    anioController.dispose();
    buscarController.dispose();
    super.dispose();
  }

  Set<int> indicesExpandidos = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panel Izquierdo - Lista de Vehículos
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF90a6b6),
              padding: const EdgeInsets.all(16),
              child: Column(
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
                    style: TextStyle(fontFamily: 'Quicksand'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vehiculosFiltrados.length,
                      itemBuilder: (context, index) {
                        final vehiculos = vehiculosFiltrados[index];
                        final estaExpandido = indicesExpandidos.contains(index);
                        return Column(
                          children: [
                            ListTile(
                              titleTextStyle: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Quicksand',
                                color: Colors.black,
                              ),
                              subtitleTextStyle: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.black,
                              ),
                              title: Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(vehiculos.nombre),
                                    Text(" - "),
                                    Text(vehiculos.sobrenombre),
                                  ],
                                ),
                              ),
                              subtitle: Text(vehiculos.anio.toString()),
                              trailing: Wrap(
                                spacing: 12,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF204c6c),
                                    ),
                                    onPressed: () => editarVehiculo(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed:
                                        () => mostrarDialogoEliminarCarro(
                                          context,
                                          index,
                                          '${vehiculos.nombre} - ${vehiculos.sobrenombre} ${vehiculos.anio.toString()}',
                                        ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  if (estaExpandido) {
                                    indicesExpandidos.remove(index);
                                  } else {
                                    indicesExpandidos.add(index);
                                  }
                                });
                              },
                            ),
                            if (estaExpandido)
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Rentas: \$${vehiculos.totalRentas.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      Text(
                                        "Total Servicios: \$${vehiculos.totalServicios.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      Text(
                                        "Ganancia Neta: \$${vehiculos.ganancia.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel Derecho - Formulario y Agregar Rentas/Servicios
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFbcc9d3),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: formCarro,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indexEditando == null
                          ? 'Agregar Vehículo'
                          : 'Editar Vehículo',
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
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega el nombre del vehículo";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: sobrenombreController,
                      style: TextStyle(fontFamily: 'Quicksand'),
                      decoration: const InputDecoration(
                        labelText: 'Sobrenombre',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega un sobrenombre para el vehículo";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: anioController,
                      style: TextStyle(fontFamily: 'Quicksand'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.length != 4) {
                          return "Agrega un año válido";
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
                          if (formCarro.currentState!.validate()) {
                            guardarVehiculo();
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
