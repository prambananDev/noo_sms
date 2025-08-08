import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/edit_cust_noo_model.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCustRepository {
  static final EditCustRepository _instance = EditCustRepository._internal();
  factory EditCustRepository() => _instance;
  EditCustRepository._internal();

  final http.Client _client = http.Client();

  final Map<String, EditCustResponse> _editCustCache = {};
  final Map<int, CustomerDetail> _customerDetailCache = {};
  final Map<String, List<PaymentTerm>> _paymentTermCache = {};

  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<int, DateTime> _detailCacheTimestamps = {};
  final Map<String, DateTime> _paymentTermCacheTimestamps = {};

  Future<EditCustResponse> fetchEditCust(RxInt page, RxInt pageSize) async {
    final String cacheKey =
        'edit_cust_page_${page.value}_size_${pageSize.value}';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");

    if (_editCustCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _editCustCache[cacheKey]!;
    }

    final url = Uri.parse(
        "${apiNOO}AXCustTable?page=${page.value}&pageSize=${pageSize.value}&username=$username");

    final response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      final editCustResponse = EditCustResponse.fromJson(jsonData);

      _editCustCache[cacheKey] = editCustResponse;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return editCustResponse;
    } else {
      throw Exception('Failed to fetch customers: ${response.statusCode}');
    }
  }

  Future<CustomerDetail> fetchCustomerDetail(int customerId,
      {bool forceRefresh = false}) async {
    // Force refresh will bypass cache
    if (!forceRefresh &&
        _customerDetailCache.containsKey(customerId) &&
        _detailCacheTimestamps.containsKey(customerId) &&
        DateTime.now()
                .difference(_detailCacheTimestamps[customerId]!)
                .inMilliseconds <
            _cacheDuration) {
      debugPrint("Returning cached customer detail for ID: $customerId");
      return _customerDetailCache[customerId]!;
    }

    final url = Uri.parse("${apiNOO}AXCustTable/$customerId");

    final response = await _client.get(
      url,
      headers: {
        'Connection': 'keep-alive',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      final customerDetail = CustomerDetail.fromJson(jsonData);

      _customerDetailCache[customerId] = customerDetail;
      _detailCacheTimestamps[customerId] = DateTime.now();

      return customerDetail;
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found with ID: $customerId');
    } else {
      throw Exception(
          'Failed to fetch customer detail: ${response.statusCode}');
    }
  }

  void debugPrintLongString(String input) {
    const int chunkSize = 800; // Safe chunk size for debugPrint
    for (int i = 0; i < input.length; i += chunkSize) {
      final end = (i + chunkSize < input.length) ? i + chunkSize : input.length;
      debugPrint(input.substring(i, end));
    }
  }

  Future<bool> updateCustomerDetail(
      int customerId, Map<String, dynamic> updateData) async {
    try {
      final url = Uri.parse("${apiNOO}AXCustTable?id=$customerId");

      final response = await _client.put(
        url,
        headers: {
          'Connection': 'keep-alive',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      debugPrint("PUT request to: $url");
      debugPrintLongString(json.encode(updateData));
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear the specific customer cache
        clearCustomerDetailCache(customerId);

        // Also clear the list cache to ensure it's refreshed
        clearCache();

        Get.snackbar(
          'Success',
          'Update Customer Data',
          snackPosition: SnackPosition.TOP,
        );

        debugPrint("Customer updated successfully and cache cleared");
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Customer not found with ID: $customerId');
      } else {
        throw Exception(
            'Failed to update customer: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint("Error updating customer: $e");
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<List<PaymentTerm>> fetchPaymentTerms({String? segment}) async {
    final String cacheKey =
        segment != null ? 'payment_terms_$segment' : 'payment_terms_all';

    if (_paymentTermCache.containsKey(cacheKey) &&
        _paymentTermCacheTimestamps.containsKey(cacheKey) &&
        DateTime.now()
                .difference(_paymentTermCacheTimestamps[cacheKey]!)
                .inMilliseconds <
            _cacheDuration) {
      debugPrint("Returning cached payment terms for key: $cacheKey");
      return _paymentTermCache[cacheKey]!;
    }

    final String apiUrl = segment != null
        ? "${apiNOO}PaymentTerms/BySegment/$segment"
        : "${apiNOO}PaymentTerms";

    final url = Uri.parse(apiUrl);

    final response = await _client.get(
      url,
      headers: {
        'Connection': 'keep-alive',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      final List<PaymentTerm> paymentTerms =
          jsonData.map((item) => PaymentTerm.fromJson(item)).toList();

      _paymentTermCache[cacheKey] = paymentTerms;
      _paymentTermCacheTimestamps[cacheKey] = DateTime.now();

      return paymentTerms;
    } else if (response.statusCode == 404) {
      throw Exception('Payment terms not found for segment: $segment');
    } else {
      throw Exception('Failed to fetch payment terms: ${response.statusCode}');
    }
  }

  void clearCustomerDetailCache(int customerId) {
    _customerDetailCache.remove(customerId);
    _detailCacheTimestamps.remove(customerId);
    debugPrint("Cleared cache for customer ID: $customerId");
  }

  void clearAllCaches() {
    clearCache();
    clearDetailCache();
    clearPaymentTermCache();
  }

  void clearCache() {
    _editCustCache.clear();
    _cacheTimestamps.clear();
    debugPrint("Cleared edit customer list cache");
  }

  void clearDetailCache() {
    _customerDetailCache.clear();
    _detailCacheTimestamps.clear();
    debugPrint("Cleared all customer detail caches");
  }

  void clearPaymentTermCache() {
    _paymentTermCache.clear();
    _paymentTermCacheTimestamps.clear();
    debugPrint("Cleared payment term cache");
  }

  CustomerDetail? getCachedCustomerDetail(int customerId) {
    if (_customerDetailCache.containsKey(customerId) &&
        _detailCacheTimestamps.containsKey(customerId) &&
        DateTime.now()
                .difference(_detailCacheTimestamps[customerId]!)
                .inMilliseconds <
            _cacheDuration) {
      return _customerDetailCache[customerId];
    }
    return null;
  }

  bool isCustomerDetailCached(int customerId) {
    return _customerDetailCache.containsKey(customerId) &&
        _detailCacheTimestamps.containsKey(customerId) &&
        DateTime.now()
                .difference(_detailCacheTimestamps[customerId]!)
                .inMilliseconds <
            _cacheDuration;
  }
}
