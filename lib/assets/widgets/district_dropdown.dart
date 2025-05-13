import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';

class DistrictDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final CustomerFormController formController;
  final String? validationText;
  final String addressType;

  const DistrictDropdownField({
    Key? key,
    required this.label,
    required this.controller,
    required this.formController,
    this.validationText,
    this.addressType = 'main',
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
              bool isLoading = formController.isDistrictsDeliveryLoading.value;
              if (isLoading) {
                return Container(
                  height: ResponsiveUtil.scaleSize(context, 48),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtil.scaleSize(context, 4)),
                  ),
                  child: Center(
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(colorAccent),
                    ),
                  ),
                );
              }
              switch (addressType) {
                case 'main':
                  isLoading = formController.isDistrictsLoading.value;
                  break;
                case 'delivery':
                  isLoading = formController.isDistrictsDeliveryLoading.value;
                  break;
                case 'delivery2':
                  isLoading = formController.isDistrictsDelivery2Loading.value;
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

              RxList<Map<String, dynamic>> districtsList =
                  formController.districtsDelivery;
              switch (addressType) {
                case 'main':
                  districtsList = formController.districts;
                  break;
                case 'delivery':
                  districtsList = formController.districtsDelivery;
                  break;
                case 'delivery2':
                  districtsList = formController.districtsDelivery2;
                  break;
                default:
                  districtsList = formController.districts;
              }

              String? currentCityId = formController.selectedCityIdDelivery;
              switch (addressType) {
                case 'main':
                  currentCityId = formController.selectedCityId;
                  break;
                case 'delivery':
                  currentCityId = formController.selectedCityIdDelivery;
                  break;
                case 'delivery2':
                  currentCityId = formController.selectedCityIdDelivery2;
                  break;
              }

              if (districtsList.isEmpty || currentCityId == null) {
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
                      fontSize: ResponsiveUtil.scaleSize(context, 14),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  readOnly: true,
                  onTap: () {
                    if (currentCityId == null) {
                      Get.snackbar(
                        'City Required',
                        'Please select a city first',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                );
              }

              return DropdownButtonFormField<String>(
                value: _findBestDistrictMatch(districtsList),
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
                items: _buildDropdownItems(context, districtsList),
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value;
                    formController.setDistrictValue(addressType, value);
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

  String? _findBestDistrictMatch(RxList<Map<String, dynamic>> districtsList) {
    if (controller.text.isEmpty || districtsList.isEmpty) return null;

    String? storedValue = formController.getDistrictValue(addressType);
    if (storedValue != null) {
      final exactMatch = districtsList.firstWhereOrNull(
          (district) => district["Text"].toString() == storedValue);
      if (exactMatch != null) {
        return storedValue;
      }
    }

    final currentText = controller.text;
    final exactMatch = districtsList.firstWhereOrNull(
        (district) => district["Text"].toString() == currentText);
    if (exactMatch != null) {
      return exactMatch["Text"].toString();
    }

    final upperText = currentText.toUpperCase();
    for (var district in districtsList) {
      if (district["Text"].toString().toUpperCase() == upperText) {
        return district["Text"].toString();
      }
    }

    for (var district in districtsList) {
      final districtName = district["Text"].toString().toUpperCase();
      if (districtName.contains(upperText) ||
          upperText.contains(districtName)) {
        return district["Text"].toString();
      }
    }

    final keywords = upperText.split(' ');
    for (var district in districtsList) {
      final districtName = district["Text"].toString().toUpperCase();
      for (var keyword in keywords) {
        if (keyword.length > 2 && districtName.contains(keyword)) {
          return district["Text"].toString();
        }
      }
    }

    return null;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      BuildContext context, RxList<Map<String, dynamic>> districtsList) {
    return districtsList.map((district) {
      final value = district["Text"].toString();

      return DropdownMenuItem<String>(
        value: value,
        child: Center(
          child: Text(
            value,
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
