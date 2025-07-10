import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class PPQuantityFields extends StatelessWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPQuantityFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildQuantityField(
            context: context,
            controller: state.qtyFrom,
            label: 'Qty From',
          ),
        ),
        SizedBox(width: dimensions.getSpacing(context)),
        Expanded(
          flex: 2,
          child: _buildQuantityField(
            context: context,
            controller: state.qtyTo,
            label: 'Qty To',
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildUnitDropdown(context),
        ),
      ],
    );
  }

  Widget _buildQuantityField({
    required BuildContext context,
    required TextEditingController? controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: dimensions.getLabelSize(context),
          fontWeight: FontWeight.bold,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: dimensions.getPadding(context),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
      style: TextStyle(
        color: Colors.black87,
        fontSize: dimensions.getTextSize(context),
      ),
    );
  }

  Widget _buildUnitDropdown(BuildContext context) {
    return SearchChoices.single(
      underline: Container(),
      isExpanded: true,
      value: state.unitSupplyItem?.selectedChoice,
      hint: Text(
        "Unit",
        style: TextStyle(fontSize: dimensions.getTextSize(context)),
      ),
      items: state.unitSupplyItem?.choiceList?.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(fontSize: dimensions.getTextSize(context)),
          ),
        );
      }).toList(),
      onChanged: (value) => controller.changeUnitSupplyItem(index, value),
    );
  }
}
