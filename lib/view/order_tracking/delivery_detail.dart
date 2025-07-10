import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          "Delivery Detail",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorAccent,
        actions: [
          Obx(() => IconButton(
                onPressed:
                    controller.isLoadingDeliveryDetail.value || _isAutoRetrying
                        ? null
                        : () => _handleManualRefresh(),
                icon: (controller.isLoadingDeliveryDetail.value ||
                        _isAutoRetrying)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 22),
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
          const SizedBox(height: 16),
          Text(
            loadingMessage,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sales ID: ${controller.currentSalesId.value}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (_isAutoRetrying) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Automatically retrying to get fresh data...',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
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
        padding: const EdgeInsets.all(32),
        child: Center(
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
                  Icons.local_shipping,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No delivery data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sales ID: ${controller.currentSalesId.value.isNotEmpty ? controller.currentSalesId.value : 'Not set'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (_retryCount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Attempted $_retryCount automatic retries',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Please check back later or contact support',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _handleManualRefresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: colorAccent.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isAutoRetrying ? 'Auto-retrying...' : 'Refreshing...',
                  style: TextStyle(
                    fontSize: 12,
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
            padding: const EdgeInsets.all(8),
            color: Colors.blue.withOpacity(0.1),
            child: Text(
              'Sales ID: ${controller.currentSalesId.value} | Items: ${controller.deliveryDetailData.length}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.deliveryDetailData.length,
            itemBuilder: (context, index) {
              final deliveryData = controller.deliveryDetailData[index];

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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${deliveryData.displayPlId} • ${deliveryData.displayPoNum}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            deliveryData.formattedDate,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${deliveryData.itemCount} Items",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliveryDetails(deliveryData),
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

  Widget _buildDeliveryDetails(deliveryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Items in this delivery",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (deliveryData.lines.isEmpty)
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
                  "No items in this delivery",
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
            children: deliveryData.lines.asMap().entries.map<Widget>((entry) {
              final lineItem = entry.value;
              final isLast = entry.key == deliveryData.lines.length - 1;

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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
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
                          const SizedBox(height: 4),
                          Text(
                            lineItem.displayQtyWithUnit,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
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
        const SizedBox(height: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.gps_fixed, size: 18),
            label: const Text(
              "View Tracking Detail",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
