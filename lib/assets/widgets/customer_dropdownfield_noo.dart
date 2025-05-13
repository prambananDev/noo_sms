import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:search_choices/search_choices.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String validationText;
  final List<Map<String, dynamic>> items;
  final ValueChanged<String?> onChanged;
  final bool? search;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.validationText,
    required this.items,
    required this.onChanged,
    this.search,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueItems = items.toSet().toList();
    final valueExists =
        value == null || uniqueItems.any((item) => item['name'] == value);

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
            child: (search ?? false)
                ? SearchChoices.single(
                    isExpanded: true,
                    value: value,
                    hint: const Text(
                      "Select an Option",
                      style: TextStyle(fontSize: 16),
                    ),
                    items: uniqueItems.map((item) {
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
                    dialogBox: true,
                    displayClearIcon: true,
                    menuBackgroundColor: colorNetral,
                  )
                : DropdownButtonFormField<String>(
                    value: valueExists ? value : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    isExpanded: true,
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(27, 158, 158, 158)),
                      ),
                    ),
                    items: uniqueItems.map((item) {
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
                    dropdownColor: colorNetral,
                    alignment: Alignment.center,
                  ),
          ),
        ],
      ),
    );
  }
}
