import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesController extends GetxController {
  User? user;
  int? code;
  List? _listHistorySO;

  void setBundleLines(
      int id, double disc, DateTime fromDate, DateTime toDate) async {
    Lines model = Lines();
    List<Lines> listDisc = List<Lines>.filled(0, Lines());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String result = preferences.getString("result")!;
    if (result != "") {
      var listStringResult = json.decode(result);
      for (var objectResult in listStringResult) {
        var objects = Lines.fromJson(objectResult as Map<String, dynamic>);
        listDisc.add(objects);
      }
    }
    model.id = id;
    model.disc = disc;
    model.fromDate = fromDate == null
        ? null
        : DateFormat('MM-dd-yyyy').format(fromDate).toString();
    model.toDate = toDate == null
        ? null
        : DateFormat('MM-dd-yyyy').format(toDate).toString();
    listDisc.add(model);
    List<Map> listResult = listDisc.map((f) => f.toJson()).toList();
    result = jsonEncode(listResult);
    preferences.setString("result", result);
  }

  approveNew(String apprroveOrReject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic id = prefs.getInt("userid");
    String url = "$apiCons/api/Approve/$id";
    List<Promotion> data = _listHistorySO != null
        ? List<Promotion>.from(_listHistorySO!.cast<Promotion>())
        : [];
    List idLines = data.map((element) => element.id).toList();
    dynamic isiBody = jsonEncode(<String, dynamic>{
      "status": apprroveOrReject == "Approve" ? 1 : 2,
      "id": idLines,
    });
    final response = await put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: isiBody,
    );

    // if (response.statusCode == 200) {
    //   Get.offAll(HistoryNomorPP());
    // } else {
    //   Get.dialog(Center(
    //     child: Text("${response.statusCode}"),
    //   ));
    // }
  }

  void getUpdateData(
      BuildContext context, List<Lines> listDisc, int idEmp, int code) async {
    List<Lines> listDisc = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Future.delayed(const Duration(milliseconds: 10));
    String result = preferences.getString("result")!;
    var listStringResult = json.decode(result);
    for (var objectResult in listStringResult) {
      var objects = Lines.fromJson(objectResult as Map<String, dynamic>);
      listDisc.add(objects);
    }
    preferences.setString("result", "");
    _approvePP(context, listDisc, idEmp, code);
  }

  DateTime convertDate(String date) {
    final dateTime = DateTime.parse(date ?? "");
    return dateTime;
  }

// Future<bool> _approvePP(
//     BuildContext context, String nomorPP, int idEmp, int code) {
  Future<bool> _approvePP(
      BuildContext context, List<Lines> listDisc, int idEmp, int code) async {
    bool success = false; // Default to false, indicating failure
    try {
      await Promotion.approveSalesOrder(
        listDisc,
      ).then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const DashboardPP(initialIndex: 1);
          // return HistoryNomorPP();
        }));
        success = true; // Operation was successful
      });
    } catch (onError) {
      // Handle error
      Navigator.pop(context);
      // Fluttertoast.showToast(
      //     msg: 'Error : $onError',
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 5,
      //     backgroundColor: Colors.red[500],
      //     textColor: Colors.black,
      //     fontSize: ScreenUtil().setSp(16));
      success = false; // Operation failed
    }
    return success; // Return the outcome of the operation
  }
}
