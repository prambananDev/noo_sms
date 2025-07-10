import 'package:flutter/material.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/create/pp_money_field.dart';

class PPValueBasedDiscount extends StatelessWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPValueBasedDiscount({
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
        _buildPriceFields(context),
        _buildValueFields(context),
      ],
    );
  }

  Widget _buildPriceFields(BuildContext context) {
    return PPResponsiveRow(
      dimensions: dimensions,
      spacing: dimensions.getSpacing(context),
      children: [
        PPMoneyField(
          controller: state.salesPrice,
          label: 'Sales Price',
          dimensions: dimensions,
          readOnly: false,
        ),
        PPMoneyField(
          controller: state.priceToCustomer,
          label: 'Price to Customer',
          dimensions: dimensions,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildValueFields(BuildContext context) {
    return PPResponsiveRow(
      dimensions: dimensions,
      spacing: dimensions.getSpacing(context),
      children: [
        PPMoneyField(
          controller: state.value1,
          label: 'Value(PRB)',
          dimensions: dimensions,
          onChanged: (_) => controller.getPriceToCustomer(index),
        ),
        PPMoneyField(
          controller: state.value2,
          label: 'Value(Principal)',
          dimensions: dimensions,
          onChanged: (_) => controller.getPriceToCustomer(index),
        ),
      ],
    );
  }
}

class PPPercentageBasedDiscount extends StatefulWidget {
  final PromotionProgramInputState state;
  final int index;
  final InputPageController controller;
  final PPDimensions dimensions;

  const PPPercentageBasedDiscount({
    Key? key,
    required this.state,
    required this.index,
    required this.controller,
    required this.dimensions,
  }) : super(key: key);

  @override
  State<PPPercentageBasedDiscount> createState() =>
      _PPPercentageBasedDiscountState();
}

class _PPPercentageBasedDiscountState extends State<PPPercentageBasedDiscount> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPriceFields(context),
        _buildPercentFields(context),
      ],
    );
  }

  Widget _buildPriceFields(BuildContext context) {
    return PPResponsiveRow(
      dimensions: widget.dimensions,
      spacing: widget.dimensions.getSpacing(context),
      children: [
        PPMoneyField(
          controller: widget.state.salesPrice,
          label: 'Sales Price',
          dimensions: widget.dimensions,
        ),
        PPMoneyField(
          controller: widget.state.priceToCustomer,
          label: 'Price to Customer',
          dimensions: widget.dimensions,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildPercentFields(BuildContext context) {
    final isMobile = widget.dimensions.isMobileScreen(context);

    if (isMobile) {
      return Column(
        children: [
          PPPercentField(
            controller: widget.state.percent1,
            label: 'Disc-1 (%) Prb',
            dimensions: widget.dimensions,
            onChanged: (_) => _updatePrice(),
          ),
          SizedBox(height: widget.dimensions.getSpacing(context)),
          PPPercentField(
            controller: widget.state.percent2,
            label: 'Disc-2 (%) COD',
            dimensions: widget.dimensions,
            onChanged: (_) => _updatePrice(),
          ),
          SizedBox(height: widget.dimensions.getSpacing(context) / 2),
          PPPercentField(
            controller: widget.state.percent3,
            label: 'Disc-3 (%) Principal',
            dimensions: widget.dimensions,
            onChanged: (_) => _updatePrice(),
          ),
          SizedBox(height: widget.dimensions.getSpacing(context) / 2),
          PPPercentField(
            controller: widget.state.percent4,
            label: 'Disc-4 (%) Principal',
            dimensions: widget.dimensions,
            onChanged: (_) => _updatePrice(),
          ),
        ],
      );
    }

    return Column(
      children: [
        PPResponsiveRow(
          dimensions: widget.dimensions,
          spacing: widget.dimensions.getSpacing(context),
          children: [
            PPPercentField(
              controller: widget.state.percent1,
              label: 'Disc-1 (%) Prb',
              dimensions: widget.dimensions,
              onChanged: (_) => _updatePrice(),
            ),
            PPPercentField(
              controller: widget.state.percent2,
              label: 'Disc-2 (%) COD',
              dimensions: widget.dimensions,
              onChanged: (_) => _updatePrice(),
            ),
          ],
        ),
        PPResponsiveRow(
          dimensions: widget.dimensions,
          spacing: widget.dimensions.getSpacing(context),
          children: [
            PPPercentField(
              controller: widget.state.percent3,
              label: 'Disc-3 (%) Principal',
              dimensions: widget.dimensions,
              onChanged: (_) => _updatePrice(),
            ),
            PPPercentField(
              controller: widget.state.percent4,
              label: 'Disc-4 (%) Principal',
              dimensions: widget.dimensions,
              onChanged: (_) => _updatePrice(),
            ),
          ],
        ),
      ],
    );
  }

  void _updatePrice() {
    setState(() {
      widget.controller.getPriceToCustomer(widget.index);
    });
  }
}
