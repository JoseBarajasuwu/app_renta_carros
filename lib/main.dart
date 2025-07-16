import 'dart:io';

import 'package:flutter/material.dart';
import 'package:renta_carros/botton_navigation_tree.dart';
import 'package:renta_carros/core/widgets_personalizados/theme_data.dart';
import 'package:renta_carros/database/database.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:renta_carros/clico_de_vida_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final dbHelper = DatabaseHelper();
  await dbHelper.init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      final initialSize = Size(600, 700);
      appWindow.minSize = Size(520, 600);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "Renta Car";
      appWindow.show();
    });
  }
  // runApp(const MyApp());
  runApp(AppLifecycleHandler(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: appTheme, home: BottonNavigation());
  }
}
