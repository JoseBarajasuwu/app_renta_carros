import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renta_carros/core/utils/upper_case.dart';
import 'package:renta_carros/database/carros_db.dart';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  List<Map<String, dynamic>> lVehiculos = [];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController placasController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController buscarController = TextEditingController();

  int? indexEditando;
  final formCarro = GlobalKey<FormState>();

  void cargaCarros() {
    final lista = CarroDAO.obtenerTodos();
    setState(() {
      lVehiculos = lista;
    });
  }

  void guardarVehiculo() {
    String nombre = nombreController.text.trim();
    String placas = placasController.text.trim();
    int? anio = int.tryParse(anioController.text.trim()) ?? 0;

    if (nombre.isEmpty || placas.isEmpty || anio == 0) return;

    setState(() {
      if (indexEditando == null) {
        CarroDAO.insertar(nombreCarro: nombre, anio: anio, placas: placas);
      } else {
        CarroDAO.actualizar(
          carroID: indexEditando!,
          nombreCarro: nombre,
          anio: anio,
          placas: placas,
        );
        indexEditando = null;
      }
      nombreController.clear();
      placasController.clear();
      anioController.clear();
    });
    cargaCarros();
  }

  void editarVehiculo({
    required int carroID,
    required String nombreCarro,
    required String placa,
    required String anio,
  }) {
    setState(() {
      indexEditando = carroID;
    });
    nombreController.text = nombreCarro;
    placasController.text = placa;
    anioController.text = anio;
  }

  void eliminarVehiculo(int index) {
    if (index == indexEditando) {
      setState(() {
        nombreController.clear();
        placasController.clear();
        anioController.clear();
        indexEditando = null;
      });
    }
    CarroDAO.eliminar(carroID: index);
    cargaCarros();
  }

  List<Map<String, dynamic>> get vehiculosFiltrados {
    final query = buscarController.text.toLowerCase();
    if (query.isEmpty) return lVehiculos;
    return lVehiculos.where((elemento) {
      String nombreCarro =
          (elemento["NombreCarro"] ?? '').toString().toLowerCase();
      String placas = (elemento["Placas"] ?? '').toString().toLowerCase();
      String anio = (elemento["Anio"] ?? '').toString().toLowerCase();

      return nombreCarro.contains(query) ||
          placas.contains(query) ||
          anio.contains(query);
    }).toList();
  }

  @override
  void initState() {
    cargaCarros();
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    placasController.dispose();
    anioController.dispose();
    buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panel Izquierdo - Lista de Vehículos
          Expanded(
            flex: 3,
            child:
                lVehiculos.isNotEmpty
                    ? Container(
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
                                int carroID =
                                    vehiculosFiltrados[index]["CarroID"];
                                String nombreCarro =
                                    vehiculosFiltrados[index]["NombreCarro"];
                                String anio =
                                    vehiculosFiltrados[index]["Anio"]
                                        .toString();
                                String placa =
                                    vehiculosFiltrados[index]["Placas"];
                                return Column(
                                  children: [
                                    ListTile(
                                      titleTextStyle: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Quicksand',
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitleTextStyle: TextStyle(
                                        fontFamily: 'Quicksand',
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nombreCarro,
                                            maxLines: 5,
                                            softWrap: true,
                                          ),
                                          Text(anio),
                                        ],
                                      ),

                                      subtitle: Text(placa),
                                      trailing: Wrap(
                                        spacing: 12,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF204c6c),
                                            ),
                                            onPressed:
                                                () => editarVehiculo(
                                                  carroID: carroID,
                                                  nombreCarro: nombreCarro,
                                                  placa: placa,
                                                  anio: anio,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed:
                                                () => mostrarDialogoEliminarCarro(
                                                  context,
                                                  carroID,
                                                  '$nombreCarro, $anio $placa',
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
                    )
                    : Container(
                      color: Color(0XFF90a6b6),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No hay datos para mostrar",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Quicksand',
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
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: placasController,
                      style: TextStyle(fontFamily: 'Quicksand'),
                      decoration: const InputDecoration(
                        labelText: 'Placas',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\s-]'),
                        ),
                        LengthLimitingTextInputFormatter(10),
                        UpperCaseTextFormatter(),
                      ],

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agrega un sobrenombre para el vehículo";
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
                            mostrarDialogoAgregarCarro(
                              context,
                              indexEditando,
                              "${nombreController.text} ${anioController.text} ${placasController.text}",
                            );
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

  mostrarDialogoAgregarCarro(
    BuildContext context,
    int? carroID,
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
                carroID != null
                    ? '¿Estás seguro de editar este carro?'
                    : '¿Estás seguro de agregar este carro?',
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
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                guardarVehiculo();
                Navigator.of(context).pop(); // confirmar
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(fontFamily: 'Quicksand'),
              ),
            ),
          ],
        );
      },
    );
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
}
