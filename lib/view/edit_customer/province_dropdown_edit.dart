import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/edit_customer/customer_detail_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:search_choices/search_choices.dart';

class ProvinceDropdownEdit extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final CustomerDetailFormController detailController;
  final TextEditingController cityController;
  final String? validationText;
  final String addressType;
  final bool search;

  const ProvinceDropdownEdit({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    required this.detailController,
    required this.cityController,
    this.validationText,
    this.addressType = 'main',
    this.search = true,
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
              final provincesList = formController.provinces;

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

              String? currentValue = _getCurrentValue(provincesList);

              return search
                  ? _buildSearchDropdown(context, provincesList, currentValue)
                  : _buildRegularDropdown(context, provincesList, currentValue);
            }),
          ),
        ],
      ),
    );
  }

  String? _getCurrentValue(RxList<Map<String, dynamic>> provincesList) {
    if (controller.text.isNotEmpty) {
      final currentText = controller.text.toUpperCase();

      // Try exact match first
      final exactMatch = provincesList.firstWhereOrNull(
        (province) => province["Text"].toString().toUpperCase() == currentText,
      );
      if (exactMatch != null) {
        return exactMatch["Text"].toString();
      }

      // Try partial match
      final partialMatch = provincesList.firstWhereOrNull(
        (province) =>
            province["Text"].toString().toUpperCase().contains(currentText) ||
            currentText.contains(province["Text"].toString().toUpperCase()),
      );
      if (partialMatch != null) {
        return partialMatch["Text"].toString();
      }
    }
    return null;
  }

  Widget _buildSearchDropdown(BuildContext context,
      RxList<Map<String, dynamic>> provincesList, String? currentValue) {
    return SearchChoices.single(
      isExpanded: true,
      value: currentValue,
      hint: Text(
        "Select a Province",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: provincesList.map((province) {
        final provinceName = province["Text"].toString();
        return DropdownMenuItem<String>(
          value: provinceName,
          child: Text(
            provinceName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleProvinceSelection(value, provincesList);
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
      },
    );
  }

  Widget _buildRegularDropdown(BuildContext context,
      RxList<Map<String, dynamic>> provincesList, String? currentValue) {
    return DropdownButtonFormField<String>(
      value: currentValue,
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
      items: provincesList.map((province) {
        final provinceName = province["Text"].toString();
        return DropdownMenuItem<String>(
          value: provinceName,
          child: Center(
            child: Text(
              provinceName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleProvinceSelection(value, provincesList);
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

  void _handleProvinceSelection(
      String? value, RxList<Map<String, dynamic>> provincesList) {
    if (value != null) {
      // Update the controller text
      controller.text = value;

      // Clear city and district for this address type
      cityController.clear();

      TextEditingController? districtController;
      switch (addressType) {
        case 'main':
          districtController = detailController.kecamatanController;
          break;
        case 'delivery':
          districtController = detailController.kecamatanControllerDelivery;
          break;
        case 'delivery2':
          districtController = detailController.kecamatanTaxController;
          break;
      }

      if (districtController != null) {
        districtController.clear();
      }

      // Find the selected province to get its ID
      final selectedProvince = provincesList.firstWhereOrNull(
        (province) => province["Text"].toString() == value,
      );

      if (selectedProvince != null) {
        final provinceId = selectedProvince["Value"]?.toString() ?? '';

        // Fetch cities using the province ID
        if (provinceId.isNotEmpty) {
          formController.fetchCities(provinceId, addressType: addressType);
        }
      }

      // Trigger UI update for detail controller only
      detailController.update();
    }
  }
}
