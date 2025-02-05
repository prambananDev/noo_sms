import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinesProvider with ChangeNotifier {
  String result = '';
  List<Map<String, dynamic>> listResult = [];

  LinesProvider();

  Future<void> setBundleLines(
      int id, double disc, DateTime fromDate, DateTime toDate) async {
    Lines model = Lines();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    model.id = id;
    model.disc = disc;
    model.fromDate = fromDate == null
        ? null
        : DateFormat('MM-dd-yyyy').format(fromDate).toString();
    model.toDate = toDate == null
        ? null
        : DateFormat('MM-dd-yyyy').format(toDate).toString();

    listResult.add(model.toJsonDisc());

    result = jsonEncode(listResult);

    preferences.setString("result", result);

    notifyListeners();
  }

  String get getBundleLines => result;
}
