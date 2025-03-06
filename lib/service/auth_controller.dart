import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/service/auth_service.dart';
import 'package:noo_sms/view/dashboard/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoggingIn = false.obs;

  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    loadRememberMeStatus();
    checkAutoLogin();
  }

  Future<void> loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('rememberMe') ?? false;

    if (rememberMe.value) {
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<void> checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> toggleRememberMe(bool value) async {
    rememberMe.value = value;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);

    if (!value) {
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  void showNotRegisteredDialog({String? apiName}) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Akun Tidak Terdaftar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apiName != null
                    ? 'Akun Anda tidak terdaftar pada sistem $apiName.'
                    : 'Akun Anda tidak terdaftar pada sistem.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Silakan hubungi Tim IT untuk bantuan pendaftaran akun.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[800],
            ),
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showWrongCredentialsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your username or password is incorrect.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4389),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> login() async {
    if (isLoggingIn.value) return;
    if (!formKey.currentState!.validate()) return;

    try {
      isLoggingIn.value = true;

      if (rememberMe.value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', usernameController.text);
        await prefs.setString('password', passwordController.text);
      }

      final result = await _authService.login(
        usernameController.text,
        passwordController.text,
      );

      if (result.success) {
        Get.offAll(() => const DashboardMain());
      } else {
        if (result.message.contains("Invalid username or password") ||
            result.message.contains("incorrect") ||
            result.message.contains("wrong password")) {
          showWrongCredentialsDialog();
        } else if (result.message.contains("not found") ||
            result.message.contains("tidak terdaftar") ||
            result.message.contains("not registered")) {
          String? apiName;
          if (result.message.toLowerCase().contains("noo")) {
            apiName = "NOO";
          } else if (result.message.toLowerCase().contains("sms")) {
            apiName = "SMS";
          } else if (result.message.toLowerCase().contains("scs")) {
            apiName = "SCS";
          }

          showNotRegisteredDialog(apiName: apiName);
        } else {
          Get.snackbar(
            'Login Failed',
            result.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoggingIn.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
