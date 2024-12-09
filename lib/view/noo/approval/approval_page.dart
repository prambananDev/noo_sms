import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/noo/approval_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:noo_sms/view/noo/approval/approval_detail.dart';

class ApprovalPage extends StatefulWidget {
  final String? name;
  final String? role;

  const ApprovalPage({Key? key, this.name, required this.role})
      : super(key: key);

  @override
  ApprovalPageState createState() => ApprovalPageState();
}

class ApprovalPageState extends State<ApprovalPage> {
  late final ApprovalController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(ApprovalController());
    controller.fetchApprovals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white60,
      title: const Text(
        "Pending Approval",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              widget.name ?? "",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value && controller.approvals.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async {
          controller.page.value = 1;
          await controller.fetchApprovals();
        },
        child: ListView.builder(
          itemCount: controller.approvals.length,
          itemBuilder: (context, index) {
            final approval = controller.approvals[index];
            return _buildApprovalCard(controller.approvals[index], index);
            // controller.approvals[index], index
          },
        ),
      );
    });
  }

  Widget _buildApprovalCard(ApprovalModel approval, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Customer Name", approval.custName),
            _buildInfoRow("Date", _formatDate(approval.createdDate.toString())),
            _buildInfoRow("Salesman", approval.salesman),
            _buildStatusBadge(approval.status),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildDetailsButton(approval),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailsButton(ApprovalModel approval) {
    return ElevatedButton.icon(
      onPressed: () {
        Get.to(ApprovalDetailPage(
          id: approval.id,
          role: widget.role,
        ));
      },
      icon: const Icon(Icons.visibility),
      label: const Text('View Details'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
