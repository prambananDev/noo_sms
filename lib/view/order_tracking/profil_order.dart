import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';

class ProfileOrderPage extends StatefulWidget {
  final String? custId;
  const ProfileOrderPage({Key? key, this.custId}) : super(key: key);

  @override
  State<ProfileOrderPage> createState() => _ProfileOrderPageState();
}

class _ProfileOrderPageState extends State<ProfileOrderPage> {
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

      controller.loadProfileForPage(custId: custId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
              color: colorNetral, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        backgroundColor: colorAccent,
        actions: [
          IconButton(
            onPressed: () {
              String? custId = widget.custId;
              if (custId == null) {
                final arguments = Get.arguments as Map<String, dynamic>?;
                custId = arguments?['custId']?.toString();
              }
              controller.loadProfileForPage(custId: custId);
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.customerProfile.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load profile data',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    String? custId = widget.custId;
                    if (custId == null) {
                      final arguments = Get.arguments as Map<String, dynamic>?;
                      custId = arguments?['custId']?.toString();
                    }
                    controller.loadProfileForPage(custId: custId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final profile = controller.customerProfile.value!;

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xffFFEFC9),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xffFBAD02),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xff1A1A2E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (profile.displayContactName != 'Not provided')
                        Text(
                          'Contact: ${profile.displayContactName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xffFFF8E1),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            label: 'Credit Line (IDR)',
                            value: profile.displayCreditLine,
                            icon: Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFinancialCard(
                            label: 'Purchased (IDR)',
                            value: profile.displayPurchased,
                            icon: Icons.shopping_cart,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            label: 'Available Credit (IDR)',
                            value: profile.formattedAvailableCredit,
                            icon: Icons.account_balance,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFinancialCard(
                            label: 'TOP (Days)',
                            value: profile.displayTOP,
                            icon: Icons.schedule,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFinancialCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
