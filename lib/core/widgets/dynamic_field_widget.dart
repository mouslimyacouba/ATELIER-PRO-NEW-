import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/metier_config.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

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

      // Champ date : DatePicker, valeur stockée en ISO-8601 (ex: "2026-03-15")
      // pour la sérialisation Firestore, affichée en dd/MM/yyyy à l'écran.
      case TypeChampMetier.date:
        return _DateFieldWidget(field: field, controller: controller);

      // Champ booléen : RadioListTile Oui/Non. Valeur stockée : 'true'/'false'
      // (String) pour rester compatible avec Map<String, dynamic>.
      case TypeChampMetier.boolean:
        return _BoolFieldWidget(field: field, controller: controller);

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

class _DateFieldWidget extends StatelessWidget {
  final ChampMetier field;
  final TextEditingController controller;
  const _DateFieldWidget({required this.field, required this.controller});

  Future<void> _pickDate(BuildContext context) async {
    DateTime initial;
    try {
      initial = controller.text.isNotEmpty
          ? DateTime.parse(controller.text)
          : DateTime.now();
    } catch (_) {
      initial = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        String display = '';
        if (value.text.isNotEmpty) {
          try {
            display = _dateFormat.format(DateTime.parse(value.text));
          } catch (_) {
            display = value.text;
          }
        }
        return FormField<String>(
          validator: field.obligatoire
              ? (_) => value.text.isEmpty ? 'Date requise' : null
              : null,
          builder: (state) => InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: GestureDetector(
              onTap: () => _pickDate(context),
              child: Text(
                display.isEmpty ? 'Sélectionner une date' : display,
                style: TextStyle(
                  color: display.isEmpty ? Theme.of(context).hintColor : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoolFieldWidget extends StatelessWidget {
  final ChampMetier field;
  final TextEditingController controller;
  const _BoolFieldWidget({required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isTrue = value.text == 'true';
        return InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Oui'),
                  value: true,
                  groupValue: value.text.isEmpty ? null : isTrue,
                  onChanged: (_) => controller.text = 'true',
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Non'),
                  value: false,
                  groupValue: value.text.isEmpty ? null : isTrue,
                  onChanged: (_) => controller.text = 'false',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
