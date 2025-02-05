import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/view/sms/approval/approval_pending_pp.dart';
import 'package:noo_sms/view/sms/approval/approved_pp.dart';
import 'package:noo_sms/view/sms/history_pp.dart';
import 'package:noo_sms/view/sms/input_pp.dart';

class DashboardPP extends StatefulWidget {
  final int initialIndex;

  const DashboardPP({
    Key? key,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<DashboardPP> createState() => DashboardPPState();
}

class DashboardPPState extends State<DashboardPP>
    with TickerProviderStateMixin {
  static late TabController tabController;

  static const List<({String text, Widget content})> tabItems = [
    (text: "Create", content: InputPagePP()),
    (text: "History", content: HistoryAll()),
    (text: "Pending", content: PendingPP()),
    (text: "Approved", content: ApprovedPP()),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: tabItems.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      controller: tabController,
      labelColor: colorAccent,
      indicatorColor: colorAccent,
      unselectedLabelColor: colorAccent,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorAccent,
            width: 2,
          ),
        ),
      ),
      tabs: tabItems.map((item) => Tab(text: item.text)).toList(),
    );
  }

  Widget _buildTabContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: Get.width,
      height: Get.height,
      child: TabBarView(
        controller: tabController,
        children: tabItems.map((item) => Center(child: item.content)).toList(),
      ),
    );
  }
}
