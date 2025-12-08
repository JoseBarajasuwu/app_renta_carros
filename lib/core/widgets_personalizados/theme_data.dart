// import 'package:flutter/material.dart';

// final ThemeData appTheme = ThemeData(
//   useMaterial3: true,
//   colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
//   // primaryColor: Colors.orange,
//   scaffoldBackgroundColor: Colors.white,
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Color(0xFF204c6c),
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//     ),
//   ),
//   inputDecorationTheme: InputDecorationTheme(
//     labelStyle: TextStyle(color: Color(0xFF204c6c), fontFamily: 'Quicksand'),
//     floatingLabelStyle: TextStyle(
//       color: Color(0xFF204c6c),
//       fontFamily: 'Quicksand',
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Color(0xFF204c6c)),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.red),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     focusedErrorBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.redAccent, width: 2),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     prefixIconColor: Colors.black54,
//     suffixIconColor: Colors.black54,
//   ),
//   textButtonTheme: TextButtonThemeData(
//     style: ButtonStyle(
//       foregroundColor: WidgetStateProperty.all<Color>(Color(0xFF204c6c)),
//       overlayColor: WidgetStateProperty.all<Color>(
//         Color(0xFF204c6c).withValues(alpha: 0.1),
//       ),
//     ),
//   ),
//   textTheme: TextTheme(
//     // bodyLarge: const TextStyle(
//     //   fontSize: 18,
//     //   color: Colors.black,
//     //   fontFamily: 'Quicksand',
//     // ),
//     // bodySmall: TextStyle(
//     //   fontSize: 14,
//     //   color: Colors.black,
//     //   fontFamily: 'Quicksand',
//     // ),
//     bodyLarge: TextStyle(fontFamily: 'Quicksand', color: Colors.black),
//     bodyMedium: TextStyle(fontFamily: 'Quicksand', color: Colors.black),
//     titleLarge: TextStyle(fontFamily: 'Quicksand', color: Colors.black),
//   ),
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: Colors.black,
//     selectionColor: Color.fromARGB(255, 192, 192, 192),
//     // selectionHandleColor: Colors.orange,
//   ),

//   // floatingActionButtonTheme: const FloatingActionButtonThemeData(
//   //   backgroundColor: Colors.orange,
//   //   foregroundColor: Colors.white,
//   // ),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//     elevation: 0,
//   ),
//   // colorScheme: ColorScheme.fromSeed(
//   //   seedColor: Colors.blueAccent, // Cambia esto al color base que quieras
//   //   surface: Colors.white, // Fondo de los componentes como BottomNavigationBar
//   // ),
// );
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  // 🎨 COLOR SCHEME OFICIAL con la paleta Azul Profesional
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E3A8A), // Azul oscuro
    onPrimary: Colors.white,
    secondary: Color(0xFF3B82F6), // Azul claro
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white, // Gris casi negro
    surface: Colors.white,
    onSurface: Color(0xFF111827),
  ),

  scaffoldBackgroundColor: const Color(0xFFF3F4F6),

  // 🟦 BOTONES ELEVADOS
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
    ),
  ),

  // 🟦 INPUTS (TextFormField)
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: Color(0xFF1E3A8A),
      fontFamily: 'Quicksand',
    ),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF1E3A8A),
      fontFamily: 'Quicksand',
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    prefixIconColor: const Color(0xFF6B7280),
    suffixIconColor: const Color(0xFF6B7280),
  ),

  // 🟦 TEXT BUTTONS
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(const Color(0xFF1E3A8A)),
      overlayColor: WidgetStateProperty.all(
        const Color(0xFF1E3A8A).withValues(alpha: 0.1),
      ),
    ),
  ),

  // 🟦 TIPOGRAFÍA GENERAL
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Quicksand', color: Color(0xFF111827)),
    bodyMedium: TextStyle(fontFamily: 'Quicksand', color: Color(0xFF111827)),
    titleLarge: TextStyle(
      fontFamily: 'Quicksand',
      color: Color(0xFF111827),
      fontWeight: FontWeight.bold,
    ),
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF1E3A8A),
    selectionColor: Color(0xFF93C5FD), // Azul claro semitransparente
  ),

  // 🟦 APPBAR
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E3A8A),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
);
