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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isExpanded: true,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text(
                    item['name'] ?? "loading..",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
      ),
    );
  }
}
