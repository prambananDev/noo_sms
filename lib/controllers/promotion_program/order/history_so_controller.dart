// history_so_controller.dart
import 'package:get/get.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:flutter/material.dart';

class HistorySOController extends GetxController {
  final RxList<Promotion> salesOrders = <Promotion>[].obs;
  final RxBool isLoading = true.obs;

  // Store IDs as normal variables
  String idProduct = '';
  String idCustomer = '';
  int idEmp = 0;
  String namePP = '';

  // Store names for display
  final RxString productName = ''.obs;
  final RxString customerName = ''.obs;

  void updateIds(String newProductId, String newCustomerId, int newEmpId,
      String newPpName) {
    idProduct = newProductId;
    idCustomer = newCustomerId;
    idEmp = newEmpId;
    namePP = newPpName;

    // Extract names for display
    if (newProductId.contains('-')) {
      productName.value = newProductId.split('-')[1].trim();
    }
    if (newCustomerId.contains('-')) {
      customerName.value = newCustomerId.split('-')[1].trim();
    }

    // Load data immediately after updating IDs
    loadSalesOrders();
  }

  Future<void> loadSalesOrders() async {
    try {
      isLoading.value = true;

      if (idProduct.isEmpty || idCustomer.isEmpty) {
        return;
      }

      final data = await Promotion.getListSalesOrder(
        idProduct,
        idCustomer,
      );

      salesOrders.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load sales orders',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadSalesOrders();
  }

  @override
  void onClose() {
    salesOrders.clear();
    super.onClose();
  }
}
