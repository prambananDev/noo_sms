import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/edit_customer/customer_detail_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:search_choices/search_choices.dart';

class DistrictDropdownEdit extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final CustomerDetailFormController detailController;
  final String? validationText;
  final String addressType;
  final bool search;
  final TextEditingController cityController;

  const DistrictDropdownEdit({
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
          Expanded(
            flex: 2,
            child: Obx(() {
              bool isLoading = false;
              RxList<Map<String, dynamic>> districtsList;

              // Get districts list based on address type
              switch (addressType) {
                case 'main':
                  isLoading = formController.isDistrictsLoading.value;
                  districtsList = formController.districts;
                  break;
                case 'delivery':
                  isLoading = formController.isDistrictsDeliveryLoading.value;
                  districtsList = formController.districtsDelivery;
                  break;
                case 'delivery2':
                  isLoading = formController.isDistrictsDelivery2Loading.value;
                  districtsList = formController.districtsDelivery2;
                  break;
                default:
                  districtsList = formController.districts;
              }

              if (isLoading) {
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

              // Check if city is selected
              if (cityController.text.isEmpty || districtsList.isEmpty) {
                return TextFormField(
                  controller: controller,
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(27, 158, 158, 158)),
                    ),
                    hintText: 'Select city first',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUtil.scaleSize(context, 16),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  readOnly: true,
                  onTap: () {
                    if (cityController.text.isEmpty) {
                      Get.snackbar(
                        'City Required',
                        'Please select a city first',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                );
              }

              String? currentValue = _getCurrentValue(districtsList);

              return search
                  ? _buildSearchDropdown(context, districtsList, currentValue)
                  : _buildRegularDropdown(context, districtsList, currentValue);
            }),
          ),
        ],
      ),
    );
  }

  String? _getCurrentValue(RxList<Map<String, dynamic>> districtsList) {
    if (controller.text.isNotEmpty) {
      final currentText = controller.text;

      // Try exact match first
      final exactMatch = districtsList.firstWhereOrNull(
        (district) => district["Text"].toString() == currentText,
      );
      if (exactMatch != null) {
        return exactMatch["Text"].toString();
      }

      // Try case-insensitive match
      final upperText = currentText.toUpperCase();
      for (var district in districtsList) {
        if (district["Text"].toString().toUpperCase() == upperText) {
          return district["Text"].toString();
        }
      }

      // Try partial match
      for (var district in districtsList) {
        final districtName = district["Text"].toString().toUpperCase();
        if (districtName.contains(upperText) ||
            upperText.contains(districtName)) {
          return district["Text"].toString();
        }
      }
    }
    return null;
  }

  Widget _buildSearchDropdown(BuildContext context,
      RxList<Map<String, dynamic>> districtsList, String? currentValue) {
    return SearchChoices.single(
      isExpanded: true,
      value: currentValue,
      hint: Text(
        "Select a District",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: districtsList.map((district) {
        final districtName = district["Text"].toString();
        return DropdownMenuItem<String>(
          value: districtName,
          child: Text(
            districtName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleDistrictSelection(value);
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
      searchHint: "Search District",
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
      RxList<Map<String, dynamic>> districtsList, String? currentValue) {
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
      items: districtsList.map((district) {
        final districtName = district["Text"].toString();
        return DropdownMenuItem<String>(
          value: districtName,
          child: Center(
            child: Text(
              districtName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleDistrictSelection(value);
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

  void _handleDistrictSelection(String? value) {
    if (value != null) {
      // Update the controller text directly
      controller.text = value;

      // Trigger UI update for detail controller only
      detailController.update();
    }
  }
}
