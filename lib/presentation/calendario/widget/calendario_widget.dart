import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renta_carros/database/rentas_db.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWithBlockedDays extends StatefulWidget {
  final double costoPorDia;
  final List<DateTime> diasOcupados;
  final List<DiaDisponible> diasDisponibles;
  final String rentaActualId;
  const CalendarWithBlockedDays({
    super.key,
    required this.costoPorDia,
    required this.diasOcupados,
    required this.diasDisponibles,
    required this.rentaActualId,
  });

  @override
  State<CalendarWithBlockedDays> createState() =>
      _CalendarWithBlockedDaysState();
}

// Clase para representar día disponible con tipo y hora límite
class DiaDisponible {
  final DateTime dia; // fecha completa con hora
  final String tipo; // 'Inicio' o 'Fin'
  final String rentaId; // ID de la renta asociada (tuya o de otros)

  DiaDisponible(this.dia, this.tipo, this.rentaId);
}

class _CalendarWithBlockedDaysState extends State<CalendarWithBlockedDays> {
  double? totalAPagar;
  final DateFormat formatoFechaHora = DateFormat('yyyy-MM-dd');
  final DateFormat formatoFecha = DateFormat('yyyy-MM-dd HH:mm');
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();
  DateTime? _day;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime? fullStartDateTime;
  DateTime? fullEndDateTime;

  List<DateTime> _daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime.utc(start.year, start.month, start.day + i));
    }
    return days;
  }

  bool _rangeHasBlockedDays(DateTime start, DateTime end) {
    final range = _daysInRange(start, end);
    // Si algún día dentro del rango está ocupado por otra renta distinta a la actual
    return range.any((day) {
      if (widget.diasOcupados.any((ocupado) => isSameDay(ocupado, day))) {
        // Revisamos si el día ocupado corresponde a una renta diferente
        final ocupadaPorMiRenta = widget.diasDisponibles.any(
          (d) => isSameDay(d.dia, day) && d.rentaId == widget.rentaActualId,
        );
        return !ocupadaPorMiRenta;
      }
      return false;
    });
  }

  // Obtiene los rangos completos (inicio, fin) de otras rentas
  List<Map<String, DateTime>> obtenerRangosDeOtrasRentas() {
    List<Map<String, DateTime>> rangos = [];

    // Agrupa días por rentaId
    Map<String, List<DiaDisponible>> rentasAgrupadas = {};

    for (var diaDisp in widget.diasDisponibles) {
      if (diaDisp.rentaId == widget.rentaActualId) {
        continue; // Excluir renta actual
      }
      rentasAgrupadas.putIfAbsent(diaDisp.rentaId, () => []).add(diaDisp);
    }

    for (var rentaId in rentasAgrupadas.keys) {
      final dias = rentasAgrupadas[rentaId]!;

      final inicio = dias.firstWhere(
        (d) => d.tipo == 'Inicio',
        orElse: () => throw Exception('No hay día inicio para renta $rentaId'),
      );
      final fin = dias.firstWhere(
        (d) => d.tipo == 'Fin',
        orElse: () => throw Exception('No hay día fin para renta $rentaId'),
      );

      rangos.add({'inicio': inicio.dia, 'fin': fin.dia});
    }

    return rangos;
  }

  // Función para checar si dos rangos se solapan
  bool rangosSeSolapan(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // No hay solapamiento si end1 <= start2 o end2 <= start1
    return !(end1.isAtSameMomentAs(start2) || end2.isAtSameMomentAs(start1)) &&
        start1.isBefore(end2) &&
        end1.isAfter(start2);
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

    // Validar solapamiento con otras rentas (usando horas)
    final rangosOtrasRentas = obtenerRangosDeOtrasRentas();
    for (final rango in rangosOtrasRentas) {
      final inicio = rango['inicio']!;
      final fin = rango['fin']!;
      if (rangosSeSolapan(fullStart, fullEnd, inicio, fin)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El rango seleccionado (con hora) se solapa con otra renta.',
            ),
          ),
        );
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
          totalAPagar = null;
          fullStartDateTime = null;
          fullEndDateTime = null;
          _rangeSelectionMode = RangeSelectionMode.toggledOn;
        });
        return;
      }
    }

    // Validar días ocupados intermedios (sin horas)
    if (_rangeHasBlockedDays(_rangeStart!, _rangeEnd!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El rango contiene días ocupados por otras rentas. Intenta otro.',
          ),
        ),
      );
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        totalAPagar = null;
        fullStartDateTime = null;
        fullEndDateTime = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
      });
      return;
    }

    final duration = fullEnd.difference(fullStart).inHours;
    final diasCompletos = (duration / 24).ceil();
    final total = diasCompletos * widget.costoPorDia;

    setState(() {
      fullStartDateTime = fullStart;
      fullEndDateTime = fullEnd;
      totalAPagar = total;
    });

    Navigator.of(context).pop({
      'start': fullStart,
      'end': fullEnd,
      'total': total,
      'diasCompletos': diasCompletos,
    });
  }

  Widget _buildInfoForDay(DateTime? day) {
    if (day == null) return const SizedBox();
    final fecha = formatoFechaHora.format(day);
    List<Map<String, dynamic>> listaRentasInfo = RentaDAO.obtenerHistorial(
      fecha: fecha,
    );
    if (listaRentasInfo.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ...listaRentasInfo.map((renta) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${renta['NombreCompleto']}, ${renta['NombreCarro']}'
                ' ${renta['Anio']}'
                ' ${renta['Placas']}'
                ' Desde: ${formatoFecha.format(DateTime.parse(renta['FechaInicio']))} '
                'Hasta: ${formatoFecha.format(DateTime.parse(renta['FechaFin']))}',
                style: const TextStyle(fontSize: 14, fontFamily: 'Quicksand'),
              ),
            );
          }),
        ],
      ),
    );
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
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            rangeSelectionMode: _rangeSelectionMode,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            enabledDayPredicate: (day) {
              // Bloquea días ocupados por otras rentas
              final ocupadoEseDia = widget.diasOcupados.any(
                (d) => isSameDay(d, day),
              );
              if (ocupadoEseDia) {
                final ocupadoPorMiRenta = widget.diasDisponibles.any(
                  (d) =>
                      isSameDay(d.dia, day) &&
                      d.rentaId == widget.rentaActualId,
                );
                if (!ocupadoPorMiRenta) return false;
              }
              // Si no está ocupado o es tu renta, permite selección
              return true;
            },

            selectedDayPredicate: (day) {
              return (_rangeStart != null && isSameDay(day, _rangeStart)) ||
                  (_rangeEnd != null && isSameDay(day, _rangeEnd));
            },
            onDayLongPressed: (day, focusedDay) {
              setState(() {
                _day = day;

                _focusedDay = focusedDay;
              });
            },
            onRangeSelected: (start, end, focusedDay) async {
              if (start != null && end != null) {
                // Primero verifica si hay días ocupados en el rango
                if (_rangeHasBlockedDays(start, end)) {
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
                    fullStartDateTime = null;
                    fullEndDateTime = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOn;
                  });
                  return;
                }
              }

              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
                totalAPagar = null;
                fullStartDateTime = null;
                fullEndDateTime = null;
              });

              if (start != null && end != null) {
                await _askForTimeAndCalculate();
              }
            },

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final disponiblesEnElDia =
                    widget.diasDisponibles
                        .where((d) => isSameDay(d.dia, day))
                        .toList();

                // Si hay más de una renta ese día, color naranja
                if (disponiblesEnElDia.length > 1) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepOrange, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  );
                }

                if (disponiblesEnElDia.length == 1) {
                  final tipo = disponiblesEnElDia.first.tipo;
                  final color = tipo == 'Inicio' ? Colors.green : Colors.blue;
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: color, fontFamily: 'Quicksand'),
                    ),
                  );
                }
                return null;
              },

              disabledBuilder: (context, day, focusedDay) {
                final disponiblesEnElDia =
                    widget.diasDisponibles
                        .where((d) => isSameDay(d.dia, day))
                        .toList();

                if (disponiblesEnElDia.length > 1) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  );
                } else if (disponiblesEnElDia.length == 1) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  );
                }

                // Días ocupados sin info parcial → gris
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                );
              },

              // Rango: día inicio
              rangeStartBuilder: (context, day, focusedDay) {
                final disponiblesEnElDia =
                    widget.diasDisponibles
                        .where((d) => isSameDay(d.dia, day))
                        .toList();

                Color borderColor = Colors.green;
                if (disponiblesEnElDia.length > 1) {
                  borderColor = Colors.deepOrange;
                } else if (disponiblesEnElDia.isNotEmpty) {
                  borderColor =
                      disponiblesEnElDia.first.tipo == 'Inicio'
                          ? Colors.green
                          : Colors.blue;
                }

                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                    border: Border.all(color: borderColor, width: 3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                );
              },

              // Rango: día fin
              rangeEndBuilder: (context, day, focusedDay) {
                final disponiblesEnElDia =
                    widget.diasDisponibles
                        .where((d) => isSameDay(d.dia, day))
                        .toList();

                Color borderColor = Colors.blue;
                if (disponiblesEnElDia.length > 1) {
                  borderColor = Colors.deepOrange;
                } else if (disponiblesEnElDia.isNotEmpty) {
                  borderColor =
                      disponiblesEnElDia.first.tipo == 'Inicio'
                          ? Colors.green
                          : Colors.blue;
                }

                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    border: Border.all(color: borderColor, width: 3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                );
              },

              // Rango: días entre inicio y fin
              withinRangeBuilder: (context, day, focusedDay) {
                final disponiblesEnElDia =
                    widget.diasDisponibles
                        .where((d) => isSameDay(d.dia, day))
                        .toList();

                Color bgColor = Colors.lightGreen.withOpacity(0.4);
                Color textColor = Colors.black;

                if (disponiblesEnElDia.length > 1) {
                  bgColor = Colors.orange.withOpacity(0.5);
                  textColor = Colors.deepOrange;
                } else if (disponiblesEnElDia.isNotEmpty) {
                  bgColor =
                      disponiblesEnElDia.first.tipo == 'Inicio'
                          ? Colors.green.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5);
                  textColor = Colors.white;
                }

                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: textColor, fontFamily: 'Quicksand'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // if (totalAPagar != null)
          //   Text(
          //     'Total a pagar: \$${totalAPagar!}',
          //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          // const SizedBox(height: 10),
          // if (fullStartDateTime != null && fullEndDateTime != null)
          //   Text(
          //     'Desde: $fullStartDateTime\nHasta: $fullEndDateTime',
          //     textAlign: TextAlign.center,
          //   )
          // else
          const Text(
            'Selecciona un rango y luego las horas.',
            style: TextStyle(fontFamily: 'Quicksand'),
          ),
          if (_day != null) _buildInfoForDay(_day),
        ],
      ),
    );
  }
}

// Helper para comparar días ignorando la hora
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
