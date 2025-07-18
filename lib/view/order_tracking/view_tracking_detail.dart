import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/map_widget_order_track.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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

    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializeTrackingDetail();
    }
  }

  void _initializeTrackingDetail() {
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
            fontSize: 16.rt(context),
            color: colorNetral,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: colorNetral,
            size: 35.ri(context),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        backgroundColor: colorAccent,
        elevation: 0,
        toolbarHeight: 56.rs(context),
        actions: [
          Obx(() => IconButton(
                onPressed: controller.isLoadingTrackingDetail.value
                    ? null
                    : () => controller.refreshTrackingDetail(),
                icon: controller.isLoadingTrackingDetail.value
                    ? SizedBox(
                        width: 20.rs(context),
                        height: 20.rs(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.rs(context),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colorNetral),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: colorNetral,
                        size: 24.ri(context),
                      ),
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
    if (controller.isLoadingTrackingDetail.value &&
        controller.trackingDetailData.isEmpty) {
      return _buildLoadingState();
    }

    if (controller.trackingDetailData.isEmpty) {
      return _buildNoDataState();
    }

    if (controller.hasTrackingError) {
      return _buildErrorState();
    }

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
          SizedBox(height: 16.rs(context)),
          Text(
            'Loading tracking details...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.rt(context),
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
            padding: EdgeInsets.all(32.rp(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.ri(context),
                  color: Colors.grey[400],
                ),
                SizedBox(height: 24.rs(context)),
                Text(
                  'No tracking data available',
                  style: TextStyle(
                    fontSize: 18.rt(context),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  'Pull down to refresh or tap the refresh button',
                  style: TextStyle(
                    fontSize: 14.rt(context),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.rs(context)),
                ElevatedButton.icon(
                  onPressed: () => controller.loadTrackingDetail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.rp(context),
                      vertical: 12.rp(context),
                    ),
                  ),
                  icon: Icon(Icons.refresh, size: 20.ri(context)),
                  label: Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
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
            padding: EdgeInsets.all(32.rp(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.ri(context),
                  color: Colors.red[400],
                ),
                SizedBox(height: 24.rs(context)),
                Text(
                  'Failed to load tracking data',
                  style: TextStyle(
                    fontSize: 18.rt(context),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.rs(context)),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.rp(context)),
                  padding: EdgeInsets.all(16.rp(context)),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.rr(context)),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    controller.trackingErrorMessage,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14.rt(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.rs(context)),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshTrackingDetail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.rp(context),
                      vertical: 12.rp(context),
                    ),
                  ),
                  icon: Icon(Icons.refresh, size: 20.ri(context)),
                  label: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
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
          if (controller.isLoadingTrackingDetail.value)
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
                    'Refreshing...',
                    style: TextStyle(
                      fontSize: 12.rt(context),
                      color: colorAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          _buildTrackingProgress(),
          SizedBox(height: 24.rs(context)),
          _buildCurrentStatus(),
          SizedBox(height: 16.rs(context)),
          Divider(thickness: 1.rs(context)),
          SizedBox(height: 16.rs(context)),
          _buildDeliveryStatusList(),
          SizedBox(height: 24.rs(context)),
          _buildDeliveryInfo(),
        ],
      ),
    );
  }

  Widget _buildTrackingProgress() {
    final deliveryStatus = controller.deliveryStatusList;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 32.rp(context),
        vertical: 24.rp(context),
      ),
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
        radius: 24.rs(context),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 20.ri(context),
        ),
      ),
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Container(
      height: 2.rs(context) / 2.5,
      width: 32.rs(context),
      color: isActive ? colorAccent : Colors.grey[300],
    );
  }

  Widget _buildCurrentStatus() {
    return Text(
      controller.trackingStatus,
      style: TextStyle(
        color: colorAccent,
        fontSize: 16.rt(context),
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
      margin: EdgeInsets.symmetric(horizontal: 16.rp(context)),
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
      margin: EdgeInsets.only(bottom: 16.rs(context)),
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.rr(context)),
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
              borderRadius: BorderRadius.circular(8.rr(context)),
            ),
            child: Icon(
              _getStatusIconData(statusItem.statusIcon),
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
                  statusItem.statusTitle,
                  style: TextStyle(
                    fontSize: 14.rt(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.rs(context)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.ri(context),
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.rp(context)),
                    Text(
                      statusItem.formattedDateTime,
                      style: TextStyle(
                        fontSize: 12.rt(context),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (statusItem.hasDeliveryData) ...[
                  SizedBox(height: 8.rs(context)),
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
              fontSize: 12.rt(context),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4.rs(context)),
        ],
        InkWell(
          onTap: () => _showReceiptImage(data.images ?? []),
          child: Text(
            "View Receipt",
            style: TextStyle(
              fontSize: 12.rt(context),
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
            margin: EdgeInsets.all(20.rp(context)),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: colorAccent,
                      size: 24.ri(context),
                    ),
                    SizedBox(width: 8.rp(context)),
                    Text(
                      "Delivery Info",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.rt(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.rs(context)),
                _buildInfoRow("PO Number", controller.currentPoNum.value),
                _buildInfoRow(
                    "Expected Delivery", controller.expectedDeliveryDate),
                if (driverInfo != null) ...[
                  _buildInfoRow("Driver Name", driverInfo.displayName),
                  _buildInfoRow("Vehicle No", driverInfo.displayPlatNumber),
                ],
                SizedBox(height: 16.rs(context)),
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
                          fontSize: 16.rt(context),
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
      padding: EdgeInsets.only(bottom: 8.rs(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.rt(context),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14.rt(context),
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
        margin: EdgeInsets.only(
          top: 40.rs(context),
          left: 32.rp(context),
          right: 16.rp(context),
          bottom: 16.rp(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.rs(context)),
                  Text(
                    "Need help with\nyour delivery?",
                    style: TextStyle(
                      fontSize: 18.rt(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.rs(context)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.rr(context)),
                      ),
                      backgroundColor: colorAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.rp(context),
                        vertical: 12.rp(context),
                      ),
                    ),
                    onPressed: _openWhatsApp,
                    icon: Icon(Icons.chat, size: 18.ri(context)),
                    label: Text(
                      "WhatsApp Support",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.rt(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.rp(context)),
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
          constraints: BoxConstraints(
            maxHeight: 400.rs(context),
            minHeight: 300.rs(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(
                  'Receipt',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      size: 24.ri(context),
                    ),
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
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64.ri(context),
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.rs(context)),
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.rs(context)),
            Text(
              'No receipt image found for this delivery',
              style: TextStyle(
                fontSize: 12.rt(context),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
                SizedBox(height: 16.rs(context)),
                Text(
                  'Loading image...',
                  style: TextStyle(
                    fontSize: 14.rt(context),
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
                  size: 64.ri(context),
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.rs(context)),
                Text(
                  'Image not available',
                  style: TextStyle(
                    fontSize: 16.rt(context),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  'Failed to load receipt image',
                  style: TextStyle(
                    fontSize: 12.rt(context),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.rs(context)),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.rp(context),
                      vertical: 8.rp(context),
                    ),
                  ),
                  icon: Icon(Icons.close, size: 16.ri(context)),
                  label: Text(
                    'Close',
                    style: TextStyle(fontSize: 14.rt(context)),
                  ),
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
