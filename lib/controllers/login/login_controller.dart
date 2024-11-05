import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';
import 'package:noo_sms/models/employee.dart';
import 'package:noo_sms/models/user.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs; // Make rememberMe reactive
  final RxBool isLoggingIn = false.obs; // Make isLoggingIn reactive
  late Box userBox;
  bool isBoxInitialized = false;
  final User _user = User();

  @override
  void onInit() {
    super.onInit();
    _initializeHive();
    loadRememberMeStatus();
  }

  Future<void> _initializeHive() async {
    if (!Hive.isBoxOpen('userBox')) {
      userBox = await Hive.openBox('userBox');
    } else {
      userBox = Hive.box('userBox');
    }
    isBoxInitialized = true;
  }

  Future<void> login(bool rememberMe, String username, String password,
      BuildContext? context) async {
    if (rememberMe) {
      await saveRememberMe(rememberMe, username, password);
    } else {
      await clearRememberMe();
    }
    getIdDevice();

    if (isLoggingIn.value) return; // Check reactive variable
    isLoggingIn.value = true;

    if (!isBoxInitialized) {
      await _initializeHive();
    }
    final user = await _user.login(username, password);
    if (user == null) {
      showLoginError(context, "Invalid username or password");
      isLoggingIn.value = false;
      return;
    }

    if (context != null) {
      Provider.of<LoginProvider>(context, listen: false)
          .setMessage(username, password, context, 1)
          .then((_) {});
    }
    final employee = Employee();
    employee.getEmployee(username, password).then((value) async {
      List<String> result = value!.message!.split('_');
      String message = result[0];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final box = GetStorage();
      prefs.setString("getIdEmp", result[2]);
      prefs.setString("idSales", result[2]);
      prefs.setString("getName", result[3]);
      prefs.setString("getWh", result[4]);
      box.write("getName", result[3]);
      String dateLogin = DateFormat("ddMMMyyyy").format(DateTime.now());
      String idSales = result[1];
      setPreference(username, message, idSales, value.token!, dateLogin);
    });

    navigateToDashboard(user);
    isLoggingIn.value = false;
  }

  Future<void> loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe.value =
        prefs.getBool('rememberMe') ?? false; // Use reactive variable
    usernameController.text = prefs.getString('username') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
  }

  Future<void> saveRememberMe(
      bool rememberMe, String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', rememberMe);
  }

  Future<void> clearRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!rememberMe.value) {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  void getIdDevice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    OneSignal.shared.setAppId(""); // Set your OneSignal app ID here
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
        event.complete(event.notification);
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    OneSignal.shared.getDeviceState().then((deviceState) {
      if (deviceState != null && deviceState.userId != null) {
        String deviceId = deviceState.userId!;
        preferences.setString("idDevice", deviceId);
      } else {}
    }).catchError((error) {});
  }

  Future<void> setPreference(String username, String flag, String idSales,
      String token, String dateLogin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("username", username);
    await preferences.setString("flag", flag);
    await preferences.setString("idSales", idSales);
    await preferences.setString("token", token);
    await preferences.setString("dateLogin", dateLogin);
  }

  void navigateToDashboard(User user) {
    if (user.role == "0") {
      // Navigate to Employee Dashboard
    } else if (user.role == "1" || user.role == "2") {
      // Navigate to Manager Dashboard
    } else {
      throw Exception("Login failed");
    }
  }

  void showLoginError(BuildContext? context, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
