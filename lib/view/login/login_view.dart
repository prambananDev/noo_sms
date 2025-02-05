import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/login/login_controller.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final LoginController _controller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      _controller.setLoginProvider(loginProvider);
      _controller.loadRememberMeStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double scaleWidth(double width) => width * screenWidth / 375;
    double scaleHeight(double height) => height * screenHeight / 812;
    double scaleFont(double fontSize) => fontSize * screenWidth / 375;

    return Scaffold(
      backgroundColor: colorNetral,
      body: Form(
        key: _controller.formKey,
        child: Padding(
          padding: EdgeInsets.all(scaleWidth(20)),
          child: Stack(
            children: <Widget>[
              ClipPath(
                child: Container(
                  height: scaleHeight(450),
                  padding: EdgeInsets.all(scaleHeight(10)),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(scaleWidth(90))),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: scaleHeight(20)),
                      TextFormField(
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please, insert your Username';
                          }
                          return null;
                        },
                        controller: _controller.usernameController,
                        textInputAction: TextInputAction.next,
                        focusNode: _controller.usernameFocus,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _controller.usernameFocus,
                              _controller.passwordFocus);
                        },
                        style: TextStyle(
                          fontSize: scaleFont(15),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Insert your username AX',
                          labelText: 'Username*',
                          errorStyle: TextStyle(
                              color: Colors.red, fontSize: scaleFont(13)),
                          hintStyle: TextStyle(
                              color: Colors.grey, fontSize: scaleFont(15)),
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: scaleFont(17)),
                          border: InputBorder.none,
                          icon: Icon(Icons.person_pin,
                              color: Theme.of(context).primaryColorDark),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).primaryColorDark,
                          thickness: 1),
                      Obx(() => TextFormField(
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please, insert your Password';
                              }
                              return null;
                            },
                            obscureText: _controller.obscureText.value,
                            controller: _controller.passwordController,
                            textInputAction: TextInputAction.done,
                            focusNode: _controller.passwordFocus,
                            onFieldSubmitted: (term) {
                              _controller.passwordFocus.unfocus();
                            },
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: scaleFont(15)),
                            decoration: InputDecoration(
                              hintText: 'Insert your password',
                              labelText: 'Password*',
                              errorStyle: TextStyle(
                                  color: Colors.red, fontSize: scaleFont(13)),
                              hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: scaleFont(15)),
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: scaleFont(17)),
                              border: InputBorder.none,
                              icon: Icon(Icons.lock,
                                  color: Theme.of(context).primaryColorDark),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _controller.obscureText.value =
                                      !_controller.obscureText.value;
                                },
                                child: Icon(_controller.obscureText.value
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                          )),
                      Divider(
                          color: Theme.of(context).primaryColorDark,
                          thickness: 1),
                      Obx(() => CheckboxListTile(
                            title: const Text("Remember me"),
                            value: _controller.rememberMe.value,
                            onChanged: (newValue) {
                              _controller.rememberMe.value = newValue ?? false;
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          )),
                      Obx(() => ElevatedButton(
                            onPressed: _controller.isLoggingIn.value
                                ? null
                                : () async {
                                    if (_controller.formKey.currentState!
                                        .validate()) {
                                      await _controller.login(
                                        _controller.rememberMe.value,
                                        _controller.usernameController.text,
                                        _controller.passwordController.text,
                                        context,
                                      );
                                    }
                                  },
                            child: _controller.isLoggingIn.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text("LOGIN"),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
