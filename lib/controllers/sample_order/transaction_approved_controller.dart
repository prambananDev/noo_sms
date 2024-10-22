import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/approved.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionApprovedController extends GetxController {
  var approvedList = <Approved>[].obs;

  @override
  void onReady() {
    super.onReady();
    fetchApproved();
  }

  Future<void> fetchApproved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? idEmpString = prefs.getString("getIdEmp");

    if (idEmpString == null || idEmpString.isEmpty) {
      Get.snackbar('Error', 'Employee ID not found',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final int idEmp = int.tryParse(idEmpString) ?? 0;
    if (idEmp == 0) {
      Get.snackbar('Error', 'Invalid Employee ID',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final Uri url =
        Uri.parse('$apiCons2/api/SampleApproval/$idEmp?approved=true');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        approvedList.value =
            jsonResponse.map((data) => Approved.fromJson(data)).toList();
      } else {
        Get.snackbar('Info', 'No approved data found',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showApprovedDetail(BuildContext context, int id) async {
    final Uri url = Uri.parse('$apiCons2/api/SampleApproval/$id?detail=true');
    try {
      final response =
          await http.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final details = (jsonResponse['Lines'] as List)
            .map((detailJson) => ApprovedDetail.fromJson(detailJson))
            .toList();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...details.map((detail) {
                      return ListTile(
                        title: Text('Product: ${detail.product}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit: ${detail.unit}'),
                            Text('Qty: ${detail.qty}'),
                          ],
                        ),
                      );
                    }).toList(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(0, 45),
                          foregroundColor: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch detail: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
