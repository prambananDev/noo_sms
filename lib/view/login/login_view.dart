import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/service/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: 24,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icons/logo.png',
                      height: isTablet ? 60 : 40,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.07),
                  Text(
                    'Hi,',
                    style: TextStyle(
                      fontSize: isTablet ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: isTablet ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: controller.usernameController,
                    focusNode: controller.usernameFocus,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      fillColor: const Color(0xFFF5F7FA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 18 : 14,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: controller.validateUsername,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(controller.passwordFocus),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Kata Sandi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocus,
                        decoration: InputDecoration(
                          hintText: 'Tulis kata sandi',
                          fillColor: const Color(0xFFF5F7FA),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isTablet ? 18 : 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF1E4389),
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        obscureText: controller.obscureText.value,
                        validator: controller.validatePassword,
                        onFieldSubmitted: (_) => controller.login(),
                      )),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) =>
                                controller.toggleRememberMe(value ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Color(0xFFCCCCCC)),
                            activeColor: colorAccent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          )),
                      SizedBox(width: screenWidth * 0.01),
                      const Text(
                        'Remember Me',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoggingIn.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFF1E4389).withOpacity(0.7),
                        ),
                        child: controller.isLoggingIn.value
                            ? SizedBox(
                                height: isTablet ? 24 : 20,
                                width: isTablet ? 24 : 20,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
