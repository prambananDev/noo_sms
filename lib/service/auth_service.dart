import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/noo_user.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/app_id.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<String?> getDeviceId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedId = prefs.getString("idDevice");
      if (cachedId != null && cachedId.isNotEmpty) {
        return cachedId;
      }

      OneSignal.initialize(appId);
      await OneSignal.Notifications.requestPermission(true);
      await Future.delayed(const Duration(seconds: 2));

      final pushSubscription = OneSignal.User.pushSubscription;
      if (pushSubscription.id != null) {
        String deviceId = pushSubscription.id!;
        await prefs.setString("idDevice", deviceId);
        return deviceId;
      }
    } catch (e) {}
    return null;
  }

  Future<LoginResult> login(String username, String password) async {
    try {
      String? deviceId = await getDeviceId();
      if (deviceId == null) {
        return LoginResult(
          success: false,
          message: "Could not retrieve device ID",
        );
      }

      User? nooUser = await _loginNOO(username, password, deviceId);
      if (nooUser == null) {
        return LoginResult(
          success: false,
          message: "Invalid username or password",
        );
      }

      User? smsUser;
      SCSUser? scsUser;

      try {
        smsUser = await _loginSMS(username, password, deviceId);
      } catch (smsError) {}

      try {
        scsUser = await _loginSCS(username, password);
      } catch (scsError) {}

      await _storeLoginSession(nooUser, smsUser, scsUser);

      String message = "Login successful";
      if (smsUser == null) {
        message += " (SMS integration incomplete)";
      }
      if (scsUser == null) {
        message += " (SCS integration incomplete)";
      }

      return LoginResult(
        success: true,
        user: nooUser,
        message: message,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: "Login failed: ${e.toString()}",
      );
    }
  }

  Future<User?> _loginNOO(
      String username, String password, String deviceId) async {
    try {
      final url =
          "${apiNOO}Login?username=$username&password=${password.replaceAll("#", "%23")}&playerId=$deviceId";

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> jsonObject = json.decode(response.body);
        return User.fromJson(jsonObject);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User> _loginSMS(
      String username, String password, String deviceId) async {
    final url = "$apiSMS/LoginSMS?playerId=$deviceId";
    final Map<String, dynamic> dataLogin = {
      "username": username,
      "password": password
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dataLogin),
    );

    if (response.statusCode == 200) {
      dynamic jsonObject = json.decode(response.body);
      return User.fromJson(jsonObject);
    } else {
      throw Exception('SMS Login failed: ${response.statusCode}');
    }
  }

  Future<SCSUser> _loginSCS(String username, String password) async {
    try {
      final url = "$apiSCS/api/Login";
      var bodyLogin = jsonEncode({"username": username, "password": password});

      final response = await http.post(
        Uri.parse(url),
        body: bodyLogin,
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonObject = json.decode(response.body);
        String? message = jsonObject['message'];
        String? token = jsonObject['token'] ?? '';

        if (message != null && message.contains('_')) {
          List<String> result = message.split('_');
          if (result.length >= 5) {
            return SCSUser(
              idEmp: result[2],
              idSales: result[2],
              name: result[3],
              wh: result[4],
              token: token,
            );
          }
        }
      }
      throw Exception('SCS Login failed: Invalid response format');
    } catch (e) {
      throw Exception('SCS Login failed: ${e.toString()}');
    }
  }

  Future<void> _storeLoginSession(
    User nooUser,
    User? smsUser,
    SCSUser? scsUser,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Store NOO user data
      await _storeNOOUserData(nooUser, prefs);

      // Store SMS user data if available
      if (smsUser != null) {
        await _storeSMSUserData(smsUser, prefs);
      }

      // Store SCS user data if available
      if (scsUser != null) {
        await _storeSCSUserData(scsUser, prefs);
      }
    } catch (e) {
      throw Exception("Failed to store login session: $e");
    }
  }

  Future<SCSUser?> getSCSUserData(String username, String password) async {
    try {
      return await _loginSCS(username, password);
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeNOOUserData(User user, SharedPreferences prefs) async {
    try {
      prefs.setInt("id", user.id ?? 0);
      prefs.setString("Username", user.username ?? '');
      prefs.setString("Role", user.role ?? '');
      prefs.setString("SO", user.SO ?? '');
      prefs.setString("BU", user.bu ?? '');
      prefs.setInt("ApprovalRole", user.approvalRole ?? 0);
      prefs.setInt("EditApproval", user.editApproval ?? 0);
    } catch (e) {
      throw Exception("Failed to store NOO user data");
    }
  }

  Future<void> _storeSMSUserData(User user, SharedPreferences prefs) async {
    try {
      prefs.setString("username", user.username ?? '');
      prefs.setString("fullname", user.fullname ?? '');
      prefs.setString("token", user.token ?? '');
      prefs.setInt("userid", user.id ?? 0);
      prefs.setString("bu", user.bu ?? '');
      prefs.setString("so", user.so?.toString() ?? '');

      // Store in Hive
      try {
        var dir = await getApplicationDocumentsDirectory();
        if (!Hive.isBoxOpen('users')) {
          Hive.init(dir.path);
        }

        Box userBox = await Hive.openBox('users');
        await userBox.clear(); // Clear existing data
        await userBox.add(user);
      } catch (e) {
        // Continue since SharedPreferences worked
      }
    } catch (e) {
      throw Exception("Failed to store SMS user data: $e");
    }
  }

  Future<void> _storeSCSUserData(SCSUser user, SharedPreferences prefs) async {
    try {
      prefs.setString("scs_idEmp", user.idEmp ?? '');
      prefs.setString("scs_idSales", user.idSales ?? '');
      prefs.setString("scs_name", user.name ?? '');
      prefs.setString("scs_wh", user.wh ?? '');
      prefs.setString("scs_token", user.token ?? '');

      // Store in Hive
      try {
        var dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);

        // Clear existing box first
        Box scsBox = await Hive.openBox('scs_users');
        await scsBox.clear();

        // Add new user data
        await scsBox.add(user);
      } catch (e) {
        // Don't throw here, as SharedPreferences data is still saved
      }
    } catch (e) {
      throw Exception("Failed to store SCS user data");
    }
  }

  Future<SCSUser?> getCachedSCSUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idEmp = prefs.getString('scs_idEmp');

      if (idEmp != null && idEmp.isNotEmpty) {
        return SCSUser(
          idEmp: prefs.getString('scs_idEmp'),
          idSales: prefs.getString('scs_idSales'),
          name: prefs.getString('scs_name'),
          wh: prefs.getString('scs_wh'),
          token: prefs.getString('scs_token'),
        );
      }

      Box scsBox = await Hive.openBox('scs_users');
      if (scsBox.isNotEmpty) {
        return scsBox.getAt(scsBox.length - 1) as SCSUser?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString("username");

      if (username != null) {
        String url = "$apiSCS/api/Logout?username=$username";
        await http.post(
          Uri.parse(url),
          headers: {'content-type': 'application/json'},
        );
      }

      // Clear user data
      Box userBox = await Hive.openBox('users');
      await userBox.clear();

      // Clear SCS data
      try {
        Box scsBox = await Hive.openBox('scs_users');
        await scsBox.clear();
      } catch (e) {}

      // Clear preferences
      await prefs.clear();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') != null;
    } catch (e) {
      return false;
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final User? user;

  LoginResult({
    required this.success,
    required this.message,
    this.user,
  });
}
