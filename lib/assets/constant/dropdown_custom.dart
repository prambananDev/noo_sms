import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T>? items;
  final T? selectedItem;
  final String hintText;
  final Function(T?)? onChanged;
  final bool isExpanded;

  const CustomDropdown({
    Key? key,
    required this.items,
    this.selectedItem,
    required this.hintText,
    required this.onChanged,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: selectedItem,
      items: items?.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      hint: Text(
        hintText,
        style: const TextStyle(fontSize: 16),
      ),
      onChanged: onChanged,
      isExpanded: isExpanded,
    );
  }
}
