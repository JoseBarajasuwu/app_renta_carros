import 'package:flutter/material.dart';
import 'package:renta_carros/presentation/calendario/calendario_page.dart';
import 'package:renta_carros/presentation/carros/carros_page.dart';
import 'package:renta_carros/presentation/clientes/clientes_page.dart';
import 'package:renta_carros/presentation/historial/historial.dart';

class BottonNavigation extends StatefulWidget {
  const BottonNavigation({super.key});

  @override
  State<BottonNavigation> createState() => _BottonNavigationState();
}

class _BottonNavigationState extends State<BottonNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalendarioPage(),
    ClientesPage(),
    VehiculosPage(),
    HistorialPage(),
    // const ProductosPage(),
    // const InventarioPage(),
    // const CuentaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.blue,
            selectedItemColor: Color(0xFF204c6c),
            unselectedItemColor: Colors.black,
            selectedIconTheme: IconThemeData(size: 25),
            unselectedIconTheme: IconThemeData(size: 20),
            showSelectedLabels: true,
            showUnselectedLabels: false,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Calendario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1_outlined),
              label: "Agregar/Editar Clientes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.car_rental_outlined),
              label: "Vehiculos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: "Productos",
            ),

            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person_outline_outlined),
            //   label: 'Cuenta',
            // ),
          ],
        ),
      ),
    );
  }
}
