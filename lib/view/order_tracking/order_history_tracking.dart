import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  final String? custId;
  const OrderHistoryPage({Key? key, this.custId}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final OrderTrackingController controller = Get.put(OrderTrackingController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? custId = widget.custId;

      if (custId == null) {
        final arguments = Get.arguments as Map<String, dynamic>?;
        custId = arguments?['custId']?.toString();
      }

      controller.loadOrderHistoryForPage(custId: custId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text(
            "Order History",
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: colorAccent,
          actions: [
            IconButton(
              onPressed: () {
                String? custId = widget.custId;
                if (custId == null) {
                  final arguments = Get.arguments as Map<String, dynamic>?;
                  custId = arguments?['custId']?.toString();
                }
                controller.loadOrderHistoryForPage(custId: custId);
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: controller.orderHistorySearchController,
                  cursorColor: colorAccent,
                  onChanged: (value) {
                    controller.onOrderHistorySearchChanged(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorAccent,
                      size: 20,
                    ),
                    hintText: 'Search PO Number...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        )));
  }

  Widget _buildContent() {
    if (controller.isLoadingOrderHistory.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading order history...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.orderHistoryData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                controller.orderHistorySearchController.text.isNotEmpty
                    ? 'No results found'
                    : 'No order history found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.orderHistorySearchController.text.isNotEmpty
                    ? 'Try searching with a different PO number'
                    : 'Your order history will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.orderHistorySearchController.text.isNotEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.clearOrderHistorySearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear Search'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.orderHistoryData.length,
      itemBuilder: (context, index) {
        final orderData = controller.orderHistoryData[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              childrenPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: colorAccent,
                  size: 24,
                ),
              ),
              title: Text(
                orderData.displayPONum,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusChip(
                          orderData.displayOrderStatus,
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          orderData.displayPaymStatus,
                          orderData.isPaid ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp. ${MoneyFormatter(amount: orderData.totalPrice).output.withoutFractionDigits}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorAccent,
                      ),
                    ),
                  ],
                ),
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetails(orderData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(orderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        _buildInfoGrid([
          _buildInfoItem(
            icon: Icons.assignment,
            label: "SO Number",
            value: orderData.displaySalesId,
          ),
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: "Order Date",
            value: orderData.formattedOrderDate,
          ),
          _buildInfoItem(
            icon: Icons.description,
            label: "Invoice Number",
            value: orderData.displayInvoice.isEmpty
                ? "Not available"
                : orderData.displayInvoice,
          ),
          _buildInfoItem(
            icon: Icons.event,
            label: "Invoice Date",
            value: orderData.formattedInvoiceDate,
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString(
                "getSalesId",
                orderData.displaySalesId,
              );
              Get.toNamed('/delivery-detail');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping,
                  color: colorAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Track Delivery",
                  style: TextStyle(
                    color: colorAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Items (${orderData.lines.length})",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (orderData.lines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox,
                  color: Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  "No items in this order",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: orderData.lines.asMap().entries.map<Widget>((entry) {
              final lineItem = entry.value;
              final isLast = entry.key == orderData.lines.length - 1;

              return Container(
                padding: const EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.shopping_basket,
                        color: colorAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lineItem.displayItem,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lineItem.displayQtyWithUnit,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Rp. ${MoneyFormatter(amount: lineItem.price).output.withoutFractionDigits}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (lineItem.disc > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Discount: ${MoneyFormatter(amount: lineItem.disc).output.withoutFractionDigits} (${lineItem.discType})",
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildInfoGrid(List<Widget> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: items[i]),
                if (i + 1 < items.length) ...[
                  const SizedBox(width: 16),
                  Expanded(child: items[i + 1]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
