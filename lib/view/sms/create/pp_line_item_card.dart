// File: widgets/pp_line_item_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_bonus_field.dart';
import 'package:noo_sms/view/sms/create/pp_customer_fields.dart';
import 'package:noo_sms/view/sms/create/pp_discount_field.dart';
import 'package:noo_sms/view/sms/create/pp_item_fields.dart';
import 'package:noo_sms/view/sms/create/pp_qty_field.dart';

class PPLineItemCard extends StatelessWidget {
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;
  final VoidCallback onAddItem;
  final ValueChanged<int> onDeleteItem;
  final bool isLastItem;

  const PPLineItemCard({
    Key? key,
    required this.index,
    required this.controller,
    required this.dimensions,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.isLastItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildCard(context),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          if (isLastItem) _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Obx(() {
      final state = controller
          .promotionProgramInputStateRx.value.promotionProgramInputState[index];

      return Container(
        margin: EdgeInsets.only(top: dimensions.getSpacing(context) / 2),
        padding: EdgeInsets.all(dimensions.getPadding(context)),
        decoration: _buildCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: dimensions.getSpacing(context)),
            PPCustomerFields(
              state: state,
              index: index,
              controller: controller,
              dimensions: dimensions,
            ),
            SizedBox(height: dimensions.getSpacing(context)),
            PPItemFields(
              state: state,
              index: index,
              controller: controller,
              dimensions: dimensions,
            ),
            PPQuantityFields(
              state: state,
              index: index,
              controller: controller,
              dimensions: dimensions,
            ),
            SizedBox(height: dimensions.getSpacing(context)),
            PPDiscountFields(
              state: state,
              index: index,
              controller: controller,
              dimensions: dimensions,
            ),
            SizedBox(height: dimensions.getSpacing(context)),
            PPBonusFields(
              state: state,
              index: index,
              controller: controller,
              dimensions: dimensions,
            ),
          ],
        ),
      );
    });
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: colorNetral,
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
    return Row(
      children: [
        Text(
          "Add Lines",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: dimensions.getTextSize(context),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onAddItem,
          icon: Icon(Icons.add, size: dimensions.getIconSize(context)),
          tooltip: 'Add new line',
        ),
        IconButton(
          onPressed: () => onDeleteItem(index),
          icon: Icon(Icons.delete, size: dimensions.getIconSize(context)),
          tooltip: 'Delete this line',
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtil.scaleSize(context, 500),
      ),
      child: Obx(() => controller.onTap.value
          ? const Center(child: CircularProgressIndicator())
          : _buildSubmitButtonContent(context)),
    );
  }

  Widget _buildSubmitButtonContent(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorAccent,
        minimumSize: Size(
          double.infinity,
          ResponsiveUtil.scaleSize(context, 50),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(dimensions.getBorderRadius(context) / 2),
        ),
      ),
      onPressed: () => controller.submitPromotionProgram(context),
      child: Text(
        "Submit",
        style: TextStyle(
          color: colorNetral,
          fontSize: dimensions.getTextSize(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
