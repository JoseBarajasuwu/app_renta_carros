import 'package:flutter/material.dart';

BoxDecoration fondoPrincipal() {
  return const BoxDecoration(
    image: DecorationImage(
      image: AssetImage("assets/imagenes/fondo.png"),
      fit: BoxFit.cover,
    ),
  );
}
