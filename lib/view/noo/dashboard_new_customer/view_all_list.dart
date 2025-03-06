import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/view_all_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/list_status_detail.dart';

import 'package:intl/intl.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/view_all_list_detail.dart';

class ViewAllListPage extends StatelessWidget {
  final String? name;
  final String? so;
  final String? bu;

  const ViewAllListPage({Key? key, this.name, this.so, this.bu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewAllController>(
      init: ViewAllController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: colorNetral,
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(ViewAllController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Obx(() {
        if (controller.isLoading.value && controller.data.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 5)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  controller.isLoading.value &&
                  controller.data.isEmpty) {
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

              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount:
              controller.data.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.data.length &&
                controller.hasMoreData.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: () {
                            controller.loadMoreData();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (controller.scrollController.hasClients) {
                                controller.scrollController.animateTo(
                                  controller.scrollController.position
                                      .maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                          child: const Text(
                            "Load More",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              );
            }
            return _buildListItem(context, controller.data[index]);
          },
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, NOOModel item) {
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
                Get.to(() => ViewAllListDetail(
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

  Widget _buildCustomerInfoRow(NOOModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Name : ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            item.custName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatusRow(NOOModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Date : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            _formatDate(item.createdDate),
            style: const TextStyle(
              fontSize: 16,
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

  Widget _buildStatusInfo(NOOModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "CustStatus : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            item.custStatus,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(NOOModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Status : ",
              style: TextStyle(
                fontSize: 16,
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
