import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/list_status_controller_noo.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/list_status_detail.dart';

import 'package:intl/intl.dart';

class StatusPage extends StatelessWidget {
  final String? name;
  final String? so;
  final String? bu;

  const StatusPage({Key? key, this.name, this.so, this.bu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      init: StatusController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: colorNetral,
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(StatusController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Obx(() {
        if (controller.isLoading.value && controller.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.data.length,
                itemBuilder: (context, index) {
                  return _buildListItem(context, controller.data[index]);
                },
              ),
            ),
            // Only show Load More button if there's more data to load
            if (controller.hasMoreData.value)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.loadMoreData(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More'),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, StatusModel item) {
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
              _buildCustomerInfoRow(item),
              _buildDateStatusRow(item),
              _buildStatusInfo(item),
              _buildStatusItem(item),
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
                Get.to(() => StatusDetailView(
                      id: item.id,
                      bu: item.businessUnit,
                      so: item.salesOffice,
                      name: item.custName,
                      status: item.status,
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
                    // letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoRow(StatusModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Name : ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            item.custName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatusRow(StatusModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Date : ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            _formatDate(item.createdDate),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildStatusInfo(StatusModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "CustStatus : ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            item.custStatus,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(StatusModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Status : ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            item.status,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
