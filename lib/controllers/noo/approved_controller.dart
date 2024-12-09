import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/models/approval_status.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class ApprovedController extends GetxController {
  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  final RxInt idUser = 0.obs;
  final Rx<Address> companyAddress = Address().obs;
  final Rx<Address> deliveryAddress = Address().obs;
  final Rx<Address> taxAddress = Address().obs;
  final RxBool isLoading = true.obs;
  final RxList<ApprovalStatus> approvalStatuses = <ApprovalStatus>[].obs;
  final Rx<ApprovalModel> currentApproval = ApprovalModel().obs;
  final RxList<ApprovalModel> approvals = <ApprovalModel>[].obs;
  final RxInt page = 1.obs;

  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final scrollController = ScrollController();

  String signatureApprovalFromServer =
      "SIGNATUREAPPROVAL_${DateFormat("ddMMyyyy_hhmm").format(DateTime.now())}_.jpg";

  @override
  void onInit() {
    super.onInit();
    getSharedPrefs();
    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';
  }

  Future<void> fetchData({bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("iduser")?.toString();
    // final String? role = prefs.getString("Role");
    if (refresh) {
      page.value = 1;
      hasMoreData.value = true;
    }

    var urlGetApproved =
        "${baseURLDevelopment}ApprovedNOO/$userId?page=${page.value}";

    final response = await http
        .get(Uri.parse(urlGetApproved), headers: {'authorization': basicAuth});
    debugPrint(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      approvals.value =
          jsonData.map((data) => ApprovalModel.fromJson(data)).toList();
    }
  }

  Future<void> getStatusDetail(int id) async {
    isLoading(true);
    var urlGetApprovalDetail = "${baseURLDevelopment}NOOCustTables/$id";
    final response = await http.get(Uri.parse(urlGetApprovalDetail),
        headers: <String, String>{'authorization': basicAuth});
    debugPrint(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      currentApproval.value = ApprovalModel.fromJson(data);
      companyAddress.value = Address.fromJson(data["CompanyAddresses"]);
      deliveryAddress.value = Address.fromJson(data["DeliveryAddresses"]);
      taxAddress.value = Address.fromJson(data["TaxAddresses"]);
      await fetchApprovalStatuses(id);
    }
  }

  Future<void> fetchApprovalStatuses(int id) async {
    var urlGetApprovalStatuses = "${baseURLDevelopment}ApprovalStatuses/$id";
    final response = await http.get(Uri.parse(urlGetApprovalStatuses),
        headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      final statusData = json.decode(response.body);
      approvalStatuses.value = (statusData as List)
          .map((data) => ApprovalStatus.fromJson(data))
          .toList();
    } else {}
  }

  Future<void> uploadSignature(List<int> imageFile, String fileName) async {
    try {
      var uri = Uri.parse("${baseURLDevelopment}Upload");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(
          http.MultipartFile.fromBytes('file', imageFile, filename: fileName));

      var response = await request.send();
      if (response.statusCode == 200) {
        String result = await response.stream.bytesToString();
        Get.snackbar(
          'Success',
          'Signature uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to upload signature');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload signature: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    idUser.value = prefs.getInt("iduser") ?? 0;
  }

  void navigateToDetail(int id) {
    Get.to(const ApprovedView(), arguments: {'id': id})?.then((value) {
      refreshData();
    });
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore(true);
      page.value++;
      await fetchData();
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> refreshData() async {
    await fetchData(refresh: true);
  }
}
