import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';

class CityDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final String? validationText;
  final String addressType;
  final bool autoOpenDropdown;

  const CityDropdownField({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    this.validationText,
    this.addressType = 'main',
    this.autoOpenDropdown = false,
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

              return DropdownButtonFormField<String>(
                value: _findBestCityMatch(citiesList),
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
                ),
                items: _buildDropdownItems(context, citiesList),
                onChanged: (value) {
                  if (value != null) {
                    final displayValue = (value);

                    TextEditingController? districtController;
                    switch (addressType) {
                      case 'main':
                        districtController = formController.kecamatanController;
                        break;
                      case 'delivery':
                        districtController =
                            formController.kecamatanControllerDelivery.value;
                        break;
                      case 'delivery2':
                        districtController =
                            formController.kecamatanControllerDelivery2.value;
                        break;
                    }

                    formController.setCityValue(addressType,
                        apiValue: value,
                        displayValue: displayValue,
                        updateController: true,
                        fetchDistrictsAfter: true);

                    if (districtController != null) {
                      districtController.clear();
                    }

                    formController.update();
                  }
                },
                validator: (value) {
                  if (validationText != null &&
                      (value == null || value.isEmpty)) {
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
            }),
          ),
        ],
      ),
    );
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

    final normalizedText = (currentText);
    for (var city in citiesList) {
      if ((city["Text"].toString()) == normalizedText) {
        return city["Text"].toString();
      }
    }

    for (var city in citiesList) {
      final normalizedCity = (city["Text"].toString());
      if (normalizedCity.contains(normalizedText) ||
          normalizedText.contains(normalizedCity)) {
        return city["Text"].toString();
      }
    }

    final keywords = normalizedText.split(' ');
    for (var city in citiesList) {
      final normalizedCity = (city["Text"].toString());
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
