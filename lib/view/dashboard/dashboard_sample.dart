import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
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
                  controller: _tabController,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
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
                  isScrollable: true,
                  tabs: const [
                    Tab(text: "Create Order Sample"),
                    Tab(text: "History Order Sample"),
                    Tab(text: "Pending Order Sample"),
                    Tab(text: "Approved Order Sample"),
                  ],
                ),
              ),
            )),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
            controller: _tabController,
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
