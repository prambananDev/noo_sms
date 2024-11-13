import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/customer_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerFormController extends GetxController {
  final String usernameAuth = 'test';
  final String passwordAuth = 'test456';
  late String basicAuth;
  String? so;

  @override
  void onInit() {
    super.onInit();

    basicAuth =
        'Basic ${base64Encode(utf8.encode('$usernameAuth:$passwordAuth'))}';
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    so = prefs.getString('so');
    update();
  }

  RxList<SalesOffice> salesOffices = <SalesOffice>[].obs;
  RxList<BusinessUnit> businessUnits = <BusinessUnit>[].obs;
  RxList<Category> categories = <Category>[].obs;
  RxList<AXRegional> axRegionals = <AXRegional>[].obs;
  RxList<CustomerPaymentMode> paymentMode = <CustomerPaymentMode>[].obs;

  String? selectedSalesOffice;
  String? selectedBusinessUnit;
  String? selectedCategory;
  String? selectedAXRegional;

  Future<void> fetchSalesOffices() async {
    final url = Uri.parse("$baseURLDevelopment/ViewSO?SO=$so");
    final response = await http.get(url, headers: {'authorization': basicAuth});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      salesOffices.value =
          data.map((json) => SalesOffice.fromJson(json)).toList();
    }
    debugPrint("salesss ${salesOffices.map((sales) => {sales.name}).toList()}");
  }

  Future<void> fetchBusinessUnits() async {/* similar to fetchSalesOffices */}
  Future<void> fetchCategories() async {/* similar to fetchSalesOffices */}

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
      paymentMode.value =
          data.map((json) => CustomerPaymentMode.fromJson(json)).toList();
    }
    debugPrint("sales ${paymentMode.map((payment) => {
          payment.paymentMode
        }).toList()}");
  }
}
