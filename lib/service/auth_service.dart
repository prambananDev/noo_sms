import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:noo_sms/models/noo_user.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
    } catch (e) {
      debugPrint("Error getting device ID: $e");
    }
    return null;
  }

  Future<LoginResult> login(String username, String password) async {
    try {
      String? deviceId = await getDeviceId();
      if (deviceId == null) {
        return LoginResult(
            success: false, message: "Could not retrieve device ID");
      }

      User? nooUser = await _loginNOO(username, password, deviceId);
      if (nooUser == null) {
        return LoginResult(
            success: false, message: "Invalid username or password");
      }

      try {
        User smsUser = await _loginSMS(username, password, deviceId);

        SCSUser? scsUser;
        try {
          scsUser = await _loginSCS(username, password);
        } catch (scsError) {
          debugPrint("SCS Login error: $scsError");
        }

        await _storeLoginSession(nooUser, smsUser, scsUser);

        return LoginResult(
            success: true, user: nooUser, message: "Login successful");
      } catch (smsError) {
        debugPrint("SMS Login error: $smsError");

        SCSUser? scsUser;
        try {
          scsUser = await _loginSCS(username, password);
        } catch (scsError) {
          debugPrint("SCS Login error: $scsError");
        }

        await _storeLoginSession(nooUser, null, scsUser);

        return LoginResult(
            success: true,
            user: nooUser,
            message: "Login successful (SMS integration incomplete)");
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return LoginResult(
          success: false, message: "Login failed: ${e.toString()}");
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
      debugPrint("NOO Login error: $e");
      return null;
    }
  }

  Future<User> _loginSMS(
      String username, String password, String deviceId) async {
    final url = "$apiSMS/api/LoginSMS?playerId=$deviceId";
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
      debugPrint("Error fetching SCS data: $e");
      throw Exception('SCS Login failed: ${e.toString()}');
    }
  }

  Future<void> _storeLoginSession(
      User nooUser, User? smsUser, SCSUser? scsUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Box userBox = await Hive.openBox('users');

    prefs.setInt("id", nooUser.id ?? 0);
    prefs.setString("Username", nooUser.username ?? '');
    prefs.setString("Role", nooUser.role ?? '');
    prefs.setString("SO", nooUser.SO ?? '');
    prefs.setString("BU", nooUser.bu ?? '');
    prefs.setInt("ApprovalRole", nooUser.approvalRole ?? 0);
    prefs.setInt("EditApproval", nooUser.editApproval ?? 0);

    if (smsUser != null) {
      prefs.setString("username", smsUser.username!);
      prefs.setString("fullname", smsUser.fullname ?? '');
      prefs.setString("token", smsUser.token ?? '');
      prefs.setInt("userid", smsUser.id!);
      prefs.setString("bu", smsUser.bu ?? '');
      prefs.setString("so", smsUser.so.toString());

      userBox.add(smsUser);

      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('ddMMyyyy');
      final String dateLogin = formatter.format(now);

      prefs.setInt("code", 1);
      prefs.setString("date", dateLogin);
      prefs.setInt("flag", 1);
      prefs.setString("result", "");
    }

    if (scsUser != null) {
      Box scsBox = await Hive.openBox('scs_users');
      scsBox.add(scsUser);

      prefs.setString("scs_idEmp", scsUser.idEmp ?? '');
      prefs.setString("scs_idSales", scsUser.idSales ?? '');
      prefs.setString("scs_name", scsUser.name ?? '');
      prefs.setString("scs_wh", scsUser.wh ?? '');
      prefs.setString("scs_token", scsUser.token ?? '');
    }
  }

  Future<SCSUser?> getSCSUserData(String username, String password) async {
    try {
      return await _loginSCS(username, password);
    } catch (e) {
      debugPrint("Error fetching SCS data: $e");
      return null;
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
      debugPrint("Error getting cached SCS user: $e");
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
      } catch (e) {
        debugPrint("Error clearing SCS box: $e");
      }

      // Clear preferences
      await prefs.clear();

      return true;
    } catch (e) {
      debugPrint("Logout error: $e");
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
