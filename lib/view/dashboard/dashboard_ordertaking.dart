// views/dashboard/dashboard_ordertaking.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_ordertaking.dart';

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

  @override
  void initState() {
    super.initState();
    // Use Get.lazyPut to ensure proper reinitialization when navigating back
    tabController = Get.put(
        DashboadOrderTakingTabController(initialIndex: widget.initialIndex));
    tabController.initController(this); // Properly pass the TickerProvider
  }

  @override
  void dispose() {
    // Use Get.delete() to clean up the controller properly when navigating away
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
              unselectedLabelColor: Colors.black,
              labelColor: Colors.green,
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
                  Center(child: Text("Create Order Taking Content")),
                  Center(child: Text("History Order Taking Content")),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
