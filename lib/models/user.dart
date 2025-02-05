import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/app_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? username;
  @HiveField(2)
  final String? password;
  @HiveField(3)
  final String? fullname;
  @HiveField(4)
  final String? level;
  @HiveField(5)
  final String? roles;
  @HiveField(6)
  final String? approvalRoles;
  @HiveField(7)
  final String? brand;
  @HiveField(8)
  final String? custSegment;
  @HiveField(9)
  final String? businessUnit;
  @HiveField(10)
  final String? token;
  @HiveField(11)
  final String? message;
  @HiveField(12)
  final int? code;
  @HiveField(13)
  final User? user;
  @HiveField(14)
  final dynamic so;
  @HiveField(15)
  final String? bu;
  @HiveField(16)
  final String? name;
  @HiveField(17)
  final String? role;
  @HiveField(18)
  final String? Username;
  @HiveField(19)
  final int? editApproval;
  @HiveField(20)
  final int? approvalRole;
  @HiveField(21)
  final dynamic SO;

  User({
    this.id,
    this.username,
    this.Username,
    this.password,
    this.fullname,
    this.level,
    this.roles,
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
    this.editApproval,
    this.approvalRole,
    this.SO,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      Username: json['Username'] ?? '',
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
      so: json['so'],
      bu: json['BU'],
      name: json['Name'],
      role: json['Role'],
      SO: json['SO'],
      editApproval: json['EditApproval'],
      approvalRole: json['ApprovalRole'],
    );
  }

  Future<User?> login(String username, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idDevice = prefs.getString("idDevice") ?? await getDeviceId();

      if (idDevice == null) {
        throw Exception("Device ID not found. Ensure it is stored properly.");
      }
      debugPrint(idDevice);

      final url =
          "${baseURLDevelopment}Login?username=$username&password=${password.replaceAll("#", "%23")}&playerId=$idDevice";

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return _handleSuccessfulLogin2(response, prefs);
      } else if (response.body.isEmpty) {
        debugPrint('Login response is empty.');
        return null;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  static User _handleSuccessfulLogin2(
      http.Response response, SharedPreferences prefs) {
    try {
      Map<String, dynamic> jsonObject = json.decode(response.body);
      User user = User.fromJson(jsonObject);
      prefs.setInt("id", user.id ?? 0);
      prefs.setString("Username", user.username ?? '');
      prefs.setString("Name", user.name ?? '');
      prefs.setString("Role", user.role ?? '');
      prefs.setString("SO", user.SO ?? '');
      prefs.setString("BU", user.bu ?? '');
      prefs.setInt("ApprovalRole", user.approvalRole ?? 0);
      prefs.setInt("EditApproval", user.editApproval ?? 0);
      debugPrint('User data: ${response.body}');
      debugPrint(prefs.getString("SO"));
      return user;
    } catch (e) {
      throw Exception("Failed to process login response: $e");
    }
  }

  static Future<String?> getDeviceId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      OneSignal.initialize(appId);

      await Future.delayed(const Duration(seconds: 2));

      final pushSubscription = OneSignal.User.pushSubscription;
      if (pushSubscription.id != null) {
        String deviceId = pushSubscription.id!;
        await preferences.setString("idDevice", deviceId);
        return deviceId;
      } else {
        throw Exception("Failed to retrieve Device ID from OneSignal");
      }
    } catch (error) {
      debugPrint('Get device ID error: $error');
      return null;
    }
  }

  static Future<User> getUsers(String username, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idDevice = prefs.getString("idDevice") ?? await getDeviceId();

      if (idDevice == null) {
        throw Exception("Device ID not found. Ensure it is stored properly.");
      }

      String url = "$apiCons/api/LoginSMS?playerId=$idDevice";
      Map<String, dynamic> dataLogin = {
        "username": username,
        "password": password
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(dataLogin),
      );

      if (response.statusCode == 200) {
        return _handleSuccessfulLogin(response, prefs);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Failed to login: $error");
    }
  }

  static User _handleSuccessfulLogin(
      http.Response response, SharedPreferences prefs) {
    try {
      dynamic jsonObject = json.decode(response.body);
      User user = User.fromJson(jsonObject);

      prefs.setString("username", user.username!);
      prefs.setString("token", user.token ?? '');
      prefs.setInt("userid", user.id!);
      prefs.setString("bu", user.bu ?? '');
      prefs.setString("so", user.so.toString());

      debugPrint(response.body);
      debugPrint(user.bu);

      return user;
    } catch (e) {
      throw Exception("Failed to process login response: $e");
    }
  }
}


// df4bfa4
