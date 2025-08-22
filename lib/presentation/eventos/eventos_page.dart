import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/database/calendario_db.dart';
import 'package:table_calendar/table_calendar.dart';

class EventoPage extends StatefulWidget {
  const EventoPage({super.key});

  @override
  State<EventoPage> createState() => _EventoPageState();
}

class _EventoPageState extends State<EventoPage>
    with SingleTickerProviderStateMixin {
  final DateTime _focusedDay = DateTime.now();

  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd HH:mm');
  DateTime? _selectedDay;
  DateTime? _diaParaEditar;

  bool _mostrarFormulario = false;
  final TextEditingController _descripcionController = TextEditingController();

  List<Map<String, dynamic>> _eventos = [];

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    cargaEventoDelDia();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _abrirFormulario(DateTime dia) {
    setState(() {
      _diaParaEditar = dia;
      _mostrarFormulario = true;
      _descripcionController.clear();
    });
    _animController.forward();
  }

  void _cerrarFormulario() {
    _animController.reverse().then((_) {
      setState(() {
        _mostrarFormulario = false;
        _selectedDay = null;
      });
    });
  }

  void _guardarEvento() {
    if (_descripcionController.text.trim().isEmpty && _diaParaEditar != null) {
      return;
    }
    String fechaFormateada = formatoFechaHora.format(_diaParaEditar!);
    CalendarioDAO.insentarEvento(
      descripcion: _descripcionController.text.trim(),
      fechaRegistro: fechaFormateada,
      estatus: null,
    );
    cargaEventoDelDia();
    setState(() {
      _selectedDay = _diaParaEditar;
      _descripcionController.clear();
    });
    _cerrarFormulario();
  }

  void eliminarEvento({required int calendarioID}) {
    CalendarioDAO.eliminarEvento(calendarioID: calendarioID);
    cargaEventoDelDia();
  }

  void editarEvento({required int calendarioID, required String descripcion}) {
    String fechaFormateada = formatoFechaHora.format(_diaParaEditar!);
    CalendarioDAO.actualizarEvento(calendarioID: calendarioID, descripcion: descripcion, fechaRegistro: fechaFormateada, estatus: null);
    cargaEventoDelDia();
  }
  void cargaEventoDelDia() async {
    DateTime hoy = DateTime.now();
    setState(() {
      _selectedDay = hoy;
    });
    final resultado = await CalendarioDAO.obtenerEventos();
    setState(() {
      _eventos = resultado;
      _eventos
        .where(
          (e) =>
              e['FechaRegistro'] != null &&
              isSameDay(formatoFechaHora.parse(e['FechaRegistro']), _selectedDay!),
        )
        .toList();
    });
    // _eventosDelDia();
  }

  // List<Map<String, dynamic>> _eventosDelDia() {
  //   if (_selectedDay == null) return [];
  //   print(isSameDay(formatoFechaHora.parse(_eventos[0]['FechaRegistro']), _selectedDay!));
  //   print(_eventos[0]['FechaRegistro']);
  //   print(_selectedDay);
  //   return _eventos
  //       .where(
  //         (e) =>
  //             e['FechaRegistro'] != null &&
  //             isSameDay(formatoFechaHora.parse(e['FechaRegistro']), _selectedDay!),
  //       )
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Columna calendario + lista eventos (ancho flexible)
          Expanded(
            child: Column(
              children: [
                // Calendario arriba
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      _abrirFormulario(selectedDay);
                    },
                    // calendarBuilders: CalendarBuilders(
                    //   todayBuilder: (context, day, focusedDay) {
                    //     return GestureDetector(
                    //       onSecondaryTap: () => _abrirFormulario(day),
                    //       child: Container(
                    //         decoration: const BoxDecoration(
                    //           color: Color(0xFF204c6c),
                    //           shape: BoxShape.circle,
                    //         ),
                    //         alignment: Alignment.center,
                    //         child: Text(
                    //           '${day.day}',
                    //           style: const TextStyle(color: Colors.white),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                    },
                    headerStyle: const HeaderStyle(formatButtonVisible: false),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFbcc9d3),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xFF204c6c),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Lista eventos debajo del calendario
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Color(0xFFbcc9d3),
                    width: double.infinity,
                    child:
                        _eventos.isEmpty
                            ? const Center(child: Text('No hay eventos'))
                            : ListView.builder(
                              itemCount: _eventos.length,
                              itemBuilder: (context, index) {
                                final evento = _eventos[index];
                                return ListTile(
                                  trailing: Row(
                                    children: [
                                      IconButton(
                                        iconSize: 18,
                                        splashRadius: 14,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {},
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        iconSize: 18,
                                        splashRadius: 14,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          showAboutDialog(context: context);
                                          showPasswordDialog(
                                            context: context,
                                            editOrDelite: true,
                                            calendarioID:
                                                evento['CalendarioID'],
                                            descripcion: evento['Descripcion'],
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Color(0xFF204c6c),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    '${evento['Descripcion']} - ',
                                    // '${evento['fecha'].day}/${evento['fecha'].month}/${evento['fecha'].year}',
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),

          // Panel lateral animado a la derecha
          if (_mostrarFormulario)
            SlideTransition(
              position: _slideAnim,
              child: Container(
                width: 300,
                color: Color(0XFF90a6b6),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evento (${_diaParaEditar?.day}/${_diaParaEditar?.month}/${_diaParaEditar?.year})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _guardarEvento,
                          child: const Text('Guardar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _cerrarFormulario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showPasswordDialog({
    required BuildContext context,
    required bool editOrDelite,
    required int calendarioID,
    required String descripcion,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                editOrDelite
                    ? '¿Desea eliminar el evento?'
                    : '¿Desea editar el evento?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      onPressed: () async {
                        switch (editOrDelite) {
                          case true:
                            eliminarEvento(calendarioID: calendarioID);
                            Navigator.of(context).pop();
                            break;
                          case false:
                            editarEvento(
                              calendarioID: calendarioID,
                              descripcion: descripcion,
                            );
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
