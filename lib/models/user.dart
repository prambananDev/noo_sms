// user.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/app_id.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user.g.dart';

@HiveType(typeId: 0) // Unique typeId for Hive
class User {
  @HiveField(0)
  int id;
  @HiveField(1)
  String username;
  @HiveField(2)
  String? password;
  @HiveField(3)
  String fullname;
  @HiveField(4)
  String level;
  @HiveField(5)
  String roles;
  @HiveField(6)
  String? approvalRoles;
  @HiveField(7)
  String? brand;
  @HiveField(8)
  String? custSegment;
  @HiveField(9)
  String? businessUnit;
  @HiveField(10)
  String? token;
  @HiveField(11)
  String? message;
  @HiveField(12)
  int? code;
  @HiveField(13)
  User? user;
  @HiveField(14)
  dynamic so;
  @HiveField(15)
  String? bu;
  @HiveField(16)
  String? name;
  @HiveField(17)
  String? role;

  User({
    this.id = 0,
    this.username = '',
    this.password,
    this.fullname = '',
    this.level = '',
    this.roles = '',
    this.approvalRoles,
    this.brand,
    this.custSegment,
    this.businessUnit,
    this.token,
    this.message,
    this.code,
    this.user,
    this.so,
    this.bu,
    this.name,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['Username'] ??
          '', // Ensure correct field name as per API response
      password: json['password'],
      fullname: json['fullname'] ?? '',
      level: json['level'] ?? '',
      roles: json['roles'] ?? '',
      approvalRoles: json['approvalRoles'],
      brand: json['brand'],
      custSegment: json['custSegment'],
      businessUnit: json['businessUnit'],
      token: json['token'],
      message: json['message'],
      code: json['code'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      so: json['SO'], // Ensure field names match the JSON structure
      bu: json['BU'],
      name: json['Name'],
      role: json[
          'Role'], // Ensure this correctly captures the role field as a string
    );
  }

  // Handles login functionality
  Future<User?> login(
    String username,
    String password,
  ) async {
    final url =
        "${baseURLDevelopment}Login?username=$username&password=${password.replaceAll("#", "%23")}&playerId=";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    debugPrint("API Login URL: $url");
    debugPrint("API Responses: ${response.statusCode}\n${response.body}");
    if (response.body.isEmpty) {
      debugPrint("kosong");
      return null;
    }
    return User.fromJson(jsonDecode(response.body));
  }

  // Saves user data to shared preferences
  Future<void> saveUserToPrefs(
      User user, String username, String password, bool rememberMe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("iduser", user.id);
    prefs.setString("username", username);
    prefs.setString("password", password);
    prefs.setString("name", user.name ?? '');
    prefs.setString("so", user.so?.toString() ?? '');
    prefs.setString("bu", user.bu ?? '');
    prefs.setString("role", user.role ?? '');

    if (rememberMe) {
      prefs.setString("savedUsername", username);
      prefs.setString("savedPassword", password);
    } else {
      prefs.remove("savedUsername");
      prefs.remove("savedPassword");
    }
  }

  // Retrieves the Player ID from Shared Preferences or OneSignal
  static Future<String?> getDeviceId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      OneSignal.shared.setAppId(appId);
      await Future.delayed(const Duration(seconds: 2));

      OSDeviceState? deviceState = await OneSignal.shared.getDeviceState();
      if (deviceState != null && deviceState.userId != null) {
        String deviceId = deviceState.userId!;
        preferences.setString("idDevice", deviceId);
        return deviceId;
      } else {
        throw Exception("Failed to retrieve Device ID from OneSignal");
      }
    } catch (error) {
      debugPrint("Error getting Device ID: $error");
      return null;
    }
  }

  // Fetches user data from the API
  Future<User> getUsers(String username, String password, int code) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? idDevice = prefs.getString("idDevice") ?? await getDeviceId();

      if (idDevice == null) {
        throw Exception("Device ID not found. Ensure it is stored properly.");
      }

      String url = "${ApiConstant(code).urlApi}api/LoginSMS?playerId=$idDevice";
      debugPrint("API Login URL: $url");
      dynamic dataLogin = {"username": username, "password": password};

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dataLogin),
      );

      debugPrint("API Response: ${response.statusCode}\n${response.body}");
      // login(username, password, idDevice);
      if (response.statusCode == 200) {
        return _handleSuccessfulLogin(response, prefs);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error during login: $error");
      throw Exception("Failed to login: $error");
    }
  }

  // Handles successful login response and saves data
  static User _handleSuccessfulLogin(
      http.Response response, SharedPreferences prefs) {
    dynamic jsonObject = json.decode(response.body);
    User user = User.fromJson(jsonObject);

    prefs.setString("username", user.username);
    prefs.setString("token", user.token ?? '');
    prefs.setInt("userid", user.id);
    prefs.setString("so", user.so.toString());

    debugPrint("Login successful for user: ${user.username}");
    return user;
  }

  // Retrieves the current play store version from the API
  Future<Map<String, dynamic>> getPlayStoreVersion() async {
    var response =
        await http.get(Uri.parse("${baseURLDevelopment}PlaystoreVersions"));
    return jsonDecode(response.body)[0];
  }
}
