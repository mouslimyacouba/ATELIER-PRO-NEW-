import 'package:flutter/material.dart';
import '../config/metier_config.dart';
import 'dynamic_field_widget.dart';

class DynamicFieldsForm extends StatefulWidget {
  final List<ChampMetier> fields;
  final Map<String, dynamic> initialValues;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final Map<String, TextEditingController> controllers;

  const DynamicFieldsForm({
    super.key,
    required this.fields,
    this.initialValues = const {},
    required this.onChanged,
    required this.controllers,
  });

  @override
  State<DynamicFieldsForm> createState() => _DynamicFieldsFormState();
}

class _DynamicFieldsFormState extends State<DynamicFieldsForm> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = Map<String, dynamic>.from(widget.initialValues);

    for (var field in widget.fields) {
      if (!widget.controllers.containsKey(field.key)) {
        final val = _values[field.key]?.toString() ?? '';
        widget.controllers[field.key] = TextEditingController(text: val);
      }
      widget.controllers[field.key]!.addListener(() {
        _onFieldChanged(field.key, widget.controllers[field.key]!.text);
      });
    }
  }

  void _onFieldChanged(String key, String value) {
    setState(() {
      _values[key] = value;
    });
    widget.onChanged(_values);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DynamicFieldWidget(
            field: field,
            controller: widget.controllers[field.key]!,
          ),
        );
      }).toList(),
    );
  }
}
