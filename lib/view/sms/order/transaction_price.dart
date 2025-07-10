import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_money_field.dart';

class TransactionPriceFields extends StatelessWidget {
  final PromotionProgramInputState state;
  final int index;
  final TransactionController controller;
  final PPDimensions dimensions;

  const TransactionPriceFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PPMoneyField(
          controller: state.priceTransaction,
          label: 'Price',
          dimensions: dimensions,
          onChanged: (value) => controller.changeQty(index, value),
        ),
        SizedBox(height: dimensions.getSpacing(context) / 2),
        PPPercentField(
          controller: state.discTransaction,
          label: 'Disc',
          dimensions: dimensions,
          onChanged: (value) => controller.changeDisc(index, value),
        ),
      ],
    );
  }
}
