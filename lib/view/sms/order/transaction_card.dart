import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_money_field.dart';
import 'package:search_choices/search_choices.dart';

class TransactionLineItemCard extends StatelessWidget {
  final int index;
  final TransactionController controller;
  final PPDimensions dimensions;

  const TransactionLineItemCard({
    Key? key,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller
          .promotionProgramInputStateRx.value.promotionProgramInputState[index];

      return Container(
        margin: EdgeInsets.only(bottom: dimensions.getSpacing(context) / 2),
        decoration: _buildCardDecoration(context),
        child: Padding(
          padding: EdgeInsets.all(dimensions.getPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: dimensions.getSpacing(context)),
              TransactionProductFields(
                state: state,
                index: index,
                controller: controller,
                dimensions: dimensions,
              ),
              SizedBox(height: dimensions.getSpacing(context)),
              TransactionQuantityFields(
                state: state,
                index: index,
                controller: controller,
                dimensions: dimensions,
              ),
              SizedBox(height: dimensions.getSpacing(context)),
              TransactionPriceFields(
                state: state,
                index: index,
                controller: controller,
                dimensions: dimensions,
              ),
              SizedBox(height: dimensions.getSpacing(context)),
              _buildTotal(context, state),
            ],
          ),
        ),
      );
    });
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
          onPressed: () => controller.addItem(),
          icon: Icon(Icons.add, size: dimensions.getIconSize(context)),
          tooltip: 'Add new line',
        ),
        IconButton(
          onPressed: () => controller.removeItem(index),
          icon: Icon(Icons.delete, size: dimensions.getIconSize(context)),
          tooltip: 'Delete this line',
        ),
      ],
    );
  }

  Widget _buildTotal(BuildContext context, PromotionProgramInputState state) {
    final totalText = state.totalTransaction?.value.text ?? '';
    final total =
        totalText.isEmpty ? 0.0 : double.parse(totalText.replaceAll(",", ""));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 1, color: Colors.grey.shade400),
        SizedBox(height: dimensions.getSpacing(context) / 2),
        Text(
          "Total",
          style: TextStyle(
            fontSize: dimensions.getLabelSize(context),
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          MoneyFormatter(amount: total).output.symbolOnLeft,
          style: TextStyle(
            fontSize: dimensions.getTextSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

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
