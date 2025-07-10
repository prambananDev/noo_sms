import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
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
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xffFBAD02),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customerEmail,
                          style: TextStyle(
                            fontSize: 14,
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
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Profile Menu Item
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Get.toNamed(
                        '/profile_order',
                        arguments: {'custId': custId},
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      Get.toNamed(
                        '/order_history_tracking',
                        arguments: {'custId': custId},
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Method',
                    onTap: () {
                      // Get.toNamed('/current-orders', arguments: {
                      //   'userId': userId,
                      // });
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuItem(
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[600])?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.grey[600],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 24,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
