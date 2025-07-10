import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/map_widget_order_track.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';
import 'package:noo_sms/models/order_tracking_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class OrderTrackingDetailPage extends StatefulWidget {
  const OrderTrackingDetailPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingDetailPage> createState() =>
      _OrderTrackingDetailPageState();
}

class _OrderTrackingDetailPageState extends State<OrderTrackingDetailPage> {
  final OrderTrackingController controller =
      Get.find<OrderTrackingController>();

  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('OrderTrackingDetailPage initState');

    // Only initialize once
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializeTrackingDetail();
    }
  }

  void _initializeTrackingDetail() {
    // Use a short delay to ensure the page is fully built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !controller.isLoadingTrackingDetail.value) {
        debugPrint('Initializing tracking detail from page');
        controller.loadTrackingDetail();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('OrderTrackingDetailPage dispose');
    controller.clearTrackingDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Order Tracking Detail",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorNetral,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: colorNetral,
            size: 35,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorAccent,
        actions: [
          Obx(() => IconButton(
                onPressed: controller.isLoadingTrackingDetail.value
                    ? null
                    : () => controller.refreshTrackingDetail(),
                icon: controller.isLoadingTrackingDetail.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colorNetral),
                        ),
                      )
                    : Icon(Icons.refresh, color: colorNetral),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshTrackingDetail(),
        child: Obx(() => _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    // Initial loading state
    if (controller.isLoadingTrackingDetail.value &&
        controller.trackingDetailData.isEmpty) {
      return _buildLoadingState();
    }

    // No data state
    if (controller.trackingDetailData.isEmpty) {
      return _buildNoDataState();
    }

    // Error state
    if (controller.hasTrackingError) {
      return _buildErrorState();
    }

    // Success state with data
    return _buildContentState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tracking details...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'No tracking data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh or tap the refresh button',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.loadTrackingDetail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to load tracking data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    controller.trackingErrorMessage,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshTrackingDetail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Refresh indicator when loading
          if (controller.isLoadingTrackingDetail.value)
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
                    'Refreshing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          _buildTrackingProgress(),
          const SizedBox(height: 24),
          _buildCurrentStatus(),
          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
          _buildDeliveryStatusList(),
          const SizedBox(height: 24),
          _buildDeliveryInfo(),
        ],
      ),
    );
  }

  Widget _buildTrackingProgress() {
    final deliveryStatus = controller.deliveryStatusList;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressCircle(
            isActive: deliveryStatus.isNotEmpty,
            icon: Icons.assignment,
          ),
          _buildProgressLine(isActive: deliveryStatus.isNotEmpty),
          _buildProgressCircle(
            isActive: deliveryStatus.isNotEmpty,
            icon: Icons.inventory,
          ),
          _buildProgressLine(isActive: deliveryStatus.length >= 2),
          _buildProgressCircle(
            isActive: deliveryStatus.length >= 2,
            icon: Icons.local_shipping,
          ),
          _buildProgressLine(isActive: deliveryStatus.length >= 5),
          _buildProgressCircle(
            isActive: controller.isDelivered,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(
      {required bool isActive, required IconData icon}) {
    return Expanded(
      child: CircleAvatar(
        backgroundColor: isActive ? colorAccent : Colors.grey[300],
        radius: 24,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Container(
      height: 2,
      width: 32,
      color: isActive ? colorAccent : Colors.grey[300],
    );
  }

  Widget _buildCurrentStatus() {
    return Text(
      controller.trackingStatus,
      style: TextStyle(
        color: colorAccent,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDeliveryStatusList() {
    final deliveryStatus = controller.deliveryStatusList;

    if (deliveryStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: deliveryStatus.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {
          final statusItem = deliveryStatus[index];
          return _buildStatusItem(statusItem);
        },
      ),
    );
  }

  Widget _buildStatusItem(TrackingDeliveryStatus statusItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIconData(statusItem.statusIcon),
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
                  statusItem.statusTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusItem.formattedDateTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (statusItem.hasDeliveryData) ...[
                  const SizedBox(height: 8),
                  _buildReceiverInfo(statusItem.data!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverInfo(TrackingDeliveryData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.hasReceiver) ...[
          Text(
            "Received by: ${data.displayReceiverName}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
        ],
        // Always show "View Receipt" button, even if no images
        InkWell(
          onTap: () => _showReceiptImage(data.images ?? []),
          child: Text(
            "View Receipt",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final driverInfo = controller.driverInfo;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: colorAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Delivery Info",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow("PO Number", controller.currentPoNum.value),
                _buildInfoRow(
                    "Expected Delivery", controller.expectedDeliveryDate),
                if (driverInfo != null) ...[
                  _buildInfoRow("Driver Name", driverInfo.displayName),
                  _buildInfoRow("Vehicle No", driverInfo.displayPlatNumber),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(""),
                    InkWell(
                      onTap: () => _openMap(),
                      child: Text(
                        "Track Location",
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white,
            colorAccent.withOpacity(0.1),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 40, left: 32, right: 16, bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Need help with\nyour delivery?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: colorAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text(
                      "WhatsApp Support",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIconData(TrackingStatusIcon statusIcon) {
    switch (statusIcon) {
      case TrackingStatusIcon.delivered:
        return Icons.check_circle;
      case TrackingStatusIcon.registered:
        return Icons.assignment;
      case TrackingStatusIcon.scheduled:
        return Icons.schedule;
      case TrackingStatusIcon.allocated:
      case TrackingStatusIcon.shipped:
      case TrackingStatusIcon.inTransit:
        return Icons.local_shipping;
      case TrackingStatusIcon.info:
      default:
        return Icons.info;
    }
  }

  void _showReceiptImage(List<String> images) {
    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Receipt'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: _buildReceiptContent(images),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptContent(List<String> images) {
    // Check if images list is empty or null
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No receipt image found for this delivery',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // If images exist, try to load the last (most recent) image
    return InteractiveViewer(
      child: Image.network(
        images.last,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading image...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Image not available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load receipt image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMap() {
    final location = controller.driverLocation;

    if (location != null) {
      Get.to(() => MapWidget(
            latitude: location['latitude']!,
            longitude: location['longitude']!,
          ));
    } else {
      Get.snackbar(
        'Error',
        'Location data not available',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  Future<void> _openWhatsApp() async {
    try {
      const link = WhatsAppUnilink(
        phoneNumber: '+62-85210000633',
        text: "I need help with my delivery!",
      );
      await launch('$link');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}
