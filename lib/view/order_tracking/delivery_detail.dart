import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDetailPage extends StatefulWidget {
  const DeliveryDetailPage({Key? key}) : super(key: key);

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  final OrderTrackingController controller =
      Get.find<OrderTrackingController>();

  int _retryCount = 0;
  bool _isAutoRetrying = false;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();

    _loadFreshDeliveryDetail();
  }

  void _loadFreshDeliveryDetail() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        setState(() {
          _retryCount = 0;
          _isAutoRetrying = false;
        });

        await _forceClearAndReload();

        await _attemptLoadWithRetry();
      }
    });
  }

  Future<void> _forceClearAndReload() async {
    try {
      controller.deliveryDetailData.clear();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? salesId = prefs.getString("getSalesId");

      if (salesId != null) {
        controller.refreshDeliveryDetail(salesId: salesId);
      }
    } catch (e) {}
  }

  Future<void> _attemptLoadWithRetry() async {
    try {
      await _forceRefreshData();

      if (controller.deliveryDetailData.isEmpty &&
          !controller.isLoadingDeliveryDetail.value &&
          _retryCount < _maxRetries) {
        if (mounted) {
          setState(() {
            _retryCount++;
            _isAutoRetrying = true;
          });
        }

        debugPrint(
            'Load returned empty, auto-retry $_retryCount/$_maxRetries...');

        int delaySeconds = (1 << (_retryCount - 1));
        await Future.delayed(Duration(seconds: delaySeconds));

        if (mounted) {
          await _attemptLoadWithRetry();
        }
      } else {
        if (mounted) {
          setState(() {
            _isAutoRetrying = false;
          });
        }
      }
    } catch (e) {
      if (_retryCount < _maxRetries) {
        if (mounted) {
          setState(() {
            _retryCount++;
            _isAutoRetrying = true;
          });
        }

        int delaySeconds = (1 << (_retryCount - 1));
        await Future.delayed(Duration(seconds: delaySeconds));

        if (mounted) {
          await _attemptLoadWithRetry();
        }
      } else {
        if (mounted) {
          setState(() {
            _isAutoRetrying = false;
          });
        }
      }
    }
  }

  Future<void> _forceRefreshData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? salesId = prefs.getString("getSalesId");

      if (salesId != null && salesId.isNotEmpty) {
        await controller.refreshDeliveryDetail(salesId: salesId);
      } else {
        await controller.loadDeliveryDetailFromPrefs();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
          "Delivery Detail",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.rt(context),
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorAccent,
        elevation: 0,
        toolbarHeight: 56.rs(context),
        actions: [
          Obx(() => IconButton(
                onPressed:
                    controller.isLoadingDeliveryDetail.value || _isAutoRetrying
                        ? null
                        : () => _handleManualRefresh(),
                icon: (controller.isLoadingDeliveryDetail.value ||
                        _isAutoRetrying)
                    ? SizedBox(
                        width: 20.rs(context),
                        height: 20.rs(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.rs(context),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 22.ri(context),
                      ),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleManualRefresh(),
        child: Obx(() => _buildContent()),
      ),
    );
  }

  Future<void> _handleManualRefresh() async {
    setState(() {
      _retryCount = 0;
      _isAutoRetrying = false;
    });

    await _forceClearAndReload();
  }

  Widget _buildContent() {
    if (controller.isLoadingDeliveryDetail.value || _isAutoRetrying) {
      return _buildLoadingState();
    }

    if (controller.deliveryDetailData.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDeliveryList();
  }

  Widget _buildLoadingState() {
    String loadingMessage = 'Loading delivery details...';

    if (_isAutoRetrying) {
      loadingMessage = 'Auto-retry $_retryCount/$_maxRetries...';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
          ),
          SizedBox(height: 16.rs(context)),
          Text(
            loadingMessage,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.rt(context),
            ),
          ),
          SizedBox(height: 8.rs(context)),
          Text(
            'Sales ID: ${controller.currentSalesId.value}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.rt(context),
            ),
          ),
          if (_isAutoRetrying) ...[
            SizedBox(height: 16.rs(context)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.rp(context),
                vertical: 8.rp(context),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.rr(context)),
              ),
              child: Text(
                'Automatically retrying to get fresh data...',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12.rt(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        padding: EdgeInsets.all(32.rp(context)),
        child: Center(
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
                  Icons.local_shipping,
                  size: 48.ri(context),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24.rs(context)),
              Text(
                'No delivery data available',
                style: TextStyle(
                  fontSize: 18.rt(context),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.rs(context)),
              Text(
                'Sales ID: ${controller.currentSalesId.value.isNotEmpty ? controller.currentSalesId.value : 'Not set'}',
                style: TextStyle(
                  fontSize: 12.rt(context),
                  color: Colors.grey[500],
                ),
              ),
              if (_retryCount > 0) ...[
                SizedBox(height: 8.rs(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.rp(context),
                    vertical: 6.rp(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.rr(context)),
                  ),
                  child: Text(
                    'Attempted $_retryCount automatic retries',
                    style: TextStyle(
                      fontSize: 11.rt(context),
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 8.rs(context)),
              Text(
                'Please check back later or contact support',
                style: TextStyle(
                  fontSize: 14.rt(context),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.rs(context)),
              ElevatedButton.icon(
                onPressed: () => _handleManualRefresh(),
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
                icon: Icon(Icons.refresh, size: 18.ri(context)),
                label: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryList() {
    return Column(
      children: [
        if (controller.isLoadingDeliveryDetail.value || _isAutoRetrying)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
            color: colorAccent.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.rs(context),
                  height: 16.rs(context),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.rs(context),
                    valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                  ),
                ),
                SizedBox(width: 8.rp(context)),
                Text(
                  _isAutoRetrying ? 'Auto-retrying...' : 'Refreshing...',
                  style: TextStyle(
                    fontSize: 12.rt(context),
                    color: colorAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (controller.currentSalesId.value.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.rp(context)),
            color: Colors.blue.withOpacity(0.1),
            child: Text(
              'Sales ID: ${controller.currentSalesId.value} | Items: ${controller.deliveryDetailData.length}',
              style: TextStyle(
                fontSize: 10.rt(context),
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.rp(context)),
            itemCount: controller.deliveryDetailData.length,
            itemBuilder: (context, index) {
              final deliveryData = controller.deliveryDetailData[index];

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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.rr(context)),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: Colors.orange,
                        size: 24.ri(context),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${deliveryData.displayPlId} • ${deliveryData.displayPoNum}",
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.rs(context)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.rp(context),
                            vertical: 4.rp(context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.rr(context)),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            deliveryData.formattedDate,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12.rt(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8.rs(context)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Colors.grey[600],
                            size: 16.ri(context),
                          ),
                          SizedBox(width: 4.rp(context)),
                          Text(
                            "${deliveryData.itemCount} Items",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.rt(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliveryDetails(context, deliveryData),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDetails(BuildContext context, deliveryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 24.rs(context)),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Colors.grey[600],
              size: 18.ri(context),
            ),
            SizedBox(width: 8.rp(context)),
            Text(
              "Items in this delivery",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.rt(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.rs(context)),
        if (deliveryData.lines.isEmpty)
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
                  "No items in this delivery",
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
            children: deliveryData.lines.asMap().entries.map<Widget>((entry) {
              final lineItem = entry.value;
              final isLast = entry.key == deliveryData.lines.length - 1;

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
                      width: 32.rs(context),
                      height: 32.rs(context),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.rr(context)),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18.ri(context),
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
                          SizedBox(height: 4.rs(context)),
                          Text(
                            lineItem.displayQtyWithUnit,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.rt(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 16.rs(context)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.navigateToTrackingDetail(
                plId: deliveryData.plId,
                poNum: deliveryData.poNum,
                salesId: controller.currentSalesId.value,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.rp(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.rr(context)),
              ),
            ),
            icon: Icon(Icons.gps_fixed, size: 18.ri(context)),
            label: Text(
              "View Tracking Detail",
              style: TextStyle(
                fontSize: 14.rt(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
