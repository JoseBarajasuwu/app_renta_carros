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

  final TextEditingController rentaController = TextEditingController();
  final TextEditingController servicioController = TextEditingController();

  int? indexEditando;
  int? indexSeleccionado;

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

  void agregarRenta() {
    final monto = double.tryParse(rentaController.text);
    if (monto == null || indexSeleccionado == null) return;
    setState(() {
      vehiculos[indexSeleccionado!].rentas.add(monto);
      rentaController.clear();
    });
  }

  void agregarServicio() {
    final monto = double.tryParse(servicioController.text);
    if (monto == null || indexSeleccionado == null) return;
    setState(() {
      vehiculos[indexSeleccionado!].servicios.add(monto);
      servicioController.clear();
    });
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
                  TextFormField(
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
                                    onPressed: () => eliminarVehiculo(index),
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
                              Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Rentas: \$${vehiculos.totalRentas.toStringAsFixed(2)}",
                                    ),
                                    Text(
                                      "Total Servicios: \$${vehiculos.totalServicios.toStringAsFixed(2)}",
                                    ),
                                    Text(
                                      "Ganancia Neta: \$${vehiculos.ganancia.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                  ],
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nombreController,
                    style: TextStyle(fontFamily: 'Quicksand'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: sobrenombreController,
                    style: TextStyle(fontFamily: 'Quicksand'),
                    decoration: const InputDecoration(
                      labelText: 'Sobrenombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        indexEditando == null ? Icons.add : Icons.save,
                      ),
                      onPressed: guardarVehiculo,
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
                  const Divider(height: 40),
                  if (indexSeleccionado != null) ...[
                    // const Text(
                    //   "Agregar Renta",
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: rentaController,
                    //         decoration: const InputDecoration(
                    //           labelText: 'Monto',
                    //         ),
                    //         keyboardType: TextInputType.number,
                    //       ),
                    //     ),
                    //     IconButton(
                    //       icon: const Icon(Icons.add),
                    //       onPressed: agregarRenta,
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 10),
                    const Text(
                      "Agregar Servicio",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: servicioController,
                            decoration: const InputDecoration(
                              labelText: 'Monto',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: agregarServicio,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
