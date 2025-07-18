// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/noo/cached_data.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/models/customer_form.dart';
import 'package:noo_sms/models/draft_model.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class CustomerFormController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static CustomerFormController get to => Get.find();

  late TabController tabController;

  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  String? so;
  String? bu;

  final isEditMode = false.obs;
  final NOOModel? editData;
  final _picker = ImagePicker();
  final useCompanyAddressForDelivery = false.obs;
  final useCompanyAddressForDelivery2 = false.obs;
  final useCompanyAddressForTax = false.obs;
  final RxBool useKtpAddressForTax = false.obs;
  final RxBool isInitializing = true.obs;
  final RxString initializationStatus = ''.obs;
  final RxBool hasInitializationError = false.obs;
  bool isInitialized = false;

  String longitudeData = "";
  String latitudeData = "";
  String addressDetail = "";
  String streetName = "";
  String city = "";
  String countrys = "";
  String state = "";
  String zipCode = "";
  String salesmanId = "";
  String village = "";
  String subDistrict = "";

  final RxString ktpFromServer = ''.obs;
  final RxString npwpFromServer = ''.obs;
  final RxString siupFromServer = ''.obs;
  final RxString sppkpFromServer = ''.obs;
  final RxString businessPhotoFrontFromServer = ''.obs;
  final RxString businessPhotoInsideFromServer = ''.obs;
  final RxString competitorTopFromServer = ''.obs;
  final RxString signatureSalesFromServer = ''.obs;
  final RxString signatureCustomersFromServer = ''.obs;
  final SignatureController signatureSalesController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController signatureCustomerController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final RxMap<String, File?> _images = <String, File?>{}.obs;
  final RxMap<String, Uint8List?> _webImages = <String, Uint8List?>{}.obs;
  final RxMap<String, String> _serverFileNames = <String, String>{}.obs;
  final RxMap<String, String> _imageUrls = <String, String>{}.obs;
  final RxMap<String, bool> _processingStates = <String, bool>{}.obs;

  Map<String, RxString> get _serverVariableMap => {
        'KTP': ktpFromServer,
        'NPWP': npwpFromServer,
        'SIUP': siupFromServer,
        'SPPKP': sppkpFromServer,
        'BUSINESS_PHOTO_FRONT': businessPhotoFrontFromServer,
        'BUSINESS_PHOTO_INSIDE': businessPhotoInsideFromServer,
        'COMPETITOR_TOP': competitorTopFromServer,
        'SIGNATURE_SALES': signatureSalesFromServer,
        'SIGNATURE_CUSTOMERS': signatureCustomersFromServer,
      };

  String getServerFileName(String type) {
    final specificVariable = _serverVariableMap[type];
    if (specificVariable != null) {
      return specificVariable.value;
    }
    return _serverFileNames[type] ?? '';
  }

  File? getImage(String type) => _images[type];
  Uint8List? getWebImage(String type) => _webImages[type];
  String getImageUrl(String type) => _imageUrls[type] ?? '';
  bool isProcessing(String type) => _processingStates[type] ?? false;

  File? get imageKTP => getImage('KTP');
  set imageKTP(File? value) {
    _images['KTP'] = value;
    update();
  }

  File? get imageNPWP => getImage('NPWP');
  set imageNPWP(File? value) {
    _images['NPWP'] = value;
    update();
  }

  File? get imageSIUP => getImage('SIUP');
  set imageSIUP(File? value) {
    _images['SIUP'] = value;
    update();
  }

  File? get imageSPPKP => getImage('SPPKP');
  set imageSPPKP(File? value) {
    _images['SPPKP'] = value;
    update();
  }

  File? get imageBusinessPhotoFront => getImage('BUSINESS_PHOTO_FRONT');
  set imageBusinessPhotoFront(File? value) {
    _images['BUSINESS_PHOTO_FRONT'] = value;
    update();
  }

  File? get imageBusinessPhotoInside => getImage('BUSINESS_PHOTO_INSIDE');
  set imageBusinessPhotoInside(File? value) {
    _images['BUSINESS_PHOTO_INSIDE'] = value;
    update();
  }

  File? get imageCompetitorTop => getImage('COMPETITOR_TOP');
  set imageCompetitorTop(File? value) {
    _images['COMPETITOR_TOP'] = value;
    update();
  }

  File? get imageSignatureSales => getImage('SIGNATURE_SALES');
  set imageSignatureSales(File? value) {
    _images['SIGNATURE_SALES'] = value;
    update();
  }

  File? get imageSignatureCustomers => getImage('SIGNATURE_CUSTOMERS');
  set imageSignatureCustomers(File? value) {
    _images['SIGNATURE_CUSTOMERS'] = value;
    update();
  }

  Uint8List? get imageKTPWeb => getWebImage('KTP');
  set imageKTPWeb(Uint8List? value) {
    _webImages['KTP'] = value;
    update();
  }

  Uint8List? get imageNPWPWeb => getWebImage('NPWP');
  set imageNPWPWeb(Uint8List? value) {
    _webImages['NPWP'] = value;
    update();
  }

  Uint8List? get imageSIUPWeb => getWebImage('SIUP');
  set imageSIUPWeb(Uint8List? value) {
    _webImages['SIUP'] = value;
    update();
  }

  Uint8List? get imageSPPKPWeb => getWebImage('SPPKP');
  set imageSPPKPWeb(Uint8List? value) {
    _webImages['SPPKP'] = value;
    update();
  }

  Uint8List? get imageBusinessPhotoFrontWeb =>
      getWebImage('BUSINESS_PHOTO_FRONT');
  set imageBusinessPhotoFrontWeb(Uint8List? value) {
    _webImages['BUSINESS_PHOTO_FRONT'] = value;
    update();
  }

  Uint8List? get imageBusinessPhotoInsideWeb =>
      getWebImage('BUSINESS_PHOTO_INSIDE');
  set imageBusinessPhotoInsideWeb(Uint8List? value) {
    _webImages['BUSINESS_PHOTO_INSIDE'] = value;
    update();
  }

  Uint8List? get imageCompetitorTopWeb => getWebImage('COMPETITOR_TOP');
  set imageCompetitorTopWeb(Uint8List? value) {
    _webImages['COMPETITOR_TOP'] = value;
    update();
  }

  Uint8List? get imageSignatureSalesWeb => getWebImage('SIGNATURE_SALES');
  set imageSignatureSalesWeb(Uint8List? value) {
    _webImages['SIGNATURE_SALES'] = value;
    update();
  }

  Uint8List? get imageSignatureCustomersWeb =>
      getWebImage('SIGNATURE_CUSTOMERS');
  set imageSignatureCustomersWeb(Uint8List? value) {
    _webImages['SIGNATURE_CUSTOMERS'] = value;
    update();
  }

  String get ktpImageUrl => getImageUrl('KTP');
  set ktpImageUrl(String value) => setImageUrl('KTP', value);

  String get npwpImageUrl => getImageUrl('NPWP');
  set npwpImageUrl(String value) => setImageUrl('NPWP', value);

  String get siupImageUrl => getImageUrl('SIUP');
  set siupImageUrl(String value) => setImageUrl('SIUP', value);

  String get sppkpImageUrl => getImageUrl('SPPKP');
  set sppkpImageUrl(String value) => setImageUrl('SPPKP', value);

  String get businessPhotoFrontImageUrl => getImageUrl('BUSINESS_PHOTO_FRONT');
  set businessPhotoFrontImageUrl(String value) =>
      setImageUrl('BUSINESS_PHOTO_FRONT', value);

  String get businessPhotoInsideImageUrl =>
      getImageUrl('BUSINESS_PHOTO_INSIDE');
  set businessPhotoInsideImageUrl(String value) =>
      setImageUrl('BUSINESS_PHOTO_INSIDE', value);

  String get competitorTopImageUrl => getImageUrl('COMPETITOR_TOP');
  set competitorTopImageUrl(String value) =>
      setImageUrl('COMPETITOR_TOP', value);

  String get signatureSalesImageUrl => getImageUrl('SIGNATURE_SALES');
  set signatureSalesImageUrl(String value) =>
      setImageUrl('SIGNATURE_SALES', value);

  String get signatureCustomersImageUrl => getImageUrl('SIGNATURE_CUSTOMERS');
  set signatureCustomersImageUrl(String value) =>
      setImageUrl('SIGNATURE_CUSTOMERS', value);

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController ktpController = TextEditingController();
  final TextEditingController ktpAddressController = TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController faxController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController streetCompanyController = TextEditingController();
  final TextEditingController kelurahanController = TextEditingController();
  final TextEditingController kecamatanController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController taxNameController = TextEditingController();
  final TextEditingController taxStreetController = TextEditingController();
  final TextEditingController deliveryNameController = TextEditingController();
  final TextEditingController streetCompanyControllerDelivery =
      TextEditingController();
  final TextEditingController kelurahanControllerDelivery =
      TextEditingController();
  Rx<TextEditingController> kecamatanControllerDelivery =
      TextEditingController().obs;

  final TextEditingController cityControllerDelivery = TextEditingController();
  final TextEditingController provinceControllerDelivery =
      TextEditingController();
  final TextEditingController countryControllerDelivery =
      TextEditingController();
  final TextEditingController zipCodeControllerDelivery =
      TextEditingController();
  final TextEditingController deliveryNameController2 = TextEditingController();
  final TextEditingController streetCompanyControllerDelivery2 =
      TextEditingController();
  final TextEditingController kelurahanControllerDelivery2 =
      TextEditingController();
  Rx<TextEditingController> kecamatanControllerDelivery2 =
      TextEditingController().obs;

  final TextEditingController cityControllerDelivery2 = TextEditingController();
  final TextEditingController provinceControllerDelivery2 =
      TextEditingController();
  final TextEditingController countryControllerDelivery2 =
      TextEditingController();
  final TextEditingController zipCodeControllerDelivery2 =
      TextEditingController();
  TextEditingController longitudeControllerDelivery = TextEditingController();
  TextEditingController latitudeControllerDelivery = TextEditingController();

  RxList<SalesOffice> salesOffices = <SalesOffice>[].obs;
  RxList<BusinessUnit> businessUnits = <BusinessUnit>[].obs;
  RxList<AXRegional> axRegionals = <AXRegional>[].obs;
  List<CustomerPaymentMode> paymentMode = [];
  List<Category1> category = [];
  List<Category2> category1 = [];
  List<Segment> segment = [];
  List<SubSegment> subSegment = [];
  List<ClassModel> classList = [];
  List<CompanyStatus> companyStatus = [];
  List<Currency> currency = [];
  List<PriceGroup> priceGroup = [];
  final RxList<CustomerGroup> customerGroups = <CustomerGroup>[].obs;

  String? selectedCustomerGroup;
  String? selectedSalesOffice;
  String? selectedSalesOfficeCode;
  String? selectedBusinessUnit;
  String? selectedCategory;
  String? selectedCategory1;
  String? selectedAXRegional;
  String? selectedPaymentMode;
  String? selectedSegment;
  String? selectedSubSegment;
  String? selectedClass;
  String? selectedCompanyStatus;
  String? selectedCurrency;
  String? selectedPriceGroup;

  String? frontImageUrl;
  String? insideImageUrl;
  String? competitorImageUrl;

  String? cityApiValueMain;
  String? cityApiValueDelivery;
  String? cityApiValueDelivery2;

  String? cityDisplayValueMain;
  String? cityDisplayValueDelivery;
  String? cityDisplayValueDelivery2;

  String? selectedCityId;
  String? selectedCityIdDelivery;
  String? selectedCityIdDelivery2;

  String? districtValueMain;
  String? districtValueDelivery;
  String? districtValueDelivery2;

  RxList<Map<String, dynamic>> provinces = <Map<String, dynamic>>[].obs;
  final isProvincesLoading = false.obs;

  RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  final isCitiesLoading = false.obs;
  String? selectedProvinceId;

  RxList<Map<String, dynamic>> citiesDelivery = <Map<String, dynamic>>[].obs;
  final isCitiesDeliveryLoading = false.obs;
  String? selectedProvinceIdDelivery;

  RxList<Map<String, dynamic>> citiesDelivery2 = <Map<String, dynamic>>[].obs;
  final isCitiesDelivery2Loading = false.obs;
  String? selectedProvinceIdDelivery2;

  RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> districtsDelivery = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> districtsDelivery2 =
      <Map<String, dynamic>>[].obs;

  final isDistrictsLoading = false.obs;
  final isDistrictsDeliveryLoading = false.obs;
  final isDistrictsDelivery2Loading = false.obs;

  CustomerFormController({this.editData});

  @override
  void onInit() async {
    super.onInit();

    tabController = TabController(length: 4, vsync: this);
    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';

    await initializeData();
    companyNameController.addListener(_onCompanyNameChanged);
    ktpAddressController.addListener(_updateTaxAddress);
    customerNameController.addListener(_updateTaxName);
  }

  @override
  void dispose() {
    companyNameController.removeListener(_onCompanyNameChanged);
    ktpAddressController.removeListener(_updateTaxAddress);
    customerNameController.removeListener(_updateTaxName);
    super.dispose();
  }

  Future<void> clearCache() async {
    await CacheService.clearAllCache();
  }

  void _onCompanyNameChanged() {
    taxNameController.text = companyNameController.text;
    deliveryNameController.text = companyNameController.text;
    update();
  }

  void _updateTaxAddress() {
    if (useKtpAddressForTax.value) {
      taxStreetController.text = ktpAddressController.text;
    }
  }

  void _updateTaxName() {
    if (useKtpAddressForTax.value) {
      taxNameController.text = customerNameController.text;
    }
  }

  Future<void> initializeData() async {
    isInitializing.value = true;

    Map<String, String> loadFailures = {};
    bool partialSuccess = false;

    await clearCache();
    await _checkCredentialsChanged();
    await loadSharedPreferences();
    await loadLongLatFromSharedPrefs();

    try {
      final bool needsFullInitialization = salesOffices.isEmpty ||
          businessUnits.isEmpty ||
          customerGroups.isEmpty;

      await loadSharedPreferences();
      await loadLongLatFromSharedPrefs();

      if (needsFullInitialization) {
        try {
          await _loadSalesOfficesFromCache();
        } catch (e) {
          loadFailures['salesOffices'] = e.toString();
        }

        try {
          await _loadBusinessUnitsFromCache();
        } catch (e) {
          loadFailures['businessUnits'] = e.toString();
        }

        try {
          await _loadCustomerGroupsFromCache();
        } catch (e) {
          loadFailures['customerGroups'] = e.toString();
        }

        _setDefaultCriticalSelections();

        partialSuccess = salesOffices.isNotEmpty ||
            businessUnits.isNotEmpty ||
            customerGroups.isNotEmpty;

        if (partialSuccess) {
          _loadRemainingDataAsync();
        }
      } else {
        _setDefaultSelections();
        partialSuccess = true;
      }

      if (partialSuccess) {
        autofill();
      }

      if (loadFailures.isEmpty) {
        initializationStatus.value = 'Initialization complete';
        hasInitializationError.value = false;
      } else {
        if (partialSuccess) {
          initializationStatus.value =
              'Partial initialization - some data could not be loaded';
          hasInitializationError.value = true;
        } else {
          initializationStatus.value =
              'Initialization failed: ${loadFailures.values.join(', ')}';
          hasInitializationError.value = true;
        }
      }
    } catch (e) {
      hasInitializationError.value = true;
      initializationStatus.value = 'Initialization failed: ${e.toString()}';
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _checkCredentialsChanged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentSO = prefs.getString("SO");
    String? currentBU = prefs.getString("BU");

    if ((so != currentSO && currentSO != null) ||
        (bu != currentBU && currentBU != null)) {
      so = currentSO;
      bu = currentBU;
      isInitialized = false;

      await CacheService.clearCache(CacheService.salesOffices);
      await CacheService.clearCache(CacheService.businessUnits);
      await CacheService.clearCache(CacheService.customerGroups);

      salesOffices.clear();
      businessUnits.clear();
      customerGroups.clear();
    }
  }

  Future<void> _loadCustomerGroupsFromCache() async {
    try {
      if (customerGroups.isNotEmpty) return;

      final cachedData =
          await CacheService.getData(CacheService.customerGroups);

      if (cachedData != null) {
        customerGroups.value = (cachedData as List)
            .map((json) => CustomerGroup.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchCustomerGroups());
    } catch (e) {
      unawaited(fetchCustomerGroups());
    }
  }

  void _setDefaultCriticalSelections() {
    if (salesOffices.isNotEmpty && selectedSalesOffice == null) {
      selectedSalesOffice = salesOffices.first.name;
      selectedSalesOfficeCode = salesOffices.first.code;

      if (bu != null && bu!.isNotEmpty) {
        unawaited(fetchPriceGroup());
      }
    }

    if (businessUnits.isNotEmpty && selectedBusinessUnit == null) {
      selectedBusinessUnit = businessUnits.first.name;
    }

    if (customerGroups.isNotEmpty && selectedCustomerGroup == null) {
      selectedCustomerGroup = customerGroups.first.value;
    }

    update();
  }

  static Future<void> resetForNewLogin() async {
    await CacheService.clearCache(CacheService.salesOffices);
    await CacheService.clearCache(CacheService.businessUnits);
    await CacheService.clearCache(CacheService.customerGroups);
    await CacheService.clearCache(CacheService.axRegionals);

    if (Get.isRegistered<CustomerFormController>()) {
      final controller = Get.find<CustomerFormController>();
      controller.isInitialized = false;
      controller.salesOffices.clear();
      controller.businessUnits.clear();
      controller.customerGroups.clear();
    }
  }

  void _loadRemainingDataAsync() {
    List<Future> futures = [];

    futures.add(_loadAXRegionalsFromCache());
    futures.add(_loadPaymentModeFromCache());
    futures.add(_loadCategoryFromCache());
    futures.add(_loadCategory1FromCache());
    futures.add(_loadSegmentFromCache());
    futures.add(_loadClassFromCache());
    futures.add(_loadCompanyStatusFromCache());
    futures.add(_loadCurrencyFromCache());
    futures.add(fetchProvinces());

    for (var future in futures) {
      unawaited(future);
    }

    if (!Get.isRegistered<PreviewController>()) {
      Get.put(PreviewController());
    }

    if (editData != null) {
      unawaited(_prepareEditDataAsync());
    }
  }

  Future<void> _prepareEditDataAsync() async {
    selectedCategory = editData!.category;
    selectedCategory1 = editData!.category1;

    if (selectedSegment != null) {
      await _loadSubSegmentFromCache();
    }

    fillFormData(editData!);
  }

  Future<void> _loadSalesOfficesFromCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentSO = prefs.getString("SO");

      if (so != currentSO || !isInitialized) {
        so = currentSO;

        await CacheService.clearCache(CacheService.salesOffices);
        salesOffices.clear();

        await fetchSalesOffices();
        return;
      }

      final cachedData = await CacheService.getData(CacheService.salesOffices);
      if (cachedData != null) {
        salesOffices.value = (cachedData as List)
            .map((json) => SalesOffice.fromJson(json))
            .toList();

        return;
      }

      await fetchSalesOffices();
    } catch (e) {
      await fetchSalesOffices();
    }
  }

  Future<void> _loadBusinessUnitsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentBU = prefs.getString("BU");

    if (bu != currentBU || !isInitialized) {
      bu = currentBU;

      await CacheService.clearCache(CacheService.businessUnits);
      businessUnits.clear();

      await fetchBusinessUnits();
      return;
    }
  }

  Future<void> _loadAXRegionalsFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.axRegionals);

      if (cachedData != null) {
        axRegionals.value = (cachedData as List)
            .map((json) => AXRegional.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchAXRegionals());
    } catch (e) {
      unawaited(fetchAXRegionals());
    }
  }

  Future<void> _loadPaymentModeFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.paymentMode);

      if (cachedData != null) {
        paymentMode = (cachedData as List)
            .map((json) => CustomerPaymentMode.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchPaymentMode());
    } catch (e) {
      unawaited(fetchPaymentMode());
    }
  }

  Future<void> _loadCategoryFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.category);

      if (cachedData != null) {
        category = (cachedData as List)
            .map((json) => Category1.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchCategory());
    } catch (e) {
      unawaited(fetchCategory());
    }
  }

  Future<void> _loadCategory1FromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.category1);

      if (cachedData != null) {
        category1 = (cachedData as List)
            .map((json) => Category2.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchCategory1());
    } catch (e) {
      unawaited(fetchCategory1());
    }
  }

  Future<void> _loadSegmentFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.segment);

      if (cachedData != null) {
        segment =
            (cachedData as List).map((json) => Segment.fromJson(json)).toList();
        return;
      }

      unawaited(fetchSegment());
    } catch (e) {
      unawaited(fetchSegment());
    }
  }

  Future<void> _loadSubSegmentFromCache() async {
    if (selectedSegment == null) return;

    try {
      final cacheKey = "${CacheService.subSegment}_$selectedSegment";
      final cachedData = await CacheService.getData(cacheKey);

      if (cachedData != null) {
        subSegment = (cachedData as List)
            .map((json) => SubSegment.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchSubSegment());
    } catch (e) {
      unawaited(fetchSubSegment());
    }
  }

  Future<void> _loadClassFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.classKey);

      if (cachedData != null) {
        classList = (cachedData as List)
            .map((json) => ClassModel.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchClass());
    } catch (e) {
      unawaited(fetchClass());
    }
  }

  Future<void> _loadCompanyStatusFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.companyStatus);

      if (cachedData != null) {
        companyStatus = (cachedData as List)
            .map((json) => CompanyStatus.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchCompanyStatus());
    } catch (e) {
      unawaited(fetchCompanyStatus());
    }
  }

  Future<void> _loadCurrencyFromCache() async {
    try {
      final cachedData = await CacheService.getData(CacheService.currency);

      if (cachedData != null) {
        currency = (cachedData as List)
            .map((json) => Currency.fromJson(json))
            .toList();
        return;
      }

      unawaited(fetchCurrency());
    } catch (e) {
      unawaited(fetchCurrency());
    }
  }

  void _setDefaultSelections() {
    if (salesOffices.isNotEmpty && selectedSalesOffice == null) {
      selectedSalesOffice = salesOffices.first.name;
      selectedSalesOfficeCode = salesOffices.first.code;

      if (bu != null && bu!.isNotEmpty) {
        unawaited(fetchPriceGroup());
      }
    }

    if (businessUnits.isNotEmpty && selectedBusinessUnit == null) {
      selectedBusinessUnit = businessUnits.first.name;
    }

    if (customerGroups.isNotEmpty && selectedCustomerGroup == null) {
      selectedCustomerGroup = customerGroups.first.value;
    }

    if (currency.isNotEmpty && selectedCurrency == null) {
      selectedCurrency = currency.first.currencyCode;
    }

    if (paymentMode.isNotEmpty && selectedPaymentMode == null) {
      selectedPaymentMode = paymentMode.first.paymentMode;
    }

    if (segment.isNotEmpty && selectedSegment == null) {
      selectedSegment = segment.first.segmentId;

      unawaited(fetchSubSegment());
    }

    update();
  }

  void fillFormData(NOOModel data) async {
    customerNameController.text = data.custName;
    brandNameController.text = data.brandName;
    contactPersonController.text = data.contactPerson;
    ktpController.text = data.ktp;
    ktpAddressController.text = data.ktpAddress ?? '';
    npwpController.text = data.npwp;
    phoneController.text = data.phoneNo;
    faxController.text = data.faxNo;
    emailAddressController.text = data.emailAddress;
    websiteController.text = data.website;

    selectedSalesOffice = data.salesOffice;

    selectedCustomerGroup = data.customerGroup;
    selectedBusinessUnit = data.businessUnit;
    selectedAXRegional = data.regional;
    selectedSegment = data.segment;

    selectedCategory =
        category.firstWhereOrNull((cat) => cat.name == data.category)?.name;

    if (data.category1 != null) {
      selectedCategory1 = category1
          .firstWhereOrNull((cat) => cat.master == data.category1)
          ?.master;
    }

    await fetchSubSegment();
    selectedSubSegment = data.subSegment;

    selectedClass = data.classField;
    selectedCompanyStatus = data.companyStatus;
    selectedCurrency = data.currency;

    final selectedOffice = salesOffices
        .firstWhereOrNull((office) => office.name == data.salesOffice);
    if (selectedOffice != null) {
      selectedSalesOfficeCode = selectedOffice.code;

      await fetchPriceGroup();
    }
    selectedPriceGroup = data.priceGroup;

    selectedCustomerGroup = customerGroups
        .firstWhereOrNull((group) => group.value == data.customerGroup)
        ?.value;

    selectedPaymentMode = data.paymentMode;

    if (data.companyAddresses != null) {
      companyNameController.text = data.companyAddresses?.name ?? '';
      streetCompanyController.text = data.companyAddresses?.streetName ?? '';
      kelurahanController.text = data.companyAddresses?.kelurahan ?? '';
      kecamatanController.text = data.companyAddresses?.kecamatan ?? '';
      cityController.text = data.companyAddresses?.city ?? '';

      countryController.text = data.companyAddresses?.country ?? '';
      zipCodeController.text = data.companyAddresses?.zipCode.toString() ?? '';

      final provinceData = data.companyAddresses?.state ?? '';
      if (provinceData.isNotEmpty && provinces.isNotEmpty) {
        setProvinceFromText(provinceData, provinceController);
      } else {
        provinceController.text = provinceData;
      }
    }

    if (data.taxAddresses != null) {
      taxNameController.text = data.taxAddresses?.name ?? '';
      taxStreetController.text = data.taxAddresses?.streetName ?? '';
    }

    if (data.deliveryAddresses != null) {
      deliveryNameController.text = data.deliveryAddresses?.name ?? '';
      streetCompanyControllerDelivery.text =
          data.deliveryAddresses?.streetName ?? '';
      kelurahanControllerDelivery.text =
          data.deliveryAddresses?.kelurahan ?? '';
      kecamatanControllerDelivery.value.text =
          data.deliveryAddresses?.kecamatan ?? '';
      cityControllerDelivery.text = data.deliveryAddresses?.city ?? '';

      countryControllerDelivery.text = data.deliveryAddresses?.country ?? '';
      zipCodeControllerDelivery.text =
          data.deliveryAddresses?.zipCode.toString() ?? '';

      final provinceData = data.deliveryAddresses?.state ?? '';
      if (provinceData.isNotEmpty && provinces.isNotEmpty) {
        setProvinceFromText(provinceData, provinceControllerDelivery);
      } else {
        provinceControllerDelivery.text = provinceData;
      }
    }

    if (data.fotoKTP?.isNotEmpty == true) {
      ktpImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoKTP}";
      ktpFromServer.value = data.fotoKTP!;
    }

    if (data.fotoNPWP?.isNotEmpty == true) {
      npwpImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoNPWP}";
      npwpFromServer.value = data.fotoNPWP!;
    }

    if (data.fotoSIUP?.isNotEmpty == true) {
      siupImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoSIUP}";
      siupFromServer.value = data.fotoSIUP!;
    }

    if (data.fotoGedung3?.isNotEmpty == true) {
      sppkpImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoGedung3}";
      sppkpFromServer.value = data.fotoGedung3!;
    }

    if (data.fotoGedung1?.isNotEmpty == true) {
      frontImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoGedung1}";
      businessPhotoFrontFromServer.value = data.fotoGedung1!;
    }

    if (data.fotoGedung2?.isNotEmpty == true) {
      insideImageUrl = "${apiNOO}Files/GetFiles?fileName=${data.fotoGedung2}";
      businessPhotoInsideFromServer.value = data.fotoGedung2!;
    }

    if (data.fotoCompetitorTop?.isNotEmpty == true) {
      competitorImageUrl =
          "${apiNOO}Files/GetFiles?fileName=${data.fotoCompetitorTop}";
      competitorTopFromServer.value = data.fotoCompetitorTop!;
    }

    longitudeControllerDelivery.text = data.long ?? '';
    latitudeControllerDelivery.text = data.lat ?? '';

    update();
  }

  void clearForm() {
    customerNameController.clear();
    brandNameController.clear();
    contactPersonController.clear();
    ktpController.clear();
    ktpAddressController.clear();
    npwpController.clear();
    phoneController.clear();
    faxController.clear();
    emailAddressController.clear();
    websiteController.clear();
    companyNameController.clear();
    taxNameController.clear();
    deliveryNameController.clear();
    deliveryNameController2.clear();
    streetCompanyControllerDelivery2.clear();
    kelurahanController.clear();
    kelurahanControllerDelivery2.clear();
    kecamatanControllerDelivery.value.clear();
    kecamatanControllerDelivery2.value.clear();
    cityControllerDelivery2.clear();
    provinceControllerDelivery2.clear();
    countryControllerDelivery2.clear();
    zipCodeControllerDelivery2.clear();
    longitudeControllerDelivery.clear();
    latitudeControllerDelivery.clear();
    signatureCustomerController.clear();
    signatureSalesController.clear();
    selectedSalesOffice = null;
    selectedCustomerGroup = null;
    selectedBusinessUnit = null;
    selectedCategory = null;
    selectedCategory1 = null;
    selectedAXRegional = null;
    selectedSegment = null;
    selectedSubSegment = null;
    selectedClass = null;
    selectedCompanyStatus = null;
    selectedCurrency = null;
    selectedPriceGroup = null;
    selectedPaymentMode = null;
    useCompanyAddressForDelivery.value = false;
    useCompanyAddressForDelivery2.value = false;
    useCompanyAddressForTax.value = false;
    useKtpAddressForTax.value = false;

    update();
  }

  void loadFromDraft(DraftModel draft) {
    customerNameController.text = draft.custName;
    brandNameController.text = draft.brandName;
    selectedSalesOffice = draft.salesOffice;
    selectedSalesOffice = draft.customerGroup;
    selectedBusinessUnit = draft.businessUnit;
    selectedCategory = draft.category;
    selectedCategory1 = draft.category1;
    selectedAXRegional = draft.regional;
    selectedSegment = draft.segment;
    selectedSubSegment = draft.subSegment;
    selectedClass = draft.classField;
    selectedCompanyStatus = draft.companyStatus;
    selectedCurrency = draft.currency;
    selectedPriceGroup = draft.priceGroup;
    selectedPaymentMode = draft.paymMode;
    contactPersonController.text = draft.contactPerson ?? '';
    ktpController.text = draft.ktp ?? '';
    ktpAddressController.text = draft.ktpAddress ?? '';
    npwpController.text = draft.npwp ?? '';
    phoneController.text = draft.phoneNo ?? '';
    faxController.text = draft.faxNo ?? '';
    emailAddressController.text = draft.emailAddress ?? '';
    websiteController.text = draft.website ?? '';

    if (draft.companyAddresses != null) {
      companyNameController.text = draft.companyAddresses?['Name'] ?? '';
      streetCompanyController.text =
          draft.companyAddresses?['StreetName'] ?? '';
      kelurahanController.text = draft.companyAddresses?['Kelurahan'] ?? '';
      kecamatanController.text = draft.companyAddresses?['Kecamatan'] ?? '';
      cityController.text = draft.companyAddresses?['City'] ?? '';

      countryController.text = draft.companyAddresses?['Country'] ?? '';
      zipCodeController.text =
          draft.companyAddresses?['ZipCode']?.toString() ?? '';
      final provinceData = draft.companyAddresses?['State'] ?? '';
      if (provinceData.isNotEmpty && provinces.isNotEmpty) {
        setProvinceFromText(provinceData, provinceController);
      } else {
        provinceController.text = provinceData;
      }
    }

    if (draft.taxAddresses != null) {
      taxNameController.text = draft.taxAddresses?['Name'] ?? '';
      taxStreetController.text = draft.taxAddresses?['StreetName'] ?? '';
    }

    if (draft.deliveryAddresses?.isNotEmpty == true) {
      deliveryNameController.text = draft.deliveryAddresses?[0]['Name'] ?? '';
      streetCompanyControllerDelivery.text =
          draft.deliveryAddresses?[0]['StreetName'] ?? '';
      kelurahanControllerDelivery.text =
          draft.deliveryAddresses?[0]['Kelurahan'] ?? '';
      kecamatanControllerDelivery.value.text =
          draft.deliveryAddresses?[0]['Kecamatan'] ?? '';
      cityControllerDelivery.text = draft.deliveryAddresses?[0]['City'] ?? '';

      countryControllerDelivery.text =
          draft.deliveryAddresses?[0]['Country'] ?? '';
      zipCodeControllerDelivery.text =
          draft.deliveryAddresses?[0]['ZipCode']?.toString() ?? '';

      final provinceData = draft.deliveryAddresses?[0]['State'] ?? '';
      if (provinceData.isNotEmpty && provinces.isNotEmpty) {
        setProvinceFromText(provinceData, provinceControllerDelivery);
      } else {
        provinceControllerDelivery.text = provinceData;
      }

      if (draft.deliveryAddresses!.length > 1) {
        deliveryNameController2.text =
            draft.deliveryAddresses?[1]['Name'] ?? '';
        streetCompanyControllerDelivery2.text =
            draft.deliveryAddresses?[1]['StreetName'] ?? '';
        kelurahanControllerDelivery2.text =
            draft.deliveryAddresses?[1]['Kelurahan'] ?? '';
        kecamatanControllerDelivery2.value.text =
            draft.deliveryAddresses?[1]['Kecamatan'] ?? '';
        cityControllerDelivery2.text =
            draft.deliveryAddresses?[1]['City'] ?? '';
        provinceControllerDelivery2.text =
            draft.deliveryAddresses?[1]['State'] ?? '';
        countryControllerDelivery2.text =
            draft.deliveryAddresses?[1]['Country'] ?? '';
        zipCodeControllerDelivery2.text =
            draft.deliveryAddresses?[1]['ZipCode']?.toString() ?? '';
      }
    }

    longitudeControllerDelivery.text = draft.longitude ?? '';
    latitudeControllerDelivery.text = draft.latitude ?? '';

    if (draft.fotoKTP != null) imageKTP = File(draft.fotoKTP!);
    if (draft.fotoNPWP != null) imageNPWP = File(draft.fotoNPWP!);
    if (draft.fotoSIUP != null) imageSIUP = File(draft.fotoSIUP!);
    if (draft.fotoGedung3 != null) imageSPPKP = File(draft.fotoGedung3!);
    if (draft.fotoGedung1 != null) {
      imageBusinessPhotoFront = File(draft.fotoGedung1!);
    }
    if (draft.fotoGedung2 != null) {
      imageBusinessPhotoInside = File(draft.fotoGedung2!);
    }

    update();
  }

  bool validateRequiredDocuments() {
    List<String> missingDocuments = [];
    List<String> missingFields = [];

    if (imageKTP == null && ktpFromServer.value.isEmpty) {
      missingDocuments.add('KTP');
    }

    if (imageNPWP == null && npwpFromServer.value.isEmpty) {
      missingDocuments.add('NPWP');
    }

    if (imageSIUP == null && siupFromServer.value.isEmpty) {
      missingDocuments.add('NIB');
    }

    if (imageSPPKP == null && sppkpFromServer.value.isEmpty) {
      missingDocuments.add('SPPKP');
    }

    if (imageBusinessPhotoFront == null &&
        businessPhotoFrontFromServer.value.isEmpty) {
      missingDocuments.add('Front View');
    }

    if (imageBusinessPhotoInside == null &&
        businessPhotoInsideFromServer.value.isEmpty) {
      missingDocuments.add('Inside View');
    }

    final salesSignaturePoints = signatureSalesController.points;
    final customerSignaturePoints = signatureCustomerController.points;

    if (salesSignaturePoints.isEmpty &&
        signatureSalesFromServer.value.isEmpty) {
      missingDocuments.add('Sales Signature');
    }

    if (customerSignaturePoints.isEmpty &&
        signatureCustomersFromServer.value.isEmpty) {
      missingDocuments.add('Customer Signature');
    }

    if (customerNameController.text.isEmpty) {
      missingFields.add('Customer Name');
    }

    if (brandNameController.text.isEmpty) {
      missingFields.add('Brand Name');
    }

    if (selectedSalesOffice == null) {
      missingFields.add('Sales Office');
    }

    if (selectedCustomerGroup == null) {
      missingFields.add('Customer Group');
    }

    if (selectedBusinessUnit == null) {
      missingFields.add('Business Unit');
    }

    if (selectedCategory == null) {
      missingFields.add('Category 1');
    }

    if (selectedCategory1 == null) {
      missingFields.add('Category 2');
    }

    if (selectedAXRegional == null) {
      missingFields.add('AX Regional');
    }

    if (selectedSegment == null) {
      missingFields.add('Distribution Channel');
    }

    if (selectedSubSegment == null) {
      missingFields.add('Channel Segmentation');
    }

    if (selectedClass == null) {
      missingFields.add('Class');
    }

    if (selectedCompanyStatus == null) {
      missingFields.add('Company Status');
    }

    if (selectedCurrency == null) {
      missingFields.add('Currency');
    }

    if (selectedPriceGroup == null) {
      missingFields.add('Price Group');
    }

    if (selectedPaymentMode == null) {
      missingFields.add('Payment Method');
    }

    if (contactPersonController.text.isEmpty) {
      missingFields.add('Contact Person');
    }

    if (ktpController.text.isEmpty) {
      missingFields.add('KTP');
    }

    if (ktpAddressController.text.isEmpty) {
      missingFields.add('KTP Address');
    }

    if (phoneController.text.isEmpty) {
      missingFields.add('Phone');
    }

    if (companyNameController.text.isEmpty) {
      missingFields.add('Company Name');
    }

    if (streetCompanyController.text.isEmpty) {
      missingFields.add('Street Name (Company Address)');
    }

    if (kelurahanController.text.isEmpty) {
      missingFields.add('Kelurahan (Company Address)');
    }

    if (provinceController.text.isEmpty) {
      missingFields.add('Provinsi (Company Address)');
    }

    if (cityController.text.isEmpty) {
      missingFields.add('City (Company Address)');
    }

    if (kecamatanController.text.isEmpty) {
      missingFields.add('Kecamatan (Company Address)');
    }

    if (countryController.text.isEmpty) {
      missingFields.add('Country (Company Address)');
    }

    if (zipCodeController.text.isEmpty) {
      missingFields.add('ZIP Code (Company Address)');
    }

    if (npwpController.text.isEmpty) {
      missingFields.add('NPWP');
    }

    if (taxNameController.text.isEmpty) {
      missingFields.add('Tax Name');
    }

    if (taxStreetController.text.isEmpty) {
      missingFields.add('Tax Address');
    }

    if (deliveryNameController.text.isEmpty) {
      missingFields.add('Name (Delivery Address)');
    }

    if (streetCompanyControllerDelivery.text.isEmpty) {
      missingFields.add('Street Name (Delivery Address)');
    }

    if (kelurahanControllerDelivery.text.isEmpty) {
      missingFields.add('Kelurahan (Delivery Address)');
    }

    if (provinceControllerDelivery.text.isEmpty) {
      missingFields.add('Provinsi (Delivery Address)');
    }

    if (cityControllerDelivery.text.isEmpty) {
      missingFields.add('City (Delivery Address)');
    }

    if (kecamatanControllerDelivery.value.text.isEmpty) {
      missingFields.add('Kecamatan (Delivery Address)');
    }

    if (countryControllerDelivery.text.isEmpty) {
      missingFields.add('Country (Delivery Address)');
    }

    if (zipCodeControllerDelivery.text.isEmpty) {
      missingFields.add('ZIP Code (Delivery Address)');
    }

    if (missingDocuments.isNotEmpty || missingFields.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Required Items Missing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (missingDocuments.isNotEmpty) ...[
                  const Text('Please complete all required documents:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...missingDocuments.map((doc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Text(doc),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (missingFields.isNotEmpty) ...[
                  const Text('Please fill in all required fields:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...missingFields.map((field) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(field)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> fetchProvinces() async {
    if (!isProvincesLoading.value) {
      isProvincesLoading.value = true;

      try {
        final cachedData = await CacheService.getData(CacheService.provinces);

        if (cachedData != null) {
          provinces.value = List<Map<String, dynamic>>.from(cachedData);
          isProvincesLoading.value = false;
          return;
        }

        final url = Uri.parse("$apiNOO/AdvoticsMasterRegenciesAPI?prov=true");
        final response =
            await http.get(url, headers: {'authorization': basicAuth});

        if (response.statusCode == 200) {
          List data = jsonDecode(response.body);
          provinces.value = List<Map<String, dynamic>>.from(data);

          unawaited(CacheService.saveData(CacheService.provinces, data));
        } else {
          throw Exception('Failed to load provinces');
        }
      } finally {
        isProvincesLoading.value = false;
      }
    }
  }

  void setProvinceFromText(String text, TextEditingController controller,
      {bool fetchCitiesAfter = false,
      TextEditingController? cityController,
      String addressType = 'main'}) {
    if (text.isEmpty || provinces.isEmpty) return;

    final currentText = text.toUpperCase();

    final exactMatch = provinces.firstWhereOrNull(
        (province) => province["Text"].toString().toUpperCase() == currentText);

    if (exactMatch != null) {
      controller.text = exactMatch["Text"];
      if (fetchCitiesAfter) {
        final provinceId = exactMatch["Value"]?.toString();

        switch (addressType) {
          case 'main':
            selectedProvinceId = provinceId;
            break;
          case 'delivery':
            selectedProvinceIdDelivery = provinceId;
            break;
          case 'delivery2':
            selectedProvinceIdDelivery2 = provinceId;
            break;
        }

        fetchCities(provinceId!, addressType: addressType);
        if (cityController != null) cityController.clear();
      }
      return;
    }

    final partialMatch = provinces.firstWhereOrNull((province) =>
        province["Text"].toString().toUpperCase().contains(currentText) ||
        currentText.contains(province["Text"].toString().toUpperCase()));

    if (partialMatch != null) {
      controller.text = partialMatch["Text"];
      if (fetchCitiesAfter) {
        final provinceId = partialMatch["Value"]?.toString();

        switch (addressType) {
          case 'main':
            selectedProvinceId = provinceId;
            break;
          case 'delivery':
            selectedProvinceIdDelivery = provinceId;
            break;
          case 'delivery2':
            selectedProvinceIdDelivery2 = provinceId;
            break;
        }

        fetchCities(provinceId!, addressType: addressType);
        if (cityController != null) cityController.clear();
      }
    }
  }

  List<Map<String, String>> getProvincesList() {
    return provinces
        .map((province) => {'name': province["Text"].toString()})
        .toList();
  }

  Future<void> fetchCities(String provinceId,
      {String addressType = 'main'}) async {
    switch (addressType) {
      case 'main':
        isCitiesLoading.value = true;
        cities.clear();
        break;
      case 'delivery':
        isCitiesDeliveryLoading.value = true;
        citiesDelivery.clear();
        break;
      case 'delivery2':
        isCitiesDelivery2Loading.value = true;
        citiesDelivery2.clear();
        break;
    }

    String? currentCityText;
    switch (addressType) {
      case 'main':
        currentCityText = cityController.text;
        break;
      case 'delivery':
        currentCityText = cityControllerDelivery.text;
        break;
      case 'delivery2':
        currentCityText = cityControllerDelivery2.text;
        break;
    }

    try {
      final url = Uri.parse(
          "$apiNOO/AdvoticsMasterRegenciesAPI?city=true&id=$provinceId");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        switch (addressType) {
          case 'main':
            cities.value = List<Map<String, dynamic>>.from(data);
            break;
          case 'delivery':
            citiesDelivery.value = List<Map<String, dynamic>>.from(data);
            break;
          case 'delivery2':
            citiesDelivery2.value = List<Map<String, dynamic>>.from(data);
            break;
        }

        if (currentCityText != null && currentCityText.isNotEmpty) {
          TextEditingController cityController;
          switch (addressType) {
            case 'main':
              cityController = this.cityController;
              break;
            case 'delivery':
              cityController = cityControllerDelivery;
              break;
            case 'delivery2':
              cityController = cityControllerDelivery2;
              break;
            default:
              cityController = this.cityController;
          }

          setCityFromText(currentCityText, cityController,
              addressType: addressType);
        }
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch cities: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      switch (addressType) {
        case 'main':
          isCitiesLoading.value = false;
          break;
        case 'delivery':
          isCitiesDeliveryLoading.value = false;
          break;
        case 'delivery2':
          isCitiesDelivery2Loading.value = false;
          break;
      }
    }
  }

  void setCityValue(String addressType,
      {required String apiValue,
      String? displayValue,
      bool updateController = false,
      bool fetchDistrictsAfter = true}) {
    final String actualDisplayValue = displayValue ?? apiValue;
    TextEditingController? controller;

    final cityObj = _getCityObjectFromApiValue(apiValue, addressType);
    final cityId = cityObj?["Value"]?.toString();

    switch (addressType) {
      case 'main':
        cityApiValueMain = apiValue;
        cityDisplayValueMain = actualDisplayValue;
        controller = cityController;
        if (cityId != null) selectedCityId = cityId;
        break;
      case 'delivery':
        cityApiValueDelivery = apiValue;
        cityDisplayValueDelivery = actualDisplayValue;
        controller = cityControllerDelivery;
        if (cityId != null) selectedCityIdDelivery = cityId;
        break;
      case 'delivery2':
        cityApiValueDelivery2 = apiValue;
        cityDisplayValueDelivery2 = actualDisplayValue;
        controller = cityControllerDelivery2;
        if (cityId != null) selectedCityIdDelivery2 = cityId;
        break;
    }

    if (updateController && controller != null) {
      controller.text = actualDisplayValue;
    }

    if (fetchDistrictsAfter && cityId != null) {
      fetchDistricts(cityId, addressType: addressType);
    }

    update();
  }

  String? getCityApiValue(String addressType) {
    switch (addressType) {
      case 'main':
        return cityApiValueMain;
      case 'delivery':
        return cityApiValueDelivery;
      case 'delivery2':
        return cityApiValueDelivery2;
      default:
        return null;
    }
  }

  String? getCityDisplayValue(String addressType) {
    switch (addressType) {
      case 'main':
        return cityDisplayValueMain;
      case 'delivery':
        return cityDisplayValueDelivery;
      case 'delivery2':
        return cityDisplayValueDelivery2;
      default:
        return null;
    }
  }

  void setCityFromText(String text, TextEditingController controller,
      {String addressType = 'main'}) {
    RxList<Map<String, dynamic>> citiesList;

    switch (addressType) {
      case 'main':
        citiesList = cities;
        break;
      case 'delivery':
        citiesList = citiesDelivery;
        break;
      case 'delivery2':
        citiesList = citiesDelivery2;
        break;
      default:
        citiesList = cities;
    }

    if (text.isEmpty || citiesList.isEmpty) return;

    final normalizedInput = (text);

    for (var city in citiesList) {
      final apiValue = city["Text"].toString();
      final displayValue = (apiValue);

      if (displayValue.toUpperCase() == text.toUpperCase()) {
        controller.text = displayValue;
        setCityValue(addressType,
            apiValue: apiValue, displayValue: displayValue);
        return;
      }

      final normalizedCity = (apiValue);
      if (normalizedCity == normalizedInput) {
        controller.text = displayValue;
        setCityValue(addressType,
            apiValue: apiValue, displayValue: displayValue);
        return;
      }
    }

    for (var city in citiesList) {
      final apiValue = city["Text"].toString();
      final displayValue = (apiValue);
      final normalizedCity = (apiValue);
      final normalizedDisplay = (displayValue);

      if (normalizedCity.contains(normalizedInput) ||
          normalizedInput.contains(normalizedCity) ||
          normalizedDisplay.contains(normalizedInput) ||
          normalizedInput.contains(normalizedDisplay)) {
        controller.text = displayValue;
        setCityValue(addressType,
            apiValue: apiValue, displayValue: displayValue);
        return;
      }
    }

    controller.text = text;
  }

  Future<void> fetchDistricts(String cityId,
      {String addressType = 'main'}) async {
    final cacheKey = '${CacheService.districts}_${cityId}_$addressType';
    final isCacheValid = await CacheService.isCacheValid(cacheKey);

    if (isCacheValid) {
      final cachedData = await CacheService.getData(cacheKey);
      if (cachedData != null) {
        switch (addressType) {
          case 'main':
            districts.value = List<Map<String, dynamic>>.from(cachedData);
            break;
          case 'delivery':
            districtsDelivery.value =
                List<Map<String, dynamic>>.from(cachedData);
            break;
          case 'delivery2':
            districtsDelivery2.value =
                List<Map<String, dynamic>>.from(cachedData);
            break;
        }
        return;
      }
    }

    switch (addressType) {
      case 'main':
        isDistrictsLoading.value = true;
        districts.clear();
        break;
      case 'delivery':
        isDistrictsDeliveryLoading.value = true;
        districtsDelivery.clear();
        break;
      case 'delivery2':
        isDistrictsDelivery2Loading.value = true;
        districtsDelivery2.clear();
        break;
    }

    String? currentDistrictText;
    switch (addressType) {
      case 'main':
        currentDistrictText = kecamatanController.text;
        break;
      case 'delivery':
        currentDistrictText = kecamatanControllerDelivery.value.text;
        break;
      case 'delivery2':
        currentDistrictText = kecamatanControllerDelivery2.value.text;
        break;
    }

    try {
      final url = Uri.parse(
          "$apiNOO/AdvoticsMasterRegenciesAPI?distric=true&id=$cityId");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        await CacheService.saveData(cacheKey, data);

        switch (addressType) {
          case 'main':
            districts.value = List<Map<String, dynamic>>.from(data);
            break;
          case 'delivery':
            districtsDelivery.value = List<Map<String, dynamic>>.from(data);
            break;
          case 'delivery2':
            districtsDelivery2.value = List<Map<String, dynamic>>.from(data);
            break;
        }

        if (currentDistrictText != null && currentDistrictText.isNotEmpty) {
          TextEditingController districtController;
          switch (addressType) {
            case 'main':
              districtController = kecamatanController;
              break;
            case 'delivery':
              districtController = kecamatanControllerDelivery.value;
              break;
            case 'delivery2':
              districtController = kecamatanControllerDelivery2.value;
              break;
            default:
              districtController = kecamatanController;
          }

          setDistrictFromText(currentDistrictText, districtController,
              addressType: addressType);
        }
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch districts: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      switch (addressType) {
        case 'main':
          isDistrictsLoading.value = false;
          break;
        case 'delivery':
          isDistrictsDeliveryLoading.value = false;
          break;
        case 'delivery2':
          isDistrictsDelivery2Loading.value = false;
          break;
      }
    }
  }

  void setDistrictValue(String addressType, String value) {
    switch (addressType) {
      case 'main':
        districtValueMain = value;
        break;
      case 'delivery':
        districtValueDelivery = value;
        break;
      case 'delivery2':
        districtValueDelivery2 = value;
        break;
    }
  }

  String? getDistrictValue(String addressType) {
    switch (addressType) {
      case 'main':
        return districtValueMain;
      case 'delivery':
        return districtValueDelivery;
      case 'delivery2':
        return districtValueDelivery2;
      default:
        return null;
    }
  }

  void setDistrictFromText(String text, TextEditingController controller,
      {String addressType = 'main'}) {
    RxList<Map<String, dynamic>> districtsList;

    switch (addressType) {
      case 'main':
        districtsList = districts;
        break;
      case 'delivery':
        districtsList = districtsDelivery;
        break;
      case 'delivery2':
        districtsList = districtsDelivery2;
        break;
      default:
        districtsList = districts;
    }

    if (text.isEmpty || districtsList.isEmpty) return;

    final exactMatch = districtsList
        .firstWhereOrNull((district) => district["Text"].toString() == text);

    if (exactMatch != null) {
      controller.text = exactMatch["Text"].toString();
      setDistrictValue(addressType, exactMatch["Text"].toString());
      return;
    }

    final upperText = text.toUpperCase();
    final caseInsensitiveMatch = districtsList.firstWhereOrNull(
        (district) => district["Text"].toString().toUpperCase() == upperText);

    if (caseInsensitiveMatch != null) {
      controller.text = caseInsensitiveMatch["Text"].toString();
      setDistrictValue(addressType, caseInsensitiveMatch["Text"].toString());
      return;
    }

    for (var district in districtsList) {
      final districtName = district["Text"].toString().toUpperCase();
      if (districtName.contains(upperText) ||
          upperText.contains(districtName)) {
        controller.text = district["Text"].toString();
        setDistrictValue(addressType, district["Text"].toString());
        return;
      }
    }

    controller.text = text;
  }

  Map<String, dynamic>? _getCityObjectFromApiValue(
      String apiValue, String addressType) {
    RxList<Map<String, dynamic>> citiesList;

    switch (addressType) {
      case 'main':
        citiesList = cities;
        break;
      case 'delivery':
        citiesList = citiesDelivery;
        break;
      case 'delivery2':
        citiesList = citiesDelivery2;
        break;
      default:
        citiesList = cities;
    }

    return citiesList
        .firstWhereOrNull((city) => city["Text"].toString() == apiValue);
  }

  void copyCompanyAddressToDelivery() {
    deliveryNameController.text = companyNameController.text;
    streetCompanyControllerDelivery.text = streetCompanyController.text;
    countryControllerDelivery.text = countryController.text;
    zipCodeControllerDelivery.text = zipCodeController.text;
    kelurahanControllerDelivery.text = kelurahanController.text;

    provinceControllerDelivery.text = provinceController.text;

    if (provinceController.text.isNotEmpty) {
      setProvinceFromText(provinceController.text, provinceControllerDelivery,
          fetchCitiesAfter: true,
          cityController: cityControllerDelivery,
          addressType: 'delivery');
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (cityController.text.isNotEmpty) {
        cityControllerDelivery.text = cityController.text;
        setCityFromText(cityController.text, cityControllerDelivery,
            addressType: 'delivery');

        Future.delayed(const Duration(milliseconds: 300), () {
          if (kecamatanController.text.isNotEmpty) {
            kecamatanControllerDelivery.value.text = kecamatanController.text;
            setDistrictFromText(
                kecamatanController.text, kecamatanControllerDelivery.value,
                addressType: 'delivery');
          }
        });
      }
    });

    update(['deliveryAddress']);
  }

  void copyCompanyAddressToDelivery2() {
    deliveryNameController2.text = companyNameController.text;
    streetCompanyControllerDelivery2.text = streetCompanyController.text;
    countryControllerDelivery2.text = countryController.text;
    zipCodeControllerDelivery2.text = zipCodeController.text;
    kelurahanControllerDelivery2.text = kelurahanController.text;

    provinceControllerDelivery2.text = provinceController.text;

    if (provinceController.text.isNotEmpty) {
      setProvinceFromText(provinceController.text, provinceControllerDelivery2,
          fetchCitiesAfter: true,
          cityController: cityControllerDelivery2,
          addressType: 'delivery2');
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (cityController.text.isNotEmpty) {
        cityControllerDelivery2.text = cityController.text;
        setCityFromText(cityController.text, cityControllerDelivery2,
            addressType: 'delivery2');

        Future.delayed(const Duration(milliseconds: 300), () {
          if (kecamatanController.text.isNotEmpty) {
            kecamatanControllerDelivery2.value.text = kecamatanController.text;
            setDistrictFromText(
                kecamatanController.text, kecamatanControllerDelivery2.value,
                addressType: 'delivery2');
          }
        });
      }
    });

    update(['deliveryAddress2']);
  }

  void copyCompanyAddressToTax() {
    taxNameController.text = companyNameController.text;
    taxStreetController.text = streetCompanyController.text;
    update(['taxAddress']);
  }

  void setupAddressListeners() {
    companyNameController.addListener(_updateDeliveryAddressIfChecked);
    streetCompanyController.addListener(_updateDeliveryAddressIfChecked);
    provinceController.addListener(_updateDeliveryAddressIfChecked);
    cityController.addListener(_updateDeliveryAddressIfChecked);
    kecamatanController.addListener(_updateDeliveryAddressIfChecked);
    kelurahanController.addListener(_updateDeliveryAddressIfChecked);
    zipCodeController.addListener(_updateDeliveryAddressIfChecked);
    countryController.addListener(_updateDeliveryAddressIfChecked);

    companyNameController.addListener(_updateTaxNameFromCompany);
    streetCompanyController.addListener(_updateTaxAddressFromCompany);
  }

  void _updateDeliveryAddressIfChecked() {
    if (useCompanyAddressForDelivery.value) {
      copyCompanyAddressToDelivery();
    }

    if (useCompanyAddressForDelivery2.value) {
      copyCompanyAddressToDelivery2();
    }
  }

  void _updateTaxNameFromCompany() {
    if (useCompanyAddressForTax.value) {
      taxNameController.text = companyNameController.text;
    }
  }

  void _updateTaxAddressFromCompany() {
    if (useCompanyAddressForTax.value) {
      taxStreetController.text = streetCompanyController.text;
    }
  }

  void disposeAddressListeners() {
    companyNameController.removeListener(_updateDeliveryAddressIfChecked);
    streetCompanyController.removeListener(_updateDeliveryAddressIfChecked);
    provinceController.removeListener(_updateDeliveryAddressIfChecked);
    cityController.removeListener(_updateDeliveryAddressIfChecked);
    kecamatanController.removeListener(_updateDeliveryAddressIfChecked);
    kelurahanController.removeListener(_updateDeliveryAddressIfChecked);
    zipCodeController.removeListener(_updateDeliveryAddressIfChecked);
    countryController.removeListener(_updateDeliveryAddressIfChecked);

    companyNameController.removeListener(_updateTaxNameFromCompany);
    streetCompanyController.removeListener(_updateTaxAddressFromCompany);
  }

  Future<Map<String, dynamic>> prepareSubmitData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt("id");

    return {
      "CustName": customerNameController.text.trim(),
      "BrandName": brandNameController.text.trim(),
      "SalesOffice": selectedSalesOffice,
      "BusinessUnit": selectedBusinessUnit,
      "Category": selectedCategory,
      "Category1": selectedCategory1,
      "Regional": selectedAXRegional,
      "Segment": selectedSegment,
      "SubSegment": selectedSubSegment,
      "Class": selectedClass,
      "CompanyStatus": selectedCompanyStatus,
      "Currency": selectedCurrency,
      "PriceGroup": selectedPriceGroup,
      "PaymMode": selectedPaymentMode,
      "ContactPerson": contactPersonController.text.trim(),
      "KTP": ktpController.text.trim(),
      "KTPAddress": ktpAddressController.text.trim(),
      "NPWP": npwpController.text.trim(),
      "PhoneNo": phoneController.text.trim(),
      "FaxNo": faxController.text.trim(),
      "EmailAddress": emailAddressController.text.trim(),
      "Website": websiteController.text.trim(),
      "FotoNPWP": npwpFromServer.value,
      "FotoKTP": ktpFromServer.value,
      "FotoSIUP": siupFromServer.value,
      "CustSignature": signatureCustomersFromServer.value,
      "SalesSignature": signatureSalesFromServer.value,
      "Long": longitudeControllerDelivery.text,
      "Lat": latitudeControllerDelivery.text,
      "CustSubGroup": selectedCustomerGroup,
      "FotoGedung1": businessPhotoFrontFromServer.value,
      "FotoGedung2": businessPhotoInsideFromServer.value,
      "FotoGedung3": sppkpFromServer.value,
      if (competitorTopFromServer.value.isNotEmpty)
        "FotoCompetitorTop": competitorTopFromServer.value,
      "CreatedBy": userId.toString(),
      "CompanyAddresses": [
        {
          "Name": companyNameController.text,
          "StreetName": streetCompanyController.text,
          "Kelurahan": kelurahanController.text,
          "Kecamatan": districtValueMain ?? kecamatanController.text,
          "City": cityApiValueMain ?? cityController.text,
          "Country": countryController.text,
          "State": provinceController.text,
          "ZipCode": zipCodeController.text.isEmpty
              ? 0
              : int.tryParse(zipCodeController.text) ?? 0
        }
      ],
      "TaxAddresses": [
        {
          "Name": taxNameController.text,
          "StreetName": taxStreetController.text,
        }
      ],
      "DeliveryAddresses": [
        {
          "Name": deliveryNameController.text,
          "StreetName": streetCompanyControllerDelivery.text,
          "Kelurahan": kelurahanControllerDelivery.text,
          "Kecamatan":
              districtValueDelivery ?? kecamatanControllerDelivery.value.text,
          "City": cityApiValueDelivery ?? cityControllerDelivery.text,
          "Country": countryControllerDelivery.text,
          "State": provinceControllerDelivery.text,
          "ZipCode": zipCodeControllerDelivery.text.isEmpty
              ? 0
              : int.tryParse(zipCodeController.text) ?? 0
        },
        {
          "Name": deliveryNameController2.text,
          "StreetName": streetCompanyControllerDelivery2.text,
          "Kelurahan": kelurahanControllerDelivery2.text,
          "Kecamatan": kecamatanControllerDelivery2.value.text,
          "City": cityControllerDelivery2.text,
          "Country": countryControllerDelivery2.text,
          "State": provinceControllerDelivery2.text,
          "ZipCode": zipCodeControllerDelivery2.text.isEmpty
              ? 0
              : int.tryParse(zipCodeController.text) ?? 0
        }
      ]
    };
  }

  Future<void> handleSubmit() async {
    try {
      if (!validateRequiredDocuments()) {
        return;
      }

      Get.dialog(
        const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Submitting form...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final requestBody = await prepareSubmitData();
      final response = await _sendRequest(requestBody);
      const encoder = JsonEncoder.withIndent('  ');
      final prettyBody = encoder.convert(requestBody);

      final directory = Directory.systemTemp;
      final file = File('${directory.path}/debug_request_body.json');
      await file.writeAsString(prettyBody);

      if (!await _uploadSignatures()) {
        Get.back();
        return;
      }

      Get.back();

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Customer data submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        _disposeAllResources();

        Get.offAllNamed('/noo', arguments: {'initialIndex': 1});
      } else {
        throw Exception('Failed to submit customer: ${response.body}');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Submit failed. Please Try Again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> refreshAllData() async {
    try {
      isInitializing.value = true;
      initializationStatus.value = 'Refreshing all data...';

      await CacheService.clearAllCache();

      salesOffices.clear();
      businessUnits.clear();
      axRegionals.clear();
      paymentMode.clear();
      category.clear();
      category1.clear();
      segment.clear();
      subSegment.clear();
      classList.clear();
      companyStatus.clear();
      currency.clear();
      customerGroups.clear();
      provinces.clear();

      await initializeData();

      Get.snackbar(
        'Success',
        'All data refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isInitializing.value = false;
    }
  }

  void _disposeAllResources() {
    customerNameController.clear();
    brandNameController.clear();
    contactPersonController.clear();
    ktpController.clear();
    ktpAddressController.clear();
    npwpController.clear();
    phoneController.clear();
    faxController.clear();
    emailAddressController.clear();
    websiteController.clear();
    companyNameController.clear();
    streetCompanyController.clear();
    kelurahanController.clear();
    kecamatanController.clear();
    cityController.clear();
    provinceController.clear();
    countryController.clear();
    zipCodeController.clear();
    taxNameController.clear();
    taxStreetController.clear();
    deliveryNameController.clear();
    streetCompanyControllerDelivery.clear();
    kelurahanControllerDelivery.clear();
    kecamatanControllerDelivery.value.clear();
    cityControllerDelivery.clear();
    provinceControllerDelivery.clear();
    countryControllerDelivery.clear();
    zipCodeControllerDelivery.clear();
    deliveryNameController2.clear();
    streetCompanyControllerDelivery2.clear();
    kelurahanControllerDelivery2.clear();
    kecamatanControllerDelivery2.value.clear();
    cityControllerDelivery2.clear();
    provinceControllerDelivery2.clear();
    countryControllerDelivery2.clear();
    zipCodeControllerDelivery2.clear();
    longitudeControllerDelivery.clear();
    latitudeControllerDelivery.clear();

    selectedSalesOffice = null;
    selectedSalesOfficeCode = null;
    selectedBusinessUnit = null;
    selectedCategory = null;
    selectedCategory1 = null;
    selectedAXRegional = null;
    selectedPaymentMode = null;
    selectedSegment = null;
    selectedSubSegment = null;
    selectedClass = null;
    selectedCompanyStatus = null;
    selectedCurrency = null;
    selectedPriceGroup = null;

    selectedProvinceId = null;
    selectedProvinceIdDelivery = null;
    selectedProvinceIdDelivery2 = null;
    selectedCityId = null;
    selectedCityIdDelivery = null;
    selectedCityIdDelivery2 = null;

    cityApiValueMain = null;
    cityApiValueDelivery = null;
    cityApiValueDelivery2 = null;
    cityDisplayValueMain = null;
    cityDisplayValueDelivery = null;
    cityDisplayValueDelivery2 = null;
    districtValueMain = null;
    districtValueDelivery = null;
    districtValueDelivery2 = null;

    imageKTP = null;
    imageKTPWeb = null;
    imageNPWP = null;
    imageSIUP = null;
    imageSPPKP = null;
    imageBusinessPhotoFront = null;
    imageBusinessPhotoInside = null;
    imageCompetitorTop = null;

    ktpFromServer.value = '';
    npwpFromServer.value = '';
    siupFromServer.value = '';
    sppkpFromServer.value = '';
    businessPhotoFrontFromServer.value = '';
    businessPhotoInsideFromServer.value = '';
    competitorTopFromServer.value = '';
    signatureSalesFromServer.value = '';
    signatureCustomersFromServer.value = '';

    frontImageUrl = null;
    insideImageUrl = null;
    competitorImageUrl = null;

    signatureSalesController.clear();
    signatureCustomerController.clear();

    useKtpAddressForTax.value = false;

    cities.clear();
    citiesDelivery.clear();
    citiesDelivery2.clear();
    districts.clear();
    districtsDelivery.clear();
    districtsDelivery2.clear();

    isEditMode.value = false;

    update();
  }

  Future<bool> _uploadSignatures() async {
    final signatureSalesImage = await signatureSalesController.toPngBytes();
    final signatureCustomerImage =
        await signatureCustomerController.toPngBytes();

    if (signatureSalesImage == null || signatureCustomerImage == null) {
      Get.snackbar('Error', 'Please provide both signatures');
      return false;
    }

    await _handleSignature(
      'SIGNATURESALES',
      signatureSalesImage,
      signatureSalesFromServer,
    );

    await _handleSignature(
      'SIGNATURECUSTOMER',
      signatureCustomerImage,
      signatureCustomersFromServer,
    );

    return true;
  }

  Future<http.Response> _sendRequest(Map<String, dynamic> requestBody) async {
    final url = Uri.parse("${apiNOO}NOOCustTables");

    final headers = {
      'authorization': 'Basic ${base64Encode(utf8.encode('test:test456'))}',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    so = prefs.getString('SO');
    bu = prefs.getString('BU');

    update();
  }

  Future<void> loadLongLatFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    salesmanId = (prefs.getString("Username") ?? "");

    streetName = (prefs.getString("getStreetName") ?? "");
    village = (prefs.getString("getKelurahan") ?? "");
    subDistrict = (prefs.getString("getKecamatan") ?? "");
    city = (prefs.getString("getCity") ?? "");
    state = (prefs.getString("getProvince") ?? "");
    countrys = (prefs.getString("getCountry") ?? "");
    zipCode = (prefs.getString("getZipCode") ?? "");
    longitudeData = (prefs.getString("getLongitude") ?? "");
    latitudeData = (prefs.getString("getLatitude") ?? "");
    addressDetail = (prefs.getString("getAddressDetail") ?? "");
  }

  void autofill() {
    streetCompanyController.text = streetName;
    kelurahanController.text = village;
    countryController.text = countrys;
    zipCodeController.text = zipCode;
    taxStreetController.text = addressDetail;

    streetCompanyControllerDelivery.text = streetName;
    kelurahanControllerDelivery.text = village;
    countryControllerDelivery.text = countrys;
    zipCodeControllerDelivery.text = zipCode;

    if (state.isNotEmpty) {
      setProvinceFromText(state, provinceController,
          fetchCitiesAfter: true,
          cityController: cityController,
          addressType: 'main');

      if (city.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setCityFromText(city, cityController, addressType: 'main');

          if (subDistrict.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setDistrictFromText(subDistrict, kecamatanController,
                  addressType: 'main');
            });
          }
        });
      }
    } else {
      if (provinces.isNotEmpty) {
        final defaultProvince = provinces.firstWhereOrNull(
            (province) => province["Text"].toString() == "DKI JAKARTA");

        if (defaultProvince != null) {
          selectedProvinceId = defaultProvince["Value"]?.toString();
          fetchCities(selectedProvinceId!, addressType: 'main');
        }
      }
    }

    if (state.isNotEmpty) {
      setProvinceFromText(state, provinceControllerDelivery,
          fetchCitiesAfter: true,
          cityController: cityControllerDelivery,
          addressType: 'delivery');

      if (city.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setCityFromText(city, cityControllerDelivery,
              addressType: 'delivery');

          if (subDistrict.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setDistrictFromText(
                  subDistrict, kecamatanControllerDelivery.value,
                  addressType: 'delivery');
            });
          }
        });
      }
    } else {
      if (provinces.isNotEmpty) {
        final defaultProvince = provinces.firstWhereOrNull(
            (province) => province["Text"].toString() == "DKI JAKARTA");

        if (defaultProvince != null) {
          selectedProvinceIdDelivery = defaultProvince["Value"]?.toString();
          fetchCities(selectedProvinceIdDelivery!, addressType: 'delivery');
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (cityApiValueMain == null && cityController.text.isNotEmpty) {
        String cityText = cityController.text;
        final cityObj = cities
            .firstWhereOrNull((city) => (city["Text"].toString()) == cityText);
        if (cityObj != null) {
          cityApiValueMain = cityObj["Text"].toString();
          selectedCityId = cityObj["Value"]?.toString();
        } else {
          cityApiValueMain = cityText;
        }
      }

      if (cityApiValueDelivery == null &&
          cityControllerDelivery.text.isNotEmpty) {
        String cityText = cityControllerDelivery.text;
        final cityObj = citiesDelivery
            .firstWhereOrNull((city) => (city["Text"].toString()) == cityText);
        if (cityObj != null) {
          cityApiValueDelivery = cityObj["Text"].toString();
          selectedCityIdDelivery = cityObj["Value"]?.toString();
        } else {
          cityApiValueDelivery = cityText;
        }
      }

      if (districtValueMain == null && kecamatanController.text.isNotEmpty) {
        districtValueMain = kecamatanController.text;
      }

      if (districtValueDelivery == null &&
          kecamatanControllerDelivery.value.text.isNotEmpty) {
        districtValueDelivery = kecamatanControllerDelivery.value.text;
      }

      update();
    });
  }

  Future<void> fetchCustomerGroups() async {
    try {
      if (customerGroups.isNotEmpty) {
        return;
      }

      final cachedData =
          await CacheService.getData(CacheService.customerGroups);

      if (cachedData != null) {
        customerGroups.value = (cachedData as List)
            .map((json) => CustomerGroup.fromJson(json))
            .toList();

        if (customerGroups.isNotEmpty && selectedCustomerGroup == null) {
          selectedCustomerGroup = customerGroups.first.value;
          update();
        }
        return;
      }

      final url = Uri.parse("${apiNOO}AX_CustSubGroup");

      final response =
          await http.get(url, headers: {'authorization': basicAuth});
      debugPrint(url.toString());
      debugPrint(response.statusCode.toString());
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        customerGroups.value =
            data.map((json) => CustomerGroup.fromJson(json)).toList();

        await CacheService.saveData(CacheService.customerGroups, data);

        if (customerGroups.isNotEmpty && selectedCustomerGroup == null) {
          selectedCustomerGroup = customerGroups.first.value;
        }
        update();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  Future<void> fetchSalesOffices() async {
    try {
      final url = Uri.parse("${apiNOO}ViewSO?SO=$so");

      final response = await http
          .get(url, headers: {'authorization': basicAuth}).timeout(
              const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Sales offices request timed out');
      });

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response from server');
        }

        List data = jsonDecode(responseBody);
        if (data.isEmpty) {}

        salesOffices.value =
            data.map((json) => SalesOffice.fromJson(json)).toList();

        if (salesOffices.isNotEmpty) {
          await CacheService.saveData(CacheService.salesOffices, data);
        }

        update();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error: ${response.statusCode}');
      } else {
        throw Exception(
            'Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is SocketException) {
      } else if (e is TimeoutException) {
      } else if (e is FormatException) {
        debugPrint(
            'Invalid response format fetching sales offices: ${e.message}');
      } else {}

      rethrow;
    }
  }

  Future<void> fetchBusinessUnits() async {
    try {
      final url = Uri.parse("${apiNOO}ViewBU?BU=$bu");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        businessUnits.value =
            data.map((json) => BusinessUnit.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.businessUnits, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchAXRegionals() async {
    try {
      final url = Uri.parse("${apiNOO}AX_Regional");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        axRegionals.value =
            data.map((json) => AXRegional.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.axRegionals, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchPaymentMode() async {
    try {
      final url = Uri.parse("${apiNOO}AX_CustPaymMode");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        paymentMode =
            data.map((json) => CustomerPaymentMode.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.paymentMode, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchCategory() async {
    try {
      final url = Uri.parse("${apiNOO}AX_Category1");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        category = data.map((json) => Category1.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.category, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchCategory1() async {
    try {
      final url = Uri.parse("${apiNOO}CustCategory");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        category1 = data.map((json) => Category2.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.category1, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchSegment() async {
    try {
      final url = Uri.parse("${apiNOO}CustSegment?bu=$bu");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        segment = data.map((json) => Segment.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.segment, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchSubSegment() async {
    selectedSubSegment = null;
    update();

    try {
      if (selectedSegment == null) return;

      final cacheKey = "${CacheService.subSegment}_$selectedSegment";

      final cachedData = await CacheService.getData(cacheKey);

      if (cachedData != null) {
        subSegment = (cachedData as List)
            .map((json) => SubSegment.fromJson(json))
            .toList();

        if (selectedSubSegment != null &&
            !subSegment
                .any((item) => item.subSegmentId == selectedSubSegment)) {
          selectedSubSegment = null;
        }
        update();
        return;
      }

      final url = Uri.parse("${apiNOO}CustSubSegment");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List rawData = jsonDecode(response.body);
        List filteredData = rawData
            .where((element) => element["SEGMENTID"] == selectedSegment)
            .toList();

        subSegment =
            filteredData.map((json) => SubSegment.fromJson(json)).toList();

        if (selectedSubSegment != null &&
            !subSegment
                .any((item) => item.subSegmentId == selectedSubSegment)) {
          selectedSubSegment = null;
        }

        unawaited(CacheService.saveData(cacheKey, filteredData));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchClass() async {
    try {
      final url = Uri.parse("${apiNOO}CustClass");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        classList = data.map((json) => ClassModel.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.classKey, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchCompanyStatus() async {
    try {
      final url = Uri.parse("${apiNOO}CustCompanyChain");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        companyStatus =
            data.map((json) => CompanyStatus.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.companyStatus, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchCurrency() async {
    try {
      final url = Uri.parse("${apiNOO}Currency");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        currency = data.map((json) => Currency.fromJson(json)).toList();

        unawaited(CacheService.saveData(CacheService.currency, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> fetchPriceGroup() async {
    if (selectedSalesOfficeCode == null && selectedSalesOffice != null) {
      final selectedOffice = salesOffices
          .firstWhereOrNull((office) => office.name == selectedSalesOffice);
      if (selectedOffice != null) {
        selectedSalesOfficeCode = selectedOffice.code;
      }
    }

    if (selectedSalesOfficeCode == null) {
      return;
    }

    try {
      final cacheKey =
          "${CacheService.priceGroup}_${selectedSalesOfficeCode}_$bu";

      final cachedData = await CacheService.getData(cacheKey);

      if (cachedData != null) {
        priceGroup = (cachedData as List)
            .map((json) => PriceGroup.fromJson(json))
            .toList();
        update();
        return;
      }

      final url = Uri.parse(
          "${apiNOO}CustPriceGroup?so=$selectedSalesOfficeCode&bu=$bu");
      final response =
          await http.get(url, headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        priceGroup = data.map((json) => PriceGroup.fromJson(json)).toList();

        unawaited(CacheService.saveData(cacheKey, data));
        update();
      }
    } catch (e) {}
  }

  Future<void> onSalesOfficeSelected(String? value) async {
    selectedSalesOffice = value;

    if (value != null) {
      final selectedOffice =
          salesOffices.firstWhereOrNull((office) => office.name == value);

      if (selectedOffice != null) {
        selectedSalesOfficeCode = selectedOffice.code;

        await fetchPriceGroup();

        if (editData != null && selectedPriceGroup == null) {
          selectedPriceGroup = editData!.priceGroup;
        }
      }

      if (editData != null) {
        selectedBusinessUnit = businessUnits
            .firstWhereOrNull((bu) => bu.name == editData!.businessUnit)
            ?.name;
      }

      update();
    }
  }

  Future<bool> updateCustomer() async {
    try {
      final updatedData = {
        "id": editData!.id,
        "CustName": customerNameController.text,
        "BrandName": brandNameController.text,
        "SalesOffice": selectedSalesOffice,
        "BusinessUnit": selectedBusinessUnit,
        "Category": selectedCategory,
        "Category1": selectedCategory1,
        "Regional": selectedAXRegional,
        "Segment": selectedSegment,
        "SubSegment": selectedSubSegment,
        "Class": selectedClass,
        "CompanyStatus": selectedCompanyStatus,
        "Currency": selectedCurrency,
        "PriceGroup": selectedPriceGroup,
        "PaymMode": selectedPaymentMode,
        "ContactPerson": contactPersonController.text,
        "KTP": ktpController.text,
        "KTPAddress": ktpAddressController.text,
        "NPWP": npwpController.text,
        "PhoneNo": phoneController.text,
        "FaxNo": faxController.text,
        "EmailAddress": emailAddressController.text,
        "Website": websiteController.text,
        "Long": longitudeControllerDelivery.text,
        "Lat": latitudeControllerDelivery.text,
        "CompanyAddresses": {
          "id": editData!.companyAddresses?.id,
          "Name": companyNameController.text,
          "StreetName": streetCompanyController.text,
          "Kelurahan": kelurahanController.text,
          "Kecamatan": kecamatanController.text,
          "City": cityController.text,
          "State": provinceController.text,
          "Country": countryController.text,
          "ZipCode": int.tryParse(zipCodeController.text) ?? 0
        },
        "TaxAddresses": {
          "id": editData!.taxAddresses?.id,
          "Name": taxNameController.text,
          "StreetName": taxStreetController.text
        },
        "DeliveryAddresses": {
          "id": editData!.deliveryAddresses?.id,
          "Name": deliveryNameController.text,
          "StreetName": streetCompanyControllerDelivery.text,
          "Kelurahan": kelurahanControllerDelivery.text,
          "Kecamatan": kecamatanControllerDelivery.value.text,
          "City": cityControllerDelivery.text,
          "State": provinceControllerDelivery.text,
          "Country": countryControllerDelivery.text,
          "ZipCode": int.tryParse(zipCodeControllerDelivery.text) ?? 0
        }
      };

      final response = await http.put(
        Uri.parse('${apiNOO}NOOCustTables/${editData!.id}'),
        headers: {
          'authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Customer updated successfully');
        return true;
      } else {
        throw Exception('Failed to update customer');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update customer: $e');
      return false;
    }
  }

  Future<void> getImageFromCamera(String type) async {
    if (isProcessing(type)) return;

    if (kIsWeb) {
      await _handleWebImageSafe(type, ImageSource.camera);
    } else {
      await _handleMobileImageSafe(type, ImageSource.camera);
    }
  }

  Future<void> getImageFromGallery(String type) async {
    if (isProcessing(type)) return;

    if (kIsWeb) {
      await _handleWebImageSafe(type, ImageSource.gallery);
    } else {
      await _handleMobileImageSafe(type, ImageSource.gallery);
    }
  }

  Future<void> getImageKTPFromCamera() => getImageFromCamera('KTP');
  Future<void> getImageKTPFromGallery() => getImageFromGallery('KTP');
  Future<void> getImageNPWPFromCamera() => getImageFromCamera('NPWP');
  Future<void> getImageNPWPFromGallery() => getImageFromGallery('NPWP');
  Future<void> getImageSIUPFromCamera() => getImageFromCamera('SIUP');
  Future<void> getImageSIUPFromGallery() => getImageFromGallery('SIUP');
  Future<void> getImageSPPKPFromCamera() => getImageFromCamera('SPPKP');
  Future<void> getImageSPPKPFromGallery() => getImageFromGallery('SPPKP');
  Future<void> getImageBusinessPhotoFrontFromCamera() =>
      getImageFromCamera('BUSINESS_PHOTO_FRONT');
  Future<void> getImageBusinessPhotoFrontFromGallery() =>
      getImageFromGallery('BUSINESS_PHOTO_FRONT');
  Future<void> getImageBusinessPhotoInsideFromCamera() =>
      getImageFromCamera('BUSINESS_PHOTO_INSIDE');
  Future<void> getImageBusinessPhotoInsideFromGallery() =>
      getImageFromGallery('BUSINESS_PHOTO_INSIDE');
  Future<void> getImageCompetitorTopFromCamera() =>
      getImageFromCamera('COMPETITOR_TOP');
  Future<void> getImageCompetitorTopFromGallery() =>
      getImageFromGallery('COMPETITOR_TOP');

  Future<void> _handleSignature(
      String type, Uint8List imageFile, RxString imageFromServerState) async {
    final username = await _getUsername();
    if (username == null) return;

    final newFile =
        "${type}_${DateFormat("ddMMyyyy_hhmmss").format(DateTime.now())}_$username.jpg";
    final uri = Uri.parse("${apiNOO}Upload");

    final request = http.MultipartRequest("POST", uri)
      ..files.add(
          http.MultipartFile.fromBytes('file', imageFile, filename: newFile));

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      imageFromServerState.value = response.body.replaceAll("\"", "");
    } else {
      throw Exception('Failed to upload signature: ${response.statusCode}');
    }
  }

  Future<void> _handleMobileImageSafe(String type, ImageSource source) async {
    _setProcessingState(type, true);

    try {
      File? selectedFile;

      if (source == ImageSource.camera) {
        selectedFile = await _takePhotoSafely();
      } else {
        selectedFile = await _pickFromGallerySafely();
      }

      if (selectedFile == null) {
        _setProcessingState(type, false);
        return;
      }

      await _processAndUploadImage(selectedFile, type);
    } catch (e) {
      debugPrint('Error in _handleMobileImageSafe for $type: $e');
      _showErrorSnackbar('Failed to process $type image: ${e.toString()}');
      _resetImageState(type);
    } finally {
      _setProcessingState(type, false);
    }
  }

  /// STATE MANAGEMENT - Updates both generic and specific variables
  void _setProcessingState(String type, bool isProcessing) {
    _processingStates[type] = isProcessing;
    update();
  }

  void _resetImageState(String type) {
    // Clear generic storage
    _images[type] = null;
    _webImages[type] = null;
    _imageUrls[type] = '';

    // Clear specific reactive variable if it exists
    final specificVariable = _serverVariableMap[type];
    if (specificVariable != null) {
      specificVariable.value = '';
    } else {
      _serverFileNames[type] = '';
    }

    update();
  }

  /// PROCESS AND UPLOAD IMAGE - Updates both systems
  Future<void> _processAndUploadImage(File imageFile, String type) async {
    try {
      final username = await _getUsername();
      if (username == null) return;

      final dateNow = DateFormat("ddMMyyyy_hhmmss").format(DateTime.now());
      final fileName = '${type}_${dateNow}_${username}_.jpg';

      final directory = await _getImageDirectory();
      final filePath = Platform.isIOS
          ? path.join((await getApplicationDocumentsDirectory()).path, fileName)
          : path.join(directory, fileName);

      final newFile = await imageFile.copy(filePath);

      // Update image in generic storage
      _images[type] = newFile;
      update();

      // Upload to server
      await _uploadImageToServer(newFile, fileName, type);
    } catch (e) {
      throw Exception('Failed to process $type image: $e');
    }
  }

  /// UPLOAD TO SERVER - Updates both specific and generic variables
  Future<void> _uploadImageToServer(
      File imageFile, String fileName, String type) async {
    try {
      final uri = Uri.parse("${apiNOO}Upload");
      final request = http.MultipartRequest("POST", uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path,
            filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final serverFileName = response.body.replaceAll("\"", "");

        // Update specific reactive variable if it exists
        final specificVariable = _serverVariableMap[type];
        if (specificVariable != null) {
          specificVariable.value = serverFileName;
        } else {
          // Fallback to generic storage for unknown types
          _serverFileNames[type] = serverFileName;
        }

        update();
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Server upload failed for $type: $e');
    }
  }

  /// WEB IMAGE HANDLING
  Future<void> _handleWebImageSafe(String type, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        _webImages[type] = imageBytes;
        update();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to process $type web image: ${e.toString()}');
    }
  }

  /// UTILITY METHODS

  void clearImage(String type) {
    _resetImageState(type);
  }

  void clearAllImages() {
    // Clear generic storage
    _images.clear();
    _webImages.clear();
    _serverFileNames.clear();
    _imageUrls.clear();
    _processingStates.clear();

    // Clear all specific variables
    ktpFromServer.value = '';
    npwpFromServer.value = '';
    siupFromServer.value = '';
    sppkpFromServer.value = '';
    businessPhotoFrontFromServer.value = '';
    businessPhotoInsideFromServer.value = '';
    competitorTopFromServer.value = '';
    signatureSalesFromServer.value = '';
    signatureCustomersFromServer.value = '';

    update();
  }

  bool get isAnyProcessing =>
      _processingStates.values.any((processing) => processing);

  List<String> get processingTypes => _processingStates.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  void setImageUrl(String type, String url) {
    _imageUrls[type] = url;
    update();
  }

  /// SAFE CAMERA ACCESS (same as before)
  Future<File?> _takePhotoSafely() async {
    try {
      final cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          _showPermissionDialog('Camera', 'camera');
          return null;
        }
      }

      if (cameraStatus.isPermanentlyDenied) {
        _showPermissionSettingsDialog('Camera');
        return null;
      }

      if (Platform.isIOS) {
        final isAvailable = await _isCameraAvailable();
        if (!isAvailable) {
          _showErrorSnackbar('Camera not available on this device');
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 20,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
    } on PlatformException catch (e) {
      debugPrint('Camera Platform Exception: ${e.message}');
      _handleCameraError(e);
    } catch (e) {
      debugPrint('Camera Error: $e');
      _showErrorSnackbar('Failed to take photo');
    }

    return null;
  }

  Future<File?> _pickFromGallerySafely() async {
    try {
      final photoStatus = await Permission.photos.status;

      if (photoStatus.isDenied) {
        final result = await Permission.photos.request();
        if (result.isDenied) {
          _showPermissionDialog('Photo Library', 'photos');
          return null;
        }
      }

      if (photoStatus.isPermanentlyDenied) {
        _showPermissionSettingsDialog('Photo Library');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 20,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
    } on PlatformException catch (e) {
      debugPrint('Gallery Platform Exception: ${e.message}');
      _handleGalleryError(e);
    } catch (e) {
      debugPrint('Gallery Error: $e');
      _showErrorSnackbar('Failed to select photo');
    }

    return null;
  }

  /// ERROR HANDLING METHODS (same as before)
  Future<bool> _isCameraAvailable() async {
    try {
      return Platform.isIOS || Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  void _handleCameraError(PlatformException e) {
    String message;
    switch (e.code) {
      case 'camera_access_denied':
        message =
            'Camera access denied. Please enable camera permission in settings.';
        break;
      case 'camera_access_denied_without_prompt':
        message =
            'Camera access denied. Please go to Settings and enable camera permission.';
        break;
      case 'camera_access_restricted':
        message = 'Camera access is restricted on this device.';
        break;
      default:
        message = 'Camera error: ${e.message ?? 'Unknown error'}';
    }
    _showErrorSnackbar(message);
  }

  void _handleGalleryError(PlatformException e) {
    String message;
    switch (e.code) {
      case 'photo_access_denied':
        message =
            'Photo library access denied. Please enable permission in settings.';
        break;
      case 'photo_access_denied_without_prompt':
        message =
            'Photo library access denied. Please go to Settings and enable permission.';
        break;
      default:
        message = 'Gallery error: ${e.message ?? 'Unknown error'}';
    }
    _showErrorSnackbar(message);
  }

  void _showPermissionDialog(String permission, String permissionType) {
    Get.dialog(
      AlertDialog(
        title: Text('$permission Permission Required'),
        content:
            Text('This app needs $permission permission to function properly.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (permissionType == 'camera') {
                Permission.camera.request();
              } else {
                Permission.photos.request();
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog(String permission) {
    Get.dialog(
      AlertDialog(
        title: Text('$permission Permission Denied'),
        content: Text(
            '$permission permission is permanently denied. Please enable it in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
    } else {}

    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
    } else if (storageStatus.isDenied) {
    } else if (storageStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  Future<String> _getImageDirectory() async {
    try {
      Directory directory;
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        return '${directory.path}/Pictures/';
      } else if (Platform.isAndroid) {
        final appDirectory = await getExternalStorageDirectory();
        directory = Directory('${appDirectory!.path}/Pictures/');
      } else {
        directory = await getTemporaryDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return directory.path;
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }
}
