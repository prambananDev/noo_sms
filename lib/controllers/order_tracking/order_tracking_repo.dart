import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/order_tracking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noo_sms/service/api_constant.dart';

class OrderTrackingRepository {
  static final OrderTrackingRepository _instance =
      OrderTrackingRepository._internal();
  factory OrderTrackingRepository() => _instance;
  OrderTrackingRepository._internal();

  final http.Client _client = http.Client();

  final Map<String, OrderTrackingResponse> _orderTrackingCache = {};
  final Map<String, CustomerProfile> _profileCache = {};
  final Map<String, OrderHistoryResponse> _orderHistoryCache = {};
  final Map<String, List<DeliveryDetailModel>> _deliveryDetailCache = {};
  final Map<String, Map<String, dynamic>> _trackingDetailCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  final int _cacheDuration = 300000;
  final int _trackingDetailCacheDuration = 10000;

  Future<Map<String, dynamic>> getTrackingDetail({required String plId}) async {
    final String cacheKey = 'tracking_detail_$plId';

    if (_trackingDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _trackingDetailCacheDuration) {
      return _trackingDetailCache[cacheKey]!;
    }

    const String apiUrl =
        "https://tms.intellitrac.co.id/api/get_order_routing_status";

    final Map<String, dynamic> requestBody = {
      "username": "prb_user_api",
      "password": "prb6788",
      "number": plId,
    };

    try {
      final response = await _client.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Connection': 'keep-alive',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        _trackingDetailCache[cacheKey] = responseData;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return responseData;
      } else {
        throw Exception(
            'Failed to fetch tracking detail: ${response.statusCode}');
      }
    } catch (e) {
      if (_trackingDetailCache.containsKey(cacheKey)) {
        return _trackingDetailCache[cacheKey]!;
      }

      return {
        'error': 'Failed to fetch tracking detail: $e',
        'data': null,
      };
    }
  }

  Future<OrderTrackingResponse> fetchOrderTracking() async {
    const String cacheKey = 'order_tracking_data';

    if (_orderTrackingCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _orderTrackingCache[cacheKey]!;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? salesmanId = prefs.getInt("getSalesId");

    final url = Uri.parse("$apiOrder/CustTable_AX?salesman_id=$salesmanId");

    final response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      final orderTrackingResponse = OrderTrackingResponse.fromJson(jsonData);

      _orderTrackingCache[cacheKey] = orderTrackingResponse;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return orderTrackingResponse;
    } else {
      throw Exception(
          'Failed to fetch order tracking data: ${response.statusCode}');
    }
  }

  Future<CustomerProfile> getProfile({String? custId}) async {
    String? userId = custId;

    if (userId == null || userId.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString("getUserId");
    }

    if (userId == null || userId.isEmpty) {
      throw Exception(
          'Customer ID not provided and User ID not found in SharedPreferences');
    }

    final String cacheKey = 'profile_data_$userId';

    if (_profileCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _profileCache[cacheKey]!;
    }

    final url = Uri.parse("$apiOrder/Account/$userId");

    final response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      final customerProfile = CustomerProfile.fromJson(jsonData);

      _profileCache[cacheKey] = customerProfile;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return customerProfile;
    } else {
      throw Exception('Failed to fetch profile data: ${response.statusCode}');
    }
  }

  Future<CustomerProfile> getProfileByCustId(String custId) async {
    if (custId.isEmpty) {
      throw Exception('Customer ID is required');
    }

    return getProfile(custId: custId);
  }

  Future<OrderHistoryResponse> getOrderHistory({String? custId}) async {
    String? userId = custId;

    if (userId == null || userId.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString("getUserId");
    }

    if (userId == null || userId.isEmpty) {
      throw Exception(
          'Customer ID not provided and User ID not found in SharedPreferences');
    }

    final String cacheKey = 'order_history_$userId';

    if (_orderHistoryCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _orderHistoryCache[cacheKey]!;
    }

    final url = Uri.parse("$apiOrder/OrderHistory/$userId");

    final response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      final orderHistoryResponse = OrderHistoryResponse.fromJson(jsonData);

      _orderHistoryCache[cacheKey] = orderHistoryResponse;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return orderHistoryResponse;
    } else {
      throw Exception(
          'Failed to fetch order history data: ${response.statusCode}');
    }
  }

  Future<OrderHistoryResponse> getOrderHistoryByCustId(String custId) async {
    if (custId.isEmpty) {
      throw Exception('Customer ID is required');
    }

    return getOrderHistory(custId: custId);
  }

  Future<List<DeliveryDetailModel>> getDeliveryDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? targetSalesId = prefs.getString("getSalesId");

    final String cacheKey = 'delivery_detail_$targetSalesId';

    if (_deliveryDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _deliveryDetailCache[cacheKey]!;
    }

    final url = Uri.parse("$apiOrder/PackingSlip/$targetSalesId");
    debugPrint(url.toString());
    final response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      final List<DeliveryDetailModel> deliveryDetails =
          jsonData.map((item) => DeliveryDetailModel.fromJson(item)).toList();

      _deliveryDetailCache[cacheKey] = deliveryDetails;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return deliveryDetails;
    } else {
      throw Exception(
          'Failed to fetch delivery detail data: ${response.statusCode}');
    }
  }

  void clearCache() {
    _orderTrackingCache.clear();
    _cacheTimestamps
        .removeWhere((key, value) => key.startsWith('order_tracking_'));
  }

  void clearProfileCache({String? custId}) {
    if (custId != null) {
      final String cacheKey = 'profile_data_$custId';
      _profileCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    } else {
      _profileCache
          .removeWhere((key, value) => key.startsWith('profile_data_'));
      _cacheTimestamps
          .removeWhere((key, value) => key.startsWith('profile_data_'));
    }
  }

  void clearOrderHistoryCache({String? custId}) {
    if (custId != null) {
      final String cacheKey = 'order_history_$custId';
      _orderHistoryCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    } else {
      _orderHistoryCache
          .removeWhere((key, value) => key.startsWith('order_history_'));
      _cacheTimestamps
          .removeWhere((key, value) => key.startsWith('order_history_'));
    }
  }

  void clearDeliveryDetailCache({String? salesId}) {
    if (salesId != null) {
      final String cacheKey = 'delivery_detail_$salesId';
      _deliveryDetailCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    } else {
      _deliveryDetailCache
          .removeWhere((key, value) => key.startsWith('delivery_detail_'));
      _cacheTimestamps
          .removeWhere((key, value) => key.startsWith('delivery_detail_'));
    }
  }

  void clearTrackingDetailCache({String? plId}) {
    if (plId != null) {
      final String cacheKey = 'tracking_detail_$plId';
      _trackingDetailCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    } else {
      _trackingDetailCache
          .removeWhere((key, value) => key.startsWith('tracking_detail_'));
      _cacheTimestamps
          .removeWhere((key, value) => key.startsWith('tracking_detail_'));
    }
  }

  void clearAllCaches() {
    _orderTrackingCache.clear();
    _profileCache.clear();
    _orderHistoryCache.clear();
    _deliveryDetailCache.clear();
    _trackingDetailCache.clear();
    _cacheTimestamps.clear();
  }

  OrderTrackingResponse? getCachedOrderTracking() {
    const String cacheKey = 'order_tracking_data';

    if (_orderTrackingCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _orderTrackingCache[cacheKey];
    }
    return null;
  }

  CustomerProfile? getCachedProfile({String? custId}) {
    String? userId = custId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final String cacheKey = 'profile_data_$userId';

    if (_profileCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _profileCache[cacheKey];
    }
    return null;
  }

  OrderHistoryResponse? getCachedOrderHistory({String? custId}) {
    if (custId == null || custId.isEmpty) return null;

    final String cacheKey = 'order_history_$custId';

    if (_orderHistoryCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _orderHistoryCache[cacheKey]!;
    }
    return null;
  }

  List<DeliveryDetailModel>? getCachedDeliveryDetail({String? salesId}) {
    if (salesId == null || salesId.isEmpty) return null;

    final String cacheKey = 'delivery_detail_$salesId';

    if (_deliveryDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _deliveryDetailCache[cacheKey]!;
    }
    return null;
  }

  Map<String, dynamic>? getCachedTrackingDetail({String? plId}) {
    if (plId == null || plId.isEmpty) return null;

    final String cacheKey = 'tracking_detail_$plId';

    if (_trackingDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _trackingDetailCacheDuration) {
      return _trackingDetailCache[cacheKey]!;
    }
    return null;
  }

  bool isOrderTrackingCached() {
    const String cacheKey = 'order_tracking_data';

    return _orderTrackingCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration;
  }

  bool isProfileCached({String? custId}) {
    if (custId == null || custId.isEmpty) return false;

    final String cacheKey = 'profile_data_$custId';

    return _profileCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration;
  }

  bool isOrderHistoryCached({String? custId}) {
    if (custId == null || custId.isEmpty) return false;

    final String cacheKey = 'order_history_$custId';

    return _orderHistoryCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration;
  }

  bool isDeliveryDetailCached({String? salesId}) {
    if (salesId == null || salesId.isEmpty) return false;

    final String cacheKey = 'delivery_detail_$salesId';

    return _deliveryDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration;
  }

  bool isTrackingDetailCached({String? plId}) {
    if (plId == null || plId.isEmpty) return false;

    final String cacheKey = 'tracking_detail_$plId';

    return _trackingDetailCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _trackingDetailCacheDuration;
  }
}
