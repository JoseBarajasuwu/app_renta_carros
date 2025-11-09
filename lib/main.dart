import 'package:flutter/material.dart';
import 'package:renta_carros/core/widgets_personalizados/theme_data.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:renta_carros/presentation/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      title: "Carros",
      home: HomeScreen(),
    );
  }
}
