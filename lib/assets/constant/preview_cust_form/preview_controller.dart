import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';

class PreviewController extends GetxController {
  late final CustomerFormController customerFormController;

  @override
  void onInit() {
    super.onInit();
    customerFormController = Get.find<CustomerFormController>();
  }

  TextEditingController get customerNameController =>
      customerFormController.customerNameController;
  TextEditingController get brandNameController =>
      customerFormController.brandNameController;
  TextEditingController get contactPersonController =>
      customerFormController.contactPersonController;
  TextEditingController get ktpController =>
      customerFormController.ktpController;
  TextEditingController get ktpAddressController =>
      customerFormController.ktpAddressController;
  TextEditingController get npwpController =>
      customerFormController.npwpController;
  TextEditingController get phoneController =>
      customerFormController.phoneController;
  TextEditingController get faxController =>
      customerFormController.faxController;
  TextEditingController get emailAddressController =>
      customerFormController.emailAddressController;
  TextEditingController get websiteController =>
      customerFormController.websiteController;

  TextEditingController get companyNameController =>
      customerFormController.companyNameController;
  TextEditingController get streetCompanyController =>
      customerFormController.streetCompanyController;
  TextEditingController get kelurahanController =>
      customerFormController.kelurahanController;
  TextEditingController get kecamatanController =>
      customerFormController.kecamatanController;
  TextEditingController get cityController =>
      customerFormController.cityController;
  TextEditingController get provinceController =>
      customerFormController.provinceController;
  TextEditingController get countryController =>
      customerFormController.countryController;
  TextEditingController get zipCodeController =>
      customerFormController.zipCodeController;

  TextEditingController get taxNameController =>
      customerFormController.taxNameController;
  TextEditingController get taxStreetController =>
      customerFormController.taxStreetController;

  TextEditingController get deliveryNameController =>
      customerFormController.deliveryNameController;
  TextEditingController get streetCompanyControllerDelivery =>
      customerFormController.streetCompanyControllerDelivery;
  TextEditingController get kelurahanControllerDelivery =>
      customerFormController.kelurahanControllerDelivery;
  TextEditingController get kecamatanControllerDelivery =>
      customerFormController.kecamatanControllerDelivery.value;
  TextEditingController get cityControllerDelivery =>
      customerFormController.cityControllerDelivery;
  TextEditingController get provinceControllerDelivery =>
      customerFormController.provinceControllerDelivery;
  TextEditingController get countryControllerDelivery =>
      customerFormController.countryControllerDelivery;
  TextEditingController get zipCodeControllerDelivery =>
      customerFormController.zipCodeControllerDelivery;

  TextEditingController get deliveryNameController2 =>
      customerFormController.deliveryNameController2;
  TextEditingController get streetCompanyControllerDelivery2 =>
      customerFormController.streetCompanyControllerDelivery2;
  TextEditingController get kelurahanControllerDelivery2 =>
      customerFormController.kelurahanControllerDelivery2;
  TextEditingController get kecamatanControllerDelivery2 =>
      customerFormController.kecamatanControllerDelivery2.value;
  TextEditingController get cityControllerDelivery2 =>
      customerFormController.cityControllerDelivery2;
  TextEditingController get provinceControllerDelivery2 =>
      customerFormController.provinceControllerDelivery2;
  TextEditingController get countryControllerDelivery2 =>
      customerFormController.countryControllerDelivery2;
  TextEditingController get zipCodeControllerDelivery2 =>
      customerFormController.zipCodeControllerDelivery2;

  String? get selectedSalesOffice => customerFormController.selectedSalesOffice;
  String? get selectedBusinessUnit =>
      customerFormController.selectedBusinessUnit;
  String? get selectedCategory => customerFormController.selectedCategory;
  String? get selectedCategory1 => customerFormController.selectedCategory1;
  String? get selectedAXRegional => customerFormController.selectedAXRegional;
  String? get selectedPaymentMode => customerFormController.selectedPaymentMode;
  String? get selectedSegment => customerFormController.selectedSegment;
  String? get selectedSubSegment => customerFormController.selectedSubSegment;
  String? get selectedClass => customerFormController.selectedClass;
  String? get selectedCompanyStatus =>
      customerFormController.selectedCompanyStatus;
  String? get selectedCurrency => customerFormController.selectedCurrency;
  String? get selectedPriceGroup => customerFormController.selectedPriceGroup;

  // Methods for preview logic
  String formatPreviewText(String? text) {
    return text != null && text.isNotEmpty ? text : 'N/A';
  }
}
