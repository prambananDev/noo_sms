import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/assets/global.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  (isKTP || isNPWP) ? TextInputType.number : inputType,
              textCapitalization: capitalization,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.left,
              maxLength: (isKTP || isNPWP) ? ktpNPWPLength : maxLength,
              inputFormatters: (isKTP || isNPWP)
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(ktpNPWPLength),
                    ]
                  : null,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: (isKTP || isNPWP)
                    ? '$label (Max $ktpNPWPLength digit)'
                    : 'Enter $label',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 8),
                counterText: '',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: colorAccent,
                    width: 2.0,
                  ),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2.0,
                  ),
                ),
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
