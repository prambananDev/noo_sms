import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/approval_status.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';

class ApprovalController extends GetxController {
  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  final RxList<ApprovalModel> approvals = <ApprovalModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<ApprovalStatus> approvalStatuses = <ApprovalStatus>[].obs;
  final RxInt page = 1.obs;
  final Rx<ApprovalModel> currentApproval = ApprovalModel().obs;
  final Rx<Address> companyAddress = Address().obs;
  final Rx<Address> deliveryAddress = Address().obs;
  final Rx<Address> taxAddress = Address().obs;

  final remarkController = TextEditingController();
  final paymentTermController = TextEditingController();
  final creditLimitController = TextEditingController();
  final signatureController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final RxDouble minCreditLimit = 0.0.obs;
  final RxDouble maxCreditLimit = 0.0.obs;
  final RxString creditLimitError = ''.obs;
  final RxList<String> paymentTerms = <String>[].obs;
  final RxString selectedPaymentTerm = ''.obs;
  final RxInt idUser = 0.obs;
  final RxInt editApproval = 0.obs;
  final RxString signatureApprovalFromServer = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';
  }

  Future<void> initializeData() async {
    await getSharedPrefs();
    await fetchApprovals();
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    idUser.value = prefs.getInt("iduser") ?? 0;
    editApproval.value = prefs.getInt("editApproval") ?? 0;
  }

  Future<void> fetchApprovals() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("iduser")?.toString();
    final String? role = prefs.getString("Role");

    final url = role == "1"
        ? '$baseURLDevelopment/FindApproval/$userId?page=${page.value}'
        : '$baseURLDevelopment/ViewAllCust?page=${page.value}';

    final response = await makeApiCall(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      approvals.value =
          jsonData.map((data) => ApprovalModel.fromJson(data)).toList();
    }
  }

  Future<void> fetchApprovalDetail(int id) async {
    isLoading.value = true;
    final response = await makeApiCall('$baseURLDevelopment/NOOCustTables/$id');
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      currentApproval.value = ApprovalModel.fromJson(data);
      companyAddress.value = Address.fromJson(data['CompanyAddresses']);
      deliveryAddress.value = Address.fromJson(data['DeliveryAddresses']);
      taxAddress.value = Address.fromJson(data['TaxAddresses']);

      await Future.wait([
        fetchCreditLimitRange(currentApproval.value.segment ?? ''),
        fetchPaymentTerms(currentApproval.value.segment ?? ''),
        fetchApprovalStatuses(id),
      ]);
      selectedPaymentTerm.value =
          currentApproval.value.paymentTerm ?? paymentTerms.first;
      paymentTermController.text = selectedPaymentTerm.value;
    }
  }

  Future<void> processApproval(int id, String approvedSignature, String remark,
      bool isCreditLimitValid) async {
    try {
      if (!isCreditLimitValid) {
        // showErrorAlert(
        //     'Credit limit must be between ${minCreditLimit.value} and ${maxCreditLimit.value}');
        return;
      }

      final url = '$baseURLDevelopment/ApprovalModel?'
          'id=$id&'
          'value=1&'
          'approveBy=${idUser.value}&'
          'ApprovedSignature=$approvedSignature&'
          'Remark=$remark&'
          'paymentId=${paymentTermController.text}&'
          'creditLimit=${creditLimitController.text.replaceAll(",", "")}';

      final response = await makeApiCall(url, method: 'POST');

      if (response.statusCode == 200) {
        Get.offAllNamed('/dashboard');
        showSuccessMessage('ApprovalModel processed successfully');
      }
    } catch (e) {
      handleError('Error processing approval', e);
    }
  }

  Future<void> processReject(int id, String remark) async {
    final url = '$baseURLDevelopment/ApprovalModel/$id?'
        'value=0&'
        'approveBy=${idUser.value}&'
        'ApprovedSignature=reject&'
        'Remark=$remark';

    final response = await makeApiCall(url, method: 'POST');

    if (response.statusCode == 200) {
      Get.offAllNamed('/dashboard');
      showSuccessMessage('Rejection processed successfully');
    }
  }

  Future<void> uploadSignature(Uint8List signature) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final filename =
        "SIGNATUREAPPROVAL_${DateFormat("ddMMyyyy_hhmmss").format(DateTime.now())}_${username}_.jpg";

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseURLDevelopment/Upload'))
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            signature,
            filename: filename,
          ));

    final response = await request.send();
    final responseStr = await response.stream.bytesToString();
    signatureApprovalFromServer.value = responseStr.replaceAll('"', '');
  }

  Future<void> fetchCreditLimitRange(String segment) async {
    final adjustedSegment = segment != "Hotels" ? "All" : segment;
    final response = await makeApiCall(
        '$baseURLDevelopment/CreditLimits/BySegment/$adjustedSegment');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      minCreditLimit.value = data[0]["Min"].toDouble();
      maxCreditLimit.value = data[0]["Max"].toDouble();
    }
  }

  void validateCreditLimit(String value) {
    try {
      final creditLimit = double.tryParse(value.replaceAll(",", "")) ?? 0;
      if (creditLimit < minCreditLimit.value ||
          creditLimit > maxCreditLimit.value) {
        creditLimitError.value =
            "Credit limit must be between ${formatCurrency(minCreditLimit.value)} "
            "and ${formatCurrency(maxCreditLimit.value)}";
      } else {
        creditLimitError.value = '';
      }
    } catch (e) {
      creditLimitError.value = 'Invalid number format';
    }
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat("#,###", "id_ID");
    return formatter.format(value);
  }

  Future<http.Response> makeApiCall(String url,
      {String method = 'GET', dynamic body}) async {
    switch (method) {
      case 'GET':
        return await http.get(
          Uri.parse(url),
          headers: {'authorization': basicAuth},
        );
      case 'POST':
        return await http.post(
          Uri.parse(url),
          headers: {
            'authorization': basicAuth,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      default:
        throw Exception('Unsupported HTTP method');
    }
  }

  Future<void> fetchApprovalStatuses(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseURLDevelopment/Approval/$id'),
        headers: {'authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        approvalStatuses.value =
            data.map((json) => ApprovalStatus.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch approval statuses: $e');
    }
  }

  Future<void> fetchPaymentTerms(String segment) async {
    var url = "${baseURLDevelopment}PaymentTerms/BySegment/$segment";
    String basicAuth = 'Basic ${base64Encode(utf8.encode('test:test456'))}';
    final response = await http.get(Uri.parse(url),
        headers: <String, String>{'authorization': basicAuth});
    List<dynamic> jsonResponse = json.decode(response.body);

    paymentTerms.value =
        jsonResponse.map((item) => item['PaymTermId'].toString()).toList();
  }

  void handleError(String message, dynamic error) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // void showErrorAlert(String message) {
  //   QuickAlert.show(
  //     context: Get.context!,
  //     type: QuickAlertType.error,
  //     text: message,
  //   );
  // }

  @override
  void onClose() {
    remarkController.dispose();
    paymentTermController.dispose();
    creditLimitController.dispose();
    signatureController.dispose();
    super.onClose();
  }
}
