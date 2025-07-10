import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:search_choices/search_choices.dart';

class ProvinceDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final String? validationText;
  final TextEditingController? cityController;
  final String addressType;
  final bool? search;

  const ProvinceDropdownField({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    this.validationText,
    this.cityController,
    this.addressType = 'main',
    this.search,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtil.scaleSize(context, 8),
      ),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaleSize(context, 10)),
          Expanded(
            flex: 2,
            child: Obx(() {
              if (formController.isProvincesLoading.value) {
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

              // Use search dropdown or regular dropdown based on search parameter
              return (search ?? false)
                  ? _buildSearchDropdown(context)
                  : _buildRegularDropdown(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown(BuildContext context) {
    return SearchChoices.single(
      isExpanded: true,
      value: _findCurrentValue(),
      hint: Text(
        "Select a Province",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: formController.provinces.map((province) {
        return DropdownMenuItem<String>(
          value: province["Text"],
          child: Text(
            province["Text"] ?? "loading..",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleProvinceSelection(value);
      },
      dialogBox: true,
      displayClearIcon: true,
      menuBackgroundColor: colorNetral,
      padding: EdgeInsets.zero,
      validator: (value) {
        if (validationText != null && (value == null || value.isEmpty)) {
          return validationText;
        }
        return null;
      },
      searchHint: "Search Province",
      searchFn: (String keyword, items) {
        return _searchProvinces(keyword, items);
      },
    );
  }

  Widget _buildRegularDropdown(BuildContext context) {
    return DropdownButtonFormField(
      value: _findCurrentValue(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(
          ResponsiveUtil.scaleSize(context, 12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(27, 158, 158, 158)),
        ),
      ),
      items: _buildDropdownItems(context),
      onChanged: (value) {
        _handleProvinceSelection(value);
      },
      validator: (value) {
        if (validationText != null && (value == null || value.isEmpty)) {
          return validationText;
        }
        return null;
      },
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down,
        size: ResponsiveUtil.scaleSize(context, 24),
      ),
      menuMaxHeight: ResponsiveUtil.scaleSize(context, 300),
      dropdownColor: Colors.white,
      alignment: Alignment.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  void _handleProvinceSelection(String? value) {
    if (value != null) {
      controller.text = value;

      final province = formController.provinces
          .firstWhereOrNull((province) => province["Text"].toString() == value);

      if (province != null) {
        final provinceId = province["Value"]?.toString();

        switch (addressType) {
          case 'main':
            formController.selectedProvinceId = provinceId;
            break;
          case 'delivery':
            formController.selectedProvinceIdDelivery = provinceId;
            break;
          case 'delivery2':
            formController.selectedProvinceIdDelivery2 = provinceId;
            break;
        }

        if (provinceId != null) {
          formController.fetchCities(provinceId, addressType: addressType);
        }

        if (cityController != null) {
          cityController!.clear();
        }
      }

      formController.update();
    }
  }

  List<int> _searchProvinces(
      String keyword, List<DropdownMenuItem<String>> items) {
    List<int> shownIndexes = [];

    if (keyword.isEmpty) {
      // Return all items if search is empty
      for (int i = 0; i < items.length; i++) {
        shownIndexes.add(i);
      }
    } else {
      // Filter based on keyword
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

  String? _findCurrentValue() {
    if (controller.text.isEmpty) return null;

    final currentText = controller.text.toUpperCase();

    final exactMatch = formController.provinces.firstWhereOrNull(
        (province) => province["Text"].toString().toUpperCase() == currentText);

    if (exactMatch != null) {
      return exactMatch["Text"];
    }

    final partialMatch = formController.provinces.firstWhereOrNull((province) =>
        province["Text"].toString().toUpperCase().contains(currentText) ||
        currentText.contains(province["Text"].toString().toUpperCase()));

    if (partialMatch != null) {
      return partialMatch["Text"];
    }

    return null;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(BuildContext context) {
    return formController.provinces.map((province) {
      return DropdownMenuItem<String>(
        value: province["Text"],
        child: Center(
          child: Text(
            province["Text"],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        ),
      );
    }).toList();
  }
}
