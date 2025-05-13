import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/view/assets_submission/all_assets.dart';
import 'package:noo_sms/view/assets_submission/asssets_history.dart';
import 'package:noo_sms/view/assets_submission/new_assets_loan.dart';

class DashboardAsset extends StatefulWidget {
  final int? initialIndex;

  const DashboardAsset({Key? key, this.initialIndex}) : super(key: key);

  @override
  DashboardSfaState createState() => DashboardSfaState();
}

class DashboardSfaState extends State<DashboardAsset>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 3, // Three tabs: All Assets, Asset History, New Asset Loan
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
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
        backgroundColor: Colors.grey[100],
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
            'Asset Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorNetral,
              letterSpacing: 0.5,
            ),
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
                indicatorColor: colorAccent, // Accent color for indicator
                labelColor: colorAccent,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorAccent,
                      width: 2,
                    ),
                  ),
                ),
                tabs: const [
                  Tab(text: "All Assets"),
                  Tab(text: "Asset History"),
                  Tab(text: "New Asset Loan"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            AllAssetsPage(),
            AssetHistoryPage(),
            NewAssetLoanPage(),
          ],
        ),
      ),
    );
  }
}
