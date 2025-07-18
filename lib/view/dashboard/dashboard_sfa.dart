import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
          ),
          title: Text(
            'Customer Visit',
            style: TextStyle(
              fontSize: 18.rt(context),
              fontWeight: FontWeight.bold,
              color: colorNetral,
              letterSpacing: 0.5,
            ),
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
                  vertical: 12.rp(context) / 6,
                ),
                indicatorColor: colorAccent,
                labelColor: colorAccent,
                unselectedLabelColor: colorAccent.withOpacity(0.7),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorAccent,
                    ),
                  ),
                ),
                tabs: [
                  Tab(
                    child: Text(
                      "New",
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "List",
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                  ),
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
