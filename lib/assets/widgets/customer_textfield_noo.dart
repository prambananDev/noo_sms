import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? validationText;
  final TextInputType inputType;
  final TextCapitalization capitalization;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validationText,
    this.inputType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            textCapitalization: capitalization,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: label,
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.all(5),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validationText ?? 'Please enter $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
