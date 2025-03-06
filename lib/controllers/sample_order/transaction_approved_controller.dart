import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/models/approved.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionApprovedController extends GetxController {
  var approvedList = <Approved>[].obs;
  var isLoading = true.obs;
  final tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApproved();
  }

  void onTabChanged() {
    if (tabIndex.value == 3) {
      refreshData();
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await fetchApproved();
    isLoading.value = false;
  }

  Future<void> fetchApproved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? idEmpString = prefs.getString("scs_idEmp");

    if (idEmpString == null || idEmpString.isEmpty) {
      Get.snackbar('Error', 'Employee ID not found',
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    final int idEmp = int.tryParse(idEmpString) ?? 0;
    if (idEmp == 0) {
      Get.snackbar('Error', 'Invalid Employee ID',
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    final Uri url =
        Uri.parse('$apiSCS/api/SampleApproval/$idEmp?approved=true');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        approvedList.value =
            jsonResponse.map((data) => Approved.fromJson(data)).toList();
      } else {
        approvedList.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
      approvedList.clear();
    }
    isLoading.value = false;
  }

  void showApprovedDetail(BuildContext context, int id) async {
    final Uri url = Uri.parse('$apiSCS/api/SampleApproval/$id?detail=true');
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
                          backgroundColor: colorAccent,
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
