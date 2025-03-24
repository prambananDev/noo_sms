import 'dart:async';
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
  final Map<String, Map<String, double>> _creditLimitCache = {};
  final RxBool isCreditLimitLoading = false.obs;

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
  final Map<int, Map<String, dynamic>> _approvalControllers = {};

  @override
  void onInit() {
    super.onInit();
    initializeData();
    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';
  }

  void initializeApprovalControllers(int id) {
    if (!_approvalControllers.containsKey(id)) {
      _approvalControllers[id] = {
        'remark': TextEditingController(),
        'paymentTerm': TextEditingController(),
        'creditLimit': TextEditingController(),
        'signature': SignatureController(
          penStrokeWidth: 1,
          penColor: Colors.black,
          exportBackgroundColor: Colors.white,
        ),
        'selectedPaymentTerm': '',
        'creditLimitError': '',
      };
      update(['approval-$id']);
    }
  }

  Future<void> initializeData() async {
    await getSharedPrefs();
    await fetchApprovals();
  }

  TextEditingController getRemarkController(int id) {
    return _approvalControllers[id]?['remark'] ?? TextEditingController();
  }

  TextEditingController getCreditLimitController(int id) {
    return _approvalControllers[id]?['creditLimit'] ?? TextEditingController();
  }

  SignatureController getSignatureController(int id) {
    return _approvalControllers[id]?['signature'] ??
        SignatureController(
          penStrokeWidth: 1,
          penColor: Colors.black,
          exportBackgroundColor: Colors.white,
        );
  }

  void setSelectedPaymentTerm(int id, String value) {
    if (!_approvalControllers.containsKey(id)) {
      initializeApprovalControllers(id);
    }
    _approvalControllers[id]!['selectedPaymentTerm'] = value; // Store as String
    update(['payment-terms-$id']);
  }

  String getSelectedPaymentTerm(int id) {
    if (!_approvalControllers.containsKey(id)) {
      initializeApprovalControllers(id);
    }
    return _approvalControllers[id]!['selectedPaymentTerm'] as String? ?? '';
  }

  void setCreditLimitError(int id, String value) {
    if (!_approvalControllers.containsKey(id)) {
      initializeApprovalControllers(id);
    }
    _approvalControllers[id]!['creditLimitError'] = value;
    update(['credit-limit-error-$id']);
  }

  String getCreditLimitError(int id) {
    return (_approvalControllers[id]?['creditLimitError'] as String?) ?? '';
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    idUser.value = prefs.getInt("id") ?? 0;
    editApproval.value = prefs.getInt("editApproval") ?? 0;
  }

  Future<void> fetchApprovals() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("id")?.toString();
    final url = '${apiNOO}FindApproval/$id?page=${page.value}';

    final response = await makeApiCall(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      approvals.value =
          jsonData.map((data) => ApprovalModel.fromJson(data)).toList();
    }
  }

  Future<void> fetchApprovalDetail(int id) async {
    isLoading.value = true;
    initializeApprovalControllers(id);

    try {
      final response = await makeApiCall('${apiNOO}NOOCustTables/$id');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentApproval.value = ApprovalModel.fromJson(data);
        companyAddress.value = Address.fromJson(data['CompanyAddresses']);
        deliveryAddress.value = Address.fromJson(data['DeliveryAddresses']);
        taxAddress.value = Address.fromJson(data['TaxAddresses']);

        fetchCreditLimitRange(currentApproval.value.segment ?? '');

        await fetchPaymentTerms(currentApproval.value.segment ?? '');
        await fetchApprovalStatuses(id);

        getCreditLimitController(id).text =
            currentApproval.value.creditLimit?.toString() ?? '';

        final currentPaymentTerm = currentApproval.value.paymentTerm;
        if (currentPaymentTerm != null &&
            currentPaymentTerm.isNotEmpty &&
            paymentTerms.contains(currentPaymentTerm)) {
          setSelectedPaymentTerm(id, currentPaymentTerm);
        } else if (paymentTerms.isNotEmpty) {
          setSelectedPaymentTerm(id, paymentTerms.first);
        } else {
          setSelectedPaymentTerm(id, "");
        }

        update(['approval-$id', 'payment-terms-$id']);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  String formatNumberForDisplay(String value) {
    try {
      final cleanValue = value.replaceAll('.', '');

      final number = double.parse(cleanValue);

      final formatter = NumberFormat('#,###', 'id_ID');
      return formatter.format(number).replaceAll(',', '.');
    } catch (e) {
      return '0';
    }
  }

  String formatForApi(String value) {
    try {
      final cleanValue = value.replaceAll('.', '');
      return double.parse(cleanValue).toString();
    } catch (e) {
      return '0';
    }
  }

  Future<void> processApproval(BuildContext context, int id, String remark,
      bool ignoreCreditLimitValidation) async {
    try {
      if (!ignoreCreditLimitValidation) {
        final creditLimitText = getCreditLimitController(id).text;
        final isValid = validateCreditLimitForSubmission(id, creditLimitText);
        if (!isValid) {
          Get.snackbar(
            'Validation Error',
            'Please correct the credit limit value.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      final signatureController = getSignatureController(id);
      final signature = await signatureController.toPngBytes();

      if (signature == null) {
        Get.snackbar('Error', 'Please provide signature');
        return;
      }

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await uploadSignature(signature);

      final apiCreditLimit = formatForApi(getCreditLimitController(id).text);

      final url = '${apiNOO}Approval?'
          'id=$id&'
          'value=1&'
          'approveBy=${idUser.value}&'
          'ApprovedSignature=${signatureApprovalFromServer.value}&'
          'Remark=$remark&'
          'paymentId=${getSelectedPaymentTerm(id)}&'
          'creditLimit=$apiCreditLimit';

      final response = await makeApiCall(url, method: 'POST');

      if (response.statusCode == 200) {
        _disposeApprovalControllers(id);

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.snackbar(
          'Success',
          'Approval processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 1));
        await Get.offNamed('/noo_approve');
      } else {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        handleError('Failed to process approval',
            'Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      handleError('Error processing approval', e.toString());
    }
  }

  bool validateCreditLimitForSubmission(int id, String value) {
    try {
      if (value.isEmpty) {
        setCreditLimitError(id, 'Credit limit is required');
        return false;
      }

      final cleanValue = value.replaceAll('.', '');
      final creditLimit = double.parse(cleanValue);

      if (!isCreditLimitLoading.value) {
        if (creditLimit < minCreditLimit.value ||
            creditLimit > maxCreditLimit.value) {
          setCreditLimitError(
              id,
              "Credit limit must be between ${formatCurrency(minCreditLimit.value)} "
              "and ${formatCurrency(maxCreditLimit.value)}");
          return false;
        }
      }

      // No errors
      setCreditLimitError(id, '');
      return true;
    } catch (e) {
      setCreditLimitError(id, 'Invalid number format');
      return false;
    }
  }

  Future<void> showSuccessMessage(String message) async {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void handleError(String message, String errorDetail) {
    Get.snackbar(
      'Error',
      '$message\n$errorDetail',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> processReject(int id, String remark) async {
    final url = '${apiNOO}Approval/$id?'
        'value=0&'
        'approveBy=${idUser.value}&'
        'ApprovedSignature=reject&'
        'Remark=$remark';

    final response = await makeApiCall(url, method: 'POST');

    showSuccessMessage('Rejection processed successfully');
    if (response.statusCode == 200) {
      _disposeApprovalControllers(id);

      Get.back();

      showSuccessMessage('Rejection processed successfully');

      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed('/noo_pending');
    } else {
      Get.back();
      handleError('Failed to process approval',
          'Server returned ${response.statusCode}');
    }
  }

  Future<void> uploadSignature(Uint8List signature) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final filename =
        "SIGNATUREAPPROVAL_${DateFormat("ddMMyyyy_hhmmss").format(DateTime.now())}_${username}_.jpg";

    var request = http.MultipartRequest('POST', Uri.parse('${apiNOO}Upload'))
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

    if (_creditLimitCache.containsKey(adjustedSegment)) {
      final cachedData = _creditLimitCache[adjustedSegment]!;
      minCreditLimit.value = cachedData['min']!;
      maxCreditLimit.value = cachedData['max']!;
      isCreditLimitLoading.value = false;
      update(['credit-range-info']);
      return;
    }

    minCreditLimit.value = 0.0;
    maxCreditLimit.value = 10000000.0;

    isCreditLimitLoading.value = true;
    update(['credit-range-info']);

    _loadCreditLimitInBackground(adjustedSegment);
  }

  Future<void> _loadCreditLimitInBackground(String segment) async {
    try {
      final response = await makeApiCall(
        '${apiNOO}CreditLimits/BySegment/$segment',
        timeout: const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final min = data[0]["Min"].toDouble();
          final max = data[0]["Max"].toDouble();

          _creditLimitCache[segment] = {
            'min': min,
            'max': max,
          };

          minCreditLimit.value = min;
          maxCreditLimit.value = max;
        }
      } else if (response.statusCode == 408) {
      } else {}
    } catch (e) {
    } finally {
      isCreditLimitLoading.value = false;

      update(['credit-range-info']);
    }
  }

  void validateCreditLimit(int id, String value) {
    if (isCreditLimitLoading.value) {
      setCreditLimitError(id, 'Loading credit limit range...');
      return;
    }

    try {
      final cleanValue = value.replaceAll('.', '');
      if (cleanValue.isEmpty) {
        setCreditLimitError(id, 'Credit limit is required');
        return;
      }

      final creditLimit = double.parse(cleanValue);
      if (creditLimit < minCreditLimit.value ||
          creditLimit > maxCreditLimit.value) {
        setCreditLimitError(
            id,
            "Credit limit must be between ${formatCurrency(minCreditLimit.value)} "
            "and ${formatCurrency(maxCreditLimit.value)}");
      } else {
        setCreditLimitError(id, '');
      }
    } catch (e) {
      setCreditLimitError(id, 'Invalid number format');
    }
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat("#,###", "id_ID");
    return formatter.format(value);
  }

  Future<http.Response> makeApiCall(
    String url, {
    String method = 'GET',
    dynamic body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      switch (method) {
        case 'GET':
          return await http.get(
            Uri.parse(url),
            headers: {'authorization': basicAuth},
          ).timeout(timeout);
        case 'POST':
          return await http
              .post(
                Uri.parse(url),
                headers: {
                  'authorization': basicAuth,
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(body),
              )
              .timeout(timeout);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } on TimeoutException {
      return http.Response(
        '{"error": "Request timed out"}',
        408, // 408 is Request Timeout
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return http.Response(
        '{"error": "API call failed: $e"}',
        500,
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<void> fetchApprovalStatuses(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${apiNOO}Approval/$id'),
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
    var url = "${apiNOO}PaymentTerms/BySegment/$segment";
    final response = await makeApiCall(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      paymentTerms.value =
          jsonResponse.map((item) => item['PaymTermId'].toString()).toList();
      update(['payment-terms']);
    }
  }

  void _disposeApprovalControllers(int id) {
    final controllers = _approvalControllers[id];
    if (controllers != null) {
      controllers['remark'].dispose();
      controllers['paymentTerm'].dispose();
      controllers['creditLimit'].dispose();
      controllers['signature'].dispose();
      _approvalControllers.remove(id);
    }
  }

  @override
  void onClose() {
    for (final id in _approvalControllers.keys.toList()) {
      _disposeApprovalControllers(id);
    }
    remarkController.dispose();
    paymentTermController.dispose();
    creditLimitController.dispose();
    signatureController.dispose();
    super.onClose();
  }
}
