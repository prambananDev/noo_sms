import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class DashboardController extends GetxController {
  RxString addressDetail = "".obs;
  RxString fullName = "".obs;
  RxList<Map<String, dynamic>> menuItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSharedPreferences();
    loadMenuItems();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    addressDetail.value = (prefs.getString("getAddressDetail") ?? "");
    fullName.value = (prefs.getString("scs_name") ?? "");
  }

  void loadMenuItems() {
    menuItems.value = [
      {
        "title": "Promotion Program",
        "svgPath": "assets/icons/sms_icon.svg",
        "route": "/sms"
      },
      {"title": "NOO", "svgPath": "assets/icons/noo_icon.svg", "route": "/noo"},
      {
        "title": "Sample\nOrder",
        "svgPath": "assets/icons/sample_order_icon.svg",
        "route": "/sample"
      },
      {
        "title": "Customer\nVisit",
        "svgPath": "assets/icons/customer_visit.svg",
        "route": "/sfa_dashboard"
      },
    ];
  }

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
