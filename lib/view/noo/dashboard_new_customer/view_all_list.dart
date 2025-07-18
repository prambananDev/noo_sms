import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/view_all_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';
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
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ViewAllController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      strokeWidth: 2.5.rs(context),
      child: Obx(() {
        if (controller.isLoading.value && controller.data.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 5)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  controller.isLoading.value &&
                  controller.data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.ri(context),
                        color: Colors.red,
                      ),
                      SizedBox(height: 8.rs(context)),
                      Text(
                        "Data not available",
                        style: TextStyle(fontSize: 16.rt(context)),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3.rs(context),
                ),
              );
            },
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.isIPad(context) ? 24.rp(context) : 0,
            vertical: 8.rp(context),
          ),
          itemCount:
              controller.data.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.data.length &&
                controller.hasMoreData.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
                child: Center(
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(
                          strokeWidth: 3.rs(context),
                        )
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
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.rp(context),
                              vertical: 8.rp(context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8.rr(context)),
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.rs(context),
                              ),
                            ),
                            child: Text(
                              "Load More",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.rt(context),
                              ),
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
      margin: EdgeInsets.symmetric(
          horizontal: 16.rp(context), vertical: 8.rp(context)),
      padding: EdgeInsets.all(
          ResponsiveUtil.isIPad(context) ? 16.rp(context) : 12.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
            offset: Offset(0, 2.rs(context)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfoRow(context, item),
              _buildDateStatusRow(context, item),
              _buildStatusInfo(context, item),
              _buildStatusItem(context, item),
              SizedBox(
                height: ResponsiveUtil.isIPad(context)
                    ? MediaQuery.of(context).size.height * 0.08
                    : MediaQuery.of(context).size.height * 0.075,
              ),
            ],
          ),
          Positioned(
            bottom: 10.rp(context),
            right: 10.rp(context),
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
                  borderRadius: BorderRadius.circular(12.rr(context)),
                  boxShadow: [
                    BoxShadow(
                      color: colorAccent.withOpacity(0.3),
                      blurRadius: 4.rs(context),
                      offset: Offset(0, 2.rs(context)),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 16.rp(context),
                    vertical: ResponsiveUtil.isIPad(context)
                        ? 8.rp(context)
                        : 6.rp(context)),
                child: Text(
                  "Detail",
                  style: TextStyle(
                    color: colorNetral,
                    fontSize: 16.rt(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoRow(BuildContext context, NOOModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 2 : 1,
            child: Text(
              "Name : ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 3 : 2,
            child: Text(
              item.custName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatusRow(BuildContext context, NOOModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 2 : 1,
            child: Text(
              "Date : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 3 : 2,
            child: Text(
              _formatDate(item.createdDate),
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
              ),
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

  Widget _buildStatusInfo(BuildContext context, NOOModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 2 : 1,
            child: Text(
              "CustStatus : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 3 : 2,
            child: Text(
              item.custStatus,
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, NOOModel item) {
    Color statusColor;
    switch (item.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 2 : 1,
            child: Text(
              "Status : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 3 : 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.rp(context),
                vertical: 4.rp(context),
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.rr(context)),
                border: Border.all(
                  color: statusColor.withOpacity(0.5),
                  width: 1.rs(context),
                ),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.rt(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
