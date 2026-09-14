import 'package:flutter/material.dart';
import '../config/metier_config.dart';

class DynamicFieldWidget extends StatelessWidget {
  final ChampMetier field;
  final TextEditingController controller;

  const DynamicFieldWidget({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case TypeChampMetier.number:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          validator: field.obligatoire
              ? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null
              : null,
        );

      case TypeChampMetier.select:
        return DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          items: field.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => controller.text = v ?? '',
          validator: field.obligatoire
              ? (v) => (v == null || v.isEmpty) ? 'Sélection requise' : null
              : null,
        );

      case TypeChampMetier.multiline:
        return TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          validator: field.obligatoire
              ? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null
              : null,
        );

      case TypeChampMetier.text:
      default:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          validator: field.obligatoire
              ? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null
              : null,
        );
    }
  }
}
