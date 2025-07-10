import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class TransactionProductFields extends StatefulWidget {
  final PromotionProgramInputState state;
  final int index;
  final TransactionController controller;
  final PPDimensions dimensions;

  const TransactionProductFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<TransactionProductFields> createState() =>
      _TransactionProductFieldsState();
}

class _TransactionProductFieldsState extends State<TransactionProductFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProductDropdown(),
        _buildUnitDropdown(),
      ],
    );
  }

  Widget _buildProductDropdown() {
    return SearchChoices.single(
      isExpanded: true,
      value: widget.state.productTransactionPageDropdownState
          ?.selectedChoiceWrapper?.value,
      items: widget
          .state.productTransactionPageDropdownState?.choiceListWrapper?.value
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
        "Select Product",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      onChanged: (value) {
        setState(() {
          widget.controller.changeProduct(widget.index, value);
        });
      },
    );
  }

  Widget _buildUnitDropdown() {
    return SearchChoices.single(
      isExpanded: true,
      value: widget.state.unitPageDropdownState?.selectedChoice,
      items: widget.state.unitPageDropdownState?.choiceList
          ?.map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                      fontSize: widget.dimensions.getTextSize(context)),
                ),
              ))
          .toList(),
      hint: Text(
        "Select Unit",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      onChanged: (value) {
        setState(() {
          widget.controller.changeUnit(widget.index, value);
        });
      },
    );
  }
}
