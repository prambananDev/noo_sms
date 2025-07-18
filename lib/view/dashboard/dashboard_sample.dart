import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
            elevation: 0,
            toolbarHeight: 70.rs(context),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 35.ri(context),
              ),
              onPressed: () async {
                if (Get.previousRoute.isNotEmpty) {
                  Get.back();
                } else {
                  await Get.offAllNamed('/dashboard');
                }
              },
              padding: EdgeInsets.all(8.rp(context)),
            ),
            title: Text(
              'Product Sample Order',
              style: TextStyle(
                  fontSize: 18.rt(context),
                  fontWeight: FontWeight.bold,
                  color: colorNetral),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40.rs(context)),
              child: Container(
                color: colorNetral,
                child: TabBar(
                  controller: tabController,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.rt(context),
                  ),
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 8.rp(context),
                    vertical: 12.rp(context) / 3,
                  ),
                  indicatorColor: colorAccent,
                  labelColor: colorAccent,
                  unselectedLabelColor: colorAccent.withOpacity(0.7),
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorAccent,
                        width: 2.5,
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
