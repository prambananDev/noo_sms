import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/assets/global.dart';

class StableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final int maxLines;
  final TextStyle? style;
  final bool? isCalendar;
  final Function()? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const StableTextField({
    Key? key,
    required this.controller,
    this.hintText = "",
    this.readOnly = false,
    this.maxLines = 1,
    this.style,
    this.isCalendar,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorAccent,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
        suffixIcon: isCalendar == true
            ? Icon(Icons.calendar_today, color: colorAccent)
            : null,
      ),
      style: style ??
          TextStyle(
            fontSize: 14,
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
    );
  }
}
