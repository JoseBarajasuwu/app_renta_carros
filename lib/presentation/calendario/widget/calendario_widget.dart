import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWithBlockedDays extends StatefulWidget {
  final double costoPorDia;
  const CalendarWithBlockedDays({super.key, required this.costoPorDia});

  @override
  State<CalendarWithBlockedDays> createState() =>
      _CalendarWithBlockedDaysState();
}

class _CalendarWithBlockedDaysState extends State<CalendarWithBlockedDays> {
  double? totalAPagar;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime? _fullStartDateTime;
  DateTime? _fullEndDateTime;

  // Días bloqueados
  final List<DateTime> blockedDays = [
    DateTime.utc(2025, 7, 21),
    DateTime.utc(2025, 7, 22),
    DateTime.utc(2025, 7, 28),
  ];

  List<DateTime> _daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime.utc(start.year, start.month, start.day + i));
    }
    return days;
  }

  bool _rangeHasBlockedDays(DateTime start, DateTime end) {
    final range = _daysInRange(start, end);
    return range.any(
      (day) => blockedDays.any((blocked) => isSameDay(blocked, day)),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, String label) async {
    return await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      cancelText: "Cancelar",
      confirmText: "Aceptar",
      hourLabelText: "Hora",
      minuteLabelText: "Minuto",
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: label,
    );
  }

  Future<void> _askForTimeAndCalculate() async {
    if (_rangeStart == null || _rangeEnd == null) return;

    final startTime = await _pickTime(context, 'Selecciona hora de inicio');
    if (startTime == null) return;

    final endTime = await _pickTime(context, 'Selecciona hora de fin');
    if (endTime == null) return;

    final fullStart = DateTime(
      _rangeStart!.year,
      _rangeStart!.month,
      _rangeStart!.day,
      startTime.hour,
      startTime.minute,
    );

    final fullEnd = DateTime(
      _rangeEnd!.year,
      _rangeEnd!.month,
      _rangeEnd!.day,
      endTime.hour,
      endTime.minute,
    );

    if (fullEnd.isBefore(fullStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora final no puede ser antes de la inicial.'),
        ),
      );
      return;
    }

    final duration = fullEnd.difference(fullStart).inHours;
    final diasCompletos = (duration / 24).ceil();
    final total = diasCompletos * widget.costoPorDia;

    setState(() {
      _fullStartDateTime = fullStart;
      _fullEndDateTime = fullEnd;
      totalAPagar = total;
    });
    Navigator.of(
      context,
    ).pop({'start': fullStart, 'end': fullEnd, 'total': total, 'diasCompletos': diasCompletos});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            selectedDayPredicate: (day) {
              return isSameDay(day, _rangeStart) || isSameDay(day, _rangeEnd);
            },
            onRangeSelected: (start, end, focusedDay) async {
              if (start != null &&
                  end != null &&
                  _rangeHasBlockedDays(start, end)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ese rango contiene días ocupados. Intenta otro.',
                    ),
                  ),
                );
                setState(() {
                  _rangeStart = null;
                  _rangeEnd = null;
                  totalAPagar = null;
                  _fullStartDateTime = null;
                  _fullEndDateTime = null;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
                return;
              }

              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
                _fullStartDateTime = null;
                _fullEndDateTime = null;
                totalAPagar = null;
              });

              if (start != null && end != null) {
                await _askForTimeAndCalculate();
              }
            },
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                if (blockedDays.any((d) => isSameDay(d, day))) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return null;
              },
            ),
            enabledDayPredicate: (day) {
              return !blockedDays.any((d) => isSameDay(d, day));
            },
          ),
          const SizedBox(height: 20),
          if (totalAPagar != null)
            Text(
              'Total a pagar: \$${totalAPagar!}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 10),
          if (_fullStartDateTime != null && _fullEndDateTime != null)
            Text(
              'Desde: $_fullStartDateTime\nHasta: $_fullEndDateTime',
              textAlign: TextAlign.center,
            )
          else
            const Text('Selecciona un rango y luego las horas.'),
        ],
      ),
    );
  }
}
