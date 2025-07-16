import 'package:flutter/material.dart';
import 'package:renta_carros/database/database.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  const AppLifecycleHandler({required this.child, super.key});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dbHelper.dispose(); // Cerramos la DB por seguridad
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      dbHelper.dispose(); // Cerramos la DB cuando la app se cierre
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
