import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white60,
      title: const Text(
        "Pending Approved",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
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
            _buildStatusBadge(approval.status),
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
        Get.to(
          ApprovalDetailView(
            id: approval.id,
          ),
        );
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

class _ApprovedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTapDetail;

  const _ApprovedCard({
    Key? key,
    required this.data,
    required this.onTapDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoItem("Name", data["CustName"]),
        _buildInfoItem("Date", data["CreatedDate"]),
        _buildInfoItem("Status", data["Status"] ?? ""),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(6),
      alignment: Alignment.centerLeft,
      child: Text(
        "$label : $value",
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: label == "Status" ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: onTapDetail,
          child: Container(
            height: 30,
            child: const Text(
              "Detail",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
