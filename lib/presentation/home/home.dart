import 'package:flutter/material.dart';
import 'package:renta_carros/presentation/clientes_2/clientes_2_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Map<String, dynamic>> botones = [
    {
      'texto': 'RENTA',
      'icono': Icons.calendar_month_outlined,
      'color': Colors.blueGrey,
      'pantalla': const HomeScreen(),
    },
    {
      'texto': 'CLIENTE',
      'icono': Icons.person_outline_sharp,
      'color': Colors.blueGrey,
      'pantalla': const ListaConBuscador(),
    },
    {
      'texto': 'VEHÍCULO',
      'icono': Icons.directions_car,
      'color': Colors.blueGrey,
      'pantalla': const HomeScreen(),
    },
    {
      'texto': 'MISCELÁNEOS',
      'icono': Icons.account_circle_outlined,
      'color': Colors.blueGrey,
      'pantalla': const HomeScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.location_pin, color: Colors.white),
            Text(
              ' Sucursal Sonora',
              style: TextStyle(fontFamily: 'Quicksand', color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const PerfilScreen()),
                // );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/imagenes/xd.jpg"),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: List.generate(botones.length, (index) {
            final boton = botones[index];
            return AspectRatio(
              aspectRatio: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: boton['color'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => boton['pantalla']),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(boton['icono'], size: 60, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      boton['texto'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
