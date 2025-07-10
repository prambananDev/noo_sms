import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class PPPrincipalSelection extends StatelessWidget {
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPPrincipalSelection({
    Key? key,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => SearchChoices.single(
          clearSearchIcon:
              Icon(Icons.clear_all, size: dimensions.getIconSize(context)),
          padding: EdgeInsets.only(top: dimensions.getPadding(context) / 2),
          isExpanded: true,
          value: _getSelectedValue(),
          hint: Text(
            "Select Principal",
            style: TextStyle(fontSize: dimensions.getTextSize(context)),
          ),
          items: _buildDropdownItems(context),
          onChanged: _handleSelectionChange,
        ));
  }

  String? _getSelectedValue() {
    if (controller.selectedDataPrincipal.isEmpty) return null;
    final index = controller.selectedDataPrincipal[0];
    return controller.listDataPrincipal[index];
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(BuildContext context) {
    return controller.listDataPrincipal.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontSize: dimensions.getTextSize(context)),
        ),
      );
    }).toList();
  }

  void _handleSelectionChange(String? value) {
    if (value == null) return;

    final index = controller.listDataPrincipal.indexOf(value);
    controller.selectedDataPrincipal.clear();
    if (index >= 0) {
      controller.selectedDataPrincipal.add(index);
    }
  }
}
