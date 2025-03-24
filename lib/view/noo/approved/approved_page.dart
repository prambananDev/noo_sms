import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/approved_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:noo_sms/view/noo/approved/approved_detail.dart';

class ApprovedView extends StatefulWidget {
  const ApprovedView({Key? key}) : super(key: key);

  @override
  ApprovedViewState createState() => ApprovedViewState();
}

class ApprovedViewState extends State<ApprovedView> {
  late final ApprovedController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(ApprovedController());
    controller.fetchData();
    controller.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (controller.scrollController.position.pixels ==
        controller.scrollController.position.maxScrollExtent) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          controller.page.value = 1;
          await controller.refreshData();
        },
        child: ListView.builder(
          itemCount: controller.approvals.length,
          itemBuilder: (context, index) {
            return _buildApprovalCard(controller.approvals[index], index);
          },
        ),
        // child: Stack(
        //   children: [
        //     ListView.builder(
        //       controller: controller.scrollController,
        //       itemCount: controller.data.length + 1,
        //       itemBuilder: (context, index) {
        //         if (index < controller.data.length) {
        //           return _ApprovedCard(
        //             data: controller.data[index],
        //             onTapDetail: () => controller.navigateToDetail(
        //               controller.data[index]["id"],
        //             ),
        //           );
        //         } else if (controller.hasMoreData.value) {
        //           return const Padding(
        //             padding: EdgeInsets.all(16.0),
        //             child: Center(child: CircularProgressIndicator()),
        //           );
        //         } else {
        //           return const SizedBox.shrink();
        //         }
        //       },
        //     ),
        //     if (controller.isLoading.value && controller.data.isEmpty)
        //       const Center(child: CircularProgressIndicator()),
        //   ],
        // ),
      );
    });
  }

  Widget _buildApprovalCard(ApprovalModel approval, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              _buildInfoRow("Customer Name", approval.custName),
              _buildInfoRow(
                  "Date", _formatDate(approval.createdDate.toString())),
              _buildStatusRow("Status", approval.status),
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
                Get.to(
                  ApprovalDetailView(
                    id: approval.id,
                  ),
                );
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
            flex: 2,
            child: Text(
              "$label : ",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
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
            flex: 2, // Adjust flex values as needed
            child: Text(
              "$label : ",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 16,
                color: _getStatusColor(value),
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow
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
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
