import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/view/noo/approval/approval_page.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/list_status_noo.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/view_all_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardNoo extends StatefulWidget {
  final int? initialIndex;

  const DashboardNoo({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<DashboardNoo> createState() => DashboardNooState();
}

class DashboardNooState extends State<DashboardNoo>
    with TickerProviderStateMixin {
  late TabController tabController;
  CustomerFormController? controller;
  String? role;
  // String role = "2";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isTabControllerInitialized = false;

  @override
  void initState() {
    super.initState();

    _getSharedPrefs().then((_) {
      _initTabController();
      _initializeController();
    });
  }

  void _initTabController() {
    final int tabCount = role == "2" ? 4 : 4;

    tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex:
          widget.initialIndex != null && widget.initialIndex! < tabCount
              ? widget.initialIndex!
              : 0,
    );

    tabController.addListener(_handleTabSelection);
    isTabControllerInitialized = true;

    if (mounted) setState(() {});
  }

  void _handleTabSelection() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    if (isTabControllerInitialized) {
      tabController.removeListener(_handleTabSelection);
      tabController.dispose();
    }

    if (Get.isRegistered<CustomerFormController>()) {
      try {
        Get.delete<CustomerFormController>();
      } catch (e) {
        debugPrint("Error deleting controller: $e");
      }
    }

    super.dispose();
  }

  Future<void> _getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      role = prefs.getString("Role");
      debugPrint("User role: $role");
    });
  }

  void _initializeController() {
    if (Get.isRegistered<CustomerFormController>()) {
      Get.delete<CustomerFormController>();
    }

    controller = Get.put(CustomerFormController());
  }

  Future<bool> _onWillPop() async {
    Get.offAllNamed('/dashboard');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isTabControllerInitialized) {
      return Scaffold(
        backgroundColor: colorNetral,
        body: Center(
          child: CircularProgressIndicator(
            color: colorAccent,
          ),
        ),
      );
    }

    final List<Widget> tabsBasedOnRole = role == "2"
        ? const [
            Tab(text: "New"),
            // Tab(text: "List NOO"),
            Tab(text: "All List"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
          ]
        : const [
            Tab(text: "New"),
            Tab(text: "List NOO"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
          ];

    final List<Widget> tabViewsBasedOnRole = role == "2"
        ? [
            GetBuilder<CustomerFormController>(
              init: controller,
              builder: (ctrl) => CustomerForm(
                editData: null,
                controller: ctrl,
              ),
            ),
            // const StatusPage(),
            const ViewAllListPage(),
            ApprovalPage(role: role),
            const ApprovedView(),
          ]
        : [
            GetBuilder<CustomerFormController>(
              init: controller,
              builder: (ctrl) => CustomerForm(
                editData: null,
                controller: ctrl,
              ),
            ),
            const StatusPage(),
            ApprovalPage(role: role),
            const ApprovedView(),
          ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorAccent,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () async {
            await _onWillPop();
          },
          tooltip: '',
        ),
        title: Text(
          'NOO Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorNetral,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Material(
            color: colorNetral,
            child: TabBar(
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              indicatorColor: colorAccent,
              labelColor: colorAccent,
              unselectedLabelColor: colorAccent,
              controller: tabController,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorAccent,
                    width: 2,
                  ),
                ),
              ),
              tabs: tabsBasedOnRole,
              // isScrollable: role == "2",
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: tabViewsBasedOnRole,
      ),
    );
  }
}
