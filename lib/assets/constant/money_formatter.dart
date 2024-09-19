import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomMoneyInputFormatter extends TextInputFormatter {
  final String thousandSeparator;
  final String decimalSeparator;

  CustomMoneyInputFormatter({
    this.thousandSeparator = '.',
    this.decimalSeparator = ',',
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If input is empty, return empty.
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digit characters (except decimal point).
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If only the decimal point is typed, allow it.
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(newText);

    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale for currency format.
      decimalDigits: 0, // Adjust this as needed for your decimal precision.
      symbol: '', // Remove the currency symbol if not needed.
    );

    String formattedText =
        formatter.format(value).replaceAll(',', thousandSeparator);

    // Set the selection to the end of the formatted text.
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
