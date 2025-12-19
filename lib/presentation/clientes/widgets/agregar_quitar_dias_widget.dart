import 'package:flutter/material.dart';

class DiasSelector extends StatefulWidget {
  final int initialValue;
  final int maxDias;
  final ValueChanged<int> onChanged;

  const DiasSelector({
    super.key,
    this.initialValue = 0,
    this.maxDias = 10,
    required this.onChanged,
  });

  @override
  State<DiasSelector> createState() => _DiasSelectorState();
}

class _DiasSelectorState extends State<DiasSelector> {
  late int dias;

  @override
  void initState() {
    super.initState();
    dias = widget.initialValue.clamp(0, widget.maxDias);
  }

  void _update(int delta) {
    final nuevo = dias + delta;

    if (nuevo < 0 || nuevo > widget.maxDias) return;

    setState(() => dias = nuevo);
    widget.onChanged(dias);
  }

  Widget _actionButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Icon(icon, color: const Color(0xFF204c6c)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canRemove = dias > 0;
    final canAdd = dias < widget.maxDias;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Días extra: ',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        /// BOTÓN -
        _actionButton(
          icon: Icons.remove,
          enabled: canRemove,
          tooltip: 'Quitar día',
          onTap: () => _update(-1),
        ),

        /// CONTADOR
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            dias.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        /// BOTÓN +
        _actionButton(
          icon: Icons.add,
          enabled: canAdd,
          tooltip: 'Agregar día',
          onTap: () => _update(1),
        ),
      ],
    );
  }
}
