import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/menu_card.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_controller.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({Key? key}) : super(key: key);

  @override
  DashboardMainState createState() => DashboardMainState();
}

class DashboardMainState extends State<DashboardMain> {
  final DashboardController _controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    double responsiveSize(double size) =>
        ResponsiveUtil.scaleSize(context, size);

    return Scaffold(
      backgroundColor: colorNetral,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                responsiveSize(24),
                responsiveSize(50),
                responsiveSize(24),
                responsiveSize(70),
              ),
              decoration: BoxDecoration(
                color: colorAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(responsiveSize(24)),
                  bottomRight: Radius.circular(responsiveSize(24)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: responsiveSize(40),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveSize(40)),
                  Text(
                    'Hello,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveSize(28),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () => Text(
                      _controller.fullName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveSize(28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -responsiveSize(50)),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsiveSize(24)),
                padding: EdgeInsets.all(responsiveSize(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(responsiveSize(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: responsiveSize(10),
                      spreadRadius: responsiveSize(1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: const Color(0xFF1A3B80),
                          size: responsiveSize(24),
                        ),
                        SizedBox(width: responsiveSize(8)),
                        Expanded(
                          child: Obx(
                            () => Text(
                              _controller.addressDetail.value,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: colorAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: responsiveSize(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsiveSize(16)),
                    Obx(() => _buildMenuGrid(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    double responsiveSize(double size) =>
        ResponsiveUtil.scaleSize(context, size);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: TextStyle(fontSize: responsiveSize(18)),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: responsiveSize(16)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: responsiveSize(16)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.logout();
              },
              child: Text(
                "Logout",
                style: TextStyle(fontSize: responsiveSize(16)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = _controller.menuItems;
    double responsiveSize(double size) =>
        ResponsiveUtil.scaleSize(context, size);

    if (items.isEmpty) {
      return SizedBox(height: responsiveSize(68));
    }

    final int itemCount = items.length;

    if (itemCount <= 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: responsiveSize(8)),
                    child: MenuCard(
                      title: item["title"],
                      svgPath: item["svgPath"],
                      onTap: () {
                        Get.toNamed(item["route"]);
                      },
                    ),
                  ),
                ))
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: responsiveSize(8),
        mainAxisSpacing: responsiveSize(8),
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuCard(
          title: item["title"],
          svgPath: item["svgPath"],
          onTap: () {
            Get.toNamed(item["route"]);
          },
        );
      },
    );
  }
}
