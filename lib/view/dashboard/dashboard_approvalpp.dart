import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_approvalpp_controller.dart';
import 'package:noo_sms/view/sms/approval/approval_pending_pp.dart';
import 'package:noo_sms/view/sms/approval/approved_pp.dart';

class DashboardApprovalPP extends StatefulWidget {
  final int initialIndex;

  const DashboardApprovalPP({Key? key, required this.initialIndex})
      : super(key: key);

  @override
  State<DashboardApprovalPP> createState() => _DashboardApprovalPPState();
}

class _DashboardApprovalPPState extends State<DashboardApprovalPP>
    with SingleTickerProviderStateMixin {
  late DashboardApprovalPPTabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = Get.put(
        DashboardApprovalPPTabController(initialIndex: widget.initialIndex));
    tabController.initController(this);
  }

  @override
  void dispose() {
    Get.delete<DashboardApprovalPPTabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      body: GetBuilder<DashboardApprovalPPTabController>(
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                unselectedLabelColor: Colors.black,
                labelColor: colorAccent,
                controller: tabController.controller,
                tabs: const [
                  Tab(text: "Pending PP"),
                  Tab(text: "Approved PP"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController.controller,
                  children: const [
                    Center(
                      child: PendingPP(),
                    ),
                    Center(
                      child: ApprovedPP(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
