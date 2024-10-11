// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:mobile_sms/assets/widgets/Debounce.dart';
// import 'package:mobile_sms/assets/widgets/TextResultCard.dart';
// import 'package:mobile_sms/models/Promosi.dart';
// import 'package:mobile_sms/models/User.dart';
// import 'package:mobile_sms/view/HistoryNomorPP_All.dart';
// import 'package:mobile_sms/view/HistoryNomorPP_Pending.dart';
// import 'package:mobile_sms/view/input-page/input-page-new.dart';
// import 'package:mobile_sms/view/transaction/transaction_history_page.dart';
// import 'package:mobile_sms/view/transaction/transaction_page.dart';
// import 'package:noo_sms/assets/widgets/debounce.dart';
// import 'package:noo_sms/assets/widgets/text_result_card.dart';
// import 'package:noo_sms/models/promotion.dart';
// import 'package:noo_sms/models/user.dart';
// import 'package:noo_sms/view/login/login_view.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'HistoryLines.dart';
// import 'Login.dart';
// import 'input-page/input-page.dart';

// class HistoryNomorPP extends StatefulWidget {
//   const HistoryNomorPP({super.key});

//   @override
//   _HistoryNomorPPState createState() => _HistoryNomorPPState();
//   // int idEmp;
//   // int codeUrl;
//   // HistoryNomorPP({this.idEmp, this.codeUrl});
// }

// class _HistoryNomorPPState extends State<HistoryNomorPP> {
//   final _debouncer = Debounce(milliseconds: 5);
//   TextEditingController filterController = TextEditingController();
//   var _listHistory, listHistoryReal;
//   GlobalKey<RefreshIndicatorState> refreshKey =
//       GlobalKey<RefreshIndicatorState>();
//   User _user = User();
//   late int code;

//   @override
//   void initState() {
//     super.initState();
//     refreshKey = GlobalKey<RefreshIndicatorState>();
//     getSharedPreference();
//   }

//   Future<void> listHistory() async {
//     await Future.delayed(const Duration(seconds: 5));
//     Promotion.getListPromotion(
//             0, code, _user.token ?? "token kosong", _user.username)
//         .then((value) {
//       print("userToken: ${_user.token}");
//       setState(() {
//         listHistoryReal = value;
//         _listHistory = listHistoryReal;
//       });
//     });
//     return;
//   }

//   Future<void> listHistoryAll() async {
//     await Future.delayed(const Duration(seconds: 5));
//     Promosi.getAllListPromosi(
//             0, code, _user.token ?? "token kosong", _user.username)
//         .then((value) {
//       print("userToken: ${_user.token}");
//       setState(() {
//         listHistoryReal = value;
//         _listHistory = listHistoryReal;
//       });
//     });
//     return;
//   }

//   List<Widget> pages = [
//     SizedBox(
//       height: Get.size.height,
//       width: Get.size.width,
//       child: HistoryPending(),
//     ),
//     SizedBox(
//       height: Get.size.height,
//       width: Get.size.width,
//       child: HistoryAll(),
//     ),
//   ];

//   final ScrollController listController = ScrollController();

//   Future<bool> onBackPressLines() {
//     Get.back();
//     return Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) {
//         return const HistoryNomorPP();
//       }),
//     ).then((_) => true); // Return true to match the Future<bool> type
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ScreenUtil.init(
//     //   BoxConstraints(
//     //     maxHeight: MediaQuery.of(context).size.height,
//     //     maxWidth: MediaQuery.of(context).size.width,
//     //   )
//     // );
//     return WillPopScope(
//       onWillPop: onBackPressLines,
//       child: MaterialApp(
//         theme: Theme.of(context),
//         home: Scaffold(
//           floatingActionButton: Column(
//             // crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               FloatingActionButton.extended(
//                   heroTag: "TransactionList",
//                   onPressed: () {
//                     Get.to(TransactionHistoryPage());
//                   },
//                   label: const Text("Order Taking List")),
//               const SizedBox(
//                 height: 10,
//               ),
//               FloatingActionButton.extended(
//                   heroTag: "Transaction",
//                   onPressed: () {
//                     Get.to(TransactionPage());
//                   },
//                   label: const Text("Order Taking")),
//               const SizedBox(
//                 height: 10,
//               ),
//               FloatingActionButton.extended(
//                   heroTag: "All PP",
//                   onPressed: () {
//                     setState(() {
//                       listController.animateTo(
//                         listController.position.maxScrollExtent,
//                         duration: const Duration(seconds: 2),
//                         curve: Curves.fastOutSlowIn,
//                       );
//                     });
//                   },
//                   label: const Text("All History")),
//             ],
//           ),
//           appBar: AppBar(
//             backgroundColor: Theme.of(context).primaryColorDark,
//             leading: IconButton(
//               icon: Icon(
//                 Icons.home,
//                 color: Theme.of(context).colorScheme.secondary,
//               ),
//               onPressed: LogOut,
//             ),
//             actions: [
//               Center(
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.edit,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Get.to(InputPageNew());
//                   },
//                 ),
//               )
//             ],
//             title: Text(
//               "List PP",
//               style: TextStyle(
//                   fontSize: ScreenUtil().setSp(20),
//                   color: Theme.of(context).colorScheme.secondary),
//             ),
//           ),
//           body: ListView(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               controller: listController,
//               children: pages),
//         ),
//       ),
//     );
//   }

//   Container CardAdapter(Promosi promosi) {
//     return Container(
//         margin: EdgeInsets.all(ScreenUtil().setWidth(10)),
//         padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
//         decoration: BoxDecoration(
//           border: Border.all(color: Theme.of(context).primaryColorDark),
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//         ),
//         child: Column(
//           children: <Widget>[
//             TextResultCard(
//               title: "No. PP",
//               value: promosi.nomorPP!,
//             ),
//             TextResultCard(
//               title: "Date",
//               value: promosi.date,
//             ),
//             TextResultCard(
//               title: "Customer",
//               value: promosi.customer!,
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (context) {
//                   return HistoryLines(
//                     numberPP: promosi?.namePP,
//                     idEmp: _user.id,
//                   );
//                 }));
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.secondary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(
//                       color: Theme.of(context).primaryColor,
//                       style: BorderStyle.solid,
//                       width: 2),
//                 ),
//                 padding: EdgeInsets.all(ScreenUtil().setWidth(7)),
//               ),
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 margin: EdgeInsets.all(ScreenUtil().setWidth(7)),
//                 padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
//                 child: Center(
//                   child: Text(
//                     "VIEW LINES",
//                     style: TextStyle(
//                         color: Theme.of(context).primaryColorDark,
//                         fontSize: ScreenUtil().setSp(13),
//                         fontWeight: FontWeight.w900),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ));
//   }

//   void getSharedPreference() async {
//     var dir = await getApplicationDocumentsDirectory();
//     Hive.init(dir.path);
//     Box userBox = await Hive.openBox('users');
//     List<User> listUser = userBox.values.map((e) => e as User).toList();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     Future.delayed(const Duration(milliseconds: 20));
//     setState(() {
//       _user = listUser[0];
//       code = pref.getInt("code")!;
//     });
//   }

//   // Future<bool> onBackPress() {
//   //   deleteBoxUser();
//   //   return Get.offAll(LoginView());
//   //   // return Navigator.pushReplacement(context,
//   //   //     MaterialPageRoute(builder: (context) {
//   //   //   return LoginView();
//   //   // }));
//   // }
//   Future<bool> onBackPress() {
//     deleteBoxUser();
//     return Get.offAll(const LoginView())?.then((_) => true) ??
//         Future.value(true);
//   }

//   void deleteBoxUser() async {
//     var dir = await getApplicationDocumentsDirectory();
//     Hive.init(dir.path);
//     Box userBox = await Hive.openBox('users');
//     SharedPreferences pref = await SharedPreferences.getInstance();

//     Future.delayed(const Duration(milliseconds: 10));
//     await userBox.deleteFromDisk();
//     pref.setInt("flag", 0);
//     pref.setString("result", "");
//   }

//   void LogOut() {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//               title: const Text('Log Out'),
//               content: const Text('Are you sure log out ?'),
//               actions: <Widget>[
//                 TextButton(
//                     onPressed: () => Navigator.pop(context, 'Cancel'),
//                     child: const Text('Cancel')),
//                 TextButton(onPressed: onBackPress, child: const Text('Ok')),
//               ],
//             ));
//   }
// }
