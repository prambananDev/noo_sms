import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/sample_order/transaction_approved_controller.dart';
import 'package:noo_sms/models/approval.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPendingController extends GetxController {
  var approvalList = <Approval>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchApprovals();
  }

  Future<void> fetchApprovals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    final int idEmp = int.tryParse(prefs.getString("getIdEmp") ?? '0') ?? 0;
    final Uri url = Uri.parse('$apiCons2/api/SampleApproval/$idEmp');

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body) as List;
        approvalList.value = jsonResponse
            .map((data) => Approval.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        approvalList.clear();
      }
    } catch (e) {
      approvalList.clear();
    }
  }

  void showApprovalDetail(BuildContext context, int id,
      Function(int, List<ApprovalDetail>) showDialog) async {
    final url = '$apiCons2/api/SampleApproval/$id?detail=true';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final details = (jsonResponse['Lines'] as List?)
                ?.map((detailJson) => ApprovalDetail.fromJson(detailJson))
                .toList() ??
            [];

        showDialog(id, details);
      } else {
        Get.snackbar('Error', 'Failed to fetch detail: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void sendApproval(int id, bool isApproved, String message,
      List<ApprovalDetail> details) async {
    final prefs = await SharedPreferences.getInstance();
    final int idEmp = int.tryParse(prefs.getString("getIdEmp") ?? '0') ?? 0;
    final int status = isApproved ? 1 : 2;
    final Uri url = Uri.parse('$apiCons2/api/SampleApproval');

    final lines = details
        .map((detail) => {
              "item": detail.productId,
              "qty": int.parse(detail.qty.toString()),
            })
        .toList();

    final requestBody = {
      "id": id,
      "idEmp": idEmp,
      "status": status,
      "message": message,
      "lines": lines,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
            'Success',
            isApproved
                ? 'Approval status updated to Approved.'
                : 'Approval status updated to Rejected.',
            snackPosition: SnackPosition.BOTTOM);

        fetchApprovals();
        if (Get.isRegistered<TransactionApprovedController>()) {
          Get.find<TransactionApprovedController>().refreshData();
        }
        DashboardOrderSampleState.tabController.animateTo(3);
      } else {
        Get.snackbar('Error',
            'Failed to update status: ${response.statusCode}\nResponse Body: ${response.body}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
