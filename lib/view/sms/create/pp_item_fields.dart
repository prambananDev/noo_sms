import 'package:flutter/material.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:search_choices/search_choices.dart';

class PPItemFields extends StatefulWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPItemFields({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<PPItemFields> createState() => _PPItemFieldsState();
}

class _PPItemFieldsState extends State<PPItemFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemGroupDropdown(),
        SizedBox(height: widget.dimensions.getSpacing(context) / 2),
        _buildProductDropdown(),
        _buildWarehouseDropdown(),
      ],
    );
  }

  Widget _buildItemGroupDropdown() {
    return DropdownButton<String>(
      hint: Text(
        "Select Item Group",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      isExpanded: true,
      value: widget.state.itemGroupInputPageDropdownState?.selectedChoice,
      items: widget.state.itemGroupInputPageDropdownState?.choiceList
          ?.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            widget.controller.changeItemGroup(widget.index, newValue);
          });
        }
      },
    );
  }

  Widget _buildProductDropdown() {
    return SearchChoices.single(
      isExpanded: true,
      value: widget.state.supplyItem?.selectedChoice,
      items: widget.state.supplyItem?.choiceList?.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.value,
            style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
          ),
        );
      }).toList(),
      hint: Text(
        "Select Product",
        style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
      ),
      onChanged: (value) {
        widget.controller.changeSupplyItem(widget.index, value);
      },
    );
  }

  Widget _buildWarehouseDropdown() {
    return SearchChoices.single(
      isExpanded: true,
      value: widget
              .state.wareHousePageDropdownState?.selectedChoiceWrapper?.value ??
          "WHS - Tunas - Buffer",
      hint: Text(
        "WHS - Tunas - Buffer",
        style: TextStyle(
          fontSize: widget.dimensions.getTextSize(context),
          fontWeight: FontWeight.w500,
        ),
      ),
      items: widget.state.wareHousePageDropdownState?.choiceListWrapper?.value
          ?.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.value,
            style: TextStyle(fontSize: widget.dimensions.getTextSize(context)),
            overflow: TextOverflow.fade,
          ),
        );
      }).toList(),
      onChanged: (value) =>
          widget.controller.changeWarehouse(widget.index, value),
    );
  }
}
