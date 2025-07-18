import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form_coba.dart';

class StatusDetailController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = RxString('');
  final statusData = Rxn<NOOModel>();
  final approvalStatusList = RxList<Map<String, dynamic>>();
  final Rx<ApprovalModel> listDetail = ApprovalModel().obs;
  final statusApproval = RxString('');
  final String statusRejected = "Rejected";
  String? statusDataApprovalDetail;
  final customerFormController =
      Get.put(CustomerFormController(), permanent: true);
  final authorization = 'Basic ${base64Encode(utf8.encode('test:test456'))}';

  Future<void> initializeData(int id) async {
    try {
      isLoading(true);
      await fetchStatusDetail(id);
      await fetchApprovalStatus(id);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchStatusDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${apiNOO}NOOCustTables/$id'),
        headers: {'authorization': authorization},
      );

      if (response.statusCode == 200) {
        listDetail.value = ApprovalModel.fromJson(jsonDecode(response.body));
        final data = NOOModel.fromJson(jsonDecode(response.body));
        statusData.value = data;

        statusApproval.value = data.status;
      } else {
        throw Exception('Failed to load status detail: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error getting status detail: $e';
      rethrow;
    }
  }

  Future<void> fetchApprovalStatus(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${apiNOO}Approval/$id'),
        headers: {'authorization': authorization},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        approvalStatusList.value = data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        approvalStatusList.value = [];
      } else {
        throw Exception(
            'Failed to load approval status: ${response.statusCode}');
      }
    } catch (e) {
      if (!e.toString().contains('404')) {
        errorMessage.value = 'Error getting approval status: $e';
        rethrow;
      }

      approvalStatusList.value = [];
    }
  }

  Future<Uint8List> getImage(String fileName) async {
    try {
      final response = await http.get(
        Uri.parse('${apiNOO}Files/GetFiles?fileName=$fileName'),
        headers: {'authorization': authorization},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error getting image: $e';
      rethrow;
    }
  }

  Future<bool> updateStatus(int id, Map<String, dynamic> data) async {
    try {
      isLoading(true);

      final response = await http.put(
        Uri.parse('${apiNOO}NOOCustTables/$id'),
        headers: {
          'authorization': authorization,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        await fetchStatusDetail(id);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Error updating status: $e';
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<String?> uploadSignature(
      String signatureBase64, String fileName) async {
    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse('${apiNOO}Files/UploadFile'),
        headers: {
          'authorization': authorization,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': signatureBase64,
          'fileName': fileName,
        }),
      );

      if (response.statusCode == 200) {
        return fileName;
      } else {
        throw Exception('Failed to upload signature: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error uploading signature: $e';
      return null;
    } finally {
      isLoading(false);
    }
  }

  void navigateToEdit() {
    if (statusData.value != null) {
      Get.delete<CustomerFormController>(force: true);

      final controller =
          Get.put(CustomerFormController(editData: statusData.value));
      controller.isEditMode.value = true;

      controller.fillFormData(statusData.value!);

      Get.to(
        () => CustomerForm(
          editData: statusData.value,
          isFromDraft: false,
          controller: controller,
        ),
        preventDuplicates: true,
      )?.then((value) {
        if (value == true) {
          initializeData(statusData.value!.id);
        }
      });
    }
  }

  bool get isStatusRejected => statusApproval.value == statusRejected;

  @override
  void onClose() {
    statusData.value = null;
    approvalStatusList.clear();
    super.onClose();
  }
}
