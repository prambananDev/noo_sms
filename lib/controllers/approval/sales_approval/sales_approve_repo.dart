import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/sales_approve_models.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesApproveRepository {
  static final SalesApproveRepository _instance =
      SalesApproveRepository._internal();
  factory SalesApproveRepository() => _instance;
  SalesApproveRepository._internal();

  final http.Client _client = http.Client();
  final String _baseUrl = apiSalesOrder;

  final Map<String, List<SalesOrder>> _ordersCache = {};
  final Map<int, SalesOrderDetail> _orderDetailCache = {};
  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<SalesOrder>> fetchPendingApproval() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    String? token = preferences.getString("token");
    final cacheKey = 'pending_approval_$username';

    if (_ordersCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _ordersCache[cacheKey]!;
    }

    try {
      final uri = Uri.parse('$_baseUrl/api/SalesOrderPending/$username');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      debugPrint(token);
      debugPrint(uri.toString());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final orders = await _processSalesOrders(data, token!);

        _ordersCache[cacheKey] = orders;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return orders;
      } else {
        throw HttpException(
            'Failed to fetch pending approvals: ${response.statusCode}');
      }
    } on TimeoutException {
      throw TimeoutException('Request timeout. Please try again.');
    } on HttpException {
      throw const HttpException(
          'No internet connection. Please check your connection.');
    } catch (e) {
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }

  Future<List<SalesOrder>> _processSalesOrders(
      List<dynamic> data, String token) async {
    final List<SalesOrder> orders = [];

    for (var item in data) {
      try {
        final order = SalesOrder.fromJson(item);

        final salesAmount = await fetchSalesAmount(order.salesId, token);
        final salesAmountPpn = salesAmount * 1.11;

        int days = 0;
        if (order.processDesc.contains('Overdue')) {
          days = await fetchDays(order.custAccount);
        }

        orders.add(order.copyWith(
          salesAmount: salesAmount,
          salesAmountPpn: salesAmountPpn,
          days: days,
        ));
      } catch (e) {}
    }

    return orders;
  }

  Future<double> fetchSalesAmount(String salesOrder, String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/sales-amount/$salesOrder/amt');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> fetchDays(String customerCode) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/overdue-days/$customerCode/days');
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as int;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<SalesOrderDetail> fetchDetailApproval(int recId, String token) async {
    if (_orderDetailCache.containsKey(recId)) {
      return _orderDetailCache[recId]!;
    }

    try {
      final uri = Uri.parse('$_baseUrl/api/sales-approval/detail/$recId');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detail = SalesOrderDetail.fromJson(data);

        final salesAmount = await fetchSalesAmount(detail.salesId, token);
        final salesAmountPpn = salesAmount * 1.11;
        final days = await fetchDays(detail.accountNum);
        final customerRef = await fetchCustomerRef(detail.salesId, token);

        final updatedDetail = detail.copyWith(
          salesAmount: salesAmount,
          salesAmountPpn: salesAmountPpn,
          days: days,
          customerRef: customerRef,
        );

        _orderDetailCache[recId] = updatedDetail;

        return updatedDetail;
      } else {
        throw HttpException(
            'Failed to fetch order details: ${response.statusCode}');
      }
    } on TimeoutException {
      throw TimeoutException('Request timeout. Please try again.');
    } on HttpException {
      throw const HttpException(
          'No internet connection. Please check your connection.');
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  Future<String> fetchCustomerRef(String salesOrder, String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/customer-ref/$salesOrder');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<bool> approveReject(ApprovalRequest request, String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/sales-approval/action');
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCache();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void clearCache() {
    _ordersCache.clear();
    _orderDetailCache.clear();
    _cacheTimestamps.clear();
  }

  void dispose() {
    _client.close();
  }
}
