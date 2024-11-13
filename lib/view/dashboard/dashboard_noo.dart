import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form.dart';

class DashboardNoo extends StatefulWidget {
  final int? initialIndex;

  const DashboardNoo({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<DashboardNoo> createState() => DashboardNooState();
}

class DashboardNooState extends State<DashboardNoo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    Get.put(CustomerFormController()); // Ensures controller is available
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  Tab(text: "New"),
                  Tab(text: "List NOO"),
                ],
              ),
            ),
          ),
        ),
        body: GetBuilder<CustomerFormController>(
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  CustomerForm(),
                  Text('List NOO'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
