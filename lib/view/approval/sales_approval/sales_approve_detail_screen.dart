import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/approval/sales_approval/sales_approve_controller.dart';
import 'package:noo_sms/models/sales_approve_models.dart';

class SalesApproveDetailScreen extends StatelessWidget {
  final SalesOrder order;
  final SalesApproveController controller = Get.find<SalesApproveController>();

  SalesApproveDetailScreen({Key? key, required this.order}) : super(key: key) {
    controller.selectOrder(order);
    controller.fetchOrderDetail(order.recId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Detail Sales Approve',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(context);
        }

        return Column(
          children: [
            Expanded(child: _buildDetailContent(context)),
            _buildActionButtons(context),
          ],
        );
      }),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchOrderDetail(order.recId),
            child: const Text('Retry', style: TextStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final detail = controller.orderDetail.value;
    if (detail == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      children: [
        _buildDetailTile('Sales Order', detail.salesId),
        _buildDetailTile('Process', detail.processDesc),
        _buildDetailTile('Customer', detail.customerName),
        _buildDetailTile('Alias', detail.custNameAlias),
        _buildDetailTile('Credit Limit', _formatCurrency(detail.creditMax)),
        _buildDetailTile(
            'Exceed Cr Lmt', _formatCurrency(detail.creditExceedAmt)),
        _buildDetailTile('Exceed AR OD', _formatCurrency(detail.dueAmount)),
        _buildDetailTile('Sales Amount', _formatCurrency(detail.salesAmount)),
        _buildDetailTile(
            'Sales Amount (Inc PPn)', _formatCurrency(detail.salesAmountPpn)),
        _buildDetailTile('Days', detail.days.toString()),
        _buildDetailTile('Business Unit', detail.businessUnit),
        _buildDetailTile('Sales Office', detail.salesOffice),
        _buildDetailTile('Reference', detail.customerRef),
        _buildDetailTile('TOP', detail.paymentTermId),
        _buildDetailTile('Segment', detail.segment),
        if (detail.userComments.isNotEmpty)
          _buildDetailTile('Comment', detail.userComments),
      ],
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[700]!),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleApprove(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Reject Sales Approval',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller.rejectMessageController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason...',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await controller.rejectOrder(
                  order.recId,
                  order.salesId,
                  controller.rejectMessageController.text,
                );
                if (success) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleApprove(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Approval',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to approve this sales order?',
            style: TextStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Approve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await controller.approveOrder(order.recId, order.salesId);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
