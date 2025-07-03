import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  bold
                      ? TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      )
                      : TextStyle(fontFamily: 'Quicksand'),
            ),
          ),
          Text(
            value,
            style:
                bold
                    ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF204c6c),
                      fontFamily: 'Quicksand',
                    )
                    : TextStyle(
                      color: Colors.grey[800],
                      fontFamily: 'Quicksand',
                    ),
          ),
        ],
      ),
    );
  }
}
