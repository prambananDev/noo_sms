import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  late Box _userBox;
  late SharedPreferences preferences;
  String _message = "";
  int _status = 0;
  User user = User();
  Future<void> setMessage(
      String username, String password, BuildContext context, int code) async {
    _userBox = await Hive.openBox('users');
    preferences = await SharedPreferences.getInstance();

    user.getUsers(username, password, code).then((value) {
      // User.getUserNOTPassword(username, code)
      user.login(username, password);
      _status = value.code!;
      if (value.code != 200) {
        _message = value.message!;
        Navigator.pop(context);
      } else {
        setBoxLogin(value, code);
        Get.offAll(const DashboardMain());
      }
    }).catchError((onError) {
      _message = onError.toString();
    });
    notifyListeners();
  }

  Future<void> setBoxLogin(User value, int code) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('ddMMyyyy');
    final String dateLogin = formatter.format(now);
    await Future.delayed(const Duration(milliseconds: 20));
    _userBox.add(value);
    await Future.delayed(const Duration(milliseconds: 20));
    preferences.setInt("code", code);
    preferences.setString("date", dateLogin);
    preferences.setInt("flag", 1);
    preferences.setString("result", "");
  }

  String get getMessage => _message;
  int get getStatus => _status;
}
