import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/submission_model.dart';
import 'package:noo_sms/service/api_constant.dart';

class SubmissionRepository {
  static final SubmissionRepository _instance =
      SubmissionRepository._internal();
  factory SubmissionRepository() => _instance;
  SubmissionRepository._internal();

  final http.Client _client = http.Client();

  final Map<String, List<Asset>> _assetsCache = {};
  final Map<String, AssetHistory> _assetsHistoryCache = {};

  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<Asset>> fetchAssets(int page, int pageSize) async {
    final cacheKey = 'assets_page_${pageSize}_$page';

    if (_assetsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _assetsCache[cacheKey]!;
    }

    try {
      var url = Uri.parse('$apiSMS/Assets?page=$page&pageSize=$pageSize');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        List<dynamic> items = data['items'];
        List<Asset> assets = items.map((item) => Asset.fromJson(item)).toList();

        _assetsCache[cacheKey] = assets;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return assets;
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<AssetHistory> fetchAssetsHistory(int page, int pageSize) async {
    final cacheKey = 'assets_history_${pageSize}_$page';

    if (_assetsHistoryCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _assetsHistoryCache[cacheKey]!;
    }

    try {
      var url =
          Uri.parse('$apiSMS/assets/loanHistory?page=$page&pageSize=$pageSize');
      var response = await _client.get(
        url,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        AssetHistory assetHistory = AssetHistory.fromJson(data);

        _assetsHistoryCache[cacheKey] = assetHistory;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return assetHistory;
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    try {
      var url = Uri.parse('$apiSMS/custtables');
      var response = await _client.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Customer.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<AssetAvail>> fetchAssetAvail() async {
    try {
      var url = Uri.parse('$apiSMS/Assets/findAvailable');
      var response = await _client.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => AssetAvail.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<AssetDetail> fetchAssetDetail(int id) async {
    try {
      var url = Uri.parse('$apiSMS/Assets/loanDetail?id=$id');
      var response = await _client.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return AssetDetail.fromJson(data);
      } else {
        throw Exception('Failed to load asset detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitAssetLoan(AssetLoan assetLoan) async {
    try {
      var url = Uri.parse('$apiSMS/Assets');
      var response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
        body: json.encode(assetLoan.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _assetsHistoryCache.clear();
        _cacheTimestamps.clear();
        return true;
      } else {
        throw Exception('Failed to submit asset loan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitAssetReturn(AssetReturn assetReturn) async {
    try {
      var url = Uri.parse('$apiSMS/assets/loanRetun');
      var response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
        body: json.encode(assetReturn.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _assetsHistoryCache.clear();
        _cacheTimestamps.clear();
        return true;
      } else {
        throw Exception('Failed to submit asset loan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
