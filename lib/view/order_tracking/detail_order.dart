import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';

class DetailOrderTrack extends StatelessWidget {
  final OrderTrackingController controller = Get.put(OrderTrackingController());

  DetailOrderTrack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final String customerName =
        arguments?['customerName'] ?? 'Unknown Customer';
    final String customerEmail =
        arguments?['customerEmail'] ?? 'Email is empty';
    final String custId = arguments?['custId'] ?? ' ';

    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Detail Order Tracking',
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
      ),
      body: Column(
        children: [
          // Profile Header Section
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
              padding: EdgeInsets.all(20.rp(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  Container(
                    width: 80.rs(context),
                    height: 80.rs(context),
                    decoration: const BoxDecoration(
                      color: Color(0xffFBAD02),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40.ri(context),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16.rp(context)),
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 18.rt(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.rs(context)),
                        Text(
                          customerEmail,
                          style: TextStyle(
                            fontSize: 14.rt(context),
                            color: customerEmail == 'Email is empty'
                                ? Colors.grey[600]
                                : Colors.black54,
                            fontStyle: customerEmail == 'Email is empty'
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items Section
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: EdgeInsets.all(16.rp(context)),
                children: [
                  // Profile Menu Item
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Get.toNamed(
                        '/profile_order',
                        arguments: {'custId': custId},
                      );
                    },
                  ),

                  SizedBox(height: 12.rs(context)),

                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      Get.toNamed(
                        '/order_history_tracking',
                        arguments: {'custId': custId},
                      );
                    },
                  ),

                  SizedBox(height: 12.rs(context)),

                  _buildMenuItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: 'Payment Method',
                    onTap: () {
                      // Get.toNamed('/current-orders', arguments: {
                      //   'userId': userId,
                      // });
                    },
                  ),

                  SizedBox(height: 12.rs(context)),

                  _buildMenuItem(
                    context,
                    icon: Icons.pin_drop_outlined,
                    title: 'My Address',
                    onTap: () {
                      // Navigate to settings
                      // Get.toNamed('/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.rs(context),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40.rs(context),
          height: 40.rs(context),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[600])?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.rr(context)),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.grey[600],
            size: 24.ri(context),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.rt(context),
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 24.ri(context),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.rp(context),
          vertical: 8.rp(context),
        ),
      ),
    );
  }
}
