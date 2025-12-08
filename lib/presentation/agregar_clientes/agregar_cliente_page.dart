import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renta_carros/core/utils/formateo_celular.dart';
import 'package:renta_carros/core/widgets_personalizados/app_bar_widget.dart';
import 'package:renta_carros/core/widgets_personalizados/custom_text_form_widget.dart';

class AgregarClientePage extends StatelessWidget {
  AgregarClientePage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSucursalAppBar('Sucursal Sonora'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("Nuevo cliente"),
                  ),
                  CustomTextField(
                    label: "NOMBRE",
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZñÑ\s]'),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agrega el nombre";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: "DIRECCIÓN",
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZñÑ\s]'),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agrega la dirección";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),
                  CustomTextField(
                    label: "CELULAR",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CelularFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agrega un celular";
                      }
                      String clean = value.replaceAll('-', '');
                      if (clean.length != 10) {
                        return "Agrega un celular válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    label: "REFERENCIA",
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZñÑ\s]'),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agrega una referencia";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'REFERENCIA',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZñÑ\s]'),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Agrega una referencia";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity, // 👉 botón ancho completo
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {}
                      },
                      child: const Text('Guardar Cliente'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
