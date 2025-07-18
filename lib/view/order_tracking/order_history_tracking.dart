import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
          centerTitle: true,
          backgroundColor: colorAccent,
          elevation: 0,
          toolbarHeight: 56.rs(context),
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 35.ri(context),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            "Order History",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.rt(context),
              color: Colors.white,
            ),
          ),
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
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 22.ri(context),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.rp(context)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.rr(context)),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: controller.orderHistorySearchController,
                  cursorColor: colorAccent,
                  style: TextStyle(fontSize: 16.rt(context)),
                  onChanged: (value) {
                    controller.onOrderHistorySearchChanged(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorAccent,
                      size: 20.ri(context),
                    ),
                    hintText: 'Search PO Number...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.rt(context),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.rp(context),
                      vertical: 12.rp(context),
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
            SizedBox(height: 16.rs(context)),
            Text(
              'Loading order history...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.rt(context),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.orderHistoryData.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.rp(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.rp(context)),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 48.ri(context),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24.rs(context)),
              Text(
                controller.orderHistorySearchController.text.isNotEmpty
                    ? 'No results found'
                    : 'No order history found',
                style: TextStyle(
                  fontSize: 18.rt(context),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.rs(context)),
              Text(
                controller.orderHistorySearchController.text.isNotEmpty
                    ? 'Try searching with a different PO number'
                    : 'Your order history will appear here',
                style: TextStyle(
                  fontSize: 14.rt(context),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.orderHistorySearchController.text.isNotEmpty) ...[
                SizedBox(height: 24.rs(context)),
                ElevatedButton.icon(
                  onPressed: () => controller.clearOrderHistorySearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.rp(context),
                      vertical: 12.rp(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.rr(context)),
                    ),
                  ),
                  icon: Icon(Icons.clear, size: 18.ri(context)),
                  label: Text(
                    'Clear Search',
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.rp(context)),
      itemCount: controller.orderHistoryData.length,
      itemBuilder: (context, index) {
        final orderData = controller.orderHistoryData[index];

        return Container(
          margin: EdgeInsets.only(bottom: 16.rs(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.rr(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8.rs(context),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.rr(context)),
            child: ExpansionTile(
              tilePadding: EdgeInsets.all(16.rp(context)),
              childrenPadding: EdgeInsets.only(
                left: 16.rp(context),
                right: 16.rp(context),
                bottom: 16.rp(context),
              ),
              leading: Container(
                width: 48.rs(context),
                height: 48.rs(context),
                decoration: BoxDecoration(
                  color: colorAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.rr(context)),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: colorAccent,
                  size: 24.ri(context),
                ),
              ),
              title: Text(
                orderData.displayPONum,
                style: TextStyle(
                  fontSize: 16.rt(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 8.rs(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusChip(
                          context,
                          orderData.displayOrderStatus,
                          Colors.blue,
                        ),
                        SizedBox(width: 8.rp(context)),
                        _buildStatusChip(
                          context,
                          orderData.displayPaymStatus,
                          orderData.isPaid ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.rs(context)),
                    Text(
                      "Rp. ${MoneyFormatter(amount: orderData.totalPrice).output.withoutFractionDigits}",
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.w700,
                        color: colorAccent,
                      ),
                    ),
                  ],
                ),
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetails(context, orderData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.rp(context),
        vertical: 4.rp(context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.rr(context)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.rt(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, orderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 24.rs(context)),
        _buildInfoGrid(context, [
          _buildInfoItem(
            context,
            icon: Icons.assignment,
            label: "SO Number",
            value: orderData.displaySalesId,
          ),
          _buildInfoItem(
            context,
            icon: Icons.calendar_today,
            label: "Order Date",
            value: orderData.formattedOrderDate,
          ),
          _buildInfoItem(
            context,
            icon: Icons.description,
            label: "Invoice Number",
            value: orderData.displayInvoice.isEmpty
                ? "Not available"
                : orderData.displayInvoice,
          ),
          _buildInfoItem(
            context,
            icon: Icons.event,
            label: "Invoice Date",
            value: orderData.formattedInvoiceDate,
          ),
        ]),
        SizedBox(height: 16.rs(context)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.rp(context)),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.rr(context)),
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
                  size: 20.ri(context),
                ),
                SizedBox(width: 8.rp(context)),
                Text(
                  "Track Delivery",
                  style: TextStyle(
                    color: colorAccent,
                    fontSize: 14.rt(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.rs(context)),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Colors.grey[600],
              size: 18.ri(context),
            ),
            SizedBox(width: 8.rp(context)),
            Text(
              "Items (${orderData.lines.length})",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.rt(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.rs(context)),
        if (orderData.lines.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.rp(context)),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.rr(context)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox,
                  color: Colors.grey[400],
                  size: 32.ri(context),
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  "No items in this order",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.rt(context),
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
                padding: EdgeInsets.all(12.rp(context)),
                margin: EdgeInsets.only(bottom: isLast ? 0 : 8.rs(context)),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.rr(context)),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.rs(context),
                      height: 40.rs(context),
                      decoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.rr(context)),
                      ),
                      child: Icon(
                        Icons.shopping_basket,
                        color: colorAccent,
                        size: 20.ri(context),
                      ),
                    ),
                    SizedBox(width: 12.rp(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lineItem.displayItem,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.rt(context),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.rs(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lineItem.displayQtyWithUnit,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.rt(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Rp. ${MoneyFormatter(amount: lineItem.price).output.withoutFractionDigits}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12.rt(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (lineItem.disc > 0) ...[
                            SizedBox(height: 4.rs(context)),
                            Text(
                              "Discount: ${MoneyFormatter(amount: lineItem.disc).output.withoutFractionDigits} (${lineItem.discType})",
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 11.rt(context),
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

  Widget _buildInfoGrid(BuildContext context, List<Widget> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 8.rs(context)),
            child: Row(
              children: [
                Expanded(child: items[i]),
                if (i + 1 < items.length) ...[
                  SizedBox(width: 16.rp(context)),
                  Expanded(child: items[i + 1]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.rp(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.rr(context)),
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
                size: 16.ri(context),
              ),
              SizedBox(width: 6.rp(context)),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11.rt(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.rs(context)),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.rt(context),
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
