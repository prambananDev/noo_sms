import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final bool isKTP = label.toUpperCase() == 'KTP';
    final bool isNPWP = label.toUpperCase() == 'NPWP';
    const int ktpNPWPLength = 16;

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
              keyboardType:
                  (isKTP || isNPWP) ? TextInputType.number : inputType,
              textCapitalization: capitalization,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              maxLength: (isKTP || isNPWP) ? ktpNPWPLength : maxLength,
              inputFormatters: (isKTP || isNPWP)
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(ktpNPWPLength),
                    ]
                  : null,
              decoration: InputDecoration(
                hintText: (isKTP || isNPWP)
                    ? '$label (Max $ktpNPWPLength digit)'
                    : label,
                isDense: true,
                filled: true,
                contentPadding: const EdgeInsets.all(5),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return validationText ?? 'Please enter $label';
                } else if (isKTP || isNPWP) {
                  if (value.length != ktpNPWPLength) {
                    return '$label must be $ktpNPWPLength digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return '$label can only contain numbers';
                  }
                } else if (maxLength != null && value.length > maxLength!) {
                  return '$label exceeds $maxLength characters';
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
