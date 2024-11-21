import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_dialog.dart';
import 'package:noo_sms/assets/widgets/customer_dropdownfield_noo.dart';
import 'package:noo_sms/assets/widgets/customer_textfield_noo.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({super.key});

  @override
  CustomerFormState createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerFormController>(builder: (controller) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              CustomDropdownField(
                label: "Sales Office",
                value: controller.selectedSalesOffice,
                validationText: "Please select a Sales Office",
                items: controller.salesOffices
                    .map((so) => {'name': so.name})
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedSalesOffice = value;
                    controller.onSalesOfficeSelected(value);
                  });
                },
              ),
              CustomDropdownField(
                label: "Business Unit",
                value: controller.selectedBusinessUnit,
                validationText: "Please select Business Unit",
                items: controller.businessUnits
                    .map((bu) => {'name': bu.name})
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedBusinessUnit = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "Category 1",
                value: controller.selectedCategory,
                validationText: "Please select Category 1",
                items: controller.category1
                    .map((cat) => {'name': cat.name})
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedCategory = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "Category 2",
                value: controller.selectedCategory2,
                validationText: "Please select Category 2",
                items: controller.category2
                    .map((cat) => {'name': cat.master})
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedCategory2 = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "AX Regional",
                value: controller.selectedAXRegional,
                validationText: "Please select a regional option",
                items: controller.axRegionals.map((item) {
                  return {'name': item.regional};
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedAXRegional = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "Distribution Channel",
                value: controller.selectedSegment,
                validationText: "Please select",
                items: controller.segment.map((item) {
                  return {'name': item.segmentId};
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedSegment = value;
                  });
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
                  setState(() {
                    controller.selectedSubSegment = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "Class",
                value: controller.selectedClass,
                validationText: "Please select class",
                items: controller.classList.map((item) {
                  return {'name': item.className};
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedClass = value;
                  });
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
                  setState(() {
                    controller.selectedCompanyStatus = value;
                  });
                },
              ),
              CustomDropdownField(
                label: "Currency",
                value: controller.selectedCurrency,
                validationText: "Please select currency",
                items: controller.currency.map((item) {
                  return {'name': item.currencyCode};
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedCurrency = value;
                  });
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
                  setState(() {
                    controller.selectedPriceGroup = value;
                  });
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
                  setState(() {
                    controller.selectedPaymentMode = value;
                  });
                },
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
              ),
              CustomTextField(
                label: "NPWP",
                controller: controller.npwpController,
                validationText: "Please enter NPWP",
                inputType: TextInputType.number,
                maxLength: 16,
              ),
              CustomTextField(
                label: "FAX",
                controller: controller.faxController,
                validationText: "Please enter Phone Number",
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
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Divider(
                    color: Colors.black,
                    height: 0,
                    thickness: 1,
                    indent: 1,
                    endIndent: 1),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    "Company Address",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
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
                label: "Kelurahan",
                controller: controller.kelurahanController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kecamatan",
                controller: controller.kecamatanController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "City",
                controller: controller.cityController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Provinsi",
                controller: controller.provinceController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Country",
                controller: controller.countryController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "ZIP Code",
                controller: controller.zipCodeController,
                inputType: TextInputType.number,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Divider(
                    color: Colors.black,
                    height: 0,
                    thickness: 1,
                    indent: 1,
                    endIndent: 1),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    "TAX Address",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              CustomTextField(
                label: "TAX Name",
                controller: controller.taxNameController,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Tax Address",
                controller: controller.taxStreetController,
                inputType: TextInputType.text,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Divider(
                    color: Colors.black,
                    height: 0,
                    thickness: 1,
                    indent: 1,
                    endIndent: 1),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
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
                label: "Kelurahan",
                controller: controller.kelurahanControllerDelivery,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kecamatan",
                controller: controller.kecamatanControllerDelivery,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kota",
                controller: controller.cityControllerDelivery,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Provinsi",
                controller: controller.provinceControllerDelivery,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Country",
                controller: controller.countryControllerDelivery,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "ZIP Code",
                controller: controller.zipCodeControllerDelivery,
                inputType: TextInputType.number,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Divider(
                    color: Colors.black,
                    height: 0,
                    thickness: 1,
                    indent: 1,
                    endIndent: 1),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    "Delivery Address 2",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              CustomTextField(
                label: "Name",
                controller: controller.deliveryNameController2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Street Name",
                controller: controller.streetCompanyControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kelurahan",
                controller: controller.kelurahanControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kecamatan",
                controller: controller.kecamatanControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Kota",
                controller: controller.cityControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Provinsi",
                controller: controller.provinceControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "Country",
                controller: controller.countryControllerDelivery2,
                inputType: TextInputType.text,
              ),
              CustomTextField(
                label: "ZIP Code",
                controller: controller.zipCodeControllerDelivery2,
                inputType: TextInputType.number,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final previewController =
                          Get.isRegistered<PreviewController>()
                              ? Get.find<PreviewController>()
                              : Get.put(PreviewController());

                      Get.dialog(
                        PreviewDialog(controller: previewController),
                      );
                    },
                    child: Text('Preview'),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
