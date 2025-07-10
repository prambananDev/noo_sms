import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/preview_edit_cust/preview_controller.dart';
import 'package:noo_sms/assets/constant/preview_edit_cust/preview_dialog.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/customer_textfield_noo.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/edit_customer/customer_detail_controller.dart';
import 'package:noo_sms/view/edit_customer/city_dropdown_edit.dart';
import 'package:noo_sms/view/edit_customer/district_dropdown_edit.dart';
import 'package:noo_sms/view/edit_customer/payment_term_dropdown.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/view/edit_customer/province_dropdown_edit.dart';

class CustomerDetailFormScreen extends StatefulWidget {
  const CustomerDetailFormScreen({super.key});

  @override
  CustomerDetailFormScreenState createState() =>
      CustomerDetailFormScreenState();
}

class CustomerDetailFormScreenState extends State<CustomerDetailFormScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late CustomerDetailFormController controller;
  late CustomerFormController controller2;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    controller = Get.put(CustomerDetailFormController());
    controller2 = Get.put(CustomerFormController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 35),
        ),
        title: const Text(
          'Customer Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Obx(() => controller.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save, color: Colors.white),
                  tooltip: 'Save Changes',
                )),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading customer details...'),
                  ],
                ),
              );
            }

            if (controller.errorMessage.isNotEmpty &&
                controller.customerDetail.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 140),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  BasicInfoSection(controller: controller),
                  CompanyAndTaxSection(
                      controller: controller, controller2: controller2),
                  DeliveryAddressSection(
                      controller: controller, controller2: controller2),
                ],
              ),
            );
          }),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: _currentIndex == index ? 24.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4.0),
                            color: _currentIndex == index
                                ? colorAccent
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            side: BorderSide(color: colorAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            if (controller.validateRequiredDocuments()) {
                              final previewController =
                                  Get.isRegistered<PreviewEditController>()
                                      ? Get.find<PreviewEditController>()
                                      : Get.put(PreviewEditController());
                              Get.dialog(PreviewEditDialog(
                                  controller: previewController));
                            }
                          },
                          child: Text(
                            'Preview',
                            style: TextStyle(
                              color: colorAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorAccent,
                                foregroundColor: colorNetral,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: controller.isSaving.value
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Saving...'),
                                      ],
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (controller.validateRequiredDocuments()) {
      await controller.updateCustomer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<CustomerDetailFormController>();
    super.dispose();
  }
}

class BasicInfoSection extends StatelessWidget {
  final CustomerDetailFormController controller;

  const BasicInfoSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Basic Information",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomTextField(
            label: "Customer Name",
            controller: controller.customerNameController,
            validationText: "Please enter Customer Name",
            capitalization: TextCapitalization.words,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Brand Name",
            controller: controller.brandNameController,
            validationText: "Please enter Brand Name",
            capitalization: TextCapitalization.words,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Contact Person",
            controller: controller.contactPersonController,
            validationText: "Please enter Contact Person",
            capitalization: TextCapitalization.words,
          ),
          CustomTextField(
            label: "KTP",
            controller: controller.ktpController,
            validationText: "Please enter KTP",
            inputType: TextInputType.number,
          ),
          CustomTextField(
            label: "KTP Address",
            controller: controller.ktpAddressController,
            validationText: "Please enter KTP Address",
            capitalization: TextCapitalization.words,
            inputType: TextInputType.text,
            maxLength: 100,
          ),
          CustomTextField(
            label: "FAX",
            controller: controller.faxController,
            inputType: TextInputType.phone,
          ),
          CustomTextField(
            label: "Phone",
            controller: controller.phoneController,
            validationText: "Please enter Phone Number",
            inputType: TextInputType.phone,
          ),
          CustomTextField(
            label: "Email Address",
            controller: controller.emailAddressController,
            validationText: "Please enter Email Address",
            inputType: TextInputType.emailAddress,
          ),
          CustomTextField(
            label: "Website",
            controller: controller.websiteController,
            inputType: TextInputType.url,
          ),
          _buildInfoRow(
              "Sales Office", controller.selectedSalesOffice ?? 'N/A'),
          _buildInfoRow(
              "Business Unit", controller.selectedBusinessUnit ?? 'N/A'),
          _buildInfoRow("Category", controller.selectedCategory ?? 'N/A'),
          _buildInfoRow("Segment", controller.selectedSegment ?? 'N/A'),
          _buildInfoRow("Sub Segment", controller.selectedSubSegment ?? 'N/A'),
          _buildInfoRow("Class", controller.selectedClass ?? 'N/A'),
          _buildInfoRow(
              "Company Status", controller.selectedCompanyStatus ?? 'N/A'),
          PaymentTermDropdownField(
            label: "Payment Term",
            controller: controller,
            isRequired: true,
            validationText: "Please select Payment Term",
          ),
          CustomTextField(
            label: "Credit Limit",
            controller: controller.creditLimitController,
            validationText: "Credit Limit",
            capitalization: TextCapitalization.words,
            inputType: TextInputType.number,
            isCurrency: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyAndTaxSection extends StatelessWidget {
  final CustomerDetailFormController controller;
  final CustomerFormController controller2;

  const CompanyAndTaxSection(
      {Key? key, required this.controller, required this.controller2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Company Address",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomTextField(
            label: "Company Name",
            controller: controller.companyNameController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Street Name",
            controller: controller.streetCompanyController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Country",
            controller: controller.countryController,
            inputType: TextInputType.text,
          ),
          ProvinceDropdownEdit(
            label: "Provinsi",
            controller: controller.provinceController,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityController,
            addressType: 'main',
            search: true,
          ),
          CityDropdownEdit(
            label: "City",
            controller: controller.cityController,
            formController: controller2,
            detailController: controller,
            provinceController: controller.provinceController,
            addressType: 'main',
            search: true,
          ),
          DistrictDropdownEdit(
            label: "Kecamatan",
            controller: controller.kecamatanController,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityController,
            addressType: 'main',
            search: true,
          ),
          CustomTextField(
            label: "Kelurahan",
            controller: controller.kelurahanController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "ZIP Code",
            controller: controller.zipCodeController,
            inputType: TextInputType.number,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Location Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.getLocationFromPrefs(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Update Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GetBuilder<CustomerDetailFormController>(
                  builder: (_) => controller.longitudeData.isNotEmpty &&
                          controller.latitudeData.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Longitude: ${controller.longitudeData}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Latitude: ${controller.latitudeData}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No location data available",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Click 'Update Location' to get current location",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: Colors.black,
              height: 0,
              thickness: 1,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Tax Address",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomTextField(
            label: "NPWP",
            controller: controller.npwpController,
            validationText: "Please enter NPWP",
            inputType: TextInputType.number,
            maxLength: 16,
          ),
          CustomTextField(
            label: "Tax Name",
            controller: controller.taxNameController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Tax Address",
            controller: controller.taxStreetController,
            inputType: TextInputType.text,
          ),
          ProvinceDropdownEdit(
            label: "Provinsi",
            controller: controller.provinceTaxController,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityTaxController,
            addressType: 'delivery2',
            search: true,
          ),
          CityDropdownEdit(
            label: "City",
            controller: controller.cityTaxController,
            formController: controller2,
            detailController: controller,
            provinceController: controller.provinceTaxController,
            addressType: 'delivery2',
            search: true,
          ),
          DistrictDropdownEdit(
            label: "Kecamatan",
            controller: controller.kecamatanTaxController,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityTaxController,
            addressType: 'delivery2',
            search: true,
          ),
          CustomTextField(
            label: "Kelurahan",
            controller: controller.kelurahanTaxController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "ZIP Code",
            controller: controller.zipCodeTaxController,
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class DeliveryAddressSection extends StatelessWidget {
  final CustomerDetailFormController controller;
  final CustomerFormController controller2;

  const DeliveryAddressSection(
      {Key? key, required this.controller, required this.controller2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomTextField(
            label: "Name",
            controller: controller.deliveryNameController,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Street Name",
            controller: controller.streetCompanyControllerDelivery,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "Country",
            controller: controller.countryControllerDelivery,
            inputType: TextInputType.text,
          ),
          ProvinceDropdownEdit(
            label: "Provinsi",
            controller: controller.provinceControllerDelivery,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityControllerDelivery,
            addressType: 'delivery',
            search: true,
          ),
          CityDropdownEdit(
            label: "City",
            controller: controller.cityControllerDelivery,
            formController: controller2,
            detailController: controller,
            provinceController: controller.provinceControllerDelivery,
            addressType: 'delivery',
            search: true,
          ),
          DistrictDropdownEdit(
            label: "Kecamatan",
            controller: controller.kecamatanControllerDelivery,
            formController: controller2,
            detailController: controller,
            cityController: controller.cityControllerDelivery,
            addressType: 'delivery',
            search: true,
          ),
          CustomTextField(
            label: "Kelurahan",
            controller: controller.kelurahanControllerDelivery,
            inputType: TextInputType.text,
          ),
          CustomTextField(
            label: "ZIP Code",
            controller: controller.zipCodeControllerDelivery,
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Divider(height: 8),
        ],
      ),
    );
  }
}
