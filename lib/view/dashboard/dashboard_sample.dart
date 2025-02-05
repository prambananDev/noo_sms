import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/sample_order/transaction_approved_controller.dart';
import 'package:noo_sms/view/sample_order/transaction_approved.dart';
import 'package:noo_sms/view/sample_order/transaction_history.dart';
import 'package:noo_sms/view/sample_order/transaction_pending.dart';
import 'package:noo_sms/view/sample_order/transaction_sample.dart';

class DashboardOrderSample extends StatefulWidget {
  final int? initialIndex;

  const DashboardOrderSample({Key? key, this.initialIndex}) : super(key: key);

  @override
  DashboardOrderSampleState createState() => DashboardOrderSampleState();
}

class DashboardOrderSampleState extends State<DashboardOrderSample>
    with TickerProviderStateMixin {
  static late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (Get.isRegistered<TransactionApprovedController>()) {
          Get.find<TransactionApprovedController>().tabIndex.value =
              tabController.index;
        }
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
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
                if (Get.previousRoute.isNotEmpty) {
                  Get.back();
                } else {
                  await Get.offAllNamed('/dashboard');
                }
              },
            ),
            title: Text(
              'Product Sample Order',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorNetral),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: colorNetral,
                child: TabBar(
                  controller: tabController,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  indicatorColor: colorAccent,
                  labelColor: colorAccent,
                  unselectedLabelColor: colorAccent,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  tabs: const [
                    Tab(text: "Create"),
                    Tab(text: "History"),
                    Tab(text: "Pending"),
                    Tab(text: "Approved"),
                  ],
                ),
              ),
            )),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
            controller: tabController,
            children: const [
              TransactionSample(),
              TransactionHistorySampleView(),
              TransactionPendingPage(),
              TransactionApprovedPage(),
            ],
          ),
        ),
      ),
    );
  }
}
