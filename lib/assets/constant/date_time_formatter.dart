import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final DateTime initialValue;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDatePickerField({
    Key? key,
    required this.controller,
    this.labelText = 'Select Date',
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  CustomDatePickerFieldState createState() => CustomDatePickerFieldState();
}

class CustomDatePickerFieldState extends State<CustomDatePickerField> {
  @override
  void initState() {
    super.initState();

    widget.controller.text =
        DateFormat('MM-dd-yyyy').format(widget.initialValue);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialValue,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      style: const TextStyle(fontSize: 16),
      onTap: () => _selectDate(context),
    );
  }
}
