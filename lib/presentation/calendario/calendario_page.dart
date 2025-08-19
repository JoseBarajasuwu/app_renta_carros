import 'package:flutter/material.dart';
import 'package:renta_carros/database/calendario_db.dart';
import 'package:renta_carros/presentation/calendario/detalle_citas_page.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
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
    if (_descripcionController.text.trim().isEmpty) return;
    CalendarioDAO.insentarEvento(
      descripcion: "",
      fechaRegistro: _diaParaEditar,
    );
    setState(() {
      _eventos.add({
        'FechaRegistro': _diaParaEditar,
        'Descripcion': _descripcionController.text.trim(),
      });
      _selectedDay = _diaParaEditar;
      _descripcionController.clear();
    });
    _cerrarFormulario();
  }

  void cargaEventoDelDia() async {
    DateTime hoy = DateTime.now();
    setState(() {
      _selectedDay = hoy;
    });
    final resultado = await CalendarioDAO.obtenerEventos();
    setState(() {
      _eventos = resultado;
    });
  }

  List<Map<String, dynamic>> _eventosDelDia() {
    if (_selectedDay == null) return [];
    return _eventos
        .where(
          (e) =>
              e['FechaRegistro'] != null &&
              isSameDay(e['FechaRegistro'] as DateTime, _selectedDay!),
        )
        .toList();
  }

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
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleCitasPage(fecha: selectedDay),
                        ),
                      );
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return GestureDetector(
                          onSecondaryTap: () => _abrirFormulario(day),
                          child: Center(child: Text('${day.day}')),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return GestureDetector(
                          onSecondaryTap: () => _abrirFormulario(day),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF204c6c),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
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
                        _eventosDelDia().isEmpty
                            ? const Center(child: Text('No hay eventos'))
                            : ListView.builder(
                              itemCount: _eventosDelDia().length,
                              itemBuilder: (context, index) {
                                final evento = _eventosDelDia()[index];
                                return ListTile(
                                  subtitle: Text(
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
}
