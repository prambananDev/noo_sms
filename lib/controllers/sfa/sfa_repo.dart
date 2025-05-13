import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/models/sfa_model.dart';

class PhotoUploadResult {
  final bool success;
  final String photoName;

  PhotoUploadResult({required this.success, required this.photoName});
}

class CheckInResponse {
  final bool success;
  final int visitId;

  CheckInResponse({required this.success, required this.visitId});
}

class SfaRepository {
  static final SfaRepository _instance = SfaRepository._internal();
  factory SfaRepository() => _instance;
  SfaRepository._internal();

  final http.Client _client = http.Client();

  final Map<String, List<SfaRecord>> _sfaRecordsCache = {};
  final Map<bool, List<VisitCustomer>> _customersCache = {};
  final Map<String, CustomerInfo> _customerInfoCache = {};
  final Map<bool, List<VisitPurpose>> _purposeCache = {};

  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<SfaRecord>> fetchSfaRecords(String username) async {
    final cacheKey = 'sfa_$username';
    if (_sfaRecordsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _sfaRecordsCache[cacheKey]!;
    }

    try {
      var url = Uri.parse('$apiSMS/VisitCustomer/?username=$username');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        final records = data.map((data) => SfaRecord.fromJson(data)).toList();
        _sfaRecordsCache[cacheKey] = records;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return records;
      } else {
        throw Exception('Failed to load SFA records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<SfaRecordDetail> fetchSfaDetail(int id) async {
    try {
      var url = Uri.parse('$apiSMS/VisitCustomer/$id');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return SfaRecordDetail.fromJson(data);
      } else {
        throw Exception('Failed to load SFA detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<VisitCustomer>> fetchCustomers(bool existing) async {
    _customersCache[existing] = [];
    _cacheTimestamps.remove('customers_$existing');

    var url = Uri.parse('$apiSMS/VisitCustomer/?existing=$existing');

    var response = await _client.get(
      url,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      final customers =
          data.map((data) => VisitCustomer.fromJson(data)).toList();

      _customersCache[existing] = customers;
      _cacheTimestamps['customers_$existing'] = DateTime.now();

      return customers;
    } else {
      throw Exception('Failed to load customers: ${response.statusCode}');
    }
  }

  Future<List<VisitPurpose>> fetchPurpose(bool existing) async {
    if (_purposeCache.containsKey(existing) &&
        _cacheTimestamps.containsKey('customers_$existing') &&
        DateTime.now()
                .difference(_cacheTimestamps['customers_$existing']!)
                .inMilliseconds <
            _cacheDuration) {
      return _purposeCache[existing]!;
    }

    try {
      var url = Uri.parse('$apiSMS/VisitCustomer/?sfaType=true');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final purpose =
            data.map((data) => VisitPurpose.fromJson(data)).toList();

        _purposeCache[existing] = purpose;
        _cacheTimestamps['customers_$existing'] = DateTime.now();

        return purpose;
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CustomerInfo?> fetchCustInfo(dynamic id) async {
    final cacheKey = 'customer_info_$id';
    if (_customerInfoCache.containsKey(id) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _customerInfoCache[id]!;
    }

    try {
      var url = Uri.parse('$apiSMS/VisitCustomer/?findInfoByCustId=$id');

      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        CustomerInfo customerInfo = CustomerInfo(
          name: data['CustName'],
          address: data['CustAddress'],
          contact: data['CustContact'],
          contactNum: data['CustContactNum'],
          contactTitle: data['CustContactTitle'],
        );

        _customerInfoCache[id] = customerInfo;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return customerInfo;
      } else if (response.statusCode == 500) {
        return null;
      } else {
        throw Exception('Failed to load customer info: ${response.statusCode}');
      }
    } catch (e) {
      return CustomerInfo(
        name: "",
        address: "",
        contact: "",
        contactNum: "",
        contactTitle: "",
      );
    }
  }

  Future<PhotoUploadResult> uploadPhoto(File photo, String customerId) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiSMS/VisitCustomer/CheckIn'));

      var fileStream = http.ByteStream(photo.openRead());
      var fileLength = await photo.length();

      String photoName =
          'SFA${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.jpg';

      var multipartFile = http.MultipartFile('photo', fileStream, fileLength,
          filename: photoName);

      request.files.add(multipartFile);
      request.fields['customerId'] = customerId;
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      request.headers['Connection'] = 'keep-alive';

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        String serverPhotoName = photoName;

        var responseJson = json.decode(responseBody);
        if (responseJson.containsKey('fileName')) {
          serverPhotoName = responseJson['fileName'];
        }

        return PhotoUploadResult(success: true, photoName: serverPhotoName);
      } else {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CheckInResponse> submitCheckIn(
      Map<String, dynamic> checkInData) async {
    try {
      checkInData.removeWhere((key, value) => value == null);

      var url = Uri.parse('$apiSMS/VisitCustomer');

      var response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
        body: json.encode(checkInData),
      );

      var responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        int visitId = int.parse(responseBody.trim());

        _sfaRecordsCache.clear();

        return CheckInResponse(success: true, visitId: visitId);
      } else {
        throw Exception('Failed to submit check-in: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitCheckOut(Map<String, dynamic> checkOutData) async {
    try {
      var url = Uri.parse('$apiSMS/VisitCustomer');

      var response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
        body: json.encode(checkOutData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _sfaRecordsCache.clear();
        return true;
      } else {
        throw Exception('Failed to submit check-out: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkPhotoExists(String photoName) async {
    try {
      if (photoName.isEmpty) return false;

      var url = Uri.parse('$apiSMS/VisitCustomer/CheckIn?filename=$photoName');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<SfaComment>> fetchComments(int recordId) async {
    final uri = Uri.parse('$apiSMS/VisitCustomer/ViewProgress/$recordId');
    final response = await _client.get(
      uri,
      headers: {'Connection': 'keep-alive'},
    );

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);

      if (jsonData is List) {
        return jsonData
            .map<SfaComment>((item) => SfaComment.fromJson(item))
            .toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data']
            .map<SfaComment>((item) => SfaComment.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  Future<bool> addComment(int recordId, String comment) async {
    final uri = Uri.parse('$apiSMS/VisitCustomer/AddProgress');
    final body = json.encode({
      'sfaTransId': recordId,
      'desc': comment,
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Connection': 'keep-alive'},
      body: body,
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteComment(int commentId) async {
    final uri = Uri.parse('$apiSMS/VisitCustomer/DelProgress/$commentId');
    final response = await _client.delete(
      uri,
      headers: {'Connection': 'keep-alive'},
    );

    return response.statusCode == 200;
  }

  Future<bool> closeVisit(int recordId) async {
    try {
      final response = await http.put(
        Uri.parse('$apiSMS/VisitCustomer/CloseVisit/$recordId'),
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error closing visit: $e');
    }
  }

  void clearCache() {
    _sfaRecordsCache.clear();
    _customersCache.clear();
    _customerInfoCache.clear();
    _cacheTimestamps.clear();
  }

  void dispose() {
    _client.close();
  }
}
