import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
            color: colorNetral,
            fontSize: 16.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorAccent,
        elevation: 0,
        toolbarHeight: 56.rs(context),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
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
              controller.loadProfileForPage(custId: custId);
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24.ri(context),
            ),
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
                Icon(
                  Icons.error_outline,
                  size: 48.ri(context),
                  color: Colors.red,
                ),
                SizedBox(height: 16.rs(context)),
                Text(
                  'Failed to load profile data',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
                SizedBox(height: 16.rs(context)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.rp(context),
                      vertical: 12.rp(context),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
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
                  padding: EdgeInsets.all(24.rp(context)),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120.rs(context),
                            height: 120.rs(context),
                            decoration: const BoxDecoration(
                              color: Color(0xffFBAD02),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60.ri(context),
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36.rs(context),
                              height: 36.rs(context),
                              decoration: const BoxDecoration(
                                color: Color(0xff1A1A2E),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20.ri(context),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.rs(context)),
                      Text(
                        profile.displayName,
                        style: TextStyle(
                          fontSize: 20.rt(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.rs(context)),
                      if (profile.displayContactName != 'Not provided')
                        Text(
                          'Contact: ${profile.displayContactName}',
                          style: TextStyle(
                            fontSize: 14.rt(context),
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
                padding: EdgeInsets.all(20.rp(context)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            context,
                            label: 'Credit Line (IDR)',
                            value: profile.displayCreditLine,
                            icon: Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12.rp(context)),
                        Expanded(
                          child: _buildFinancialCard(
                            context,
                            label: 'Purchased (IDR)',
                            value: profile.displayPurchased,
                            icon: Icons.shopping_cart,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.rs(context)),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            context,
                            label: 'Available Credit (IDR)',
                            value: profile.formattedAvailableCredit,
                            icon: Icons.account_balance,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12.rp(context)),
                        Expanded(
                          child: _buildFinancialCard(
                            context,
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

  Widget _buildFinancialCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8.rs(context),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.rp(context)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.rr(context)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.ri(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.rs(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.rt(context),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.rs(context)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.rt(context),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
