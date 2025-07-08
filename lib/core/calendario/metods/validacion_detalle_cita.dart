import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:renta_carros/botton_navigation_tree.dart';

void validacionDetalleCita(BuildContext context, bool valid) {
  if (valid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottonNavigation()),
    );
    appWindow.title = "Calendario";
  }
}
