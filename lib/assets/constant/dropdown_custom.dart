import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T>? items; // The list of items
  final T? selectedItem; // The currently selected item
  final String hintText; // The hint to display when no item is selected
  final Function(T?)? onChanged; // The callback to handle selection changes
  final bool isExpanded; // Whether the dropdown should expand

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
          child: Text(item.toString()), // Customize this if needed
        );
      }).toList(),
      hint: Text(
        hintText,
        style: const TextStyle(fontSize: 12),
      ),
      onChanged: onChanged,
      isExpanded: isExpanded,
    );
  }
}
