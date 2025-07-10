import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class PPCustomerFields extends StatefulWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPCustomerFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<PPCustomerFields> createState() => _PPCustomerFieldsState();
}

class _PPCustomerFieldsState extends State<PPCustomerFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomerGroupDropdown(),
        SizedBox(height: widget.dimensions.getSpacing(context)),
        _buildCustomerNameDropdown(),
      ],
    );
  }

  Widget _buildCustomerGroupDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      isDense: true,
      value: widget.state.customerGroupInputPageDropdownState?.selectedChoice,
      hint: Text(
        "Customer/Cust Group",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      items: widget.state.customerGroupInputPageDropdownState?.choiceList
          ?.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                      fontSize: widget.dimensions.getTextSize(context)),
                  overflow: TextOverflow.fade,
                ),
              ))
          .toList(),
      onChanged: (value) =>
          widget.controller.changeCustomerGroup(widget.index, value),
    );
  }

  Widget _buildCustomerNameDropdown() {
    return Obx(() => SearchChoices.single(
          isExpanded: true,
          padding:
              EdgeInsets.only(top: widget.dimensions.getPadding(context) / 2),
          value: widget.controller.custNameHeaderValueDropdownStateRx.value
              .selectedChoice,
          items: widget
              .controller.custNameHeaderValueDropdownStateRx.value.choiceList
              ?.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item.value,
                      style: TextStyle(
                          fontSize: widget.dimensions.getTextSize(context)),
                    ),
                  ))
              .toList(),
          hint: Text(
            "Select Customer",
            style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
          ),
          onChanged: (value) {
            setState(() {
              widget.controller.changeCustomerNameOrDiscountGroupHeader(value);
            });
          },
        ));
  }
}
