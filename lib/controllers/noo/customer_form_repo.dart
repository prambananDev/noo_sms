// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/noo/cached_data.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/models/customer_form.dart';

class CustomerFormRepository {
  static final CustomerFormRepository _instance =
      CustomerFormRepository._internal();
  factory CustomerFormRepository() => _instance;
  CustomerFormRepository._internal();

  final http.Client _client = http.Client();

  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;

  final Map<String, List<SalesOffice>> _salesOfficesCache = {};
  final Map<String, List<BusinessUnit>> _businessUnitsCache = {};
  final Map<String, List<AXRegional>> _axRegionalsCache = {};
  final Map<String, List<CustomerPaymentMode>> _paymentModeCache = {};
  final Map<String, List<Category1>> _categoryCache = {};
  final Map<String, List<Category2>> _category1Cache = {};
  final Map<String, List<Segment>> _segmentCache = {};
  final Map<String, List<SubSegment>> _subSegmentCache = {};
  final Map<String, List<ClassModel>> _classCache = {};
  final Map<String, List<CompanyStatus>> _companyStatusCache = {};
  final Map<String, List<Currency>> _currencyCache = {};
  final Map<String, List<PriceGroup>> _priceGroupCache = {};
  final Map<String, List<CustomerGroup>> _customerGroupsCache = {};
  final Map<String, List<Map<String, dynamic>>> _provincesCache = {};
  final Map<String, List<Map<String, dynamic>>> _citiesCache = {};
  final Map<String, List<Map<String, dynamic>>> _districtsCache = {};

  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};

  void dispose() {
    _client.close();
  }

  Future<void> clearCache() async {
    await CacheService.clearAllCache();
    clearMemoryCache();
  }

  clearMemoryCache() {
    _salesOfficesCache.clear();
    _businessUnitsCache.clear();
    _axRegionalsCache.clear();
    _paymentModeCache.clear();
    _categoryCache.clear();
    _category1Cache.clear();
    _segmentCache.clear();
    _subSegmentCache.clear();
    _classCache.clear();
    _companyStatusCache.clear();
    _currencyCache.clear();
    _priceGroupCache.clear();
    _customerGroupsCache.clear();
    _provincesCache.clear();
    _citiesCache.clear();
    _districtsCache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> clearSpecificCache(String cacheKey) async {
    await CacheService.clearCache(cacheKey);

    switch (cacheKey) {
      case CacheService.salesOffices:
        _salesOfficesCache.clear();
        break;
      case CacheService.businessUnits:
        _businessUnitsCache.clear();
        break;

      default:
        break;
    }

    _cacheTimestamps.remove(cacheKey);
  }

  Future<List<SalesOffice>> fetchSalesOffices(String? so) async {
    const cacheKey = CacheService.salesOffices;

    if (_salesOfficesCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _salesOfficesCache[cacheKey]!;
    }

    final cachedData = await CacheService.getData(cacheKey);
    if (cachedData != null) {
      final salesOffices = (cachedData as List)
          .map((json) => SalesOffice.fromJson(json))
          .toList();
      _salesOfficesCache[cacheKey] = salesOffices;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return salesOffices;
    }

    final url = Uri.parse("${apiNOO}ViewSO?SO=${so ?? ''}");
    final response =
        await _client.get(url, headers: {'authorization': basicAuth});

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      final salesOffices =
          data.map((json) => SalesOffice.fromJson(json)).toList();

      await CacheService.saveData(cacheKey, data);
      _salesOfficesCache[cacheKey] = salesOffices;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return salesOffices;
    } else {
      throw Exception('Failed to load sales offices: ${response.statusCode}');
    }
  }

  Future<List<BusinessUnit>> fetchBusinessUnits(String? bu) async {
    const cacheKey = CacheService.businessUnits;

    if (_businessUnitsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _businessUnitsCache[cacheKey]!;
    }

    final cachedData = await CacheService.getData(cacheKey);
    if (cachedData != null) {
      final businessUnits = (cachedData as List)
          .map((json) => BusinessUnit.fromJson(json))
          .toList();
      _businessUnitsCache[cacheKey] = businessUnits;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return businessUnits;
    }

    try {
      final url = Uri.parse("${apiNOO}ViewBU?BU=${bu ?? ''}");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final businessUnits =
            data.map((json) => BusinessUnit.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _businessUnitsCache[cacheKey] = businessUnits;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return businessUnits;
      } else {
        throw Exception(
            'Failed to load business units: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AXRegional>> fetchAXRegionals() async {
    const cacheKey = CacheService.axRegionals;

    if (_axRegionalsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _axRegionalsCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final axRegionals = (cachedData as List)
            .map((json) => AXRegional.fromJson(json))
            .toList();
        _axRegionalsCache[cacheKey] = axRegionals;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return axRegionals;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}AX_Regional");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final axRegionals =
            data.map((json) => AXRegional.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _axRegionalsCache[cacheKey] = axRegionals;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return axRegionals;
      } else {
        throw Exception('Failed to load AX regionals: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CustomerPaymentMode>> fetchPaymentMode() async {
    const cacheKey = CacheService.paymentMode;

    if (_paymentModeCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _paymentModeCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final paymentModes = (cachedData as List)
            .map((json) => CustomerPaymentMode.fromJson(json))
            .toList();
        _paymentModeCache[cacheKey] = paymentModes;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return paymentModes;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}AX_CustPaymMode");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final paymentModes =
            data.map((json) => CustomerPaymentMode.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _paymentModeCache[cacheKey] = paymentModes;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return paymentModes;
      } else {
        throw Exception('Failed to load payment mode: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category1>> fetchCategory() async {
    const cacheKey = CacheService.category;

    if (_categoryCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _categoryCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final categories = (cachedData as List)
            .map((json) => Category1.fromJson(json))
            .toList();
        _categoryCache[cacheKey] = categories;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return categories;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}AX_Category1");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final categories =
            data.map((json) => Category1.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _categoryCache[cacheKey] = categories;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category2>> fetchCategory1() async {
    const cacheKey = CacheService.category1;

    if (_category1Cache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _category1Cache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final categories = (cachedData as List)
            .map((json) => Category2.fromJson(json))
            .toList();
        _category1Cache[cacheKey] = categories;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return categories;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}CustCategory");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final categories =
            data.map((json) => Category2.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _category1Cache[cacheKey] = categories;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return categories;
      } else {
        throw Exception('Failed to load category1: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Segment>> fetchSegment(String? bu) async {
    const cacheKey = CacheService.segment;

    if (_segmentCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _segmentCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final segments =
            (cachedData as List).map((json) => Segment.fromJson(json)).toList();
        _segmentCache[cacheKey] = segments;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return segments;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}CustSegment?bu=${bu ?? ''}");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final segments = data.map((json) => Segment.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _segmentCache[cacheKey] = segments;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return segments;
      } else {
        throw Exception('Failed to load segments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubSegment>> fetchSubSegment(String? selectedSegment) async {
    if (selectedSegment == null) {
      return [];
    }

    final cacheKey = "${CacheService.subSegment}_$selectedSegment";

    if (_subSegmentCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _subSegmentCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final subSegments = (cachedData as List)
            .map((json) => SubSegment.fromJson(json))
            .toList();
        _subSegmentCache[cacheKey] = subSegments;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return subSegments;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}CustSubSegment");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List rawData = jsonDecode(response.body);
        List filteredData = rawData
            .where((element) => element["SEGMENTID"] == selectedSegment)
            .toList();

        final subSegments =
            filteredData.map((json) => SubSegment.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, filteredData);
        _subSegmentCache[cacheKey] = subSegments;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return subSegments;
      } else {
        throw Exception('Failed to load sub segments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ClassModel>> fetchClass() async {
    const cacheKey = CacheService.classKey;

    if (_classCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _classCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final classes = (cachedData as List)
            .map((json) => ClassModel.fromJson(json))
            .toList();
        _classCache[cacheKey] = classes;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return classes;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}CustClass");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final classes = data.map((json) => ClassModel.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _classCache[cacheKey] = classes;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return classes;
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CompanyStatus>> fetchCompanyStatus() async {
    const cacheKey = CacheService.companyStatus;

    if (_companyStatusCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _companyStatusCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final statuses = (cachedData as List)
            .map((json) => CompanyStatus.fromJson(json))
            .toList();
        _companyStatusCache[cacheKey] = statuses;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return statuses;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}CustCompanyChain");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final statuses =
            data.map((json) => CompanyStatus.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _companyStatusCache[cacheKey] = statuses;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return statuses;
      } else {
        throw Exception(
            'Failed to load company statuses: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Currency>> fetchCurrency() async {
    const cacheKey = CacheService.currency;

    if (_currencyCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _currencyCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final currencies = (cachedData as List)
            .map((json) => Currency.fromJson(json))
            .toList();
        _currencyCache[cacheKey] = currencies;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return currencies;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}Currency");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final currencies = data.map((json) => Currency.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _currencyCache[cacheKey] = currencies;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return currencies;
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CustomerGroup>> fetchCustomerGroups() async {
    const cacheKey = CacheService.customerGroups;

    if (_customerGroupsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _customerGroupsCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final groups = (cachedData as List)
            .map((json) => CustomerGroup.fromJson(json))
            .toList();
        _customerGroupsCache[cacheKey] = groups;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return groups;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("${apiNOO}AX_CustSubGroup");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final groups =
            data.map((json) => CustomerGroup.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _customerGroupsCache[cacheKey] = groups;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return groups;
      } else {
        throw Exception(
            'Failed to load customer groups: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PriceGroup>> fetchPriceGroup(
      String? salesOfficeCode, String? bu) async {
    if (salesOfficeCode == null || bu == null) {
      return [];
    }

    final cacheKey = "${CacheService.priceGroup}_${salesOfficeCode}_$bu";

    if (_priceGroupCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _priceGroupCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final priceGroups = (cachedData as List)
            .map((json) => PriceGroup.fromJson(json))
            .toList();
        _priceGroupCache[cacheKey] = priceGroups;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return priceGroups;
      }
    } catch (e) {}

    try {
      final url =
          Uri.parse("${apiNOO}CustPriceGroup?so=$salesOfficeCode&bu=$bu");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final priceGroups =
            data.map((json) => PriceGroup.fromJson(json)).toList();

        await CacheService.saveData(cacheKey, data);
        _priceGroupCache[cacheKey] = priceGroups;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return priceGroups;
      } else {
        throw Exception('Failed to load price groups: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    const cacheKey = CacheService.provinces;

    if (_provincesCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _provincesCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final provinces = List<Map<String, dynamic>>.from(cachedData);
        _provincesCache[cacheKey] = provinces;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return provinces;
      }
    } catch (e) {}

    try {
      final url = Uri.parse("$apiNOO/AdvoticsMasterRegenciesAPI?prov=true");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final provinces = List<Map<String, dynamic>>.from(data);

        await CacheService.saveData(cacheKey, data);
        _provincesCache[cacheKey] = provinces;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return provinces;
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCities(
      String provinceId, String addressType) async {
    final cacheKey = "${CacheService.cities}_${provinceId}_$addressType";

    if (_citiesCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _citiesCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final cities = List<Map<String, dynamic>>.from(cachedData);
        _citiesCache[cacheKey] = cities;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return cities;
      }
    } catch (e) {}

    try {
      final url = Uri.parse(
          "$apiNOO/AdvoticsMasterRegenciesAPI?city=true&id=$provinceId");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final cities = List<Map<String, dynamic>>.from(data);

        await CacheService.saveData(cacheKey, data);
        _citiesCache[cacheKey] = cities;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return cities;
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDistricts(
      String cityId, String addressType) async {
    final cacheKey = "${CacheService.districts}_${cityId}_$addressType";

    if (_districtsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _districtsCache[cacheKey]!;
    }

    try {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        final districts = List<Map<String, dynamic>>.from(cachedData);
        _districtsCache[cacheKey] = districts;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return districts;
      }
    } catch (e) {}

    try {
      final url = Uri.parse(
          "$apiNOO/AdvoticsMasterRegenciesAPI?distric=true&id=$cityId");
      final response =
          await _client.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        final districts = List<Map<String, dynamic>>.from(data);

        await CacheService.saveData(cacheKey, data);
        _districtsCache[cacheKey] = districts;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return districts;
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> submitCustomerForm(Map<String, dynamic> data) async {
    final url = Uri.parse("${apiNOO}NOOCustTables");

    final headers = {
      'authorization': 'Basic ${base64Encode(utf8.encode('test:test456'))}',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    return await _client.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('${apiNOO}NOOCustTables/$id'),
        headers: {
          'authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadImage(
      File imageFile, String type, String username) async {
    final dateNow = DateFormat("ddMMyyyy_hhmmss").format(DateTime.now());
    final fileName = '${type}_${dateNow}_$username.jpg';

    final uri = Uri.parse("${apiNOO}Upload");
    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path,
          filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.body.replaceAll("\"", "");
    } else {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  Future<String> uploadSignature(
      Uint8List signatureImage, String type, String username) async {
    final dateNow = DateFormat("ddMMyyyy_hhmmss").format(DateTime.now());
    final fileName = '${type}_${dateNow}_$username.jpg';

    final uri = Uri.parse("${apiNOO}Upload");
    final request = http.MultipartRequest("POST", uri);

    request.files.add(http.MultipartFile.fromBytes('file', signatureImage,
        filename: fileName));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.body.replaceAll("\"", "");
    } else {
      throw Exception('Failed to upload signature: ${response.statusCode}');
    }
  }
}
