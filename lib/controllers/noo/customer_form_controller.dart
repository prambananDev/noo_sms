import 'dart:convert';
import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/models/customer_form.dart';
import 'package:noo_sms/models/draft_model.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerFormController extends GetxController {
  static CustomerFormController get to => Get.find();

  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  String? so;
  String? bu;
  String? codeSO;
  final isEditMode = false.obs;
  final StatusModel? editData;
  final _picker = ImagePicker();
  final _deviceInfo = DeviceInfoPlugin();

  String longitudeData = "";
  String latitudeData = "";
  String addressDetail = "";
  String streetName = "";
  String city = "";
  String countrys = "";
  String state = "";
  String zipCode = "";
  String salesmanId = "";

  final Rx<Uint8List?> _imageKTPWeb = Rx<Uint8List?>(null);
  final Rx<File?> _imageKTP = Rx<File?>(null);
  final Rx<File?> _imageNPWP = Rx<File?>(null);
  final Rx<File?> _imageSIUP = Rx<File?>(null);
  final Rx<File?> _imageSPPKP = Rx<File?>(null);
  final Rx<File?> _imageBusinessPhotoFront = Rx<File?>(null);
  final Rx<File?> _imageBusinessPhotoInside = Rx<File?>(null);
  final Rx<File?> _imageCompetitorTop = Rx<File?>(null);

  final RxString ktpFromServer = ''.obs;
  final RxString npwpFromServer = ''.obs;
  final RxString siupFromServer = ''.obs;
  final RxString sppkpFromServer = ''.obs;
  final RxString businessPhotoFrontFromServer = ''.obs;
  final RxString businessPhotoInsideFromServer = ''.obs;
  final RxString competitorTopFromServer = ''.obs;
  final RxString signatureSalesFromServer = ''.obs;

  // Getters for images
  File? get imageKTP => _imageKTP.value;
  File? get imageNPWP => _imageNPWP.value;
  File? get imageSIUP => _imageSIUP.value;
  File? get imageSPPKP => _imageSPPKP.value;
  File? get imageBusinessPhotoFront => _imageBusinessPhotoFront.value;
  File? get imageBusinessPhotoInside => _imageBusinessPhotoInside.value;
  File? get imageCompetitorTop => _imageCompetitorTop.value;
  Uint8List? get imageKTPWeb => _imageKTPWeb.value;

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
  final TextEditingController kecamatanControllerDelivery =
      TextEditingController();
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
  final TextEditingController kecamatanControllerDelivery2 =
      TextEditingController();
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
  List<Category1> category1 = [];
  List<Category2> category2 = [];
  List<Segment> segment = [];
  List<SubSegment> subSegment = [];
  List<ClassModel> classList = [];
  List<CompanyStatus> companyStatus = [];
  List<Currency> currency = [];
  List<PriceGroup> priceGroup = [];

  String? selectedSalesOffice;
  String? selectedBusinessUnit;
  String? selectedCategory;
  String? selectedCategory2;
  String? selectedAXRegional;
  String? selectedPaymentMode;
  String? selectedSegment;
  String? selectedSubSegment;
  String? selectedClass;
  String? selectedCompanyStatus;
  String? selectedCurrency;
  String? selectedPriceGroup;

  CustomerFormController({this.editData});

  @override
  void onInit() {
    super.onInit();
    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';
    if (editData != null) {
      isEditMode.value = true;
      _fillFormData(editData!);
    }
    initializeData();

    loadLongLatFromSharedPrefs();
  }

  Future<void> initializeData() async {
    await loadSharedPreferences();
    await Future.wait([
      fetchSalesOffices(),
      fetchBusinessUnits(),
      fetchAXRegionals(),
      fetchPaymentMode(),
      fetchCategory1(),
      fetchCategory2(),
      fetchSegment(),
      fetchSubSegment(),
      fetchClass(),
      fetchCompanyStatus(),
      fetchCurrency(),
    ]);

    if (!Get.isRegistered<PreviewController>()) {
      Get.put(PreviewController());
    }

    longitudeControllerDelivery.text = longitudeData;
    latitudeControllerDelivery.text = latitudeData;
    update();
  }

  void _fillFormData(StatusModel data) async {
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

    await initializeData();

    if (salesOffices.isNotEmpty) {
      selectedSalesOffice = salesOffices
          .firstWhereOrNull((so) => so.name == data.salesOffice)
          ?.name;
    }
    if (businessUnits.isNotEmpty) {
      selectedBusinessUnit = businessUnits
          .firstWhereOrNull((bu) => bu.name == data.businessUnit)
          ?.name;
    }
    if (category1.isNotEmpty) {
      selectedCategory =
          category1.firstWhereOrNull((cat) => cat.name == data.category)?.name;
    }
    if (category2.isNotEmpty) {
      selectedCategory2 = category2
          .firstWhereOrNull((cat) => cat.master == data.category1)
          ?.master;
    }
    if (axRegionals.isNotEmpty) {
      selectedAXRegional = axRegionals
          .firstWhereOrNull((reg) => reg.regional == data.regional)
          ?.regional;
    }
    if (segment.isNotEmpty) {
      selectedSegment = segment
          .firstWhereOrNull((seg) => seg.segmentId == data.segment)
          ?.segmentId;
    }
    if (subSegment.isNotEmpty) {
      selectedSubSegment = subSegment
          .firstWhereOrNull((sub) => sub.subSegmentId == data.subSegment)
          ?.subSegmentId;
    }
    if (classList.isNotEmpty) {
      selectedClass = classList
          .firstWhereOrNull((cls) => cls.className == data.classField)
          ?.className;
    }
    if (companyStatus.isNotEmpty) {
      selectedCompanyStatus = companyStatus
          .firstWhereOrNull((cs) => cs.chainId == data.companyStatus)
          ?.chainId;
    }
    if (currency.isNotEmpty) {
      selectedCurrency = currency
          .firstWhereOrNull((cur) => cur.currencyCode == data.currency)
          ?.currencyCode;
    }
    if (priceGroup.isNotEmpty) {
      selectedPriceGroup = priceGroup
          .firstWhereOrNull((pg) => pg.groupId == data.priceGroup)
          ?.groupId;
    }
    if (paymentMode.isNotEmpty) {
      selectedPaymentMode = paymentMode
          .firstWhereOrNull((pm) => pm.paymentMode == data.paymentMode)
          ?.paymentMode;
    }

    if (data.companyAddresses != null) {
      companyNameController.text = data.companyAddresses?.name ?? '';
      streetCompanyController.text = data.companyAddresses?.streetName ?? '';
      kelurahanController.text = data.companyAddresses?.kelurahan ?? '';
      kecamatanController.text = data.companyAddresses?.kecamatan ?? '';
      cityController.text = data.companyAddresses?.city ?? '';
      provinceController.text = data.companyAddresses?.state ?? '';
      countryController.text = data.companyAddresses?.country ?? '';
      zipCodeController.text = data.companyAddresses?.zipCode.toString() ?? '';
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
      kecamatanControllerDelivery.text =
          data.deliveryAddresses?.kecamatan ?? '';
      cityControllerDelivery.text = data.deliveryAddresses?.city ?? '';
      provinceControllerDelivery.text = data.deliveryAddresses?.state ?? '';
      countryControllerDelivery.text = data.deliveryAddresses?.country ?? '';
      zipCodeControllerDelivery.text =
          data.deliveryAddresses?.zipCode.toString() ?? '';
    }

    // longitudeControllerDelivery.text = longitudeData;
    // latitudeControllerDelivery.text = latitudeData;

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
    kecamatanControllerDelivery.clear();
    cityControllerDelivery.clear();
    provinceControllerDelivery.clear();
    countryControllerDelivery.clear();
    zipCodeControllerDelivery.clear();
    deliveryNameController2.clear();
    streetCompanyControllerDelivery2.clear();
    kelurahanControllerDelivery2.clear();
    kecamatanControllerDelivery2.clear();
    cityControllerDelivery2.clear();
    provinceControllerDelivery2.clear();
    countryControllerDelivery2.clear();
    zipCodeControllerDelivery2.clear();
    longitudeControllerDelivery.clear();
    latitudeControllerDelivery.clear();
    selectedSalesOffice = null;
    selectedBusinessUnit = null;
    selectedCategory = null;
    selectedCategory2 = null;
    selectedAXRegional = null;
    selectedSegment = null;
    selectedSubSegment = null;
    selectedClass = null;
    selectedCompanyStatus = null;
    selectedCurrency = null;
    selectedPriceGroup = null;
    selectedPaymentMode = null;
    _imageKTP.value = null;
    _imageKTPWeb.value = null;
    _imageNPWP.value = null;
    _imageSIUP.value = null;
    _imageSPPKP.value = null;
    _imageBusinessPhotoFront.value = null;
    _imageBusinessPhotoInside.value = null;
    _imageCompetitorTop.value = null;

    update();
  }

  void loadFromDraft(DraftModel draft) {
    customerNameController.text = draft.custName;
    brandNameController.text = draft.brandName;
    selectedSalesOffice = draft.salesOffice;
    selectedBusinessUnit = draft.businessUnit;
    selectedCategory = draft.category;
    selectedCategory2 = draft.category1;
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
      provinceController.text = draft.companyAddresses?['State'] ?? '';
      countryController.text = draft.companyAddresses?['Country'] ?? '';
      zipCodeController.text =
          draft.companyAddresses?['ZipCode']?.toString() ?? '';
    }

    // Load tax address
    if (draft.taxAddresses != null) {
      taxNameController.text = draft.taxAddresses?['Name'] ?? '';
      taxStreetController.text = draft.taxAddresses?['StreetName'] ?? '';
    }

    // Load delivery addresses
    if (draft.deliveryAddresses?.isNotEmpty == true) {
      // First delivery address
      deliveryNameController.text = draft.deliveryAddresses?[0]['Name'] ?? '';
      streetCompanyControllerDelivery.text =
          draft.deliveryAddresses?[0]['StreetName'] ?? '';
      kelurahanControllerDelivery.text =
          draft.deliveryAddresses?[0]['Kelurahan'] ?? '';
      kecamatanControllerDelivery.text =
          draft.deliveryAddresses?[0]['Kecamatan'] ?? '';
      cityControllerDelivery.text = draft.deliveryAddresses?[0]['City'] ?? '';
      provinceControllerDelivery.text =
          draft.deliveryAddresses?[0]['State'] ?? '';
      countryControllerDelivery.text =
          draft.deliveryAddresses?[0]['Country'] ?? '';
      zipCodeControllerDelivery.text =
          draft.deliveryAddresses?[0]['ZipCode']?.toString() ?? '';

      if (draft.deliveryAddresses!.length > 1) {
        deliveryNameController2.text =
            draft.deliveryAddresses?[1]['Name'] ?? '';
        streetCompanyControllerDelivery2.text =
            draft.deliveryAddresses?[1]['StreetName'] ?? '';
        kelurahanControllerDelivery2.text =
            draft.deliveryAddresses?[1]['Kelurahan'] ?? '';
        kecamatanControllerDelivery2.text =
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

    // Load location data
    longitudeControllerDelivery.text = draft.longitude ?? '';
    latitudeControllerDelivery.text = draft.latitude ?? '';

    if (draft.fotoKTP != null) _imageKTP.value = File(draft.fotoKTP!);
    if (draft.fotoNPWP != null) _imageNPWP.value = File(draft.fotoNPWP!);
    if (draft.fotoSIUP != null) _imageSIUP.value = File(draft.fotoSIUP!);
    if (draft.fotoGedung3 != null) _imageSPPKP.value = File(draft.fotoGedung3!);
    if (draft.fotoGedung1 != null) {
      _imageBusinessPhotoFront.value = File(draft.fotoGedung1!);
    }
    if (draft.fotoGedung2 != null) {
      _imageBusinessPhotoInside.value = File(draft.fotoGedung2!);
    }

    update();
  }

  Map<String, dynamic> prepareSubmitData() {
    return {
      "CustName": customerNameController.text,
      "BrandName": brandNameController.text,
      "SalesOffice": selectedSalesOffice,
      "BusinessUnit": selectedBusinessUnit,
      "Category": selectedCategory,
      "Category1": selectedCategory2,
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
      "FotoNPWP": npwpFromServer.value,
      "FotoKTP": ktpFromServer.value,
      "FotoSIUP": siupFromServer.value,
      "CustSignature": signatureSalesFromServer.value,
      "SalesSignature": signatureSalesFromServer.value,
      "Long": longitudeControllerDelivery.text,
      "Lat": latitudeControllerDelivery.text,
      "FotoGedung1": businessPhotoFrontFromServer.value,
      "FotoGedung2": businessPhotoInsideFromServer.value,
      "FotoGedung3": sppkpFromServer.value,
      "FotoCompetitorTop": competitorTopFromServer.value,
      // "CreatedBy": idUserFromLogin,
      "CompanyAddresses": [
        {
          "Name": companyNameController.text,
          "StreetName": streetCompanyController.text,
          "Kelurahan": kelurahanController.text,
          "Kecamatan": kecamatanController.text,
          "City": cityController.text,
          "Country": countryController.text,
          "State": provinceController.text,
          "ZipCode": zipCodeController.text.isEmpty
              ? 0
              : int.parse(zipCodeController.text)
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
          "Kecamatan": kecamatanControllerDelivery.text,
          "City": cityControllerDelivery.text,
          "Country": countryControllerDelivery.text,
          "State": provinceControllerDelivery.text,
          "ZipCode": zipCodeControllerDelivery.text.isEmpty
              ? 0
              : int.parse(zipCodeControllerDelivery.text)
        },
        {
          "Name": deliveryNameController2.text,
          "StreetName": streetCompanyControllerDelivery2.text,
          "Kelurahan": kelurahanControllerDelivery2.text,
          "Kecamatan": kecamatanControllerDelivery2.text,
          "City": cityControllerDelivery2.text,
          "Country": countryControllerDelivery2.text,
          "State": provinceControllerDelivery2.text,
          "ZipCode": zipCodeControllerDelivery2.text.isEmpty
              ? 0
              : int.parse(zipCodeControllerDelivery2.text)
        },
      ]
    };
  }

  Future<void> handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth = 'Basic ${base64Encode(utf8.encode('test:test456'))}';

    final requestBody = prepareSubmitData();

    final response = await http.post(
      Uri.parse('$baseURLDevelopment/NOOCustTables'),
      headers: {
        'authorization': basicAuth,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    await prefs.setString("responseBody", response.body);
    await prefs.setInt("statusCode", response.statusCode);

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Customer updated successfully');
      clearForm();
    } else {
      throw Exception('Failed to update customer');
    }
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
    city = (prefs.getString("getCity") ?? "");
    countrys = (prefs.getString("getCountry") ?? "");
    state = (prefs.getString("getState") ?? "");
    zipCode = (prefs.getString("getZipCode") ?? "");
    longitudeData = (prefs.getString("getLongitude") ?? "");
    latitudeData = (prefs.getString("getLatitude") ?? "");
    addressDetail = (prefs.getString("getAddressDetail") ?? "");
  }

  Future<void> fetchSalesOffices() async {
    final url = Uri.parse("$baseURLDevelopment/ViewSO?SO=$so");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    debugPrint(response.body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      salesOffices.value =
          data.map((json) => SalesOffice.fromJson(json)).toList();
    }
  }

  Future<void> fetchBusinessUnits() async {
    final url = Uri.parse("$baseURLDevelopment/ViewBU?BU=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      businessUnits.value =
          data.map((json) => BusinessUnit.fromJson(json)).toList();
    }
  }

  Future<void> fetchAXRegionals() async {
    final url = Uri.parse("$baseURLDevelopment/AX_Regional");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      axRegionals.value =
          data.map((json) => AXRegional.fromJson(json)).toList();
    }
  }

  Future<void> fetchPaymentMode() async {
    final url = Uri.parse("$baseURLDevelopment/AX_CustPaymMode");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      paymentMode =
          data.map((json) => CustomerPaymentMode.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchCategory1() async {
    final url = Uri.parse("$baseURLDevelopment/AX_Category1");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      category1 = data.map((json) => Category1.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchCategory2() async {
    final url = Uri.parse("$baseURLDevelopment/CustCategory");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      category2 = data.map((json) => Category2.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchSegment() async {
    final url = Uri.parse("$baseURLDevelopment/CustSegment?bu=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      segment = data.map((json) => Segment.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchSubSegment() async {
    final url = Uri.parse("$baseURLDevelopment/CustSubSegment");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      subSegment = data.map((json) => SubSegment.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchClass() async {
    final url = Uri.parse("$baseURLDevelopment/CustClass");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      classList = data.map((json) => ClassModel.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchCompanyStatus() async {
    final url = Uri.parse("$baseURLDevelopment/CustCompanyChain");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      companyStatus = data.map((json) => CompanyStatus.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchCurrency() async {
    final url = Uri.parse("$baseURLDevelopment/Currency");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      currency = data.map((json) => Currency.fromJson(json)).toList();
      update();
    }
  }

  Future<void> fetchPriceGroup() async {
    final url =
        Uri.parse("$baseURLDevelopment/CustPriceGroup?so=$codeSO&bu=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      priceGroup = data.map((json) => PriceGroup.fromJson(json)).toList();
      update();
    }
  }

  void onSalesOfficeSelected(String? value) async {
    selectedSalesOffice = value;
    if (value != null) {
      final selectedOffice = salesOffices.firstWhere(
        (office) => office.name == value,
        orElse: () => SalesOffice(name: '', code: ''),
      );
      codeSO = selectedOffice.code;
      selectedPriceGroup = null;
      await fetchPriceGroup();
    }
    update();
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
        "Category1": selectedCategory2,
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
          "Kecamatan": kecamatanControllerDelivery.text,
          "City": cityControllerDelivery.text,
          "State": provinceControllerDelivery.text,
          "Country": countryControllerDelivery.text,
          "ZipCode": int.tryParse(zipCodeControllerDelivery.text) ?? 0
        }
      };

      final response = await http.put(
        Uri.parse('$baseURLDevelopment/NOOCustTables/${editData!.id}'),
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

  Future<void> getImageKTPFromCamera() async {
    if (kIsWeb) {
      await _handleWebImage('KTP');
    } else {
      await _handleMobileImage('KTP', ImageSource.camera, _imageKTP);
    }
  }

  Future<void> getImageKTPFromGallery() async {
    if (kIsWeb) {
      await _handleWebImage('KTP');
    } else {
      await _handleMobileImage('KTP', ImageSource.gallery, _imageKTP);
    }
  }

  Future<void> getImageNPWPFromCamera() async {
    await _handleMobileImage('NPWP', ImageSource.camera, _imageNPWP);
  }

  Future<void> getImageNPWPFromGallery() async {
    await _handleMobileImage('NPWP', ImageSource.gallery, _imageNPWP);
  }

  Future<void> getImageSIUPFromCamera() async {
    await _handleMobileImage('SIUP', ImageSource.camera, _imageSIUP);
  }

  Future<void> getImageSIUPFromGallery() async {
    await _handleMobileImage('SIUP', ImageSource.gallery, _imageSIUP);
  }

  Future<void> getImageSPPKP() async {
    await _handleMobileImage('SPPKP', ImageSource.camera, _imageSPPKP);
  }

  Future<void> getImageSPPKPFromGallery() async {
    await _handleMobileImage('SPPKP', ImageSource.gallery, _imageSPPKP);
  }

  Future<void> getImageBusinessPhotoFrontFromCamera() async {
    await _handleMobileImage(
        'BUSINESSPHOTOFRONT', ImageSource.camera, _imageBusinessPhotoFront);
  }

  Future<void> getImageBusinessPhotoFrontFromGallery() async {
    await _handleMobileImage(
        'BUSINESSPHOTOFRONT', ImageSource.gallery, _imageBusinessPhotoFront);
  }

  Future<void> getImageBusinessPhotoInsideFromCamera() async {
    await _handleMobileImage(
        'BUSINESSPHOTOINSIDE', ImageSource.camera, _imageBusinessPhotoInside);
  }

  Future<void> getImageBusinessPhotoInsideFromGallery() async {
    await _handleMobileImage(
        'BUSINESSPHOTOINSIDE', ImageSource.gallery, _imageBusinessPhotoInside);
  }

  Future<void> getImageCompetitorTopFromCamera() async {
    await _handleMobileImage(
        'COMPETITORTOP', ImageSource.camera, _imageCompetitorTop);
  }

  Future<void> getImageCompetitorTopFromGallery() async {
    await _handleMobileImage(
        'COMPETITORTOP', ImageSource.gallery, _imageCompetitorTop);
  }

  // Upload Methods
  Future<void> uploadKTP(File imageFile) async =>
      await _uploadImage(imageFile, 'KTP', ktpFromServer);
  Future<void> uploadNPWP(File imageFile) async =>
      await _uploadImage(imageFile, 'NPWP', npwpFromServer);
  Future<void> uploadSIUP(File imageFile) async =>
      await _uploadImage(imageFile, 'SIUP', siupFromServer);
  Future<void> uploadSPPKP(File imageFile) async =>
      await _uploadImage(imageFile, 'SPPKP', sppkpFromServer);
  Future<void> uploadBusinessPhotoFront(File imageFile) async =>
      await _uploadImage(
          imageFile, 'BUSINESSPHOTOFRONT', businessPhotoFrontFromServer);
  Future<void> uploadBusinessPhotoInside(File imageFile) async =>
      await _uploadImage(
          imageFile, 'BUSINESSPHOTOINSIDE', businessPhotoInsideFromServer);
  Future<void> uploadCompetitorTop(File imageFile) async =>
      await _uploadImage(imageFile, 'COMPETITORTOP', competitorTopFromServer);

  // Private Helper Methods
  Future<void> _handleWebImage(String type) async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      _imageKTPWeb.value = imageBytes;
    }
  }

  Future<void> _handleMobileImage(
      String type, ImageSource source, Rx<File?> imageState) async {
    // if (!await _checkPermissions()) {
    //   Get.snackbar('Error', 'Storage permissions not granted');
    //   return;
    // }

    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 20);
    if (pickedFile == null) return;

    final username = await _getUsername();
    if (username == null) return;

    final dateNow = DateFormat("ddMMyyyy_hhmmss").format(DateTime.now());
    final directory = await _getImageDirectory();

    final newFile = await File(pickedFile.path)
        .copy('$directory${type}_${dateNow}_${username}_.jpg');
    imageState.value = newFile;
  }

  Future<void> _uploadImage(
      File imageFile, String type, RxString serverResponse) async {
    try {
      final stream = http.ByteStream((imageFile.openRead()));
      final length = await imageFile.length();
      final username = await _getUsername();
      final uri = Uri.parse('$baseURLDevelopment/Upload');

      final request = http.MultipartRequest("POST", uri)
        ..files.add(http.MultipartFile('file', stream, length,
            filename: basename(imageFile.path)));

      final response = await request.send();

      response.stream.transform(utf8.decoder).listen((value) {
        final fileName =
            "${type}_${DateFormat("ddMMyyyy_hhmmss").format(DateTime.now())}_${username}_.jpg";
        serverResponse.value = value.replaceAll("\"", "");
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    bool storage = true;
    bool videos = true;
    bool photos = true;

    final androidInfo = await _deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt <= 33) {
      videos = await Permission.videos.status.isGranted;
      photos = await Permission.photos.status.isGranted;
    } else {
      storage = await Permission.storage.status.isGranted;
    }

    if (storage && videos && photos) {
      return await Permission.storage.request().isGranted;
    }
    return false;
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
    final appDirectory = await getExternalStorageDirectory();
    final directory = '${appDirectory!.path}/id.prb.noo_sms/files/Pictures/';

    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return directory;
  }
}
