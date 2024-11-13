import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String validationText;
  final List<Map<String, dynamic>> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.validationText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value:
                value, // Ensure the value is a String (e.g., 'regional' from AXRegional)
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              hintText: label,
              contentPadding: const EdgeInsets.all(5),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item[
                    'name'], // Use the 'name' from the map (which is 'regional')
                child: Text(item['name'] ?? "loading.."),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return validationText;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
