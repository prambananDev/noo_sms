// controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:noo_sms/view/dashboard/dashboard_ordertaking.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class DashboardController {
  List<Map<String, dynamic>> dataMenu = [
    {
      "title": "Program\nPromotion",
      "icon": Icons.discount_outlined,
      "naviGateTo": const DashboardPP(initialIndex: 0),
    },
    {
      "title": "Approval\nPP",
      "icon": Icons.approval_outlined,
      "naviGateTo": const DashboardApprovalPP(initialIndex: 0),
    },
    {
      "title": "Order\nTaking",
      "icon": Icons.shopping_bag_outlined,
      "naviGateTo": const DashboardOrderTaking(initialIndex: 0),
    },
  ];
  Future<bool> logout() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('user');

    await userBox.clear();
    await userBox.deleteFromDisk();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Get.offAll(const LoginView());

    return Future.value(false);
  }

  Future<void> deleteBoxUser() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();

    Future.delayed(const Duration(milliseconds: 10));
    await userBox.deleteFromDisk();
    pref.setInt("flag", 0);
    pref.setString("result", "");
  }
}
