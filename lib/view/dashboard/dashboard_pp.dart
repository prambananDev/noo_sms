// views/dashboard/dashboard_pp.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/promotion_program/history_pp.dart';
import 'package:noo_sms/view/promotion_program/input_pp.dart';

class DashboardPP extends StatefulWidget {
  final int initialIndex;

  const DashboardPP({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<DashboardPP> createState() => _DashboardPPState();
}

class _DashboardPPState extends State<DashboardPP>
    with SingleTickerProviderStateMixin {
  late DashboardPPTabController tabController;

  @override
  void initState() {
    super.initState();
    tabController =
        Get.put(DashboardPPTabController(initialIndex: widget.initialIndex));
    tabController.initController(this); // Pass `this` as the TickerProvider
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardPPTabController>(
      builder: (_) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: DefaultTabController(
            initialIndex: tabController.initialIndex,
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  unselectedLabelColor: Colors.black,
                  labelColor: Colors.green,
                  controller: tabController.controller,
                  tabs: const [
                    Tab(text: "Create PP"),
                    Tab(text: "History PP"),
                  ],
                ),
                SizedBox(
                  width: Get.width,
                  height: Get.height,
                  child: TabBarView(
                    controller: tabController.controller,
                    children: const [
                      Center(
                        child: InputPagePP(),
                      ),
                      Center(
                        child: HistoryAll(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
