// // lib/core/services/storage_service.dart
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive/hive.dart';
// import '../../features/auth/models/user_model.dart';

// class StorageService extends GetxService {
//   late SharedPreferences _prefs;
//   late Box<dynamic> _userBox;

//   Future<StorageService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     _userBox = await Hive.openBox('userBox');
//     return this;
//   }

//   // User Related Storage
//   Future<void> saveUser(User user) async {
//     await _userBox.put('currentUser', user.toJson());
//     await _prefs.setInt('iduser', user.id ?? 0);
//     await _prefs.setString('username', user.username ?? '');
//     await _prefs.setString('name', user.name ?? '');
//     await _prefs.setString('so', user.so ?? '');
//     await _prefs.setString('bu', user.bu ?? '');
//     await _prefs.setInt('editApproval', user.editApproval ?? 0);
//   }

//   Future<User?> getUser() async {
//     final userData = _userBox.get('currentUser');
//     if (userData != null) {
//       return User.fromJson(Map<String, dynamic>.from(userData));
//     }
//     return null;
//   }

//   Future<void> clearUser() async {
//     await _userBox.delete('currentUser');
//     await _prefs.remove('iduser');
//     await _prefs.remove('username');
//     await _prefs.remove('name');
//     await _prefs.remove('so');
//     await _prefs.remove('bu');
//     await _prefs.remove('editApproval');
//   }

//   // Remember Me Related Storage
//   Future<void> saveCredentials(String username, String password) async {
//     await _prefs.setString('savedUsername', username);
//     await _prefs.setString('savedPassword', password);
//     await _prefs.setBool('rememberMe', true);
//   }

//   Future<void> clearCredentials() async {
//     await _prefs.remove('savedUsername');
//     await _prefs.remove('savedPassword');
//     await _prefs.setBool('rememberMe', false);
//   }

//   // Generic Storage Methods
//   Future<void> setString(String key, String value) async {
//     await _prefs.setString(key, value);
//   }

//   Future<void> setBool(String key, bool value) async {
//     await _prefs.setBool(key, value);
//   }

//   Future<void> setInt(String key, int value) async {
//     await _prefs.setInt(key, value);
//   }

//   Future<void> remove(String key) async {
//     await _prefs.remove(key);
//   }

//   String? getString(String key) => _prefs.getString(key);
//   bool? getBool(String key) => _prefs.getBool(key);
//   int? getInt(String key) => _prefs.getInt(key);
// }

// // lib/features/auth/models/user_model.dart
// class User {
//   final int? id;
//   final String? username;
//   final String? name;
//   final String? so;
//   final String? bu;
//   final String? role;
//   final String? message;
//   final int? code;
//   final int? editApproval;

//   User({
//     this.id,
//     this.username,
//     this.name,
//     this.so,
//     this.bu,
//     this.role,
//     this.message,
//     this.code,
//     this.editApproval,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['Id'],
//       username: json['Username'],
//       name: json['Name'],
//       so: json['SO'],
//       bu: json['BU'],
//       role: json['Role'],
//       message: json['message'],
//       code: json['code'],
//       editApproval: json['EditApproval'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'Id': id,
//       'Username': username,
//       'Name': name,
//       'SO': so,
//       'BU': bu,
//       'Role': role,
//       'message': message,
//       'code': code,
//       'EditApproval': editApproval,
//     };
//   }

//   User copyWith({
//     int? id,
//     String? username,
//     String? name,
//     String? so,
//     String? bu,
//     String? role,
//     String? message,
//     int? code,
//     int? editApproval,
//   }) {
//     return User(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       name: name ?? this.name,
//       so: so ?? this.so,
//       bu: bu ?? this.bu,
//       role: role ?? this.role,
//       message: message ?? this.message,
//       code: code ?? this.code,
//       editApproval: editApproval ?? this.editApproval,
//     );
//   }
// }

// // lib/features/auth/services/auth_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../core/constants/api_constants.dart';

// class AuthService {
//   static Future<Map<String, dynamic>> login(String username, String password, String playerId) async {
//     try {
//       final String basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.authUsername}:${ApiConstants.authPassword}'))}';

//       final urlPostLogin = '${ApiConstants.baseURLDevelopment}${ApiConstants.loginEndpoint}?'
//           'username=$username&password=${password.replaceAll("#", "%23")}&playerId=$playerId';

//       final response = await http.post(
//         Uri.parse(urlPostLogin),
//         headers: {'authorization': basicAuth},
//       );

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         if (response.body.isEmpty) {
//           throw Exception('Empty response from server');
//         }
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to login: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Login Error: $e');
//       throw Exception('Error during login: $e');
//     }
//   }

//   static Map<String, String> getAuthHeaders() {
//     final String basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.authUsername}:${ApiConstants.authPassword}'))}';
//     return {'authorization': basicAuth};
//   }
// }

// // lib/features/auth/controllers/auth_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/services/storage_service.dart';
// import '../services/auth_service.dart';
// import '../models/user_model.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// class AuthController extends GetxController {
//   final StorageService _storage = Get.find<StorageService>();

//   // Form Controllers
//   final formKey = GlobalKey<FormState>();
//   final usernameController = TextEditingController(text: kIsWeb ? "gs002" : null);
//   final passwordController = TextEditingController(text: kIsWeb ? "prambanan1!" : null);

//   // Focus Nodes
//   final usernameFocus = FocusNode();
//   final passwordFocus = FocusNode();

//   // Observable Variables
//   final RxBool obscureText = true.obs;
//   final RxBool rememberMe = false.obs;
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString playerId = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     initializeController();
//   }

//   Future<void> initializeController() async {
//     await loadSavedCredentials();
//     await initializeOneSignal();
//     await getPlayerID();
//   }

//   Future<void> initializeOneSignal() async {
//     OneSignal.shared.setAppId("YOUR_ONESIGNAL_APP_ID");
//     OneSignal.shared.setNotificationWillShowInForegroundHandler(
//       (OSNotificationReceivedEvent event) {
//         event.complete(event.notification);
//       },
//     );

//     OneSignal.shared.getDeviceState().then((deviceState) {
//       if (deviceState?.userId != null) {
//         _storage.setString("idDevice", deviceState!.userId!);
//       }
//     });
//   }

//   Future<void> getPlayerID() async {
//     playerId.value = await _storage.getString("getPlayerID") ?? "";
//   }

//   Future<void> loadSavedCredentials() async {
//     rememberMe.value = await _storage.getBool('rememberMe') ?? false;
//     if (rememberMe.value) {
//       usernameController.text = await _storage.getString('savedUsername') ?? '';
//       passwordController.text = await _storage.getString('savedPassword') ?? '';
//     }
//   }

//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) return;

//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final response = await AuthService.login(
//         usernameController.text,
//         passwordController.text,
//         playerId.value
//       );

//       final user = User.fromJson(response);

//       if (user.code == 200) {
//         await saveUserData(user);
//         await handleRememberMe();
//         navigateBasedOnRole(user);
//       } else {
//         errorMessage.value = user.message ?? 'Login failed';
//         Get.snackbar(
//           'Error',
//           errorMessage.value,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       Get.snackbar(
//         'Error',
//         'Login failed: ${errorMessage.value}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> saveUserData(User user) async {
//     await _storage.saveUser(user);
//   }

//   Future<void> handleRememberMe() async {
//     if (rememberMe.value) {
//       await _storage.saveCredentials(
//         usernameController.text,
//         passwordController.text
//       );
//     } else {
//       await _storage.clearCredentials();
//     }
//   }

//   void navigateBasedOnRole(User user) {
//     if (user.role == "0") {
//       Get.offAllNamed('/dashboard/employee', arguments: {
//         'username': user.username,
//         'iduser': user.id,
//         'so': user.so,
//         'bu': user.bu,
//       });
//     } else if (user.role == "1" || user.role == "2") {
//       Get.offAllNamed('/dashboard/manager', arguments: {
//         'username': user.username,
//         'role': user.role,
//       });
//     } else {
//       throw Exception("Invalid user role");
//     }
//   }

//   void togglePasswordVisibility() {
//     obscureText.toggle();
//   }

//   @override
//   void onClose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     usernameFocus.dispose();
//     passwordFocus.dispose();
//     super.onClose();
//   }
// }

// // lib/features/auth/views/login_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import 'widgets/login_form.dart';

// class LoginView extends GetView<AuthController> {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: LoginForm(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // lib/features/auth/views/widgets/login_form.dart
// class LoginForm extends GetView<AuthController> {
//   const LoginForm({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: controller.formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(),
//           const SizedBox(height: 15),
//           _buildUsernameField(),
//           const SizedBox(height: 10),
//           _buildPasswordField(),
//           const SizedBox(height: 10),
//           _buildRememberMeCheckbox(),
//           const SizedBox(height: 20),
//           _buildLoginButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo() {
//     return Image.asset(
//       'assets/images/prb-icon.png',
//       height: 120,
//       fit: BoxFit.contain,
//     );
//   }

//   Widget _buildUsernameField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 45),
//       child: TextFormField(
//         controller: controller.usernameController,
//         focusNode: controller.usernameFocus,
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.emailAddress,
//         decoration: InputDecoration(
//           hintText: 'Username',
//           filled: true,
//           contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(32.0),
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter Username!!';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 45),
//       child: Obx(() => TextFormField(
//         controller: controller.passwordController,
//         focusNode: controller.passwordFocus,
//         obscureText: controller.obscureText.value,
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//           hintText: 'Password',
//           filled: true,
//           contentPadding: const EdgeInsets.fromLTRB(65.0, 10.0, 20.0, 10.0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(32.0),
//           ),
//           suffixIcon: IconButton(
//             icon: Icon(
//               controller.obscureText.value
//                 ? Icons.visibility_off
//                 : Icons.visibility,
//               color: Theme.of(Get.context!).primaryColorDark,
//             ),
//             onPressed: controller.togglePasswordVisibility,
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter Password!!';
//           }
//           return null;
//         },
//       )),
//     );
//   }

//   Widget _buildRememberMeCheckbox() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 65),
//       child: Obx(() => CheckboxListTile(
//         title: const Text(
//           "Remember Me",
//           style: TextStyle(fontSize: 14),
//         ),
//         value: controller.rememberMe.value,
//         onChanged: (value) => controller.rememberMe.value = value ?? false,
//         controlAffinity: ListTileControlAffinity.leading,
//       )),
//     );
//   }

//   Widget _buildLoginButton() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 55),
//       height: 45,
//       child: Obx(() => ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(50)),
//           ),
//           backgroundColor: Theme.of(Get.context!).primaryColor,
//         ),
//         onPressed: controller.isLoading.value ? null : controller.login,
//         child: controller.isLoading.value
//           ? const SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 strokeWidth: 2,
//               ),
//             )
//           : const Text(
//               "Login",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//       )),
//     );
//   }
// }

// // lib/features/auth/bindings/auth_binding.dart
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';

// class AuthBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<AuthController>(() => AuthController());
//   }
// }

// // lib/routes/app_routes.dart
// import 'package:get/get.dart';
// import '../features/auth/views/login_view.dart';
// import '../features/auth/bindings/auth_binding.dart';
// import '../features/dashboard/employee/views/dashboard_employee_view.dart';
// import '../features/dashboard/manager/views/dashboard_manager_view.dart';
// import '../features/dashboard/employee/bindings/dashboard_employee_binding.dart';
// import '../features/dashboard/manager/bindings/dashboard_manager_binding.dart';

// class AppRoutes {
//   static const String LOGIN = '/login';
//   static const String DASHBOARD_EMPLOYEE = '/dashboard/employee';
//   static const String DASHBOARD_MANAGER = '/dashboard/manager';

//   static final List<GetPage> pages = [
//     GetPage(
//       name: LOGIN,
//       page: () => const LoginView(),
//       binding: AuthBinding(),
//     ),
//     GetPage(
//       name: DASHBOARD_EMPLOYEE,
//       page: () => const DashboardEmployeeView(),
//       binding: DashboardEmployeeBinding(),
//       middlewares: [AuthMiddleware()],
//     ),
//     GetPage(
//       name: DASHBOARD_MANAGER,
//       page: () => const DashboardManagerView(),
//       binding: DashboardManagerBinding(),
//       middlewares: [AuthMiddleware()],
//     ),
//   ];
// }

// // lib/routes/middleware/auth_middleware.dart
// class AuthMiddleware extends GetMiddleware {
//   @override
//   RouteSettings? redirect(String? route) {
//     final storageService = Get.find<StorageService>();
//     final user = storageService.getUser();

//     if (user == null && route != AppRoutes.LOGIN) {
//       return const RouteSettings(name: AppRoutes.LOGIN);
//     }
//     return null;
//   }
// }

// // lib/models/user_model.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import '../core/constants/api_constants.dart';
// import '../core/constants/app_constants.dart';

// part 'user.g.dart';

// @HiveType(typeId: 0)
// class User {
//   @HiveField(0)
//   final int id;
//   @HiveField(1)
//   final String username;
//   @HiveField(2)
//   final String? password;
//   @HiveField(3)
//   final String fullname;
//   @HiveField(4)
//   final String level;
//   @HiveField(5)
//   final String roles;
//   @HiveField(6)
//   final String? approvalRoles;
//   @HiveField(7)
//   final String? brand;
//   @HiveField(8)
//   final String? custSegment;
//   @HiveField(9)
//   final String? businessUnit;
//   @HiveField(10)
//   final String? token;
//   @HiveField(11)
//   final String? message;
//   @HiveField(12)
//   final int? code;
//   @HiveField(13)
//   final User? user;
//   @HiveField(14)
//   final dynamic so;
//   @HiveField(15)
//   final String? bu;
//   @HiveField(16)
//   final String? name;
//   @HiveField(17)
//   final String? role;
//   @HiveField(18)
//   final String Username;

//   User({
//     this.id = 0,
//     this.username = '',
//     this.Username = '',
//     this.password,
//     this.fullname = '',
//     this.level = '',
//     this.roles = '',
//     this.approvalRoles,
//     this.brand,
//     this.custSegment,
//     this.businessUnit,
//     this.token,
//     this.message,
//     this.code,
//     this.user,
//     this.so,
//     this.bu,
//     this.name,
//     this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] ?? 0,
//       username: json['username'] ?? '',
//       Username: json['Username'] ?? '',
//       password: json['password'],
//       fullname: json['fullname'] ?? '',
//       level: json['level'] ?? '',
//       roles: json['roles'] ?? '',
//       approvalRoles: json['approvalRoles'],
//       brand: json['brand'],
//       custSegment: json['custSegment'],
//       businessUnit: json['businessUnit'],
//       token: json['token'],
//       message: json['message'],
//       code: json['code'],
//       user: json['user'] != null ? User.fromJson(json['user']) : null,
//       so: json['so'],
//       bu: json['BU'],
//       name: json['Name'],
//       role: json['Role'],
//     );
//   }

//   Future<User?> login(String username, String password) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? idDevice = prefs.getString("idDevice") ?? await getDeviceId();

//       final url = "${ApiConstants.baseURLDevelopment}Login?username=$username&password=${password.replaceAll("#", "%23")}&playerId=$idDevice";

//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       );

//       if (response.body.isEmpty) {
//         return null;
//       }

//       return User.fromJson(jsonDecode(response.body));
//     } catch (e) {
//       debugPrint('Login error: $e');
//       return null;
//     }
//   }

//   Future<void> saveUserToPrefs(User user, String username, String password, bool rememberMe) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString("Username", user.Username);
//       await prefs.setString("username", user.username);
//       await prefs.setInt("iduser", user.id);
//       await prefs.setString("name", user.name ?? '');
//       await prefs.setString("so", user.so?.toString() ?? '');
//       await prefs.setString("bu", user.bu ?? '');
//       await prefs.setString("role", user.role ?? '');
//     } catch (e) {
//       debugPrint('Save user preferences error: $e');
//     }
//   }

//   static Future<String?> getDeviceId() async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       OneSignal.shared.setAppId(AppConstants.appId);
//       await Future.delayed(const Duration(seconds: 2));

//       OSDeviceState? deviceState = await OneSignal.shared.getDeviceState();
//       if (deviceState != null && deviceState.userId != null) {
//         String deviceId = deviceState.userId!;
//         preferences.setString("idDevice", deviceId);
//         return deviceId;
//       } else {
//         throw Exception("Failed to retrieve Device ID from OneSignal");
//       }
//     } catch (error) {
//       debugPrint('Get device ID error: $error');
//       return null;
//     }
//   }

//   static Future<User> getUsers(String username, String password) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? idDevice = prefs.getString("idDevice") ?? await getDeviceId();

//       if (idDevice == null) {
//         throw Exception("Device ID not found. Ensure it is stored properly.");
//       }

//       String url = "${ApiConstants.apiCons}/api/LoginSMS?playerId=$idDevice";
//       Map<String, dynamic> dataLogin = {
//         "username": username,
//         "password": password
//       };

//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode(dataLogin),
//       );

//       if (response.statusCode == 200) {
//         return _handleSuccessfulLogin(response, prefs);
//       } else {
//         throw Exception('Failed to login: ${response.statusCode}');
//       }
//     } catch (error) {
//       throw Exception("Failed to login: $error");
//     }
//   }

//   static User _handleSuccessfulLogin(http.Response response, SharedPreferences prefs) {
//     try {
//       dynamic jsonObject = json.decode(response.body);
//       User user = User.fromJson(jsonObject);

//       prefs.setString("username", user.username);
//       prefs.setString("token", user.token ?? '');
//       prefs.setInt("userid", user.id);
//       prefs.setString("bu", user.bu ?? '');
//       prefs.setString("so", user.so.toString());

//       debugPrint(response.body);
//       debugPrint(user.bu);

//       return user;
//     } catch (e) {
//       throw Exception("Failed to process login response: $e");
//     }
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'Username': Username,
//       'password': password,
//       'fullname': fullname,
//       'level': level,
//       'roles': roles,
//       'approvalRoles': approvalRoles,
//       'brand': brand,
//       'custSegment': custSegment,
//       'businessUnit': businessUnit,
//       'token': token,
//       'message': message,
//       'code': code,
//       'user': user?.toJson(),
//       'so': so,
//       'BU': bu,
//       'Name': name,
//       'Role': role,
//     };
//   }
// }

class SalesOffice {
  final String name;
  // final String code;

  SalesOffice({
    required this.name,
  });

  factory SalesOffice.fromJson(Map<String, dynamic> json) {
    return SalesOffice(
      name: json['NameSO'] ?? 'Unknown',
      // code: json['CodeSO'] ?? 'Unknown',
    );
  }
}

class BusinessUnit {
  final String name;

  BusinessUnit({required this.name});

  factory BusinessUnit.fromJson(Map<String, dynamic> json) {
    return BusinessUnit(name: json['NameBU'] ?? 'Unknown');
  }
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] ?? 'Unknown');
  }
}

class Category2 {
  final String master;

  Category2({required this.master});

  factory Category2.fromJson(Map<String, dynamic> json) {
    return Category2(master: json['MASTER_SETUP'] ?? 'Unknown');
  }
}

class AXRegional {
  final String regional;

  AXRegional({required this.regional});

  factory AXRegional.fromJson(Map<String, dynamic> json) {
    return AXRegional(regional: json['REGIONAL'] ?? 'Unknown');
  }
}

class Segment {
  final String segmentId;

  Segment({required this.segmentId});

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(segmentId: json['SEGMENTID'] ?? 'Unknown');
  }
}

class SubSegment {
  final String subSegmentId;

  SubSegment({required this.subSegmentId});

  factory SubSegment.fromJson(Map<String, dynamic> json) {
    return SubSegment(subSegmentId: json['SUBSEGMENTID'] ?? 'Unknown');
  }
}

class ClassModel {
  final String className;

  ClassModel({required this.className});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(className: json['CLASS'] ?? 'Unknown');
  }
}

class CompanyStatus {
  final String chainId;

  CompanyStatus({required this.chainId});

  factory CompanyStatus.fromJson(Map<String, dynamic> json) {
    return CompanyStatus(chainId: json['CHAINID'] ?? 'Unknown');
  }
}

class PriceGroup {
  final String groupId;

  PriceGroup({required this.groupId});

  factory PriceGroup.fromJson(Map<String, dynamic> json) {
    return PriceGroup(groupId: json['GROUPID'] ?? 'Unknown');
  }
}

class Currency {
  final String currencyCode;

  Currency({required this.currencyCode});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(currencyCode: json['CurrencyCode'] ?? 'Unknown');
  }
}

class CustomerPaymentMode {
  final String paymentMode;

  CustomerPaymentMode({required this.paymentMode});

  factory CustomerPaymentMode.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentMode(paymentMode: json['PAYMMODE'] ?? 'Unknown');
  }
}
