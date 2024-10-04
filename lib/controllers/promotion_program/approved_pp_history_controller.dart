import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HistoryController {
  late String token;
  late String username;
  late int code;

  Future<void> init() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();

    token = userBox.get('token') ?? '';
    username = userBox.get('username') ?? '';
    code = pref.getInt("code") ?? 0;
  }

  Future<List<Promotion>> getPromotions(String numberPP) async {
    return await Promotion.getListLines(numberPP, code, token, username);
  }

  Future<void> approveOrReject(int status, List<int> ids) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic id = prefs.getInt("userid");
    debugPrint(id);
    String url = "$apiCons/api/Approve/$id";
    var body = {'status': status, 'ids': ids};

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      throw Exception("Approval/Reject Failed");
    }
  }
}
