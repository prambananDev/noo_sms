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
    final isIPad = ResponsiveUtil.isIPad(context);

    return Scaffold(
      backgroundColor: colorNetral,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24.rp(context),
                50.rp(context),
                24.rp(context),
                70.rp(context),
              ),
              decoration: BoxDecoration(
                color: colorAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.rr(context)),
                  bottomRight: Radius.circular(24.rr(context)),
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
                        size: 40.ri(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.rp(context)),
                  Text(
                    'Hello,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isIPad ? 36.rt(context) : 32.rt(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () => Text(
                      _controller.fullName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isIPad ? 36.rt(context) : 32.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -50.rs(context)),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.rp(context)),
                padding: EdgeInsets.all(16.rp(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.rr(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.rs(context),
                      spreadRadius: 1.rs(context),
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
                          size: 24.ri(context),
                        ),
                        SizedBox(width: 8.rp(context)),
                        Expanded(
                          child: Obx(
                            () => Text(
                              _controller.addressDetail.value,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: colorAccent,
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    isIPad ? 20.rt(context) : 18.rt(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.rp(context)),
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
    final isIPad = ResponsiveUtil.isIPad(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: TextStyle(
              fontSize: isIPad ? 24.rt(context) : 20.rt(context),
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              fontSize: isIPad ? 20.rt(context) : 18.rt(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: isIPad ? 18.rt(context) : 16.rt(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.logout();
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  fontSize: isIPad ? 18.rt(context) : 16.rt(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = _controller.menuItems;
    final isIPad = ResponsiveUtil.isIPad(context);

    if (items.isEmpty) {
      return SizedBox(height: 68.rs(context));
    }

    final int itemCount = items.length;

    if (itemCount <= 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.rp(context),
                    ),
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
        crossAxisCount: isIPad ? 3 : 2,
        crossAxisSpacing: isIPad ? 16.rp(context) : 8.rp(context),
        mainAxisSpacing: isIPad ? 16.rp(context) : 8.rp(context),
        childAspectRatio: isIPad ? 1.3 : 1.2,
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
