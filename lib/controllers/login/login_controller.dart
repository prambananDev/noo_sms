import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';
import 'package:noo_sms/models/employee.dart';
import 'package:noo_sms/models/user.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoggingIn = false.obs;
  late Box userBox;
  bool isBoxInitialized = false;
  final User _user = User();

  // Make loginProvider nullable and observable
  final Rx<LoginProvider?> _loginProvider = Rx<LoginProvider?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeHive();
    loadRememberMeStatus();
  }

  // Method to set the login provider
  void setLoginProvider(LoginProvider provider) {
    _loginProvider.value = provider;
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
    try {
      if (isLoggingIn.value) return;
      isLoggingIn.value = true;

      // Check if provider is initialized
      if (_loginProvider.value == null) {
        throw Exception('LoginProvider not initialized');
      }

      if (rememberMe) {
        await saveRememberMe(rememberMe, username, password);
      } else {
        await clearRememberMe();
      }

      await getIdDevice();

      if (!isBoxInitialized) {
        await _initializeHive();
      }

      final user = await _user.login(username, password);
      if (user == null) {
        showLoginError(context, "Invalid username or password");
        return;
      }

      if (context != null) {
        await _loginProvider.value!.setMessage(username, password, context, 1);
      }

      final employee = Employee();
      final value = await employee.getEmployee(username, password);

      if (value != null && value.message != null) {
        List<String> result = value.message!.split('_');
        String message = result[0];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        final box = GetStorage();

        await prefs.setString("getIdEmp", result[2]);
        await prefs.setString("idSales", result[2]);
        await prefs.setString("getName", result[3]);
        await prefs.setString("getWh", result[4]);
        box.write("getName", result[3]);

        String dateLogin = DateFormat("ddMMMyyyy").format(DateTime.now());
        String idSales = result[1];

        await setPreference(
            username, message, idSales, value.token!, dateLogin);
      }

      navigateToDashboard(user);
    } catch (e) {
      showLoginError(context, e.toString());
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<void> loadRememberMeStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      rememberMe.value = prefs.getBool('rememberMe') ?? false;
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    } catch (e) {}
  }

  Future<void> saveRememberMe(
      bool rememberMe, String username, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', rememberMe);
    } catch (e) {}
  }

  Future<void> clearRememberMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!rememberMe.value) {
        await prefs.remove('username');
        await prefs.remove('password');
        await prefs.remove('rememberMe');
      }
    } catch (e) {}
  }

  Future<void> getIdDevice() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      OneSignal.initialize("");
      await OneSignal.Notifications.requestPermission(true);

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });

      await Future.delayed(const Duration(seconds: 2));

      final pushSubscription = OneSignal.User.pushSubscription;
      if (pushSubscription.id != null) {
        String deviceId = pushSubscription.id!;
        await preferences.setString("idDevice", deviceId);
      }
    } catch (error) {}
  }

  Future<void> setPreference(String username, String flag, String idSales,
      String token, String dateLogin) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("username", username);
      await preferences.setString("flag", flag);
      await preferences.setString("idSales", idSales);
      await preferences.setString("token", token);
      await preferences.setString("dateLogin", dateLogin);
    } catch (e) {}
  }

  void navigateToDashboard(User user) {
    if (user.role == "0") {
    } else if (user.role == "1" || user.role == "2") {
    } else {
      throw Exception("Invalid user role");
    }
  }

  void showLoginError(BuildContext? context, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void onClose() {
    usernameFocus.dispose();
    passwordFocus.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
