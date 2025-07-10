import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class PPTextField extends StatelessWidget {
  final Rx<TextEditingController> controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final PPDimensions dimensions;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final String? prefix;
  final String? suffix;
  final int maxLines;

  const PPTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.dimensions,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixText: prefix,
            suffixText: suffix,
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: dimensions.getLabelSize(context),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorAccent),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: dimensions.getTextSize(context),
          ),
        ));
  }
}

class PPPromotionTypeDropdown extends StatelessWidget {
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPPromotionTypeDropdown({
    Key? key,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<IdAndValue<String>>(
          value: controller
              .promotionTypeInputPageDropdownStateRx.value.selectedChoice,
          hint: Text("Type",
              style: TextStyle(fontSize: dimensions.getTextSize(context))),
          items: controller
              .promotionTypeInputPageDropdownStateRx.value.choiceList
              ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                    value: item,
                    child: Text(
                      item.value,
                      style:
                          TextStyle(fontSize: dimensions.getTextSize(context)),
                    ),
                  ))
              .toList(),
          onChanged: (value) => controller.changePromotionType(value!),
        ));
  }
}
