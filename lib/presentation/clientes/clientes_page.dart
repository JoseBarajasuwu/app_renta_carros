import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/core/utils/formateo_celular.dart';
import 'package:renta_carros/database/clientes_db.dart';
import 'package:renta_carros/presentation/clientes/historial_cliente.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  DateTime fechaRegistro = DateTime.now();

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController buscarController = TextEditingController();
  int? indexEditando;
  final formCliente = GlobalKey<FormState>();

  List<Map<String, dynamic>> lUsuarios = [];
  bool isLoading = false;
  Future<void> cargarUsuarios() async {
    setState(() => isLoading = true);
    // simula carga si quieres mostrar el spinner aunque sea poco
    // await Future.delayed(Duration(milliseconds: 300));
    final lista = ClienteDAO.obtenerTodos();
    setState(() {
      lUsuarios = lista;
      isLoading = false;
    });
  }

  void guardarCliente() async {
    String nombre = nombreController.text.trim();
    String apellido = apellidoController.text.trim();
    String celular = celularController.text.trim();

    if (nombre.isEmpty || celular.isEmpty || apellido.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    if (indexEditando == null) {
      String fechaFormateada = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(fechaRegistro);
      ClienteDAO.insertar(
        nombre: nombre,
        apellido: apellido,
        telefono: celular,
        fechaRegistro: fechaFormateada,
      );
    } else {
      ClienteDAO.actualizar(
        clienteID: indexEditando!,
        nombre: nombre,
        apellido: apellido,
        telefono: celular,
      );
      indexEditando = null;
    }

    nombreController.clear();
    apellidoController.clear();
    celularController.clear();
    await cargarUsuarios();
  }

  void editarCliente({
    required int index,
    required String nombre,
    required String apellido,
    required String celular,
  }) {
    setState(() {
      indexEditando = index;
    });
    nombreController.text = nombre;
    apellidoController.text = apellido;
    celularController.text = celular;
  }

  eliminarCliente(int index) async {
    setState(() => isLoading = true);
    if (index == indexEditando) {
      nombreController.clear();
      apellidoController.clear();
      celularController.clear();
      setState(() {
        indexEditando = null;
      });
    }
    ClienteDAO.eliminar(clienteID: index);
    await cargarUsuarios();
  }

  List<Map<String, dynamic>> get clientesFiltrados {
    String query = buscarController.text.toLowerCase();
    if (query.isEmpty) return lUsuarios;

    return lUsuarios.where((elemento) {
      String nombre = (elemento["Nombre"] ?? '').toString().toLowerCase();
      String apellido = (elemento["Apellido"] ?? '').toString().toLowerCase();
      String celular = (elemento["Telefono"] ?? '').toString().toLowerCase();

      return nombre.contains(query) ||
          apellido.contains(query) ||
          celular.contains(query);
    }).toList();
  }

  @override
  void initState() {
    cargarUsuarios();
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.blueAccent,
                ),
              )
              : Row(
                children: [
                  // Lista de Clientes
                  Expanded(
                    flex: 3,
                    child:
                        lUsuarios.isNotEmpty
                            ? Container(
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
                                      separatorBuilder:
                                          (_, __) =>
                                              const Divider(thickness: 1),
                                      itemBuilder: (context, index) {
                                        int clienteID =
                                            clientesFiltrados[index]["ClienteID"];
                                        String nombre =
                                            clientesFiltrados[index]["Nombre"];
                                        String apellido =
                                            clientesFiltrados[index]["Apellido"];
                                        String telefono =
                                            clientesFiltrados[index]["Telefono"];

                                        return ListTile(
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
                                          title: Text(
                                            "$nombre $apellido",
                                            maxLines: 5,
                                            softWrap: true,
                                          ),
                                          subtitle: Text(
                                            clientesFiltrados[index]["Telefono"],
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                            ),
                                          ),

                                          trailing: Wrap(
                                            spacing: 12,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Color(0xFF204c6c),
                                                ),
                                                onPressed:
                                                    () => editarCliente(
                                                      index: clienteID,
                                                      nombre: nombre,
                                                      apellido: apellido,
                                                      celular: telefono,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                ),
                                                onPressed:
                                                    () => mostrarDialogoEliminarCliente(
                                                      context,
                                                      clienteID,
                                                      "$nombre $apellido, $telefono",
                                                    ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => HistorialClientePage(
                                                      clienteID: clienteID,
                                                      nombreCliente:
                                                          "$nombre $apellido",
                                                    ),
                                              ),
                                            );
                                          },
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
                                  indexEditando == null
                                      ? Icons.add
                                      : Icons.save,
                                ),
                                onPressed: () {
                                  if (formCliente.currentState!.validate()) {
                                    mostrarDialogoAgregarCliente(
                                      context,
                                      indexEditando,
                                      "${nombreController.text} ${apellidoController.text}, ${celularController.text}",
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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

  mostrarDialogoAgregarCliente(
    BuildContext context,
    int? clienteID,
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
                clienteID != null
                    ? '¿Estás seguro de editar este cliente?'
                    : '¿Estás seguro de agregar este cliente?',
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
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                guardarCliente();
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
}
