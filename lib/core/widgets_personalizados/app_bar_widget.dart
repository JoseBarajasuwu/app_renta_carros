import 'package:flutter/material.dart';

AppBar buildSucursalAppBar(String titulo) {
  return AppBar(
    title: Text(
      titulo,
      style: const TextStyle(fontFamily: 'Quicksand-Bold', color: Colors.white),
    ),
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
