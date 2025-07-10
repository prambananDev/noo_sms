import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/edit_customer/edit_customer_controller.dart';
import 'package:noo_sms/controllers/edit_customer/edit_customer_repo.dart';
import 'package:noo_sms/models/edit_cust_noo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:signature/signature.dart';

class CustomerDetailFormController extends GetxController {
  final EditCustRepository _repository = EditCustRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoadingPaymentTerms = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<CustomerDetail?> customerDetail = Rx<CustomerDetail?>(null);
  final RxInt customerId = 0.obs;

  final RxList<PaymentTerm> paymentTerms = <PaymentTerm>[].obs;
  final Rx<PaymentTerm?> selectedPaymentTerm = Rx<PaymentTerm?>(null);

  final customerNameController = TextEditingController();
  final brandNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final ktpController = TextEditingController();
  final ktpAddressController = TextEditingController();
  final faxController = TextEditingController();
  final phoneController = TextEditingController();
  final emailAddressController = TextEditingController();
  final websiteController = TextEditingController();

  final companyNameController = TextEditingController();
  final streetCompanyController = TextEditingController();
  final countryController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final kecamatanController = TextEditingController();
  final kelurahanController = TextEditingController();
  final zipCodeController = TextEditingController();

  final npwpController = TextEditingController();
  final taxNameController = TextEditingController();
  final taxStreetController = TextEditingController();
  final countryTaxController = TextEditingController();
  final provinceTaxController = TextEditingController();
  final cityTaxController = TextEditingController();
  final kecamatanTaxController = TextEditingController();
  final kelurahanTaxController = TextEditingController();
  final zipCodeTaxController = TextEditingController();

  final deliveryNameController = TextEditingController();
  final streetCompanyControllerDelivery = TextEditingController();
  final countryControllerDelivery = TextEditingController();
  final provinceControllerDelivery = TextEditingController();
  final cityControllerDelivery = TextEditingController();
  final kecamatanControllerDelivery = TextEditingController();
  final kelurahanControllerDelivery = TextEditingController();
  final zipCodeControllerDelivery = TextEditingController();
  final creditLimitController = TextEditingController();
  final paymentTermController = TextEditingController();

  String? selectedSalesOffice;
  String? selectedBusinessUnit;
  String? selectedCategory;
  String? selectedCategory1;
  String? selectedAXRegional;
  String? selectedSegment;
  String? selectedSubSegment;
  String? selectedClass;
  String? selectedCompanyStatus;
  String? selectedCurrency;
  String? selectedPriceGroup;
  String? selectedPaymentMode;

  String longitudeData = '';
  String latitudeData = '';

  final signatureSalesController = SignatureController();
  final signatureCustomerController = SignatureController();

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      customerId.value = arguments['customerId'] ?? 0;

      if (customerId.value > 0) {
        fetchCustomerDetail();
        fetchPaymentTerms();
      }
    }
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    customerNameController.dispose();
    brandNameController.dispose();
    contactPersonController.dispose();
    ktpController.dispose();
    ktpAddressController.dispose();
    faxController.dispose();
    phoneController.dispose();
    emailAddressController.dispose();
    websiteController.dispose();
    companyNameController.dispose();
    streetCompanyController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    kecamatanController.dispose();
    kelurahanController.dispose();
    zipCodeController.dispose();
    npwpController.dispose();
    taxNameController.dispose();
    taxStreetController.dispose();
    deliveryNameController.dispose();
    streetCompanyControllerDelivery.dispose();
    countryControllerDelivery.dispose();
    provinceControllerDelivery.dispose();
    cityControllerDelivery.dispose();
    kecamatanControllerDelivery.dispose();
    kelurahanControllerDelivery.dispose();
    zipCodeControllerDelivery.dispose();
    creditLimitController.dispose();
    paymentTermController.dispose();
    signatureSalesController.dispose();
    signatureCustomerController.dispose();
  }

  Future<void> fetchCustomerDetail({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint(
          "Fetching customer detail for ID: ${customerId.value}${forceRefresh ? ' (force refresh)' : ''}");

      final detail = await _repository.fetchCustomerDetail(customerId.value,
          forceRefresh: forceRefresh);
      customerDetail.value = detail;

      _populateFormWithCustomerDetail(detail);
    } catch (e) {
      errorMessage.value = 'Failed to load customer detail: $e';
      debugPrint("Error fetching customer detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentTerms({String? segment}) async {
    try {
      isLoadingPaymentTerms.value = true;

      debugPrint(
          "Fetching payment terms${segment != null ? ' for segment: $segment' : ''}");

      final terms = await _repository.fetchPaymentTerms(segment: segment);
      paymentTerms.value = terms;

      if (customerDetail.value != null &&
          customerDetail.value!.paymentTerm.isNotEmpty) {
        _setSelectedPaymentTerm(customerDetail.value!.paymentTerm);
      }

      debugPrint("Successfully loaded ${terms.length} payment terms");
    } catch (e) {
      debugPrint("Error fetching payment terms: $e");
    } finally {
      isLoadingPaymentTerms.value = false;
    }
  }

  void _setSelectedPaymentTerm(String paymentTermId) {
    try {
      final term = paymentTerms.firstWhere(
        (term) => term.paymTermId == paymentTermId,
      );
      selectedPaymentTerm.value = term;
    } catch (e) {
      debugPrint("Payment term not found in list: $paymentTermId");
    }
  }

  void updateSelectedPaymentTerm(PaymentTerm? term) {
    selectedPaymentTerm.value = term;
    if (term != null) {
      paymentTermController.text = term.paymTermId;
    } else {
      paymentTermController.clear();
    }
  }

  String get currentPaymentTermId {
    return paymentTermController.text.trim().isNotEmpty
        ? paymentTermController.text.trim()
        : (selectedPaymentTerm.value?.paymTermId ?? '');
  }

  Future<void> getLocationFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final longitude = prefs.getString("getLongitude") ?? "";
      final latitude = prefs.getString("getLatitude") ?? "";

      if (longitude.isNotEmpty && latitude.isNotEmpty) {
        longitudeData = longitude;
        latitudeData = latitude;
        update();
      }
    } catch (e) {
      debugPrint("Error getting location from prefs: $e");
      Get.snackbar(
        'Error',
        'Failed to retrieve location',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _populateFormWithCustomerDetail(CustomerDetail detail) {
    try {
      customerNameController.text = detail.custName;
      brandNameController.text = detail.brandName ?? '';
      contactPersonController.text = detail.contactPerson ?? '';
      ktpController.text = detail.ktp ?? '';
      ktpAddressController.text = detail.ktpAddress ?? '';
      faxController.text = detail.faxNo ?? '';
      phoneController.text = detail.phoneNo ?? '';
      emailAddressController.text = detail.emailAddress ?? '';
      websiteController.text = detail.website ?? '';
      creditLimitController.text = detail.creditLimit;
      paymentTermController.text = detail.paymentTerm;

      if (paymentTerms.isNotEmpty && detail.paymentTerm.isNotEmpty) {
        _setSelectedPaymentTerm(detail.paymentTerm);
      }

      selectedSalesOffice = detail.salesOffice;
      selectedBusinessUnit = detail.businessUnit;
      selectedCategory = detail.category;
      selectedCategory1 = detail.category1;
      selectedAXRegional = detail.regional;
      selectedSegment = detail.segment;
      selectedSubSegment = detail.subSegment;
      selectedClass = detail.classType;
      selectedCompanyStatus = detail.companyStatus;
      selectedCurrency = detail.currency;
      selectedPriceGroup = detail.priceGroup;
      selectedPaymentMode = detail.paymMode;

      if (detail.companyAddresses != null) {
        final companyAddr = detail.companyAddresses!;
        companyNameController.text = companyAddr.name;
        streetCompanyController.text = companyAddr.streetName;
        countryController.text = companyAddr.country;
        cityController.text = companyAddr.city;
        provinceController.text = companyAddr.state;
        kecamatanController.text = companyAddr.kecamatan ?? '';
        kelurahanController.text = companyAddr.kelurahan ?? '';
        zipCodeController.text = companyAddr.zipCode.toString();
      }

      npwpController.text = detail.npwp ?? '';
      if (detail.taxAddresses != null) {
        final taxAddr = detail.taxAddresses!;
        taxNameController.text = taxAddr.name;
        taxStreetController.text = taxAddr.streetName;
      }

      if (detail.deliveryAddresses != null) {
        final deliveryAddr = detail.deliveryAddresses!;
        deliveryNameController.text = deliveryAddr.name;
        streetCompanyControllerDelivery.text = deliveryAddr.streetName;
        countryControllerDelivery.text = deliveryAddr.country;
        cityControllerDelivery.text = deliveryAddr.city;
        provinceControllerDelivery.text = deliveryAddr.state;
        kecamatanControllerDelivery.text = deliveryAddr.kecamatan ?? '';
        kelurahanControllerDelivery.text = deliveryAddr.kelurahan ?? '';
        zipCodeControllerDelivery.text = deliveryAddr.zipCode.toString();
      }

      longitudeData = detail.longCoord ?? '';
      latitudeData = detail.lat ?? '';

      if (longitudeData.isEmpty || latitudeData.isEmpty) {
        getLocationFromPrefs();
      }

      update();

      debugPrint("Form populated with customer detail: ${detail.custName}");
    } catch (e) {
      debugPrint("Error populating form: $e");
    }
  }

  Future<void> updateCustomer() async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      if (customerDetail.value == null) {
        throw Exception('Customer detail not loaded');
      }
      final updateData = _prepareCustomerUpdateData(customerDetail.value!);

      final success =
          await _repository.updateCustomerDetail(customerId.value, updateData);

      if (success) {
        Get.snackbar(
          'Success',
          'Customer updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Force refresh the customer detail from server to get latest data
        await fetchCustomerDetail(forceRefresh: true);

        // Optional: Also refresh the list in the parent controller if it exists
        if (Get.isRegistered<EditCustController>()) {
          final editCustController = Get.find<EditCustController>();
          await editCustController.fetchCust();
        }

        Get.back(result: true);
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      errorMessage.value = 'Failed to update customer: $e';
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _prepareCustomerUpdateData(CustomerDetail detail) {
    return {
      'id': customerId.value,
      'Custid': detail.custId,
      'CustName': customerNameController.text.trim(),
      'BrandName': brandNameController.text.trim(),
      'Category1': selectedCategory1,
      'PaymMode': selectedPaymentMode,
      'Category': selectedCategory,
      'Segment': selectedSegment,
      'SubSegment': selectedSubSegment,
      'Class': selectedClass,
      'PhoneNo': phoneController.text.trim(),
      'CompanyStatus': selectedCompanyStatus,
      'FaxNo': faxController.text.trim(),
      'ContactPerson': contactPersonController.text.trim(),
      'EmailAddress': emailAddressController.text.trim(),
      'Website': websiteController.text.trim(),
      'NPWP': npwpController.text.trim(),
      'KTP': ktpController.text.trim(),
      'SPPKP': detail.sppkp,
      'SIUP': detail.siup,
      'Currency': selectedCurrency,
      'PriceGroup': selectedPriceGroup,
      'Salesman': detail.salesman,
      'SalesOffice': selectedSalesOffice,
      'BusinessUnit': selectedBusinessUnit,
      'Notes': detail.notes,
      'FotoNPWP': detail.fotoNPWP,
      'FotoSPPKP': "",
      'FotoKTP': detail.fotoKTP,
      'FotoSIUP': detail.fotoSIUP,
      'FotoGedung': detail.fotoGedung,
      'FotoGedung1': detail.fotoGedung1,
      'FotoGedung2': detail.fotoGedung2,
      'FotoGedung3': detail.fotoGedung3,
      'SalesSignature': detail.salesSignature,
      'CustSignature': detail.custSignature,
      'Approval1Signature': detail.approval1Signature,
      'Approval2Signature': detail.approval2Signature,
      'Approval3Signature': detail.approval3Signature,
      'Approval1': detail.approval1,
      'Approval2': detail.approval2,
      'Approval3': detail.approval3,
      'Approved1': detail.approved1,
      'Approved2': detail.approved2,
      'Approved3': detail.approved3,
      'Status': detail.status,
      'CreatedBy': detail.createdBy,
      'CreatedDate': detail.createdDate,
      'Imported': detail.imported,
      'Long': longitudeData,
      'Lat': latitudeData,
      'Remarks': detail.remark,
      'Regional': selectedAXRegional,
      'KTPAddress': ktpAddressController.text.trim(),
      'PaymentTerm': currentPaymentTermId,
      'CreditLimit': creditLimitController.text,
      'FotoCompetitorTop': detail.fotoCompetitorTop,
      'NPWPImage': detail.npwp,
      'CompanyAddresses': {
        'id': 0,
        'Name': companyNameController.text.trim(),
        'StreetName': streetCompanyController.text.trim(),
        'City': cityController.text.trim(),
        'Country': countryController.text.trim(),
        'Kelurahan': kelurahanController.text.trim(),
        'Kecamatan': kecamatanController.text.trim(),
        'State': provinceController.text.trim(),
        'ZipCode': int.tryParse(zipCodeController.text.trim()) ?? 0,
        'ParentId': 0,
      },
      'DeliveryAddresses': {
        'id': 0,
        'Name': deliveryNameController.text.trim(),
        'StreetName': streetCompanyControllerDelivery.text.trim(),
        'City': cityControllerDelivery.text.trim(),
        'Country': countryControllerDelivery.text.trim(),
        'Kelurahan': kelurahanControllerDelivery.text.trim(),
        'Kecamatan': kecamatanControllerDelivery.text.trim(),
        'State': provinceControllerDelivery.text.trim(),
        'ZipCode': int.tryParse(zipCodeControllerDelivery.text.trim()) ?? 0,
        'ParentId': 0,
      },
      'TaxAddresses': {
        'id': 0,
        'Name': taxNameController.text.trim(),
        'StreetName': taxStreetController.text.trim(),
        'City': cityTaxController.text.trim(),
        'Country': countryTaxController.text.trim(),
        'State': provinceTaxController.text.trim(),
        'Kelurahan': kelurahanTaxController.text.trim(),
        'Kecamatan': kecamatanTaxController.text.trim(),
        'ZipCode': int.tryParse(zipCodeTaxController.text.trim()) ?? 0,
        'ParentId': null,
      },
    };
  }

  bool validateRequiredDocuments() {
    List<String> missingDocuments = [];
    List<String> missingFields = [];

    if (customerNameController.text.isEmpty) {
      missingFields.add('Customer Name');
    }

    if (brandNameController.text.isEmpty) {
      missingFields.add('Brand Name');
    }

    if (selectedSalesOffice == null) {
      missingFields.add('Sales Office');
    }

    if (selectedBusinessUnit == null) {
      missingFields.add('Business Unit');
    }

    if (selectedCategory == null) {
      missingFields.add('Category 1');
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

    if (selectedPriceGroup == null) {
      missingFields.add('Price Group');
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

    if (provinceController.text.isEmpty) {
      missingFields.add('Provinsi (Company Address)');
    }

    if (cityController.text.isEmpty) {
      missingFields.add('City (Company Address)');
    }

    if (kecamatanController.text.isEmpty) {
      missingFields.add('Kecamatan (Company Address)');
    }

    if (kelurahanController.text.isEmpty) {
      missingFields.add('Kelurahan (Company Address)');
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

    if (provinceTaxController.text.isEmpty) {
      missingFields.add('Provinsi (TAX Address)');
    }

    if (cityTaxController.text.isEmpty) {
      missingFields.add('City (TAX Address)');
    }

    if (kecamatanTaxController.text.isEmpty) {
      missingFields.add('Kecamatan (TAX Address)');
    }

    if (kelurahanTaxController.text.isEmpty) {
      missingFields.add('Kelurahan (CompTAXany Address)');
    }

    if (countryTaxController.text.isEmpty) {
      missingFields.add('Country (TAX Address)');
    }

    if (zipCodeTaxController.text.isEmpty) {
      missingFields.add('ZIP Code (TAX Address)');
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

    if (kecamatanControllerDelivery.text.isEmpty) {
      missingFields.add('Kecamatan (Delivery Address)');
    }

    if (countryControllerDelivery.text.isEmpty) {
      missingFields.add('Country (Delivery Address)');
    }

    if (zipCodeControllerDelivery.text.isEmpty) {
      missingFields.add('ZIP Code (Delivery Address)');
    }

    if (paymentTermController.text.trim().isEmpty) {
      missingFields.add('Payment Term');
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
}
