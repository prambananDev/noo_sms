import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';

class StableTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final int maxLines;
  final TextStyle? style;
  final bool? isCalendar;
  final Function()? onTap;

  const StableTextField({
    Key? key,
    required this.controller,
    this.hintText = "",
    this.readOnly = false,
    this.maxLines = 1,
    this.style,
    this.isCalendar,
    this.onTap,
  }) : super(key: key);

  @override
  State<StableTextField> createState() => _StableTextFieldState();
}

class _StableTextFieldState extends State<StableTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorAccent,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: widget.readOnly,
        fillColor: widget.readOnly ? Colors.grey[200] : null,
        suffixIcon: widget.isCalendar == true
            ? Icon(Icons.calendar_today, color: colorAccent)
            : null,
      ),
      style: widget.style ??
          TextStyle(
            fontSize: 14,
            color: widget.readOnly ? Colors.grey[600] : Colors.black,
          ),
    );
  }
}
