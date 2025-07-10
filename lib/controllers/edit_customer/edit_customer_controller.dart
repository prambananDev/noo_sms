import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/edit_customer/edit_customer_repo.dart';
import 'package:noo_sms/models/edit_cust_noo_model.dart';

class EditCustController extends GetxController {
  final EditCustRepository _repository = EditCustRepository();

  final RxList<EditCustModel> customer = <EditCustModel>[].obs;
  final RxList<EditCustModel> filteredCustomers = <EditCustModel>[].obs;

  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  RxInt page = 1.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  final RxInt totalPages = 0.obs;
  final RxInt pageSize = 20.obs;

  final RxBool showScrollButtons = false.obs;
  final RxBool showLoadMoreButton = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCust();
    _setupScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final double scrollPosition = scrollController.position.pixels;
      final double maxScrollExtent = scrollController.position.maxScrollExtent;

      if (scrollPosition > 200) {
        showScrollButtons.value = true;
      } else {
        showScrollButtons.value = false;
      }

      if (scrollPosition >= maxScrollExtent * 0.8 &&
          hasMoreData.value &&
          !isLoading.value &&
          !isLoadingMore.value &&
          !isSearching.value) {
        showLoadMoreButton.value = true;
      } else {
        showLoadMoreButton.value = false;
      }

      if (scrollPosition >= maxScrollExtent &&
          !isLoading.value &&
          !isLoadingMore.value &&
          hasMoreData.value &&
          !isSearching.value) {
        loadMoreCustomers();
      }
    });
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      filteredCustomers.value = customer;
    } else {
      isSearching.value = true;
      filteredCustomers.value = customer.where((cust) {
        return cust.custName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    filteredCustomers.value = customer;
  }

  Future<void> fetchCust() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      page.value = 1;
      pageSize.value = 100;

      _repository.clearCache();

      final response = await _repository.fetchEditCust(page, pageSize);
      customer.value = response.data;
      filteredCustomers.value = response.data;

      if (isSearching.value) {
        clearSearch();
      }

      hasMoreData.value =
          response.data.isNotEmpty && response.data.length >= pageSize.value;
    } catch (e) {
      errorMessage.value = 'Failed to find customers: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCustomers() async {
    if (isLoadingMore.value || !hasMoreData.value || isSearching.value) return;

    try {
      isLoadingMore.value = true;
      showLoadMoreButton.value = false;

      pageSize.value += 100;

      final response = await _repository.fetchEditCust(page, pageSize);

      if (response.data.isEmpty || response.data.length < pageSize.value) {
        hasMoreData.value = false;
      }

      if (response.data.isNotEmpty) {
        customer.value = response.data;
        filteredCustomers.value = customer;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollToBottom();
          }
        });
      }
    } catch (e) {
      errorMessage.value = 'Failed to load more customers: $e';
      pageSize.value -= 100;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
