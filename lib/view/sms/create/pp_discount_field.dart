import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_value_based_discount.dart';

class PPDiscountFields extends StatefulWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPDiscountFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<PPDiscountFields> createState() => _PPDiscountFieldsState();
}

class _PPDiscountFieldsState extends State<PPDiscountFields> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shouldHide = widget.controller.promotionTypeInputPageDropdownStateRx
              .value.selectedChoice?.value ==
          "Bonus";

      if (shouldHide) return const SizedBox.shrink();

      return Column(
        children: [
          _buildDiscountTypeDropdown(),
          SizedBox(height: widget.dimensions.getSpacing(context)),
          _buildDiscountContent(),
        ],
      );
    });
  }

  Widget _buildDiscountTypeDropdown() {
    return DropdownButtonFormField<IdAndValue<String>>(
      value: widget.state.percentValueInputPageDropdownState?.selectedChoice,
      hint: Text(
        "Disc Type (percent/value)",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      items: widget.state.percentValueInputPageDropdownState?.choiceList
          ?.map((item) => DropdownMenuItem<IdAndValue<String>>(
                value: item,
                child: Text(
                  item.value,
                  style: TextStyle(
                      fontSize: widget.dimensions.getTextSize(context)),
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          widget.controller.changePercentValue(widget.index, value);
        }
      },
    );
  }

  Widget _buildDiscountContent() {
    final isValueBased =
        widget.state.percentValueInputPageDropdownState?.selectedChoice ==
            widget.state.percentValueInputPageDropdownState?.choiceList?[1];

    return isValueBased
        ? PPValueBasedDiscount(
            state: widget.state,
            index: widget.index,
            controller: widget.controller,
            dimensions: widget.dimensions,
          )
        : PPPercentageBasedDiscount(
            state: widget.state,
            index: widget.index,
            controller: widget.controller,
            dimensions: widget.dimensions,
          );
  }
}
