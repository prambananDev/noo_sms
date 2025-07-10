import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:noo_sms/controllers/order_tracking/order_tracking_repo.dart';
import 'package:noo_sms/models/order_tracking_model.dart';

class OrderTrackingController extends GetxController {
  final OrderTrackingRepository _repository = OrderTrackingRepository();

  final RxList<OrderTrackingModel> data = <OrderTrackingModel>[].obs;
  final RxList<OrderTrackingModel> dataOriginal = <OrderTrackingModel>[].obs;
  final RxList<OrderTrackingModel> filteredData = <OrderTrackingModel>[].obs;

  final Rx<CustomerProfile?> customerProfile = Rx<CustomerProfile?>(null);
  final RxString currentCustId = ''.obs;

  final RxList<OrderHistoryModel> orderHistoryData = <OrderHistoryModel>[].obs;
  final RxList<OrderHistoryModel> orderHistoryDataOriginal =
      <OrderHistoryModel>[].obs;
  final orderHistorySearchController = TextEditingController();

  final RxList<DeliveryDetailModel> deliveryDetailData =
      <DeliveryDetailModel>[].obs;
  final RxString currentSalesId = ''.obs;

  final RxMap trackingDetailData = {}.obs;
  final RxString currentPoNum = ''.obs;
  final RxString currentPlId = ''.obs;
  final RxBool isLoadingTrackingDetail = false.obs;

  final RxBool _trackingDetailLoaded = false.obs;
  String _lastLoadedPlId = '';

  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isLoadingOrderHistory = false.obs;
  final RxBool isLoadingDeliveryDetail = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    orderHistorySearchController.dispose();
    super.onClose();
  }

  OrderTrackingDetailResponse? get trackingDetailResponse {
    if (trackingDetailData.isEmpty) return null;

    try {
      final Map<String, dynamic> jsonMap =
          Map<String, dynamic>.from(trackingDetailData.value);
      return OrderTrackingDetailResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error converting tracking data to model: $e');
      return null;
    }
  }

  Future<void> loadTrackingDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? plId = prefs.getString("getPlId");

    if (plId == null || plId.isEmpty) {
      debugPrint('No PL ID found in preferences');
      return;
    }

    if (isLoadingTrackingDetail.value) {
      debugPrint('Already loading tracking detail, skipping...');
      return;
    }

    if (_trackingDetailLoaded.value && _lastLoadedPlId == plId) {
      debugPrint(
          'Tracking detail already loaded for PL ID: $plId, skipping...');
      return;
    }

    try {
      isLoadingTrackingDetail.value = true;
      _trackingDetailLoaded.value = false;
      errorMessage.value = '';

      String? poNum = prefs.getString("getPoNum");

      currentPlId.value = plId;
      currentPoNum.value = poNum ?? '';
      _lastLoadedPlId = plId;

      debugPrint('Loading tracking detail for PL ID: $plId');

      final Map<String, dynamic> response =
          await _repository.getTrackingDetail(plId: plId);
      trackingDetailData.value = response;

      _trackingDetailLoaded.value = true;
      debugPrint('Successfully loaded tracking detail');
    } catch (e) {
      debugPrint('Error loading tracking detail: $e');
      trackingDetailData.value = {'error': e.toString()};
      _trackingDetailLoaded.value = false;

      Get.snackbar(
        'Error',
        'Failed to load tracking detail: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingTrackingDetail.value = false;
    }
  }

  Future<void> refreshTrackingDetail() async {
    try {
      String? targetPlId =
          currentPlId.value.isNotEmpty ? currentPlId.value : null;

      _repository.clearTrackingDetailCache(plId: targetPlId);

      _trackingDetailLoaded.value = false;
      _lastLoadedPlId = '';
      trackingDetailData.clear();

      await loadTrackingDetail();

      Get.snackbar(
        'Success',
        'Tracking detail refreshed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error refreshing tracking detail: $e');
    }
  }

  Future<void> navigateToTrackingDetailPage({
    required String plId,
    required String poNum,
    String? salesId, // Add optional salesId parameter
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("getPlId", plId);
      await prefs.setString("getPoNum", poNum);

      // Save salesId if provided
      if (salesId != null && salesId.isNotEmpty) {
        await prefs.setString("getSalesId", salesId);
        currentSalesId.value = salesId;
        debugPrint('Saved salesId to preferences: $salesId');
      }

      debugPrint(
          'Navigating to tracking detail with PLId: $plId, PONum: $poNum, SalesId: $salesId');

      if (_lastLoadedPlId != plId) {
        _trackingDetailLoaded.value = false;
        _lastLoadedPlId = '';
        trackingDetailData.clear();
      }

      Get.toNamed('/order-tracking-detail');
    } catch (e) {
      debugPrint('Error navigating to tracking detail: $e');
      Get.snackbar(
        'Error',
        'Failed to navigate to tracking detail',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void clearTrackingDetail() {
    trackingDetailData.clear();
    currentPlId.value = '';
    currentPoNum.value = '';
    isLoadingTrackingDetail.value = false;
    _trackingDetailLoaded.value = false;
    _lastLoadedPlId = '';
  }

  bool get hasTrackingDetail {
    final response = trackingDetailResponse;
    return response != null && response.hasData && response.isSuccess;
  }

  String get trackingStatus {
    final response = trackingDetailResponse;
    if (response == null || !response.hasData) {
      return 'No data available';
    }

    return response.data!.currentStatusText;
  }

  Map<String, double>? get driverLocation {
    final response = trackingDetailResponse;
    if (response == null ||
        !response.hasData ||
        response.data!.driverInfo == null) {
      return null;
    }

    final driverInfo = response.data!.driverInfo!;
    if (!driverInfo.hasLocation) return null;

    return driverInfo.lastPosition!.locationMap;
  }

  List<TrackingDeliveryStatus> get deliveryStatusList {
    final response = trackingDetailResponse;
    if (response == null || !response.hasData) {
      return [];
    }

    return response.data!.deliveryStatus;
  }

  String get expectedDeliveryDate {
    final response = trackingDetailResponse;
    if (response == null || !response.hasData) {
      return 'N/A';
    }

    return response.data!.expectedDeliveryDate;
  }

  TrackingDriverInfo? get driverInfo {
    final response = trackingDetailResponse;
    if (response == null || !response.hasData) {
      return null;
    }

    return response.data!.driverInfo;
  }

  bool get isDelivered {
    final response = trackingDetailResponse;
    if (response == null || !response.hasData) {
      return false;
    }

    return response.data!.isDelivered;
  }

  bool get hasTrackingError {
    return trackingDetailData.isNotEmpty && trackingDetailData['error'] != null;
  }

  String get trackingErrorMessage {
    return trackingDetailData['error']?.toString() ?? 'Unknown error';
  }

  Future<void> navigateToTrackingDetail({
    required String plId,
    required String poNum,
    String? salesId,
  }) async {
    await navigateToTrackingDetailPage(
        plId: plId, poNum: poNum, salesId: salesId);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      filteredData.value = data;
    } else {
      isSearching.value = true;
      filteredData.value = data.where((item) {
        return item.custName.toLowerCase().contains(query.toLowerCase()) ||
            item.custAlias.toLowerCase().contains(query.toLowerCase()) ||
            item.custId.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void onCustomerSearchChanged(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      filteredData.value = data;
    } else {
      isSearching.value = true;
      filteredData.value = data.where((item) {
        return item.custName.toLowerCase().contains(query.toLowerCase()) ||
            item.custAlias.toLowerCase().contains(query.toLowerCase()) ||
            item.custId.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void clearCustomerSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    filteredData.value = data;
    update();
  }

  Future<void> loadProfileForPage({String? custId}) async {
    try {
      isLoadingProfile.value = true;

      if (custId != null && custId.isNotEmpty) {
        currentCustId.value = custId;
      }

      CustomerProfile profile = await _repository.getProfile(custId: custId);
      customerProfile.value = profile;

      await storeCustomerProfile(profile);
    } catch (e) {
      CustomerProfile? storedProfile = await getStoredCustomerProfile();
      if (storedProfile != null) {
        customerProfile.value = storedProfile;
      }

      Get.snackbar(
        'Error',
        'Failed to load profile data: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> loadProfileForCustomer(OrderTrackingModel customer) async {
    try {
      currentCustId.value = customer.custId;
      await loadProfileForPage(custId: customer.custId);
    } catch (e) {
      debugPrint('Error loading profile for customer ${customer.custId}: $e');
      rethrow;
    }
  }

  Future<void> loadOrderHistoryForPage({String? custId}) async {
    try {
      isLoadingOrderHistory.value = true;

      if (custId != null && custId.isNotEmpty) {
        currentCustId.value = custId;
      }

      final response = await _repository.getOrderHistory(custId: custId);

      orderHistoryData.clear();
      orderHistoryDataOriginal.clear();

      orderHistoryData.addAll(response.orders);
      orderHistoryDataOriginal.addAll(response.orders);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order history data: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingOrderHistory.value = false;
    }
  }

  Future<void> loadOrderHistoryForCustomer(OrderTrackingModel customer) async {
    try {
      currentCustId.value = customer.custId;
      await loadOrderHistoryForPage(custId: customer.custId);
    } catch (e) {
      debugPrint(
          'Error loading order history for customer ${customer.custId}: $e');
      rethrow;
    }
  }

  Future<void> navigateToDeliveryDetailPage() async {
    try {
      debugPrint('Navigating to delivery detail page');

      Get.toNamed('/delivery-detail');

      if (deliveryDetailData.isEmpty) {
        await loadDeliveryDetailFromPrefs();
      }
    } catch (e) {
      debugPrint('Error navigating to delivery detail: $e');
      Get.snackbar(
        'Error',
        'Failed to navigate to delivery detail',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  Future<void> loadDeliveryDetailFromPrefs({bool forceRefresh = false}) async {
    if (isLoadingDeliveryDetail.value) {
      debugPrint('Already loading delivery detail, skipping...');
      return;
    }

    try {
      isLoadingDeliveryDetail.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? salesId = prefs.getString("getSalesId");

      if (salesId != null && salesId.isNotEmpty) {
        currentSalesId.value = salesId;

        // Clear cache if force refresh is requested
        if (forceRefresh) {
          _repository.clearDeliveryDetailCache(salesId: salesId);
        }

        await loadDeliveryDetailForPage(salesId: salesId);
      } else {
        throw Exception('Sales ID not found in preferences');
      }
    } catch (e) {
      debugPrint('Error loading delivery detail from preferences: $e');
      Get.snackbar(
        'Error',
        'Sales ID not found. Please select an order first.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingDeliveryDetail.value = false;
    }
  }

  Future<void> loadDeliveryDetailForPage({String? salesId}) async {
    if (isLoadingDeliveryDetail.value) {
      debugPrint('Already loading delivery detail for page, skipping...');
      return;
    }

    try {
      isLoadingDeliveryDetail.value = true;

      if (salesId != null && salesId.isNotEmpty) {
        currentSalesId.value = salesId;
      }

      debugPrint(
          'Loading delivery detail for sales ID: ${currentSalesId.value}');

      final List<DeliveryDetailModel> deliveryDetails =
          await _repository.getDeliveryDetail();

      deliveryDetailData.clear();
      deliveryDetailData.addAll(deliveryDetails);

      debugPrint(
          'Successfully loaded ${deliveryDetails.length} delivery details');
    } catch (e) {
      debugPrint('Error loading delivery detail: $e');
      Get.snackbar(
        'Error',
        'Failed to load delivery detail data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingDeliveryDetail.value = false;
    }
  }

  Future<void> navigateToDeliveryDetail() async {
    await navigateToDeliveryDetailPage();
  }

  void onOrderHistorySearchChanged(String query) {
    if (query.isEmpty) {
      orderHistoryData.value = orderHistoryDataOriginal;
    } else {
      orderHistoryData.value = orderHistoryDataOriginal
          .where(
              (item) => item.poNum.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void clearOrderHistorySearch() {
    orderHistorySearchController.clear();
    orderHistoryData.value = orderHistoryDataOriginal;
  }

  Future<CustomerProfile?> getStoredCustomerProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? profileData = prefs.getString('customer_profile_data');
      if (profileData != null) {
        Map<String, dynamic> profileJson = json.decode(profileData);
        return CustomerProfile.fromJson(profileJson);
      }
    } catch (e) {}
    return null;
  }

  Future<void> storeCustomerProfile(CustomerProfile profile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'customer_profile_data', json.encode(profile.toJson()));
    } catch (e) {}
  }

  Future<void> navigateToDetail(OrderTrackingModel item) async {
    try {
      OrderTrackingUser? currentUser = await getStoredUserData();

      Get.toNamed(
        '/order_detail',
        arguments: {
          'userId': currentUser?.userId,
          'customerName': item.custName,
          'customerEmail': currentUser?.email ?? 'Email is empty',
          'customerAlias': item.custAlias,
          'custId': item.custId,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customer details',
        snackPosition: SnackPosition.TOP,
      );
      debugPrint('Error navigating to detail: $e');
    }
  }

  Future<void> navigateToCustomerProfile(OrderTrackingModel customer) async {
    try {
      _repository.clearProfileCache(custId: customer.custId);
      await loadProfileForCustomer(customer);

      Get.toNamed('/customer_profile', arguments: {
        'custId': customer.custId,
        'custName': customer.custName,
        'custAlias': customer.custAlias,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customer profile',
        snackPosition: SnackPosition.TOP,
      );
      debugPrint('Error navigating to customer profile: $e');
    }
  }

  Future<void> navigateToOrderHistory(OrderTrackingModel customer) async {
    try {
      _repository.clearOrderHistoryCache(custId: customer.custId);
      await loadOrderHistoryForCustomer(customer);

      Get.toNamed('/order-history', arguments: {
        'custId': customer.custId,
        'custName': customer.custName,
        'custAlias': customer.custAlias,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order history',
        snackPosition: SnackPosition.TOP,
      );
      debugPrint('Error navigating to order history: $e');
    }
  }

  Future<void> navigateToDetailWithUser(OrderTrackingUser user) async {
    try {
      Get.toNamed(
        '/order_detail',
        arguments: {
          'userId': user.userId,
          'customerName': user.name,
          'customerEmail': user.email,
          'salesId': user.salesId,
          'role': user.role,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customer details',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    filteredData.value = data;
  }

  Future<void> getData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.fetchOrderTracking();

      data.clear();
      dataOriginal.clear();

      data.addAll(response.data);
      dataOriginal.addAll(response.data);
      filteredData.value = data;

      if (isSearching.value) {
        clearSearch();
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch order tracking data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    _repository.clearCache();
    await getData();
  }

  Future<void> refreshProfile({String? custId}) async {
    String? targetCustId = custId ?? currentCustId.value;
    _repository.clearProfileCache(custId: targetCustId);
    await loadProfileForPage(
        custId: targetCustId.isNotEmpty ? targetCustId : null);
  }

  Future<void> refreshOrderHistory({String? custId}) async {
    String? targetCustId = custId ?? currentCustId.value;
    _repository.clearOrderHistoryCache(custId: targetCustId);
    await loadOrderHistoryForPage(
        custId: targetCustId.isNotEmpty ? targetCustId : null);
  }

  Future<void> refreshDeliveryDetail({String? salesId}) async {
    String? targetSalesId = salesId ?? currentSalesId.value;
    _repository.clearDeliveryDetailCache(salesId: targetSalesId);
    await loadDeliveryDetailForPage(
        salesId: targetSalesId.isNotEmpty ? targetSalesId : null);
  }

  Future<void> refreshAll() async {
    _repository.clearAllCaches();
    await Future.wait([
      getData(),
      if (customerProfile.value != null && currentCustId.value.isNotEmpty)
        loadProfileForPage(custId: currentCustId.value),
      if (orderHistoryData.isNotEmpty && currentCustId.value.isNotEmpty)
        loadOrderHistoryForPage(custId: currentCustId.value),
      if (deliveryDetailData.isNotEmpty && currentSalesId.value.isNotEmpty)
        loadDeliveryDetailForPage(salesId: currentSalesId.value),
      if (trackingDetailData.isNotEmpty && currentPlId.value.isNotEmpty)
        loadTrackingDetail(),
    ]);
  }

  Future<OrderTrackingUser?> getStoredUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');
      if (userData != null) {
        Map<String, dynamic> userJson = json.decode(userData);
        return OrderTrackingUser.fromJson(userJson);
      }
    } catch (e) {}
    return null;
  }
}
