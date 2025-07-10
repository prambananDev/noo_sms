import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:intl/intl.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? validationText;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  final int? maxLength;
  final bool isCurrency;
  final String? prefix;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validationText,
    this.inputType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
    this.maxLength,
    this.isCurrency = false,
    this.prefix,
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
              keyboardType: isCurrency
                  ? TextInputType.number
                  : (isKTP || isNPWP)
                      ? TextInputType.number
                      : inputType,
              textCapitalization: capitalization,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.left,
              maxLength: (isKTP || isNPWP) ? ktpNPWPLength : maxLength,
              inputFormatters: _getInputFormatters(isKTP, isNPWP),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixText: isCurrency ? prefix : null,
                prefixStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                hintText: _getHintText(isKTP, isNPWP),
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
              validator: (value) => _validateInput(
                value,
                isKTP,
                isNPWP,
                ktpNPWPLength,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextInputFormatter>? _getInputFormatters(bool isKTP, bool isNPWP) {
    if (isKTP || isNPWP) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
      ];
    } else if (isCurrency) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ];
    }
    return null;
  }

  String _getHintText(bool isKTP, bool isNPWP) {
    if (isKTP || isNPWP) {
      return '$label (Max 16 digit)';
    } else if (isCurrency) {
      return '0';
    } else {
      return 'Enter $label';
    }
  }

  String? _validateInput(
    String? value,
    bool isKTP,
    bool isNPWP,
    int ktpNPWPLength,
  ) {
    if (value == null || value.isEmpty) {
      return validationText ?? 'Please enter $label';
    } else if (isKTP || isNPWP) {
      final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanValue.length != ktpNPWPLength) {
        return '$label must be $ktpNPWPLength digits';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
        return '$label can only contain numbers';
      }
    } else if (isCurrency) {
      final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanValue.isEmpty) {
        return validationText ?? 'Please enter $label';
      }
    } else if (maxLength != null && value.length > maxLength!) {
      return '$label exceeds $maxLength characters';
    }
    return null;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final int value = int.parse(cleanedText);
    final formatter = NumberFormat('#,###', 'id_ID');
    final String formattedText = formatter.format(value).replaceAll(',', '.');

    int cursorPosition = formattedText.length;

    if (oldValue.text.isNotEmpty &&
        newValue.text.length > oldValue.text.length) {
      final int digitCount = cleanedText.length;
      final int oldDigitCount =
          oldValue.text.replaceAll(RegExp(r'[^0-9]'), '').length;

      if (digitCount == oldDigitCount + 1) {
        final int separatorCount = formattedText.split('.').length - 1;
        final int oldSeparatorCount = oldValue.text.split('.').length - 1;

        if (separatorCount > oldSeparatorCount) {
          cursorPosition = oldValue.selection.baseOffset + 2;
        } else {
          cursorPosition = oldValue.selection.baseOffset + 1;
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
          offset: cursorPosition.clamp(0, formattedText.length)),
    );
  }
}

extension CurrencyExtension on TextEditingController {
  String get cleanValue {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  int get numericValue {
    final clean = cleanValue;
    return clean.isEmpty ? 0 : int.parse(clean);
  }
}
