import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/city_dropdown.dart';
import 'package:noo_sms/assets/widgets/district_dropdown.dart';
import 'package:noo_sms/assets/widgets/province_dropdown.dart';
import 'package:noo_sms/assets/widgets/customer_dropdownfield_noo.dart';
import 'package:noo_sms/assets/widgets/customer_textfield_noo.dart';
import 'package:noo_sms/assets/widgets/image_upload_card.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:signature/signature.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class BasicInfoSection extends StatelessWidget {
  final CustomerFormController controller;

  const BasicInfoSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<CustomerFormController>(
            id: 'basicInfo',
            builder: (_) => Column(
              children: [
                CustomTextField(
                  label: "Customer Name",
                  controller: controller.customerNameController,
                  validationText: "Please enter Customer Name",
                  capitalization: TextCapitalization.words,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Alias Name",
                  controller: controller.brandNameController,
                  validationText: "Please enter Alias Name",
                  capitalization: TextCapitalization.words,
                  inputType: TextInputType.text,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.rs(context)),
          GetBuilder<CustomerFormController>(
            id: 'salesOffice',
            builder: (_) => CustomDropdownField(
              label: "Sales Office",
              value: controller.selectedSalesOffice,
              validationText: "Please select a Sales Office",
              items: controller.salesOffices
                  .map((so) => {'name': so.name})
                  .toList(),
              onChanged: (value) {
                controller.selectedSalesOffice = value;
                controller.onSalesOfficeSelected(value);
                controller.update(['salesOffice', 'priceGroup']);
              },
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'customerGroup',
            builder: (_) => CustomDropdownField(
              label: "Customer Group",
              value: controller.selectedCustomerGroup,
              items: controller.customerGroups
                  .map((group) => {'name': group.name, 'value': group.value})
                  .toList(),
              onChanged: (value) {
                controller.selectedCustomerGroup = value;
                controller.update(['customerGroup']);
              },
              search: true,
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'businessUnit',
            builder: (_) => CustomDropdownField(
              label: "Business Unit",
              value: controller.selectedBusinessUnit,
              validationText: "Please select Business Unit",
              items: controller.businessUnits
                  .map((bu) => {'name': bu.name})
                  .toList(),
              onChanged: (value) {
                controller.selectedBusinessUnit = value;
                controller.update(['businessUnit', 'segment']);
              },
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'categories',
            builder: (_) => Column(
              children: [
                CustomDropdownField(
                  label: "Category 1",
                  value: controller.selectedCategory,
                  validationText: "Please select Category 1",
                  items: controller.category
                      .map((cat) => {'name': cat.name})
                      .toList(),
                  onChanged: (value) {
                    controller.selectedCategory = value;
                    controller.update(['categories']);
                  },
                ),
                CustomDropdownField(
                  label: "Category 2",
                  value: controller.selectedCategory1,
                  validationText: "Please select Category 2",
                  items: controller.category1
                      .map((cat) => {'name': cat.master})
                      .toList(),
                  onChanged: (value) {
                    controller.selectedCategory1 = value;
                    controller.update(['categories']);
                  },
                ),
              ],
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'axRegional',
            builder: (_) => CustomDropdownField(
              label: "AX Regional",
              value: controller.selectedAXRegional,
              validationText: "Please select a regional option",
              items: controller.axRegionals.map((item) {
                return {'name': item.regional};
              }).toList(),
              onChanged: (value) {
                controller.selectedAXRegional = value;
                controller.update(['axRegional']);
              },
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'segment',
            builder: (_) => Column(
              children: [
                CustomDropdownField(
                  label: "Distribution Channel",
                  value: controller.selectedSegment,
                  validationText: "Please select",
                  items: controller.segment.map((item) {
                    return {'name': item.segmentId};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedSegment = value;
                    controller.selectedSubSegment = null;
                    controller.fetchSubSegment();
                    controller.update(['segment', 'subsegment']);
                  },
                ),
                CustomDropdownField(
                  label: "Channel Segmentation",
                  value: controller.selectedSubSegment,
                  validationText: "Please select",
                  items: controller.subSegment.map((item) {
                    return {'name': item.subSegmentId};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedSubSegment = value;
                    controller.update(['subsegment']);
                  },
                ),
              ],
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'classifications',
            builder: (_) => Column(
              children: [
                CustomDropdownField(
                  label: "Class",
                  value: controller.selectedClass,
                  validationText: "Please select class",
                  items: controller.classList.map((item) {
                    return {'name': item.className};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedClass = value;
                    controller.update(['classifications']);
                  },
                ),
                CustomDropdownField(
                  label: "Company Status",
                  value: controller.selectedCompanyStatus,
                  validationText: "Please select company status",
                  items: controller.companyStatus.map((item) {
                    return {'name': item.chainId};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCompanyStatus = value;
                    controller.update(['classifications']);
                  },
                ),
              ],
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'financial',
            builder: (_) => Column(
              children: [
                CustomDropdownField(
                  label: "Currency",
                  value: controller.selectedCurrency,
                  validationText: "Please select currency",
                  items: controller.currency.map((item) {
                    return {'name': item.currencyCode};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCurrency = value;
                    controller.update(['financial']);
                  },
                ),
                CustomDropdownField(
                  label: "Price Group",
                  value: controller.selectedPriceGroup,
                  validationText: "Please select price group",
                  items: controller.priceGroup.map((item) {
                    return {'name': item.groupId};
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedPriceGroup = value;
                    controller.update(['financial']);
                  },
                ),
                CustomDropdownField(
                  label: "Payment Method",
                  value: controller.selectedPaymentMode,
                  validationText: "Please select payment method",
                  items: controller.paymentMode
                      .map((pay) => {'name': pay.paymentMode})
                      .toList(),
                  onChanged: (value) {
                    controller.selectedPaymentMode = value;
                    controller.update(['financial']);
                  },
                ),
              ],
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'contactDetails',
            builder: (_) => Column(
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyAndTaxSection extends StatefulWidget {
  final CustomerFormController controller;

  const CompanyAndTaxSection({Key? key, required this.controller})
      : super(key: key);

  @override
  State<CompanyAndTaxSection> createState() => _CompanyAndTaxSectionState();
}

class _CompanyAndTaxSectionState extends State<CompanyAndTaxSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.rp(context)),
            child: Center(
              child: Text(
                "Company Address",
                style: TextStyle(
                    fontSize: 20.rt(context),
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'companyAddress',
            builder: (_) => Column(
              children: [
                CustomTextField(
                  label: "Company Name",
                  controller: widget.controller.companyNameController,
                  inputType: TextInputType.text,
                ),
                Obx(() => CustomTextField(
                      label: "Street Name",
                      controller: widget.controller.streetCompanyController,
                      inputType: TextInputType.text,
                      readOnly: widget.controller.useKtpAddressForCompany.value,
                    )),
                CustomTextField(
                  label: "Country",
                  controller: widget.controller.countryController,
                  inputType: TextInputType.text,
                ),
                ProvinceDropdownField(
                  label: "Provinsi",
                  controller: widget.controller.provinceController,
                  formController: widget.controller,
                  cityController: widget.controller.cityController,
                  addressType: 'main',
                  search: true,
                ),
                CityDropdownField(
                  label: "City",
                  controller: widget.controller.cityController,
                  formController: widget.controller,
                  addressType: 'main',
                  search: true,
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller: widget.controller.kecamatanController,
                  formController: widget.controller,
                  addressType: 'main',
                  search: true,
                ),
                CustomTextField(
                  label: "Kelurahan",
                  controller: widget.controller.kelurahanController,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "ZIP Code",
                  controller: widget.controller.zipCodeController,
                  inputType: TextInputType.number,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.rp(context)),
                  padding: EdgeInsets.all(12.rp(context)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.rr(context)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                            value:
                                widget.controller.useKtpAddressForCompany.value,
                            activeColor: colorAccent,
                            onChanged: (bool? value) {
                              if (value == true) {
                                widget.controller.streetCompanyController.text =
                                    widget.controller.ktpAddressController.text;
                              } else {
                                widget.controller.streetCompanyController
                                    .clear();
                              }
                              widget.controller.useKtpAddressForCompany.value =
                                  value ?? false;
                            },
                          )),
                      Expanded(
                        child: Text(
                          "Use KTP Address for Company Address",
                          style: TextStyle(
                            fontSize: 14.rt(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
            child: const Divider(
                color: Colors.black,
                height: 0,
                thickness: 1,
                indent: 1,
                endIndent: 1),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.rp(context)),
            child: Center(
              child: Text(
                "TAX Address",
                style: TextStyle(
                    fontSize: 20.rt(context),
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'taxAddress',
            builder: (_) => Column(
              children: [
                Obx(() => CustomTextField(
                      label: "NPWP",
                      controller: widget.controller.npwpController,
                      validationText: "Please enter NPWP",
                      inputType: TextInputType.number,
                      maxLength: 16,
                      readOnly: widget.controller.useKtpAddressForTax.value,
                    )),

                Obx(() => CustomTextField(
                      label: "TAX Name",
                      controller: widget.controller.taxNameController,
                      inputType: TextInputType.text,
                      readOnly: widget.controller.useKtpAddressForTax.value,
                    )),

                Obx(() => CustomTextField(
                      label: "Tax Address",
                      controller: widget.controller.taxStreetController,
                      inputType: TextInputType.text,
                      readOnly: widget.controller.useKtpAddressForTax.value,
                    )),
                CustomTextField(
                  label: "Country",
                  controller: widget.controller.countryTaxController,
                  inputType: TextInputType.text,
                ),
                ProvinceDropdownField(
                  label: "Provinsi",
                  controller: widget.controller.provinceTaxController,
                  formController: widget.controller,
                  cityController: widget.controller.cityTaxController,
                  addressType: 'tax',
                  search: true,
                ),
                CityDropdownField(
                  label: "City",
                  controller: widget.controller.cityTaxController,
                  formController: widget.controller,
                  addressType: 'tax',
                  search: true,
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller: widget.controller.kecamatanTaxController,
                  formController: widget.controller,
                  addressType: 'tax',
                  search: true,
                ),

                CustomTextField(
                  label: "Kelurahan",
                  controller: widget.controller.kelurahanTaxController,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "ZIP Code",
                  controller: widget.controller.zipCodeTaxController,
                  inputType: TextInputType.number,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.rp(context)),
                  padding: EdgeInsets.all(12.rp(context)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.rr(context)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                            value: widget.controller.useKtpAddressForTax.value,
                            activeColor: colorAccent,
                            onChanged: (bool? value) {
                              if (value == true) {
                                widget.controller.useCompanyAddressForTax
                                    .value = false;

                                widget.controller.taxNameController.text =
                                    widget.controller.contactPersonController
                                        .text;
                                widget.controller.taxStreetController.text =
                                    widget.controller.ktpAddressController.text;
                                widget.controller.npwpController.text =
                                    widget.controller.ktpController.text;
                              } else {
                                // Clear tax fields when unchecked (optional)
                                // controller.taxNameController.clear();
                                // controller.taxStreetController.clear();
                                // controller.npwpController.clear();
                              }
                              widget.controller.useKtpAddressForTax.value =
                                  value ?? false;
                            },
                          )),
                      Text(
                        "Use KTP Data for Tax Data",
                        style: TextStyle(
                          fontSize: 14.rt(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Row(
                //   children: [
                //     Obx(() => Checkbox(
                //           value: controller.useCompanyAddressForTax.value,
                //           activeColor: colorAccent,
                //           onChanged: (bool? value) {
                //             if (value == true) {
                //               controller.useKtpAddressForTax.value = false;
                //               controller.copyCompanyAddressToTax();
                //             }
                //             controller.useCompanyAddressForTax.value =
                //                 value ?? false;
                //             controller.update(['taxAddress']);
                //           },
                //         )),
                //     Expanded(
                //       child: Text(
                //         "Use Company Address for Tax Data",
                //         style: TextStyle(fontSize: 14.rt(context)),
                //       ),
                //     ),
                //   ],
                // ),

                // Optional: Add a button to manually unlock fields if needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryAddressSection extends StatefulWidget {
  final CustomerFormController controller;

  const DeliveryAddressSection({Key? key, required this.controller})
      : super(key: key);

  @override
  State<DeliveryAddressSection> createState() => _DeliveryAddressSectionState();
}

class _DeliveryAddressSectionState extends State<DeliveryAddressSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.rp(context)),
            child: Center(
              child: Text(
                "Delivery Address",
                style: TextStyle(
                    fontSize: 20.rt(context),
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'deliveryAddress',
            builder: (_) => Column(
              children: [
                CustomTextField(
                  label: "Name",
                  controller: widget.controller.deliveryNameController,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Street Name",
                  controller: widget.controller.streetCompanyControllerDelivery,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Country",
                  controller: widget.controller.countryControllerDelivery,
                  inputType: TextInputType.text,
                ),
                ProvinceDropdownField(
                  label: "Provinsi",
                  controller: widget.controller.provinceControllerDelivery,
                  formController: widget.controller,
                  cityController: widget.controller.cityControllerDelivery,
                  addressType: 'delivery',
                  search: true,
                ),
                CityDropdownField(
                  label: "Kota",
                  controller: widget.controller.cityControllerDelivery,
                  formController: widget.controller,
                  addressType: 'delivery',
                  search: true,
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller:
                      widget.controller.kecamatanControllerDelivery.value,
                  formController: widget.controller,
                  addressType: 'delivery',
                  search: true,
                ),
                CustomTextField(
                  label: "Kelurahan",
                  controller: widget.controller.kelurahanControllerDelivery,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "ZIP Code",
                  controller: widget.controller.zipCodeControllerDelivery,
                  inputType: TextInputType.number,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.rp(context)),
                  padding: EdgeInsets.all(12.rp(context)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.rr(context)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                            value: widget
                                .controller.useCompanyAddressForDelivery.value,
                            activeColor: colorAccent,
                            onChanged: (bool? value) {
                              setState(() {
                                widget.controller.useCompanyAddressForDelivery
                                    .value = value ?? false;
                                if (value == true) {
                                  widget.controller
                                      .copyCompanyAddressToDelivery();
                                }
                              });
                            },
                          )),
                      Expanded(
                        child: Text(
                          "Use Company Address Data",
                          style: TextStyle(fontSize: 14.rt(context)),
                        ),
                      ),
                    ],
                  ),
                ),
                LocationInfoCard(controller: widget.controller),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
            child: const Divider(
                color: Colors.black,
                height: 0,
                thickness: 1,
                indent: 1,
                endIndent: 1),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.rp(context)),
            child: Center(
              child: Text(
                "Delivery Address 2",
                style: TextStyle(
                    fontSize: 20.rt(context),
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GetBuilder<CustomerFormController>(
            id: 'deliveryAddress2',
            builder: (_) => Column(
              children: [
                CustomTextField(
                  label: "Name",
                  controller: widget.controller.deliveryNameController2,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Street Name",
                  controller:
                      widget.controller.streetCompanyControllerDelivery2,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Country",
                  controller: widget.controller.countryControllerDelivery2,
                  inputType: TextInputType.text,
                ),
                ProvinceDropdownField(
                  label: "Provinsi",
                  controller: widget.controller.provinceControllerDelivery2,
                  formController: widget.controller,
                  addressType: 'delivery2',
                  search: true,
                ),
                CityDropdownField(
                  label: "Kota",
                  controller: widget.controller.cityControllerDelivery2,
                  formController: widget.controller,
                  addressType: 'delivery2',
                  search: true,
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller:
                      widget.controller.kecamatanControllerDelivery2.value,
                  formController: widget.controller,
                  addressType: 'delivery2',
                  search: true,
                ),
                CustomTextField(
                  label: "Kelurahan",
                  controller: widget.controller.kelurahanControllerDelivery2,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "ZIP Code",
                  controller: widget.controller.zipCodeControllerDelivery2,
                  inputType: TextInputType.number,
                ),
                // Row(
                //   children: [
                //     Obx(() => Checkbox(
                //           value: widget
                //               .controller.useCompanyAddressForDelivery2.value,
                //           activeColor: colorAccent,
                //           onChanged: (bool? value) {
                //             widget.controller.useCompanyAddressForDelivery2
                //                 .value = value ?? false;
                //             if (value == true) {
                //               widget.controller.copyCompanyAddressToDelivery2();
                //             }
                //           },
                //         )),
                //     Expanded(
                //       child: Text(
                //         "Use Company Address Data",
                //         style: TextStyle(fontSize: 14.rt(context)),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentsSection extends StatelessWidget {
  final CustomerFormController controller;

  const DocumentsSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.rp(context)),
            child: Center(
              child: Text(
                "Documents",
                style: TextStyle(
                    fontSize: 20.rt(context),
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DocumentsGallery(controller: controller),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
            child: const Divider(
                color: Colors.black,
                height: 0,
                thickness: 1,
                indent: 1,
                endIndent: 1),
          ),
          SignatureSection(controller: controller),
        ],
      ),
    );
  }
}

class LocationInfoCard extends StatefulWidget {
  final CustomerFormController controller;
  const LocationInfoCard({Key? key, required this.controller})
      : super(key: key);

  @override
  State<LocationInfoCard> createState() => _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard> {
  bool _isFront = true;
  bool _isEditing = false;
  bool _isUpdatingAddress = false;
  bool _isGettingLocation = false;

  late TextEditingController _longitudeController;
  late TextEditingController _latitudeController;

  final FocusNode _longitudeFocus = FocusNode();
  final FocusNode _latitudeFocus = FocusNode();
  static const Color successColor = Color(0xFF4CAF50);

  static const Color errorColor = Color(0xFFF44336);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();

    _longitudeController =
        TextEditingController(text: widget.controller.longitudeData.toString());
    _latitudeController =
        TextEditingController(text: widget.controller.latitudeData.toString());
  }

  @override
  void dispose() {
    _longitudeController.dispose();
    _latitudeController.dispose();
    _longitudeFocus.dispose();
    _latitudeFocus.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        return addressParts.join(', ');
      } else {
        return 'Address not found for these coordinates';
      }
    } catch (e) {
      return 'Unable to retrieve address';
    }
  }

  void _saveChanges() async {
    try {
      double longitude = double.parse(_longitudeController.text);
      if (longitude < -180 || longitude > 180) {
        _showErrorSnackbar('Longitude must be between -180 and 180');
        return;
      }

      double latitude = double.parse(_latitudeController.text);
      if (latitude < -90 || latitude > 90) {
        _showErrorSnackbar('Latitude must be between -90 and 90');
        return;
      }

      widget.controller.longitudeData = longitude.toString();
      widget.controller.latitudeData = latitude.toString();

      setState(() {
        _isUpdatingAddress = true;
      });

      String newAddress = await _getAddressFromCoordinates(latitude, longitude);

      widget.controller.addressDetail = newAddress;

      setState(() {
        _isUpdatingAddress = false;
      });

      _showSuccessSnackbar(
          'Location coordinates and address updated successfully');

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isFront = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isUpdatingAddress = false;
      });

      _showErrorSnackbar(
          'Invalid coordinate format. Please enter valid numbers.');
      _longitudeController.text = widget.controller.longitudeData.toString();
      _latitudeController.text = widget.controller.latitudeData.toString();
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _getCurrentGPSLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackbar(
            'Please enable location services in your device settings');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackbar(
              'Location permission denied. Please grant location access.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackbar(
            'Location permission permanently denied. Please enable in app settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _longitudeController.text = position.longitude.toStringAsFixed(6);
      _latitudeController.text = position.latitude.toStringAsFixed(6);

      _showSuccessSnackbar(
          'GPS coordinates loaded. Click Save to confirm or continue editing.');
    } catch (e) {
      if (e is TimeoutException || e.toString().contains('timeout')) {
        _showErrorSnackbar(
            'GPS timeout. Please try again or check if you\'re in an open area.');
      } else {
        _showErrorSnackbar('Failed to get GPS location: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;

      _longitudeController.text = widget.controller.longitudeData.toString();
      _latitudeController.text = widget.controller.latitudeData.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.rr(context)),
      ),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Location",
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to view details",
                      style: TextStyle(
                        fontSize: 12.rt(context),
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap:
                      (_isEditing || _isUpdatingAddress || _isGettingLocation)
                          ? null
                          : () {
                              setState(() {
                                _isFront = !_isFront;
                              });
                            },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12.rr(context)),
                      border: Border.all(
                        color: _isEditing ? colorAccent : borderColor,
                        width: _isEditing ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    width: ResponsiveUtil.isIPad(context)
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: _isFront ? _buildFront() : _buildBack(),
                  ),
                ),
              ),
            ],
          ),
          if (_isFront) _buildEditControls(),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Padding(
      padding: EdgeInsets.all(12.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: colorAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                "Coordinates",
                style: TextStyle(
                  fontSize: 12.rt(context),
                  fontWeight: FontWeight.w600,
                  color: colorAccent,
                ),
              ),
              if (_isGettingLocation) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_isGettingLocation) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Getting current location...",
                      style: TextStyle(
                        fontSize: 10.rt(context),
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _buildCoordinateField(
              label: "Longitude",
              controller: _longitudeController,
              focusNode: _longitudeFocus,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_latitudeFocus),
              value: widget.controller.longitudeData.toString(),
            ),
            const SizedBox(height: 6),
            _buildCoordinateField(
              label: "Latitude",
              controller: _latitudeController,
              focusNode: _latitudeFocus,
              onSubmitted: (_) => _toggleEditMode(),
              value: widget.controller.latitudeData.toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoordinateField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onSubmitted,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: 11.rt(context),
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: _isEditing
              ? SizedBox(
                  height: 28,
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    style: TextStyle(
                      fontSize: 11.rt(context),
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: colorAccent, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textInputAction: label == "Latitude"
                        ? TextInputAction.done
                        : TextInputAction.next,
                    onFieldSubmitted: onSubmitted,
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 11.rt(context),
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Container(
      padding: EdgeInsets.all(12.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, color: colorAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                "Address",
                style: TextStyle(
                  fontSize: 12.rt(context),
                  fontWeight: FontWeight.w600,
                  color: colorAccent,
                ),
              ),
              if (_isUpdatingAddress) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isUpdatingAddress
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(colorAccent),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Updating address...",
                          style: TextStyle(
                            fontSize: 10.rt(context),
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    widget.controller.addressDetail,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.rt(context),
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditControls() {
    return Container(
      margin: EdgeInsets.only(top: 16.rp(context)),
      padding: EdgeInsets.all(12.rp(context)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.rr(context)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Location Controls",
            style: TextStyle(
              fontSize: 13.rt(context),
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (!_isEditing) ...[
            _buildModernButton(
              onPressed: _toggleEditMode,
              icon: Icons.edit_location,
              label: 'Edit Coordinates',
              color: colorAccent,
              isFullWidth: true,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildModernButton(
                    onPressed: (_isUpdatingAddress || _isGettingLocation)
                        ? null
                        : _toggleEditMode,
                    icon: (_isUpdatingAddress || _isGettingLocation)
                        ? Icons.hourglass_empty
                        : Icons.save,
                    label: (_isUpdatingAddress || _isGettingLocation)
                        ? 'Saving...'
                        : 'Save',
                    color: (_isUpdatingAddress || _isGettingLocation)
                        ? Colors.grey
                        : successColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildModernButton(
                    onPressed: (_isUpdatingAddress || _isGettingLocation)
                        ? null
                        : _cancelEdit,
                    icon: Icons.close,
                    label: 'Cancel',
                    color: (_isUpdatingAddress || _isGettingLocation)
                        ? Colors.grey
                        : errorColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildModernButton(
                    onPressed: (_isUpdatingAddress || _isGettingLocation)
                        ? null
                        : _getCurrentGPSLocation,
                    icon: _isGettingLocation
                        ? Icons.gps_fixed
                        : Icons.my_location,
                    label: _isGettingLocation ? 'Getting GPS...' : 'Use GPS',
                    color: (_isUpdatingAddress || _isGettingLocation)
                        ? Colors.grey
                        : const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.rt(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DocumentsGallery extends StatelessWidget {
  final CustomerFormController controller;

  const DocumentsGallery({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtil.isIPad(context)
          ? MediaQuery.of(context).size.height * 0.5
          : MediaQuery.of(context).size.height * 0.4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.rp(context)),
        children: [
          Obx(
            () => ImageUploadCard(
              title: 'KTP',
              image: controller.imageKTP,
              webImage: controller.imageKTPWeb,
              imageUrl: controller.ktpImageUrl,
              onCameraPress: controller.getImageKTPFromCamera,
              onGalleryPress: controller.getImageKTPFromGallery,
              heroTagCamera: 'ktpCamera',
              heroTagGallery: 'ktpGallery',
            ),
          ),
          SizedBox(width: 8.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'NPWP',
                image: controller.imageNPWP,
                imageUrl: controller.npwpImageUrl,
                onCameraPress: controller.getImageNPWPFromCamera,
                onGalleryPress: controller.getImageNPWPFromGallery,
                heroTagCamera: 'npwpCamera',
                heroTagGallery: 'npwpGallery',
              )),
          SizedBox(width: 5.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'NIB',
                image: controller.imageSIUP,
                imageUrl: controller.siupImageUrl,
                onCameraPress: controller.getImageSIUPFromCamera,
                onGalleryPress: controller.getImageSIUPFromGallery,
                heroTagCamera: 'siupCamera',
                heroTagGallery: 'siupGallery',
              )),
          SizedBox(width: 5.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'SPPKP',
                image: controller.imageSPPKP,
                imageUrl: controller.sppkpImageUrl,
                onCameraPress: controller.getImageSPPKPFromCamera,
                onGalleryPress: controller.getImageSPPKPFromGallery,
                heroTagCamera: 'sppkpCamera',
                heroTagGallery: 'sppkpGallery',
              )),
          SizedBox(width: 5.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'Front View',
                image: controller.imageBusinessPhotoFront,
                imageUrl: controller.frontImageUrl,
                onCameraPress: controller.getImageBusinessPhotoFrontFromCamera,
                onGalleryPress:
                    controller.getImageBusinessPhotoFrontFromGallery,
                heroTagCamera: 'frontCamera',
                heroTagGallery: 'frontGallery',
              )),
          SizedBox(width: 5.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'Inside View',
                image: controller.imageBusinessPhotoInside,
                imageUrl: controller.insideImageUrl,
                onCameraPress: controller.getImageBusinessPhotoInsideFromCamera,
                onGalleryPress:
                    controller.getImageBusinessPhotoInsideFromGallery,
                heroTagCamera: 'insideCamera',
                heroTagGallery: 'insideGallery',
              )),
          SizedBox(width: 5.rs(context)),
          Obx(() => ImageUploadCard(
                title: 'Competitor TOP (Optional)',
                image: controller.imageCompetitorTop,
                imageUrl: controller.competitorImageUrl,
                onCameraPress: controller.getImageCompetitorTopFromCamera,
                onGalleryPress: controller.getImageCompetitorTopFromGallery,
                heroTagCamera: 'competitorCamera',
                heroTagGallery: 'competitorGallery',
              )),
        ],
      ),
    );
  }
}

class SignatureSection extends StatelessWidget {
  final CustomerFormController controller;

  const SignatureSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
          child: Center(
            child: Text(
              "Signature Form",
              style: TextStyle(
                  fontSize: 20.rt(context),
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Center(
          child: Text(
            'Sales',
            style: TextStyle(
              fontSize: 16.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.rp(context)),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.rr(context)),
          ),
          child: Signature(
            controller: controller.signatureSalesController,
            height: ResponsiveUtil.isIPad(context)
                ? MediaQuery.of(context).size.height * 0.35
                : MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            backgroundColor: Colors.grey[200]!,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.rp(context)),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.rp(context),
                  vertical: 12.rp(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.rr(context)),
                ),
              ),
              onPressed: controller.signatureSalesController.clear,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: colorNetral,
                  fontSize: 14.rt(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            'Customer',
            style: TextStyle(
              fontSize: 16.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.rp(context)),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.rr(context)),
          ),
          child: Signature(
            controller: controller.signatureCustomerController,
            height: ResponsiveUtil.isIPad(context)
                ? MediaQuery.of(context).size.height * 0.35
                : MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            backgroundColor: Colors.grey[200]!,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.rp(context)),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.rp(context),
                  vertical: 12.rp(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.rr(context)),
                ),
              ),
              onPressed: controller.signatureCustomerController.clear,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: colorNetral,
                  fontSize: 14.rt(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormActionButtons extends StatelessWidget {
  final CustomerFormController controller;
  final VoidCallback onSubmit;
  final VoidCallback onPreview;

  const FormActionButtons({
    Key? key,
    required this.controller,
    required this.onSubmit,
    required this.onPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final additionalPadding = bottomPadding > 0 ? bottomPadding : 16.0;

    return Container(
      color: colorNetral,
      child: Padding(
        padding: EdgeInsets.only(
          right: 16.rp(context),
          left: 16.rp(context),
          top: 16.rp(context),
          bottom: 16.rp(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8.rp(context)),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
                    side: BorderSide(
                      color: colorAccent,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.rr(context)),
                    ),
                  ),
                  onPressed: _handlePreviewOrUpdate,
                  child: Obx(() => Text(
                        controller.isEditMode.value ? 'Update' : 'Preview',
                        style: TextStyle(
                          color: colorAccent,
                          fontSize: 16.rt(context),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.rp(context)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: colorNetral,
                    padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
                    elevation: 4.rs(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.rr(context)),
                    ),
                  ),
                  onPressed: _handleSubmit,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16.rt(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePreviewOrUpdate() async {
    if (controller.isEditMode.value) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.rr(Get.context!)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.rp(Get.context!)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorAccent),
                    SizedBox(height: 16.rs(Get.context!)),
                    Text(
                      'Updating customer...',
                      style: TextStyle(fontSize: 14.rt(Get.context!)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final success = await controller.updateCustomer();

      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Customer updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.back(result: true);
      }
    } else {
      onPreview();
    }
  }

  void _handleSubmit() {
    if (controller.validateRequiredDocuments()) {
      onSubmit();
    }
  }
}
