import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/order/create_order_controller.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/order/transaction_card.dart';
import 'package:noo_sms/view/sms/order/transaction_header_card.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionController _controller = Get.put(TransactionController());
  late final PPDimensions _dimensions;

  @override
  void initState() {
    super.initState();
    _dimensions = PPDimensions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(_dimensions.getPadding(context)),
          child: Column(
            children: [
              TransactionHeaderCard(
                controller: _controller,
                dimensions: _dimensions,
              ),
              SizedBox(height: _dimensions.getSpacing(context) / 2),
              _buildLineItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItems() {
    return Obx(() {
      final state = _controller.promotionProgramInputStateRx.value;

      if (state.promotionProgramInputState.isEmpty) {
        return _buildAddButton();
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.promotionProgramInputState.length,
        itemBuilder: (context, index) => Column(
          children: [
            TransactionLineItemCard(
              index: index,
              controller: _controller,
              dimensions: _dimensions,
            ),
            if (index == state.promotionProgramInputState.length - 1)
              _buildSubmitButton(),
          ],
        ),
      );
    });
  }

  Widget _buildAddButton() {
    return Obx(() {
      final isEnabled =
          _controller.promotionProgramInputStateRx.value.isAddItem;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorAccent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(_dimensions.getBorderRadius(context) / 2),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _dimensions.getPadding(context) * 2,
            vertical: _dimensions.getPadding(context),
          ),
        ),
        onPressed: isEnabled ? () => _controller.addItem() : null,
        child: Text(
          "Add Data Transaction",
          style: TextStyle(
            color: Colors.white,
            fontSize: _dimensions.getTextSize(context),
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(top: _dimensions.getSpacing(context)),
      child: Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  _dimensions.getBorderRadius(context) / 2,
                ),
              ),
            ),
            onPressed: () => _controller.submitPromotionProgram(),
            child: Text(
              "Submit",
              style: TextStyle(
                color: colorNetral,
                fontSize: _dimensions.getTextSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
    );
  }
}
