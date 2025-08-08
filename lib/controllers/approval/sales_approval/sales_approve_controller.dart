import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/approval/sales_approval/sales_approve_repo.dart';
import 'package:noo_sms/models/sales_approve_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesApproveController extends GetxController {
  final SalesApproveRepository _repository = SalesApproveRepository();

  final RxList<SalesOrder> allOrders = <SalesOrder>[].obs;
  final RxList<SalesOrder> filteredOrders = <SalesOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 10;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController rejectMessageController = TextEditingController();

  final Rx<SalesOrder?> selectedOrder = Rx<SalesOrder?>(null);
  final Rx<SalesOrderDetail?> orderDetail = Rx<SalesOrderDetail?>(null);

  String _username = '';
  String _token = '';

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);

    fetchSalesOrders();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    rejectMessageController.dispose();
    super.onClose();
  }

  List<SalesOrder> get currentPageOrders {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredOrders.length);
    return filteredOrders.sublist(startIndex, endIndex);
  }

  void _onSearchChanged() {
    final query = searchController.text;
    searchQuery.value = query;
    _filterOrders();
  }

  Future<void> fetchSalesOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final orders = await _repository.fetchPendingApproval();
      allOrders.value = orders;
      _filterOrders();
    } catch (e) {
      errorMessage.value = 'Failed to fetch sales orders: $e';
      allOrders.clear();
      filteredOrders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _filterOrders() {
    if (searchQuery.value.isEmpty) {
      filteredOrders.value = List.from(allOrders);
    } else {
      filteredOrders.value = allOrders
          .where((order) =>
              order.salesId
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              order.custName
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              order.custNameAlias
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    _calculatePagination();
    currentPage.value = 1;
  }

  void _calculatePagination() {
    totalPages.value = (filteredOrders.length / itemsPerPage).ceil();
    if (totalPages.value == 0) totalPages.value = 1;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  void searchSalesOrders() {
    _filterOrders();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterOrders();
  }

  void refreshData() {
    fetchSalesOrders();
  }

  Future<void> fetchOrderDetail(int recId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final detail = await _repository.fetchDetailApproval(recId, _token);
      orderDetail.value = detail;
    } catch (e) {
      errorMessage.value = 'Failed to fetch order details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveOrder(int recId, String salesId) async {
    try {
      final request = ApprovalRequest(
        refRecId: recId,
        status: 1,
        comments: '',
        actionBy: _username,
        documentNo: salesId,
      );

      final success = await _repository.approveReject(request, _token);

      if (success) {
        Get.snackbar(
          'Success',
          'Order approved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        refreshData();
        return true;
      } else {
        Get.snackbar(
          'Failed',
          'Failed to approve order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error approving order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> rejectOrder(int recId, String salesId, String reason) async {
    try {
      final request = ApprovalRequest(
        refRecId: recId,
        status: 0,
        comments: reason,
        actionBy: _username,
        documentNo: salesId,
      );

      final success = await _repository.approveReject(request, _token);

      if (success) {
        Get.snackbar(
          'Success',
          'Order rejected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        rejectMessageController.clear();
        refreshData();
        return true;
      } else {
        Get.snackbar(
          'Failed',
          'Failed to reject order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error rejecting order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  void showRejectDialog(int recId, String salesId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Sales Approval'),
        content: TextField(
          controller: rejectMessageController,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              rejectOrder(recId, salesId, rejectMessageController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void selectOrder(SalesOrder order) {
    selectedOrder.value = order;
  }

  void clearSelectedOrder() {
    selectedOrder.value = null;
    orderDetail.value = null;
  }
}
