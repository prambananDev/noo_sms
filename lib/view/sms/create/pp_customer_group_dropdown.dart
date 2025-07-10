import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class PPCustomerGroupDropdown extends StatefulWidget {
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPCustomerGroupDropdown({
    Key? key,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<PPCustomerGroupDropdown> createState() =>
      _PPCustomerGroupDropdownState();
}

class _PPCustomerGroupDropdownState extends State<PPCustomerGroupDropdown> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          isExpanded: true,
          isDense: true,
          value: widget.controller.customerGroupInputPageDropdownState.value
              .selectedChoice,
          hint: Text(
            "Customer/Cust Group",
            style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
          ),
          items: _buildDropdownItems(context),
          onChanged: _handleSelectionChange,
        ));
  }

  List<DropdownMenuItem<String>>? _buildDropdownItems(BuildContext context) {
    return widget
        .controller.customerGroupInputPageDropdownState.value.choiceList
        ?.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style:
                    TextStyle(fontSize: widget.dimensions.getTextSize(context)),
                overflow: TextOverflow.fade,
              ),
            ))
        .toList();
  }

  void _handleSelectionChange(String? value) {
    if (value == null) return;

    setState(() {
      widget.controller.changeCustomerGroupHeader(value);
      // Delay to ensure state update
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() {});
      });
    });
  }
}
