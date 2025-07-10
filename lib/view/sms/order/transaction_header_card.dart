import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_from_field.dart';
import 'package:search_choices/search_choices.dart';

class TransactionHeaderCard extends StatelessWidget {
  final TransactionController controller;
  final PPDimensions dimensions;

  const TransactionHeaderCard({
    Key? key,
    required this.controller,
    required this.dimensions,
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
          _buildCustomerDropdown(context),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          PPTextField(
            controller: controller.transactionNumberTextEditingControllerRx,
            label: 'Transaction Number',
            dimensions: dimensions,
            onChanged: (_) => controller.checkAddItemStatus(),
          ),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          _buildDateField(context),
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
          "New Order Taking",
          style: TextStyle(
            fontSize: dimensions.getTextSize(context),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDropdown(BuildContext context) {
    return Obx(() => SearchChoices.single(
          isExpanded: true,
          value: controller
              .customerNameInputPageDropdownStateRx.value.selectedChoice,
          hint: Text(
            "Customer Name",
            style: TextStyle(fontSize: dimensions.getTextSize(context)),
          ),
          items: controller
              .customerNameInputPageDropdownStateRx.value.choiceList
              ?.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item.value,
                      style:
                          TextStyle(fontSize: dimensions.getTextSize(context)),
                    ),
                  ))
              .toList(),
          onChanged: (value) => controller.changeSelectCustomer2(value),
        ));
  }

  Widget _buildDateField(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.transactionDateTextEditingControllerRx.value,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Transaction Date',
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: dimensions.getLabelSize(context),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorAccent),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: dimensions.getTextSize(context),
          ),
        ));
  }
}
