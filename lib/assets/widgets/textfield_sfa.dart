import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';

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
        hintStyle: TextStyle(
          fontSize: 14.rt(context),
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rr(context)),
          borderSide: const BorderSide(
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rr(context)),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rr(context)),
          borderSide: BorderSide(
            color: colorAccent,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.rr(context)),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.rp(context),
          vertical: 8.rp(context),
        ),
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
        suffixIcon: isCalendar == true
            ? Icon(
                Icons.calendar_today,
                color: colorAccent,
                size: 20.ri(context),
              )
            : null,
      ),
      style: style ??
          TextStyle(
            fontSize: 14.rt(context),
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
    );
  }
}
