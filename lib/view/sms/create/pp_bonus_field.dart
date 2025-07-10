import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class PPBonusFields extends StatelessWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPBonusFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shouldHide = controller.promotionTypeInputPageDropdownStateRx.value
              .selectedChoice?.value ==
          "Discount";

      if (shouldHide) return const SizedBox.shrink();

      return Column(
        children: [
          _buildBonusItemDropdown(context),
          dimensions.isMobileScreen(context)
              ? _buildVerticalQuantityFields(context)
              : _buildHorizontalQuantityFields(context),
        ],
      );
    });
  }

  Widget _buildBonusItemDropdown(BuildContext context) {
    return SearchChoices.single(
      isExpanded: true,
      value: state.supplyItem?.selectedChoice,
      hint: Text(
        "Bonus Item",
        style: TextStyle(fontSize: dimensions.getTextSize(context)),
      ),
      items: state.supplyItem?.choiceList?.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.value,
            style: TextStyle(fontSize: dimensions.getTextSize(context)),
            overflow: TextOverflow.fade,
          ),
        );
      }).toList(),
      onChanged: (value) => controller.changeSupplyItem(index, value),
    );
  }

  Widget _buildVerticalQuantityFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuantityField(context),
        SizedBox(height: dimensions.getSpacing(context) / 2),
        _buildUnitDropdown(context),
      ],
    );
  }

  Widget _buildHorizontalQuantityFields(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ResponsiveUtil.scaleSize(context, 50),
          child: _buildQuantityField(context),
        ),
        const Spacer(),
        SizedBox(
          width: ResponsiveUtil.scaleSize(context, 120),
          child: _buildUnitDropdown(context),
        ),
      ],
    );
  }

  Widget _buildQuantityField(BuildContext context) {
    return TextFormField(
      controller: state.qtyItem,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Qty Item',
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: dimensions.getLabelSize(context),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
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
      isExpanded: true,
      value: state.unitSupplyItem?.selectedChoice,
      hint: Text(
        "Unit Bonus Item",
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
