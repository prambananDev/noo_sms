import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class TransactionQuantityFields extends StatelessWidget {
  final PromotionProgramInputState state;
  final int index;
  final TransactionController controller;
  final PPDimensions dimensions;

  const TransactionQuantityFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: state.qtyTransaction,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) => controller.changeQty(index, value),
      decoration: InputDecoration(
        labelText: 'Qty',
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
}
