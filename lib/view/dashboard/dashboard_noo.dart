import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/view/noo/approval/approval_page.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/list_status_noo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardNoo extends StatefulWidget {
  final int? initialIndex;

  const DashboardNoo({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<DashboardNoo> createState() => DashboardNooState();
}

class DashboardNooState extends State<DashboardNoo>
    with TickerProviderStateMixin {
  static late TabController tabController;
  CustomerFormController? controller;
  String? role;
  final customerFormController = Get.put(CustomerFormController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    initializeController();
    getSharedPrefs();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("Role");
    });
  }

  void initializeController() {
    if (Get.isRegistered<CustomerFormController>()) {
      Get.delete<CustomerFormController>();
    }
    controller = Get.put(CustomerFormController());
  }

  Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offAllNamed('/dashboard');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Container(
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
              tabs: const [
                Tab(text: "New"),
                Tab(text: "List NOO"),
                Tab(text: "Pending"),
                Tab(text: "Approved"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          GetBuilder<CustomerFormController>(
            init: controller,
            builder: (ctrl) => CustomerForm(
              editData: null,
              controller: customerFormController,
            ),
          ),
          const StatusPage(),
          ApprovalPage(role: role),
          const ApprovedView(),
        ],
      ),
    );
  }
}
