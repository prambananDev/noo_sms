import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/view/noo/approval/approval_page.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardNoo extends StatefulWidget {
  final int? initialIndex;

  const DashboardNoo({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<DashboardNoo> createState() => DashboardNooState();
}

class DashboardNooState extends State<DashboardNoo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? role;
  // CustomerFormController? controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    getSharedPrefs();
    // initializeController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString("Role");
  }

  // void initializeController() {
  //   if (Get.isRegistered<CustomerFormController>()) {
  //     Get.delete<CustomerFormController>();
  //   }
  //   controller = Get.put(CustomerFormController());
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: colorNetral,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colorAccent,
          title: Text(
            'NOO Dashboard',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: colorNetral),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: colorNetral,
              child: TabBar(
                indicatorColor: colorAccent,
                labelColor: colorAccent,
                unselectedLabelColor: colorAccent,
                controller: _tabController,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorAccent,
                      width: 2,
                    ),
                  ),
                ),
                tabs: const [
                  Tab(text: "Approved"),
                  Tab(text: "Approved"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const ApprovedView(),
            ApprovalPage(
              role: role,
            ),
          ],
        ),
      ),
    );
  }
}
