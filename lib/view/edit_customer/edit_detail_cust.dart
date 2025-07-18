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
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 56.rs(context),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
        ),
        title: Text(
          'Customer Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.rt(context),
          ),
        ),
        actions: [
          Obx(() => controller.isSaving.value
              ? Padding(
                  padding: EdgeInsets.all(16.rp(context)),
                  child: SizedBox(
                    width: 20.rs(context),
                    height: 20.rs(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _handleSave,
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 24.ri(context),
                  ),
                  tooltip: 'Save Changes',
                )),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.rs(context)),
                    Text(
                      'Loading customer details...',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
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
                    Icon(
                      Icons.error_outline,
                      size: 64.ri(context),
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.rs(context)),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                    SizedBox(height: 16.rs(context)),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 140.rs(context)),
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
            bottom: 32.rs(context),
            left: 16.rp(context),
            right: 16.rp(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 16.rs(context),
                    top: 8.rs(context),
                  ),
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
                          width: _currentIndex == index
                              ? 24.rs(context)
                              : 8.rs(context),
                          height: 8.rs(context),
                          margin:
                              EdgeInsets.symmetric(horizontal: 4.rp(context)),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4.rr(context)),
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
                    borderRadius: BorderRadius.circular(12.rr(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10.rs(context),
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.rp(context)),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding:
                                EdgeInsets.symmetric(vertical: 16.rp(context)),
                            side: BorderSide(color: colorAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8.rr(context)),
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
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.rp(context)),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorAccent,
                                foregroundColor: colorNetral,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.rp(context)),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8.rr(context)),
                                ),
                              ),
                              child: controller.isSaving.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20.rs(context),
                                          height: 20.rs(context),
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12.rp(context)),
                                        Text(
                                          'Saving...',
                                          style: TextStyle(
                                              fontSize: 16.rt(context)),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16.rt(context),
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
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.rs(context)),
            child: Text(
              "Basic Information",
              style: TextStyle(
                fontSize: 20.rt(context),
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
              context, "Sales Office", controller.selectedSalesOffice ?? 'N/A'),
          _buildInfoRow(context, "Business Unit",
              controller.selectedBusinessUnit ?? 'N/A'),
          _buildInfoRow(
              context, "Category", controller.selectedCategory ?? 'N/A'),
          _buildInfoRow(
              context, "Segment", controller.selectedSegment ?? 'N/A'),
          _buildInfoRow(
              context, "Sub Segment", controller.selectedSubSegment ?? 'N/A'),
          _buildInfoRow(context, "Class", controller.selectedClass ?? 'N/A'),
          _buildInfoRow(context, "Company Status",
              controller.selectedCompanyStatus ?? 'N/A'),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.rt(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontSize: 16.rt(context)),
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
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.rs(context)),
            child: Text(
              "Company Address",
              style: TextStyle(
                fontSize: 20.rt(context),
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
            margin: EdgeInsets.symmetric(vertical: 16.rs(context)),
            padding: EdgeInsets.all(16.rp(context)),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.rr(context)),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Location Information",
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.getLocationFromPrefs(),
                        borderRadius: BorderRadius.circular(8.rr(context)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.rp(context),
                            vertical: 6.rp(context),
                          ),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(8.rr(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16.ri(context),
                              ),
                              SizedBox(width: 4.rp(context)),
                              Text(
                                "Update Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.rt(context),
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
                SizedBox(height: 12.rs(context)),
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
                                  size: 16.ri(context),
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 8.rp(context)),
                                Expanded(
                                  child: Text(
                                    "Longitude: ${controller.longitudeData}",
                                    style: TextStyle(
                                      fontSize: 14.rt(context),
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.rs(context)),
                            Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  size: 16.ri(context),
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 8.rp(context)),
                                Expanded(
                                  child: Text(
                                    "Latitude: ${controller.latitudeData}",
                                    style: TextStyle(
                                      fontSize: 14.rt(context),
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
                              size: 48.ri(context),
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 8.rs(context)),
                            Text(
                              "No location data available",
                              style: TextStyle(
                                fontSize: 14.rt(context),
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 8.rs(context)),
                            Text(
                              "Click 'Update Location' to get current location",
                              style: TextStyle(
                                fontSize: 12.rt(context),
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rs(context)),
            child: const Divider(
              color: Colors.black,
              height: 0,
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.rs(context)),
            child: Text(
              "Tax Address",
              style: TextStyle(
                fontSize: 20.rt(context),
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
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.rs(context)),
            child: Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 20.rt(context),
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

  Widget detailRow(BuildContext context, String title, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rs(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.rt(context),
              color: Colors.grey,
            ),
          ),
          Text(
            value ?? '',
            style: TextStyle(
              fontSize: 16.rt(context),
            ),
          ),
          Divider(height: 8.rs(context)),
        ],
      ),
    );
  }
}
