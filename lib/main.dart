import 'dart:io';

import 'package:flutter/material.dart';
import 'package:renta_carros/presentation/login/login_page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      final initialSize = Size(600, 700);
      appWindow.minSize = Size(520, 600);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "Iniciar sesión";
      appWindow.show();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        // primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: Colors.orange,
        //   foregroundColor: Colors.white,
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF204c6c),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xFF204c6c),
            fontFamily: 'Quicksand',
          ),
          floatingLabelStyle: TextStyle(
            color: Color(0xFF204c6c),
            fontFamily: 'Quicksand',
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF204c6c)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIconColor: Colors.black54,
          suffixIconColor: Colors.black54,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Color(0xFF204c6c)),
            overlayColor: WidgetStateProperty.all<Color>(
              Color(0xFF204c6c).withValues(alpha: 0.1),
            ),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Quicksand',
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'Quicksand',
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Color.fromARGB(255, 192, 192, 192),
          // selectionHandleColor: Colors.orange,
        ),

        // floatingActionButtonTheme: const FloatingActionButtonThemeData(
        //   backgroundColor: Colors.orange,
        //   foregroundColor: Colors.white,
        // ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber, // Cambia esto al color base que quieras
          surface:
              Colors.white, // Fondo de los componentes como BottomNavigationBar
        ),
      ),
      home: LoginPage(),
    );
  }
}
