import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/promotion_program/order/history_so_controller.dart';
import 'package:noo_sms/view/sms/approval/empty_screen.dart';
import 'package:noo_sms/view/sms/approval/sales_order_adp.dart';

class HistorySO extends StatelessWidget {
  final int idEmp;
  final String namePP;
  final String idProduct;
  final String idCustomer;

  const HistorySO({
    Key? key,
    required this.idEmp,
    required this.namePP,
    required this.idProduct,
    required this.idCustomer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      HistorySOController()..updateIds(idProduct, idCustomer, idEmp, namePP),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List Sales Order',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colorNetral,
              ),
            ),
            Obx(() {
              final productInfo = controller.productName.value;
              if (productInfo.isNotEmpty) {
                return Text(
                  productInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorNetral.withOpacity(0.8),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: colorNetral,
            size: 35,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading sales orders...'),
                ],
              ),
            );
          }

          if (controller.salesOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.refreshData,
              child: EmptyStateWidget(
                onRefresh: () => controller.refreshData(),
                productId: idProduct,
                customerId: idCustomer,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.salesOrders.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = controller.salesOrders[index];
                return SalesOrderAdapter(
                  models: item,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
