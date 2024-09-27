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
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digit characters (except decimal point).
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(newText);

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      decimalDigits: 0,
      symbol: '',
    );

    String formattedText =
        formatter.format(value).replaceAll(',', thousandSeparator);
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
