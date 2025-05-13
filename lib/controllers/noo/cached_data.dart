import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String cachePrefix = 'noo_cache_';
  static const int defaultCacheDuration = 86400000;

  static const String salesOffices = '${cachePrefix}sales_offices';
  static const String businessUnits = '${cachePrefix}business_units';
  static const String axRegionals = '${cachePrefix}ax_regionals';
  static const String paymentMode = '${cachePrefix}payment_mode';
  static const String category = '${cachePrefix}category';
  static const String category1 = '${cachePrefix}category1';
  static const String segment = '${cachePrefix}segment';
  static const String subSegment = '${cachePrefix}sub_segment';
  static const String classKey = '${cachePrefix}class';
  static const String companyStatus = '${cachePrefix}company_status';
  static const String currency = '${cachePrefix}currency';
  static const String customerGroups = '${cachePrefix}customer_groups';
  static const String priceGroup = '${cachePrefix}price_group';
  static const String provinces = '${cachePrefix}provinces';
  static const String cities = '${cachePrefix}cities';
  static const String districts = '${cachePrefix}districts';

  static const String timestampPrefix = 'timestamp_';

  static Future<bool> saveData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonData = await compute(_encodeJson, data);

      final dataSaved = await prefs.setString(key, jsonData);

      final timestampSaved = await prefs.setInt(
          '$timestampPrefix$key', DateTime.now().millisecondsSinceEpoch);

      return dataSaved && timestampSaved;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> getData(String key,
      {int maxAge = defaultCacheDuration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonData = prefs.getString(key);
      if (jsonData == null) {
        return null;
      }

      final timestamp = prefs.getInt('$timestampPrefix$key') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > maxAge) {
        return null;
      }

      return await compute(_decodeJson, jsonData);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataRemoved = await prefs.remove(key);
      final timestampRemoved = await prefs.remove('$timestampPrefix$key');

      return dataRemoved && timestampRemoved;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) =>
          key.startsWith(cachePrefix) || key.startsWith(timestampPrefix));

      for (var key in keys) {
        await prefs.remove(key);
      }

      await prefs.reload();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isCacheValid(String key,
      {int maxAge = defaultCacheDuration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonData = prefs.getString(key);
      if (jsonData == null) {
        return false;
      }

      final timestamp = prefs.getInt('$timestampPrefix$key') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      return now - timestamp <= maxAge;
    } catch (e) {
      return false;
    }
  }

  static Future<int?> getCacheTimestamp(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$timestampPrefix$key');
    } catch (e) {
      return null;
    }
  }
}

String _encodeJson(dynamic data) {
  return jsonEncode(data);
}

dynamic _decodeJson(String jsonData) {
  return jsonDecode(jsonData);
}
