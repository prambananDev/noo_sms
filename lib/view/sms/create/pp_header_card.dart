import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_customer_group_dropdown.dart';
import 'package:noo_sms/view/sms/create/pp_date_picker.dart';
import 'package:noo_sms/view/sms/create/pp_from_field.dart';
import 'package:noo_sms/view/sms/create/pp_note_field.dart';
import 'package:noo_sms/view/sms/create/pp_principal_selection.dart';

class PPHeaderCard extends StatelessWidget {
  final InputPageController controller;
  final PPDimensions dimensions;
  final FocusNode noteFocusNode;
  final bool isNoteTapped;
  final ValueChanged<bool> onNoteTapChanged;

  const PPHeaderCard({
    Key? key,
    required this.controller,
    required this.dimensions,
    required this.noteFocusNode,
    required this.isNoteTapped,
    required this.onNoteTapChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(dimensions.getPadding(context)),
      decoration: _buildCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: dimensions.getSpacing(context)),
          PPTextField(
            controller: controller.programNameTextEditingControllerRx,
            label: 'Program Name',
            onChanged: (_) => controller.checkAddItemStatus(),
            dimensions: dimensions,
          ),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          PPPromotionTypeDropdown(
            controller: controller,
            dimensions: dimensions,
          ),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          PPCustomerGroupDropdown(
            controller: controller,
            dimensions: dimensions,
          ),
          PPPrincipalSelection(
            controller: controller,
            dimensions: dimensions,
          ),
          PPDateRangePicker(
            fromController: controller.programFromDateTextEditingControllerRx,
            toController: controller.programToDateTextEditingControllerRx,
            dimensions: dimensions,
          ),
          PPNoteField(
            controller: controller.programNoteTextEditingControllerRx,
            focusNode: noteFocusNode,
            isExpanded: isNoteTapped,
            onTapChanged: onNoteTapChanged,
            dimensions: dimensions,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(dimensions.getBorderRadius(context)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create",
          style: TextStyle(
            fontSize: dimensions.getHeadingSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Setup a trade agreement",
          style: TextStyle(
            fontSize: dimensions.getTextSize(context),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
