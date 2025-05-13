import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/view/sfa/sfa_create_visit.dart';
import 'package:noo_sms/view/sfa/sfa_list.dart';

class DashboardSfa extends StatefulWidget {
  final int? initialIndex;

  const DashboardSfa({Key? key, this.initialIndex}) : super(key: key);

  @override
  DashboardSfaState createState() => DashboardSfaState();
}

class DashboardSfaState extends State<DashboardSfa>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
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
            'Customer Visit',
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
                indicatorColor: colorAccent,
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
                  Tab(text: "New"),
                  Tab(text: "List"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            SfaCreate(),
            SfaListView(),
          ],
        ),
      ),
    );
  }
}
