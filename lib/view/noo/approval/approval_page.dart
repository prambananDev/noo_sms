import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/approval_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:noo_sms/view/noo/approval/approval_detail.dart';

class ApprovalPage extends StatelessWidget {
  final String? role;

  const ApprovalPage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApprovalController>(
      init: ApprovalController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: colorNetral,
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(ApprovalController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.page.value = 1;
        await controller.fetchApprovals();
      },
      child: Obx(() {
        if (controller.isLoading.value && controller.approvals.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 5)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  controller.isLoading.value &&
                  controller.approvals.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Data not available",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                  child: CircularProgressIndicator(
                color: colorAccent,
              ));
            },
          );
        }

        return ListView.builder(
          itemCount: controller.approvals.length,
          itemBuilder: (context, index) {
            return _buildListItem(context, controller.approvals[index]);
          },
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, ApprovalModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Name", item.custName),
              _buildInfoRow("Date", _formatDate(item.createdDate.toString())),
              _buildInfoRow("Salesman", item.salesman),
              _buildStatusRow("Status", item.status),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Get.to(() => ApprovalDetailPage(
                      id: item.id,
                      role: role,
                    ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Detail",
                  style: TextStyle(
                    color: colorNetral,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label : ",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value ?? '-',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label : ",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 16,
              color: _getStatusColor(value),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
