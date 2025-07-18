import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/view/sms/approval/approval_pending_pp.dart';
import 'package:noo_sms/view/sms/approval/approved_pp.dart';
import 'package:noo_sms/view/sms/history_pp.dart';
import 'package:noo_sms/view/sms/create/input_pp.dart';

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
    const double tabFontSize = 16.0;
    const double paddingSize = 16.0;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBar(context, tabFontSize),
          _buildTabContent(context, paddingSize),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, double baseFontSize) {
    final double scaledFontSize =
        ResponsiveUtil.scaleSize(context, baseFontSize);

    return TabBar(
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: scaledFontSize,
      ),
      controller: tabController,
      labelColor: colorAccent,
      indicatorColor: colorAccent,
      unselectedLabelColor: colorAccent,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorAccent,
            width: 4,
          ),
        ),
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: 8.rp(context),
        vertical: 12.rp(context) / 3,
      ),
      tabs: tabItems.map((item) => Tab(text: item.text)).toList(),
    );
  }

  Widget _buildTabContent(BuildContext context, double basePadding) {
    final double scaledPadding = ResponsiveUtil.scaleSize(context, basePadding);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.isIPad(context) ? 16.rp(context) : 0,
      ),
      width: Get.width,
      height: Get.height,
      child: TabBarView(
        controller: tabController,
        children: tabItems.map((item) => Center(child: item.content)).toList(),
      ),
    );
  }
}
