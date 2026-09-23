import 'package:flutter/material.dart';
import '../core/theme.dart';

/// TradeUnitInput - Champ d'entrée numérique pour mesures avec sélecteur d'unités (cm / in / mm).
class TradeUnitInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String initialUnit;
  final ValueChanged<String>? onUnitChanged;
  final FormFieldValidator<String>? validator;

  const TradeUnitInput({
    super.key,
    required this.label,
    required this.controller,
    this.initialUnit = 'cm',
    this.onUnitChanged,
    this.validator,
  });

  @override
  State<TradeUnitInput> createState() => _TradeUnitInputState();
}

class _TradeUnitInputState extends State<TradeUnitInput> {
  late String _currentUnit;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.initialUnit;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: '0.0',
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['cm', 'in', 'mm'].map((unit) {
              final isSelected = _currentUnit == unit;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentUnit = unit);
                  if (widget.onUnitChanged != null) {
                    widget.onUnitChanged!(unit);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(left: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AtelierProColors.primaryContainer
                        : AtelierProColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AtelierProColors.primaryContainer
                          : AtelierProColors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : AtelierProColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: widget.validator,
    );
  }
}
