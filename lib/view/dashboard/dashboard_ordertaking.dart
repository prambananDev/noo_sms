import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_ordertaking.dart';
import 'package:noo_sms/view/sms/create/dimension.dart';
import 'package:noo_sms/view/sms/order/create_order_taking.dart';
import 'package:noo_sms/view/sms/order/history_order_taking.dart';

class DashboardOrderTaking extends StatefulWidget {
  final int initialIndex;

  const DashboardOrderTaking({Key? key, required this.initialIndex})
      : super(key: key);

  @override
  State<DashboardOrderTaking> createState() => _DashboardOrderTakingState();
}

class _DashboardOrderTakingState extends State<DashboardOrderTaking>
    with SingleTickerProviderStateMixin {
  late DashboadOrderTakingTabController tabController;
  late PPDimensions dimensions;

  @override
  void initState() {
    super.initState();

    tabController = Get.put(
        DashboadOrderTakingTabController(initialIndex: widget.initialIndex));
    tabController.initController(this);
    dimensions = PPDimensions();
  }

  @override
  void dispose() {
    Get.delete<DashboadOrderTakingTabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboadOrderTakingTabController>(
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: dimensions.getHeadingSize(context),
              ),
              unselectedLabelColor: Colors.black,
              labelColor: colorAccent,
              controller: tabController.controller,
              tabs: const [
                Tab(text: "Create Order Taking"),
                Tab(text: "History Order Taking"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController.controller,
                children: const [
                  TransactionPage(),
                  HistoryOrder(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
