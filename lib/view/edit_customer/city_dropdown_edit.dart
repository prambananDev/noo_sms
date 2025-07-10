import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/edit_customer/customer_detail_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:search_choices/search_choices.dart';

class CityDropdownEdit extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final CustomerDetailFormController detailController;
  final String? validationText;
  final String addressType;
  final bool search;
  final TextEditingController provinceController;

  const CityDropdownEdit({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    required this.detailController,
    required this.provinceController,
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
              RxList<Map<String, dynamic>> citiesList;

              // Get cities list based on address type
              switch (addressType) {
                case 'main':
                  isLoading = formController.isCitiesLoading.value;
                  citiesList = formController.cities;
                  break;
                case 'delivery':
                  isLoading = formController.isCitiesDeliveryLoading.value;
                  citiesList = formController.citiesDelivery;
                  break;
                case 'delivery2':
                  isLoading = formController.isCitiesDelivery2Loading.value;
                  citiesList = formController.citiesDelivery2;
                  break;
                default:
                  citiesList = formController.cities;
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

              // Check if province is selected
              if (provinceController.text.isEmpty || citiesList.isEmpty) {
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
                    hintText: 'Select province first',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUtil.scaleSize(context, 14),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  readOnly: true,
                  onTap: () {
                    if (provinceController.text.isEmpty) {
                      Get.snackbar(
                        'Province Required',
                        'Please select a province first',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                );
              }

              // Get current value from controller text
              String? currentValue = _getCurrentValue(citiesList);

              return search
                  ? _buildSearchDropdown(context, citiesList, currentValue)
                  : _buildRegularDropdown(context, citiesList, currentValue);
            }),
          ),
        ],
      ),
    );
  }

  String? _getCurrentValue(RxList<Map<String, dynamic>> citiesList) {
    if (controller.text.isNotEmpty) {
      // Try exact match first
      final exactMatch = citiesList.firstWhereOrNull(
        (city) => city["Text"].toString() == controller.text,
      );
      if (exactMatch != null) {
        return controller.text;
      }

      // Try case-insensitive match
      final caseInsensitiveMatch = citiesList.firstWhereOrNull(
        (city) =>
            city["Text"].toString().toLowerCase() ==
            controller.text.toLowerCase(),
      );
      if (caseInsensitiveMatch != null) {
        return caseInsensitiveMatch["Text"].toString();
      }
    }
    return null;
  }

  Widget _buildSearchDropdown(BuildContext context,
      RxList<Map<String, dynamic>> citiesList, String? currentValue) {
    return SearchChoices.single(
      isExpanded: true,
      value: currentValue,
      hint: Text(
        "Select a City",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: citiesList.map((city) {
        final cityName = city["Text"].toString();
        return DropdownMenuItem<String>(
          value: cityName,
          child: Text(
            cityName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleCitySelection(value, citiesList);
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
      searchHint: "Search City",
      searchFn: (String keyword, items) {
        return _searchCities(keyword, items);
      },
    );
  }

  Widget _buildRegularDropdown(BuildContext context,
      RxList<Map<String, dynamic>> citiesList, String? currentValue) {
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
      items: citiesList.map((city) {
        final cityName = city["Text"].toString();
        return DropdownMenuItem<String>(
          value: cityName,
          child: Center(
            child: Text(
              cityName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleCitySelection(value, citiesList);
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

  void _handleCitySelection(
      String? value, RxList<Map<String, dynamic>> citiesList) {
    if (value != null) {
      // Update the controller text directly
      controller.text = value;

      // Find the selected city to get its ID
      final selectedCity = citiesList.firstWhereOrNull(
        (city) => city["Text"].toString() == value,
      );

      if (selectedCity != null) {
        final cityId = selectedCity["Value"]?.toString() ?? '';

        // Clear the district controller for this address type only
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

        // Fetch districts using the city ID
        if (cityId.isNotEmpty) {
          formController.fetchDistricts(cityId, addressType: addressType);
        }
      }

      // Trigger UI update for detail controller only
      detailController.update();
    }
  }

  List<int> _searchCities(
      String keyword, List<DropdownMenuItem<String>> items) {
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
}
