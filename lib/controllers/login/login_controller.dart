import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/login/login_view.dart';
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
  final RxBool rememberMe = false.obs;
  bool isLoggingIn = false;
  late Box userBox;
  bool isBoxInitialized = false;
  final User _user = User();

  @override
  void onInit() {
    super.onInit();
    _initializeHive();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _initializeHive() async {
    if (!Hive.isBoxOpen('userBox')) {
      userBox = await Hive.openBox('userBox');
    } else {
      userBox = Hive.box('userBox');
    }
    isBoxInitialized = true;
  }

  Future<void> login(
      String username, String password, BuildContext? context) async {
    if (!formKey.currentState!.validate()) return;
    getIdDevice();

    if (isLoggingIn) return;
    isLoggingIn = true;

    if (!isBoxInitialized) {
      await _initializeHive();
    }

    userBox.put('username', username);
    userBox.put('password', password);

    final user = await _user.login(username, password);
    if (user == null) {
      // Handle login failure
      showLoginError(context, "Invalid username or password");
      isLoggingIn = false;
      return;
    }

    await user.saveUserToPrefs(user, username, password, rememberMe.value);

    if (context != null) {
      Provider.of<LoginProvider>(context, listen: false)
          .setMessage(username, password, context, 1)
          .then((_) {
        int statusCode =
            Provider.of<LoginProvider>(context, listen: false).getStatus;
        if (statusCode == 200 && rememberMe.value) {
          saveCredentials(
              username, password); // Save if "Remember Me" is active
        }
      });
    }

    navigateToDashboard(user);
    isLoggingIn = false;
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool keepCredentials = rememberMe.value;

    String savedUsername = usernameController.text;
    String savedPassword = passwordController.text;

    await prefs.clear();

    if (keepCredentials) {
      await prefs.setString('savedUsername', savedUsername);
      await prefs.setString('savedPassword', savedPassword);
      await prefs.setBool('rememberMe', true);
    }

    Get.offAll(const LoginView());
  }

  Future<void> saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUsername', username);
    await prefs.setString('savedPassword', password);
    await prefs.setBool('rememberMe', true);
  }

  Future<void> clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!rememberMe.value) {
      await prefs.remove('savedUsername');
      await prefs.remove('savedPassword');
      await prefs.remove('rememberMe');
    }
  }

  void getIdDevice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    OneSignal.shared.setAppId(
        "d51e7b74-eebc-48e9-8af6-a2d1cbd58e33"); // Set your OneSignal app ID here
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
      } else {
        debugPrint("Failed to retrieve Device ID from OneSignal");
      }
    }).catchError((error) {
      debugPrint("Error retrieving Device ID from OneSignal: $error");
    });
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
