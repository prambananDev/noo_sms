import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:search_choices/search_choices.dart';

class CityDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final String? validationText;
  final String addressType;
  final bool autoOpenDropdown;
  final bool? search;
  final String?
      initialValue; // New parameter for initial value - can be from controller.text or manual input

  const CityDropdownField({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    this.validationText,
    this.addressType = 'main',
    this.autoOpenDropdown = false,
    this.search,
    this.initialValue, // Can be null, from controller.text, or manual string
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
          SizedBox(width: 16.rs(context)),
          Expanded(
            flex: 2,
            child: Obx(() {
              bool isLoading = false;
              switch (addressType) {
                case 'main':
                  isLoading = formController.isCitiesLoading.value;
                  break;
                case 'delivery':
                  isLoading = formController.isCitiesDeliveryLoading.value;
                  break;
                case 'delivery2':
                  isLoading = formController.isCitiesDelivery2Loading.value;
                  break;
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

              RxList<Map<String, dynamic>> citiesList;
              switch (addressType) {
                case 'main':
                  citiesList = formController.cities;
                  break;
                case 'delivery':
                  citiesList = formController.citiesDelivery;
                  break;
                case 'delivery2':
                  citiesList = formController.citiesDelivery2;
                  break;
                default:
                  citiesList = formController.cities;
              }

              String? currentProvinceId;
              switch (addressType) {
                case 'main':
                  currentProvinceId = formController.selectedProvinceId;
                  break;
                case 'delivery':
                  currentProvinceId = formController.selectedProvinceIdDelivery;
                  break;
                case 'delivery2':
                  currentProvinceId =
                      formController.selectedProvinceIdDelivery2;
                  break;
              }

              if (citiesList.isEmpty || currentProvinceId == null) {
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
                    if (currentProvinceId == null) {
                      Get.snackbar(
                        'Province Required',
                        'Please select a province first',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                );
              }

              // Return search dropdown or regular dropdown based on search parameter
              return (search ?? false)
                  ? _buildSearchDropdown(context, citiesList)
                  : _buildRegularDropdown(context, citiesList);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown(
      BuildContext context, RxList<Map<String, dynamic>> citiesList) {
    return SearchChoices.single(
      isExpanded: true,
      value: _getDropdownValue(citiesList),
      hint: Text(
        "Select a City",
        style: TextStyle(
          fontSize: ResponsiveUtil.scaleSize(context, 16),
        ),
      ),
      items: citiesList.map((city) {
        final apiValue = city["Text"].toString();
        final displayValue = apiValue;

        return DropdownMenuItem<String>(
          value: apiValue,
          child: Text(
            displayValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaleSize(context, 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        _handleCitySelection(value);
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

  Widget _buildRegularDropdown(
      BuildContext context, RxList<Map<String, dynamic>> citiesList) {
    return DropdownButtonFormField<String>(
      value: _getDropdownValue(citiesList),
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
      items: _buildDropdownItems(context, citiesList),
      onChanged: (value) {
        _handleCitySelection(value);
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

  String? _getDropdownValue(RxList<Map<String, dynamic>> citiesList) {
    // Priority 1: Use controller.text if it exists in cities list
    if (controller.text.isNotEmpty) {
      final controllerMatch = citiesList.firstWhereOrNull(
        (city) => city["Text"].toString() == controller.text,
      );
      if (controllerMatch != null) {
        return controller.text;
      }
    }

    // Priority 2: Use initialValue if provided and valid
    if (initialValue != null && initialValue!.isNotEmpty) {
      // Check if initialValue exists in the cities list
      final initialMatch = citiesList.firstWhereOrNull(
        (city) => city["Text"].toString() == initialValue,
      );
      if (initialMatch != null) {
        // Also update the controller to match the initial value if it's different
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.text != initialValue) {
            controller.text = initialValue!;
          }
        });
        return initialValue;
      }
    }

    // Priority 3: Use existing findBestCityMatch logic for fuzzy matching
    return _findBestCityMatch(citiesList);
  }

  void _handleCitySelection(String? value) {
    if (value != null) {
      final displayValue = value;

      // Update the city value
      formController.setCityValue(addressType,
          apiValue: value,
          displayValue: displayValue,
          updateController: true,
          fetchDistrictsAfter: true);

      // Only clear the district controller for the same address type
      TextEditingController? districtController;
      switch (addressType) {
        case 'main':
          districtController = formController.kecamatanController;
          break;
        case 'delivery':
          districtController = formController.kecamatanControllerDelivery.value;
          break;
        case 'delivery2':
          districtController =
              formController.kecamatanControllerDelivery2.value;
          break;
      }

      if (districtController != null) {
        districtController.clear();
      }

      // Use a more targeted update instead of updating the entire controller
      formController.update([addressType]);
    }
  }

  List<int> _searchCities(
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

  String? _findBestCityMatch(RxList<Map<String, dynamic>> citiesList) {
    if (controller.text.isEmpty || citiesList.isEmpty) return null;

    final currentText = controller.text;

    String? apiValue = formController.getCityApiValue(addressType);
    if (apiValue != null) {
      final exactApiMatch = citiesList
          .firstWhereOrNull((city) => city["Text"].toString() == apiValue);
      if (exactApiMatch != null) {
        return apiValue;
      }
    }

    for (var city in citiesList) {
      if ((city["Text"].toString()) == currentText) {
        return city["Text"].toString();
      }
    }

    final upperText = currentText.toUpperCase();
    for (var city in citiesList) {
      if ((city["Text"].toString()).toUpperCase() == upperText) {
        return city["Text"].toString();
      }
    }

    final normalizedText = currentText;
    for (var city in citiesList) {
      if ((city["Text"].toString()) == normalizedText) {
        return city["Text"].toString();
      }
    }

    for (var city in citiesList) {
      final normalizedCity = city["Text"].toString();
      if (normalizedCity.contains(normalizedText) ||
          normalizedText.contains(normalizedCity)) {
        return city["Text"].toString();
      }
    }

    final keywords = normalizedText.split(' ');
    for (var city in citiesList) {
      final normalizedCity = city["Text"].toString();
      for (var keyword in keywords) {
        if (keyword.length > 2 && normalizedCity.contains(keyword)) {
          return city["Text"].toString();
        }
      }
    }

    return null;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      BuildContext context, RxList<Map<String, dynamic>> citiesList) {
    return citiesList.map((city) {
      final apiValue = city["Text"].toString();
      final displayValue = apiValue;

      return DropdownMenuItem<String>(
        value: apiValue,
        child: Center(
          child: Text(
            displayValue,
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
