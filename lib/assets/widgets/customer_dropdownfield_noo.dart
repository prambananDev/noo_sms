import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:search_choices/search_choices.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String validationText;
  final List<Map<String, dynamic>> items;
  final ValueChanged<String?> onChanged;
  final bool? search;
  final bool isLoading;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.validationText,
    required this.items,
    required this.onChanged,
    this.search,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtil.scaleSize(context, 8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.rs(context)),
          Expanded(
            flex: 2,
            child: isLoading
                ? _buildLoadingWidget(context)
                : (search ?? false)
                    ? _buildSearchDropdown(context)
                    : _buildRegularDropdown(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      height: ResponsiveUtil.scaleSize(context, 48),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(
          ResponsiveUtil.scaleSize(context, 4),
        ),
      ),
      child: Center(
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(colorAccent),
        ),
      ),
    );
  }

  Widget _buildSearchDropdown(BuildContext context) {
    final uniqueItems = _getUniqueItems();

    return SearchChoices.single(
      isExpanded: true,
      value: _findCurrentValue(uniqueItems),
      hint: Text(
        "Select an Option",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: uniqueItems.map((item) {
        return DropdownMenuItem<String>(
          value: item['name']?.toString(),
          child: Text(
            item['name']?.toString() ?? "loading..",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dialogBox: true,
      displayClearIcon: true,
      menuBackgroundColor: colorNetral,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationText;
        }
        return null;
      },
      searchFn: (String keyword, items) {
        return _searchItems(keyword, items);
      },
      clearIcon: Icon(
        Icons.clear,
        size: ResponsiveUtil.scaleSize(context, 20),
      ),
    );
  }

  Widget _buildRegularDropdown(BuildContext context) {
    final uniqueItems = _getUniqueItems();
    final currentValue = _findCurrentValue(uniqueItems);

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.scaleSize(context, 10),
          vertical: ResponsiveUtil.scaleSize(context, 8),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(27, 158, 158, 158),
            width: 1,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: ResponsiveUtil.scaleSize(context, 1),
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: ResponsiveUtil.scaleSize(context, 2),
          ),
        ),
        errorStyle: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 12),
          color: Colors.red.shade400,
        ),
      ),
      items: _buildDropdownItems(context, uniqueItems),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationText;
        }
        return null;
      },
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: ResponsiveUtil.scaleSize(context, 24),
        color: Colors.grey[600],
      ),
      menuMaxHeight: ResponsiveUtil.isIPad(context)
          ? ResponsiveUtil.getScreenHeight(context) * 0.6
          : ResponsiveUtil.getScreenHeight(context) * 0.5,
      dropdownColor: colorNetral,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        fontSize: ResponsiveUtil.scaleSize(context, 16),
        color: Colors.black,
      ),
    );
  }

  List<Map<String, dynamic>> _getUniqueItems() {
    try {
      final seen = <String>{};
      final uniqueItems = <Map<String, dynamic>>[];

      for (final item in items) {
        final name = item['name']?.toString();
        if (name != null && !seen.contains(name)) {
          seen.add(name);
          uniqueItems.add(<String, dynamic>{
            'name': name,
            if (item.containsKey('value')) 'value': item['value'],
            ...item,
          });
        }
      }

      return uniqueItems;
    } catch (e) {
      return items;
    }
  }

  String? _findCurrentValue(List<Map<String, dynamic>> uniqueItems) {
    if (value == null || value!.isEmpty) return null;

    final currentText = value!.toUpperCase();

    final exactMatch = uniqueItems.firstWhere(
      (item) => item['name']?.toString().toUpperCase() == currentText,
      orElse: () => <String, dynamic>{},
    );

    if (exactMatch.isNotEmpty) {
      return exactMatch['name']?.toString();
    }

    final partialMatch = uniqueItems.firstWhere(
      (item) {
        final itemName = item['name']?.toString().toUpperCase() ?? '';
        return itemName.contains(currentText) || currentText.contains(itemName);
      },
      orElse: () => <String, dynamic>{},
    );

    if (partialMatch.isNotEmpty) {
      return partialMatch['name']?.toString();
    }

    return null;
  }

  List<int> _searchItems(String keyword, List<DropdownMenuItem<String>> items) {
    List<int> shownIndexes = [];

    if (keyword.isEmpty) {
      for (int i = 0; i < items.length; i++) {
        shownIndexes.add(i);
      }
    } else {
      for (int i = 0; i < items.length; i++) {
        String? itemValue = items[i].value;
        if (itemValue != null &&
            itemValue.toLowerCase().contains(keyword.toLowerCase())) {
          shownIndexes.add(i);
        }
      }
    }

    return shownIndexes;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      BuildContext context, List<Map<String, dynamic>> uniqueItems) {
    return uniqueItems.map((item) {
      return DropdownMenuItem<String>(
        value: item['name']?.toString(),
        child: Text(
          item['name']?.toString() ?? "loading..",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ResponsiveUtil.scaleSize(context, 16),
          ),
        ),
      );
    }).toList();
  }
}
