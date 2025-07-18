import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/order/transaction_history_order_controller.dart';
import 'package:noo_sms/models/transaction_history.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';

class HistoryOrder extends StatelessWidget {
  const HistoryOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryOrderController());
    final dimensions = PPDimensions();

    return Scaffold(
      backgroundColor: colorNetral,
      body: SafeArea(
        child: _buildBody(context, controller, dimensions),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HistoryOrderController controller,
    PPDimensions dimensions,
  ) {
    return Obx(() {
      if (controller.transactionHistory.isEmpty) {
        return _buildEmptyState(context, dimensions);
      }

      return ListView.builder(
        padding: EdgeInsets.all(dimensions.getPadding(context)),
        itemCount: controller.transactionHistory.length,
        itemBuilder: (context, index) => OrderHistoryCard(
          transaction: controller.transactionHistory[index],
          dimensions: dimensions,
          onTap: () =>
              _showOrderDetails(context, controller, dimensions, index),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, PPDimensions dimensions) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: dimensions.getIconSize(context) * 3,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: dimensions.getSpacing(context)),
          Text(
            'No transaction history',
            style: TextStyle(
              fontSize: dimensions.getTextSize(context),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    HistoryOrderController controller,
    PPDimensions dimensions,
    int index,
  ) {
    Get.bottomSheet(
      OrderDetailsBottomSheet(
        transaction: controller.transactionHistory[index],
        dimensions: dimensions,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(dimensions.getBorderRadius(context)),
        ),
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final TransactionHistory transaction;
  final PPDimensions dimensions;
  final VoidCallback onTap;

  const OrderHistoryCard({
    Key? key,
    required this.transaction,
    required this.dimensions,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: dimensions.getSpacing(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(dimensions.getBorderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(dimensions.getBorderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(dimensions.getPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfo(context),
              SizedBox(height: dimensions.getSpacing(context) / 2),
              _buildDateInfo(context),
              SizedBox(height: dimensions.getSpacing(context) / 2),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          radius: dimensions.getIconSize(context),
          child: Text(
            (transaction.customerName ?? 'U')[0].toUpperCase(),
            style: TextStyle(
              fontSize: dimensions.getTextSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
        SizedBox(width: dimensions.getSpacing(context) / 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.customerName ?? 'Unknown Customer',
                style: TextStyle(
                  fontSize: dimensions.getTextSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    final date = transaction.date != null
        ? DateFormat('dd MMM yyyy, HH:mm')
            .format(DateTime.parse(transaction.date!))
        : 'No date';

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: dimensions.getIconSize(context) * 0.8,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: dimensions.getSpacing(context) / 4),
        Text(
          date,
          style: TextStyle(
            fontSize: dimensions.getLabelSize(context),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final itemCount = transaction.transactionLines?.length ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.getPadding(context) / 2,
            vertical: dimensions.getPadding(context) / 4,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius:
                BorderRadius.circular(dimensions.getBorderRadius(context) / 2),
          ),
          child: Text(
            '$itemCount items',
            style: TextStyle(
              fontSize: dimensions.getLabelSize(context),
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: dimensions.getIconSize(context) * 0.8,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }
}

class OrderDetailsBottomSheet extends StatelessWidget {
  final TransactionHistory transaction;
  final PPDimensions dimensions;

  const OrderDetailsBottomSheet({
    Key? key,
    required this.transaction,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(dimensions.getPadding(context)),
              itemCount: transaction.transactionLines?.length ?? 0,
              itemBuilder: (context, index) => OrderDetailItemCard(
                line: transaction.transactionLines![index],
                dimensions: dimensions,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: dimensions.getPadding(context) / 2),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(dimensions.getPadding(context)),
      child: Column(
        children: [
          Text(
            'Order Details',
            style: TextStyle(
              fontSize: dimensions.getHeadingSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: dimensions.getSpacing(context) / 2),
          Text(
            transaction.customerName ?? 'Unknown Customer',
            style: TextStyle(
              fontSize: dimensions.getTextSize(context),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailItemCard extends StatelessWidget {
  final TransactionLines line;
  final PPDimensions dimensions;

  const OrderDetailItemCard({
    Key? key,
    required this.line,
    required this.dimensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: dimensions.getSpacing(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(dimensions.getBorderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(dimensions.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(context),
            SizedBox(height: dimensions.getSpacing(context) / 2),
            _buildDetailsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line.productName ?? 'Unknown Product',
          style: TextStyle(
            fontSize: dimensions.getTextSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (line.productId != null)
          Text(
            'ID: ${line.productId}',
            style: TextStyle(
              fontSize: dimensions.getLabelSize(context),
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(context, 'Unit', line.unit ?? '-'),
        _buildDetailRow(context, 'Quantity', '${line.qty ?? 0}'),
        _buildDetailRow(
            context, 'Price', _formatCurrency((line.price ?? 0.0).toDouble())),
        if (line.disc != null && line.disc! > 0)
          _buildDetailRow(context, 'Discount', '${line.disc}%'),
        Divider(height: dimensions.getSpacing(context)),
        _buildDetailRow(
          context,
          'Total',
          _formatCurrency(_parseTotal(line.totalPrice)),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: dimensions.getPadding(context) / 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: dimensions.getLabelSize(context),
              color: isTotal ? Colors.black : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: dimensions.getTextSize(context),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  double _parseTotal(dynamic totalPrice) {
    if (totalPrice == null) return 0;
    final cleanedString = totalPrice.toString().replaceAll(RegExp(r'[.,]'), '');
    return double.tryParse(cleanedString) ?? 0;
  }
}
