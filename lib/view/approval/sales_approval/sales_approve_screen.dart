import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/approval/sales_approval/sales_approve_controller.dart';
import 'package:noo_sms/models/sales_approve_models.dart';
import 'package:noo_sms/view/approval/sales_approval/sales_approve_detail_screen.dart';

class SalesApproveScreen extends StatelessWidget {
  final SalesApproveController controller = Get.put(SalesApproveController());

  SalesApproveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Sales Approve',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildPaginationInfo(context),
          Expanded(child: _buildSalesOrdersList(context)),
          _buildPaginationControls(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          hintText: 'Search sales order...',
          suffixIcon: IconButton(
            onPressed: controller.searchSalesOrders,
            icon: Icon(Icons.search, color: Colors.blue[700]),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => controller.searchSalesOrders(),
      ),
    );
  }

  Widget _buildPaginationInfo(BuildContext context) {
    return Obx(() => controller.filteredOrders.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${controller.filteredOrders.length} items found',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildSalesOrdersList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorWidget(context);
      }

      if (controller.filteredOrders.isEmpty) {
        return _buildEmptyWidget(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: controller.currentPageOrders.length,
        itemBuilder: (context, index) {
          final order = controller.currentPageOrders[index];
          return _buildSalesOrderCard(order, context);
        },
      );
    });
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshData,
            child: const Text('Retry', style: TextStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No sales orders found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Try refreshing or check back later',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOrderCard(SalesOrder order, BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => _navigateToDetail(order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(order),
            _buildCardContent(order),
            _buildCardFooter(order),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(SalesOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.salesId,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCardContent(SalesOrder order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.custNameAlias,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            '${order.custAccount} - ${order.custName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            order.processDesc,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          if (order.processDesc.contains('Credit'))
            ..._buildCreditContent(order),
          if (order.processDesc.contains('Overdue'))
            ..._buildOverdueContent(order),
          if (!order.processDesc.contains('Credit') &&
              !order.processDesc.contains('Overdue'))
            ..._buildRegularContent(order),
          const SizedBox(height: 5),
          _buildCardDetails(order),
        ],
      ),
    );
  }

  List<Widget> _buildCreditContent(SalesOrder order) {
    return [
      Text(
        'CR Limit: ${_formatCurrency(order.clAmt)}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 5),
      Text(
        'CR Limit Exc: ${_formatCurrency(order.creditExceedAmt)}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 5),
      Text(
        'Sales Amount: ${_formatCurrency(order.salesAmount)}',
        style: const TextStyle(fontSize: 14),
      ),
    ];
  }

  List<Widget> _buildOverdueContent(SalesOrder order) {
    return [
      Text(
        'Exceed AR Overdue: ${_formatCurrency(order.dueAmount)}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 5),
      Text(
        'Sales Amount: ${_formatCurrency(order.salesAmount)}',
        style: const TextStyle(fontSize: 14),
      ),
    ];
  }

  List<Widget> _buildRegularContent(SalesOrder order) {
    return [
      Text(
        'Sales Amount: ${_formatCurrency(order.salesAmount)}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 5),
      Text(
        'Sales Amount(Inc. PPn): ${_formatCurrency(order.salesAmountPpn)}',
        style: const TextStyle(fontSize: 14),
      ),
    ];
  }

  Widget _buildCardDetails(SalesOrder order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!order.processDesc.contains('Credit'))
          _buildDetailColumn('Days:', order.days.toString()),
        _buildDetailColumn('Sales Office:', order.salesOffice),
        _buildDetailColumn('TOP:', order.top),
        _buildDetailColumn('BU:', order.businessUnit),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(color: Colors.blue[700], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCardFooter(SalesOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.date,
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
          Text(
            order.statusName,
            style: TextStyle(color: Colors.blue[700], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 15),
        child: Center(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: controller.totalPages.value,
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              final isCurrentPage = controller.currentPage.value == pageNumber;

              return InkWell(
                onTap: () => controller.goToPage(pageNumber),
                child: Container(
                  width: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Card(
                    color: isCurrentPage ? Colors.blue[700] : Colors.grey[300],
                    elevation: 3,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(
                        pageNumber.toString(),
                        style: TextStyle(
                          color:
                              isCurrentPage ? Colors.white : Colors.blue[700],
                          fontWeight: isCurrentPage
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _navigateToDetail(SalesOrder order) async {
    final result = await Get.to(() => SalesApproveDetailScreen(order: order));
    if (result == true) {
      controller.refreshData();
    }
  }
}
