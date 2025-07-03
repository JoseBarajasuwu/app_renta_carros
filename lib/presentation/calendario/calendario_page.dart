import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'detalle_citas_page.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});
  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Simulamos los días que tienen datos (carros reservados o disponibles)
  final Map<DateTime, List<String>> _diasConDatos = {
    DateTime.utc(2025, 7, 2): ['Camioneta A', 'Sedán B'],
    DateTime.utc(2025, 7, 3): ['SUV X'],
    DateTime.utc(2025, 7, 5): ['PickUp Z', 'Hatchback Y'],
  };

  List<String> _getEventosDelDia(DateTime day) {
    final fecha = DateTime.utc(day.year, day.month, day.day);
    return _diasConDatos[fecha] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
          calendarFormat: CalendarFormat.month,
          eventLoader: _getEventosDelDia, // <-- Aquí está la magia

          availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
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
    );
  }
}
