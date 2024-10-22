import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class Employee {
  int? id;
  String? employeeId;
  String? name;
  String? username;
  String? password;
  String? salesOffice;
  String? businessUnit;
  String? segment;
  int? flag;
  String? message;
  String? token;

  Employee(
      {this.id,
      this.employeeId,
      this.name,
      this.username,
      this.password,
      this.salesOffice,
      this.businessUnit,
      this.segment,
      this.flag});
  factory Employee.convertUser(Map<String, dynamic> object) {
    return Employee(
        id: object['id'],
        employeeId: object['employeeId'],
        name: object['name'],
        username: object['username'],
        password: object['password'],
        salesOffice: object['salesOffice'],
        businessUnit: object['businessUnit'],
        segment: object['segment'],
        flag: object['flag']);
  }

  Employee.fromLoginJson(Map<String, dynamic> json) {
    token = json['token'];
    message = json['message'];
  }

  Map<String, dynamic> toLoginJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['message'] = message;
    return data;
  }

  static Future<void> setBoxLogin(User value, int code) async {
    Box userBox = await Hive.openBox('users');
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('ddMMyyyy');
    final String dateLogin = formatter.format(now);

    userBox.add(value);
    preferences.setInt("code", code);
    preferences.setString("date", dateLogin);
    preferences.setInt("flag", code);
    preferences.setString("result", "");
  }

  Future<Employee?> getEmployee(
    String username,
    String password,
  ) async {
    Employee employee = Employee();
    String url = "$apiCons2/api/Login";
    var bodyLogin = jsonEncode({"username": username, "password": password});
    try {
      final apiResult = await http.post(
        Uri.parse(url),
        body: bodyLogin,
        headers: {'content-type': 'application/json'},
      );
      var jsonObject = json.decode(apiResult.body);
      employee = Employee.fromLoginJson(jsonObject);

      if (apiResult.statusCode == 200) {
        Box userBox;
        SharedPreferences preferences;
        String? message = "";
        int? status;
        preferences = await SharedPreferences.getInstance();
        userBox = await Hive.openBox('users');
        User.getUsers(
          username,
          password,
        ).then((value) {
          status = value.code;
          if (value.code != 200) {
            //
            //
            message = value.message;
          } else {
            // Get.offAll(MainMenuView());
            // setBoxLogin(value, code!);
          }
        }).catchError((onError) {
          message = onError.toString();
        });
        return employee;
      } else {}
    } on TimeoutException catch (_) {
      employee.message = "Time out. Please reload._0";
    } on SocketException catch (_) {
      employee.message = "No Connection. Please connect to Internet._0";
    } on HttpException catch (_) {
      employee.message = "No Connection. Please connect to Internet._0";
    } catch (e) {
      employee.message = "Unexpected error: ${e.toString()}";
    }

    return null;
  }

  Future<String> logOut(String username) async {
    String url = "$apiCons2/api/Logout?username=$username";
    var apiResult, data;
    try {
      apiResult = await http.post(
        Uri.parse(url),
        headers: {'content-type': 'application/json'},
      );
      final jsonObject = json.decode(apiResult.body);

      data = jsonObject as String;
    } on TimeoutException catch (_) {
      data = "Time out. Please reload._0";
    } on SocketException catch (_) {
      data = "No Connection. Please connect to Internet._0";
    } on HttpException catch (_) {
      data = "No Connection. Please connect to Internet._0";
    } catch (_) {
      data = "No Connection. Please connect to Internet._0";
    }
    return data;
  }
}
