import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/view/noo/approval/approval_page.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form_coba.dart';
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
      Get.delete<CustomerFormController>();
    }

    super.dispose();
  }

  Future<void> _getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      role = prefs.getString("Role");
    });
  }

  void _initializeController() {
    if (Get.isRegistered<CustomerFormController>()) {
      Get.delete<CustomerFormController>();
    }

    controller = Get.put(CustomerFormController());
  }

  void _clearAndExit() {
    final controller = Get.find<CustomerFormController>();
    controller.clearForm();
    controller.isEditMode.value = false;
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    _clearAndExit();
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
            strokeWidth: 3.0.rs(context),
          ),
        ),
      );
    }

    final List<Widget> tabsBasedOnRole = role == "2"
        ? [
            Tab(
              child: Text(
                "New",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "All List",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "Pending",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "Approved",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
          ]
        : [
            Tab(
              child: Text(
                "New",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "List NOO",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "Pending",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
            Tab(
              child: Text(
                "Approved",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.rt(context),
                ),
              ),
            ),
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
        elevation: 0,
        toolbarHeight: 70.rs(context),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
          onPressed: () async {
            await _onWillPop();
          },
        ),
        title: Text(
          'NOO Dashboard',
          style: TextStyle(
            fontSize: 18.rt(context),
            fontWeight: FontWeight.bold,
            color: colorNetral,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.rs(context)),
          child: Container(
            color: colorNetral,
            child: TabBar(
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.rt(context),
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.rt(context),
              ),
              indicatorColor: colorAccent,
              labelColor: colorAccent,
              unselectedLabelColor: colorAccent.withOpacity(0.7),
              controller: tabController,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorAccent,
                    width: 2.5,
                  ),
                ),
              ),
              labelPadding: EdgeInsets.symmetric(
                horizontal: 8.rp(context),
                vertical: 12.rp(context) / 3,
              ),
              tabs: tabsBasedOnRole,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.isIPad(context) ? 16.rp(context) : 0,
        ),
        child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabViewsBasedOnRole,
        ),
      ),
    );
  }
}
