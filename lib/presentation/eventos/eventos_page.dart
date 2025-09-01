import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? indexEditando;
  List<Map<String, dynamic>> eventosFiltrados = [];
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
    });
    _animController.forward();
  }

  void _cerrarFormulario() {
    _animController.reverse().then((_) {
      setState(() {
        _mostrarFormulario = false;
        _selectedDay = null;
        indexEditando = null;
        _descripcionController.clear();
      });
    });
  }

  void _guardarEvento() {
    if (_descripcionController.text.trim().isEmpty && _diaParaEditar != null) {
      return;
    }
    String fechaFormateada = formatoFechaHora.format(_diaParaEditar!);

    if (indexEditando == null) {
      CalendarioDAO.insentarEvento(
        descripcion: _descripcionController.text.trim(),
        fechaRegistro: fechaFormateada,
        estatus: null,
      );
    } else {
      CalendarioDAO.actualizarEvento(
        calendarioID: indexEditando!,
        descripcion: _descripcionController.text.trim(),
        fechaRegistro: fechaFormateada,
        estatus: null,
      );
    }

    cargaEventoDelDia();
    setState(() {
      indexEditando = null;
      _selectedDay = _diaParaEditar;
      _descripcionController.clear();
    });
    _cerrarFormulario();
  }

  void eliminarEvento({required int calendarioID}) {
    CalendarioDAO.eliminarEvento(calendarioID: calendarioID);
    cargaEventoDelDia();
  }

  void cargaEventoDelDia() async {
    DateTime hoy = DateTime.now();
    setState(() {
      _selectedDay = hoy;
    });
    final resultado = await CalendarioDAO.obtenerEventos();
    _eventos = resultado;
    filtroEventos(_selectedDay);
  }

  filtroEventos(DateTime? selectedDay) async {
    setState(() {
      eventosFiltrados =
          _eventos.where((e) {
            if (e['FechaRegistro'] == null) return false;

            final fechaEvento = formatoFechaHora.parse(e['FechaRegistro']);
            return isSameDay(fechaEvento, selectedDay);
          }).toList();
    });
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, String label) async {
    return await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      cancelText: "Cancelar",
      confirmText: "Aceptar",
      hourLabelText: "Hora",
      minuteLabelText: "Minuto",
      initialTime: TimeOfDay.now(),
      helpText: label,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  Future<void> fechaEvento(DateTime rangeStart) async {
    final startTime = await _pickTime(context, 'Selecciona hora');
    if (startTime == null) return;

    final fullStart = DateTime(
      rangeStart.year,
      rangeStart.month,
      rangeStart.day,
      startTime.hour,
      startTime.minute,
    );
    setState(() {
      _diaParaEditar = fullStart;
    });
  }

  bool sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  final formCarro = GlobalKey<FormState>();
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
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      filtroEventos(selectedDay);
                      _abrirFormulario(selectedDay);
                    },

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
                        eventosFiltrados.isEmpty
                            ? const SizedBox()
                            : ListView.builder(
                              itemCount: eventosFiltrados.length,
                              itemBuilder: (context, index) {
                                final evento = eventosFiltrados[index];

                                return ListTile(
                                  trailing: Wrap(
                                    spacing: 12,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF204c6c),
                                        ),
                                        onPressed: () {
                                          final fecha = formatoFechaHora.parse(
                                            evento["FechaRegistro"],
                                          );
                                          setState(() {
                                            indexEditando =
                                                evento["CalendarioID"];
                                            _descripcionController.text =
                                                evento["Descripcion"];
                                          });

                                          _abrirFormulario(fecha);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          showPasswordDialog(
                                            context: context,
                                            calendarioID:
                                                evento['CalendarioID'],
                                            descripcion: evento['Descripcion'],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    '${evento['Descripcion']}',
                                    style: TextStyle(fontFamily: 'Quicksand'),
                                  ),
                                  subtitle: Text(
                                    evento['FechaRegistro'],
                                    style: TextStyle(fontFamily: 'Quicksand'),
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
                child: Form(
                  key: formCarro,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evento ${_diaParaEditar?.year}/${_diaParaEditar?.month}/${_diaParaEditar?.day} ${_diaParaEditar?.hour.toString().padLeft(2, '0')}:${_diaParaEditar?.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        style: TextStyle(fontFamily: 'Quicksand'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s\$]'),
                          ),
                          LengthLimitingTextInputFormatter(300),
                        ],
                        maxLines: 7,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Agrega la descripción del evento";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_diaParaEditar != null) {
                            fechaEvento(_diaParaEditar!);
                          }
                        },
                        child: const Text(
                          'Selecciona la hora',
                          style: TextStyle(fontFamily: 'Quicksand'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            height: 45,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                indexEditando == null ? Icons.add : Icons.save,
                              ),
                              onPressed:
                                  () => {
                                    if (formCarro.currentState!.validate())
                                      {
                                        mostrarDialogoAgregarEvento(
                                          context,
                                          indexEditando,
                                        ),
                                      },
                                  },

                              label: Text(
                                indexEditando == null ? 'Agregar' : 'Guardar',
                                style: TextStyle(fontFamily: 'Quicksand'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 45,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.delete),
                              onPressed: _cerrarFormulario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              label: const Text(
                                'Cancelar',
                                style: TextStyle(fontFamily: 'Quicksand'),
                              ),
                            ),
                          ),
                        ],
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

  void showPasswordDialog({
    required BuildContext context,

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
                '¿Desea eliminar el evento?',
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
                        eliminarEvento(calendarioID: calendarioID);
                        Navigator.of(context).pop();
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

  mostrarDialogoAgregarEvento(BuildContext context, int? clienteID) {
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
                    ? '¿Estás seguro de editar este evento?'
                    : '¿Estás seguro de agregar este evento?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
                _guardarEvento();
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
}
