// //IM SIGN OUT, THANK YOU

// // views/dashboard/dashboard_ordertaking.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DashboardNoo extends StatefulWidget {
//   final int initialIndex;

//   const DashboardNoo({Key? key, required this.initialIndex})
//       : super(key: key);

//   @override
//   State<DashboardNoo> createState() => DashboardNooState();
// }

// class DashboardNooState extends State<DashboardNoo>
//     with SingleTickerProviderStateMixin {

//   @override
//   void initState() {
//     super.initState();

//   }

//   @override
//   void dispose() {
//     // Use Get.delete() to clean up the controller properly when navigating away
//     Get.delete<DashboadOrderTakingTabController>();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<DashboadOrderTakingTabController>(
//       builder: (_) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TabBar(
//               unselectedLabelColor: Colors.black,
//               labelColor: colorAccent,
//               controller: tabController.controller,
//               tabs: const [
//                 Tab(text: "Create Order Taking"),
//                 Tab(text: "History Order Taking"),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: tabController.controller,
//                 children: const [
//                   TransactionPage(),
//                   HistoryOrder(),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';

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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorNetral),
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
                      Tab(text: "Create PP"),
                      Tab(text: "History PP"),
                    ],
                  ),
                ))
            // bottom : DefaultTabController(
            //   initialIndex: tabController.initialIndex,
            //   length: 2,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       TabBar(
            //         unselectedLabelColor: Colors.black,
            //         labelColor: colorAccent,
            //         controller: tabController.controller,
            //         tabs: const [
            //           Tab(text: "Create PP"),
            //           Tab(text: "History PP"),
            //         ],
            //       ),
            //       SizedBox(
            //         width: Get.width,
            //         height: Get.height,
            //         child: TabBarView(
            //           controller: tabController.controller,
            //           children: const [
            //             Center(
            //               child: InputPagePP(),
            //             ),
            //             Center(
            //               child: HistoryAll(),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // bottom: TabBar(
            //   controller: _tabController,
            //   labelStyle: const TextStyle(
            //     fontWeight: FontWeight.w500,
            //   ),
            //   indicatorColor: colorNetral,
            //   labelColor: colorNetral,
            //   unselectedLabelColor: colorNetral,
            //   isScrollable: true,
            //   tabs: const [
            //     Tab(text: "New Form NOO"),
            //     Tab(text: "List NOO"),
            //   ],
            // ),
            ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
            controller: _tabController,
            children: const [Text('NOO Form'), Text('List NOO')],
          ),
        ),
      ),
    );
  }
}
