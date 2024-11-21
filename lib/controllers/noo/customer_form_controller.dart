import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/models/customer_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerFormController extends GetxController {
  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  String? so;
  String? bu;
  String? codeSO;
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

  @override
  void onInit() {
    super.onInit();

    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';

    initializeData();
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
      // fetchPriceGroup(),
    ]);

    if (!Get.isRegistered<PreviewController>()) {
      Get.put(PreviewController());
    }
    update();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    so = prefs.getString('SO');
    bu = prefs.getString('BU');

    update();
  }

  RxList<SalesOffice> salesOffices = <SalesOffice>[].obs;
  RxList<BusinessUnit> businessUnits = <BusinessUnit>[].obs;
  RxList<AXRegional> axRegionals = <AXRegional>[].obs;
  List<CustomerPaymentMode> paymentMode = [];
  List<Category> category1 = [];
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

  Future<void> fetchSalesOffices() async {
    final url = Uri.parse("$baseURLDevelopment/ViewSO?SO=$so");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    debugPrint("reszz1 " + response.body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      salesOffices.value =
          data.map((json) => SalesOffice.fromJson(json)).toList();
    }
    debugPrint("sales ${salesOffices.map((sales) => {sales.name}).toList()}");
  }

  Future<void> fetchBusinessUnits() async {
    final url = Uri.parse("$baseURLDevelopment/ViewBU?BU=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      businessUnits.value =
          data.map((json) => BusinessUnit.fromJson(json)).toList();
    }
    debugPrint("salesbu ${businessUnits.map((unit) => {unit.name}).toList()}");
  }

  Future<void> fetchAXRegionals() async {
    final url = Uri.parse("$baseURLDevelopment/AX_Regional");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      axRegionals.value =
          data.map((json) => AXRegional.fromJson(json)).toList();
    }
    debugPrint(
        "sales ${axRegionals.map((region) => {region.regional}).toList()}");
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
    debugPrint("Payment modes: ${paymentMode.map((payment) => {
          payment.paymentMode
        }).toList()}");
  }

  Future<void> fetchCategory1() async {
    final url = Uri.parse("$baseURLDevelopment/AX_Category1");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      category1 = data.map((json) => Category.fromJson(json)).toList();
      update();
    }
    debugPrint("Category: ${category1.map((cat) => {cat.name}).toList()}");
  }

  Future<void> fetchCategory2() async {
    final url = Uri.parse("$baseURLDevelopment/CustCategory");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      category2 = data.map((json) => Category2.fromJson(json)).toList();
      update();
    }
    debugPrint("Category2: ${category2.map((cat) => {cat.master}).toList()}");
  }

  Future<void> fetchSegment() async {
    final url = Uri.parse("$baseURLDevelopment/CustSegment?bu=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      segment = data.map((json) => Segment.fromJson(json)).toList();
      update();
    }
    debugPrint("Category3: ${segment.map((seg) => {seg.segmentId}).toList()}");
  }

  Future<void> fetchSubSegment() async {
    final url = Uri.parse("$baseURLDevelopment/CustSubSegment");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      subSegment = data.map((json) => SubSegment.fromJson(json)).toList();
      update();
    }
    debugPrint(
        "Category4: ${subSegment.map((seg) => {seg.subSegmentId}).toList()}");
  }

  Future<void> fetchClass() async {
    final url = Uri.parse("$baseURLDevelopment/CustClass");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      classList = data.map((json) => ClassModel.fromJson(json)).toList();
      update();
    }
    debugPrint(
        "Category4: ${classList.map((cls) => {cls.className}).toList()}");
  }

  Future<void> fetchCompanyStatus() async {
    final url = Uri.parse("$baseURLDevelopment/CustCompanyChain");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      companyStatus = data.map((json) => CompanyStatus.fromJson(json)).toList();
      update();
    }
    debugPrint(
        "Category4: ${companyStatus.map((cls) => {cls.chainId}).toList()}");
  }

  Future<void> fetchCurrency() async {
    final url = Uri.parse("$baseURLDevelopment/Currency");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      currency = data.map((json) => Currency.fromJson(json)).toList();
      update();
    }
    debugPrint(
        "Category4: ${currency.map((cls) => {cls.currencyCode}).toList()}");
  }

  Future<void> fetchPriceGroup() async {
    final url =
        Uri.parse("$baseURLDevelopment/CustPriceGroup?so=$codeSO&bu=$bu");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    debugPrint("reszz2 " + response.body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      priceGroup = data.map((json) => PriceGroup.fromJson(json)).toList();
      update();
    }
    debugPrint("price: ${priceGroup.map((cls) => {cls.groupId}).toList()}");
  }

  void onSalesOfficeSelected(String? value) async {
    selectedSalesOffice = value;

    if (value != null) {
      final selectedOffice = salesOffices.firstWhere(
        (office) => office.name == value,
        orElse: () => SalesOffice(name: '', code: ''),
      );
      codeSO = selectedOffice.code;
      debugPrint("reszz " + codeSO!);
      selectedPriceGroup = null;

      await fetchPriceGroup();
    }
    update();
  }
}
