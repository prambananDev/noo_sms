import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? validationText;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validationText,
    this.inputType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              keyboardType: inputType,
              textCapitalization: capitalization,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: label,
                isDense: true,
                filled: true,
                contentPadding: const EdgeInsets.all(5),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return validationText ?? 'Please enter $label';
                } else if (maxLength != null && value.length < maxLength!) {
                  return 'NPWP kurang dari $maxLength digit';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
