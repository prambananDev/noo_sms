import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'preview_controller.dart';

class PreviewEditDialog extends StatelessWidget {
  final PreviewEditController controller;

  const PreviewEditDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      child: GetBuilder<PreviewEditController>(
        init: controller,
        builder: (controller) {
          return SizedBox(
            child: AlertDialog(
              insetPadding: const EdgeInsets.all(16),
              contentPadding: const EdgeInsets.all(4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide.none,
              ),
              title: Center(
                child: Text(
                  'Preview Details',
                  style: TextStyle(
                    color: colorAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Form Details",
                      style: TextStyle(
                        fontSize: 24,
                        color: colorAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildRow("Customer Name",
                        controller.customerNameController.text),
                    buildRow("Alias Name", controller.brandNameController.text),
                    buildRow("Contact Person",
                        controller.contactPersonController.text),
                    buildRow("KTP", controller.ktpController.text),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "KTP Address",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            controller.ktpAddressController.text.isNotEmpty ==
                                    true
                                ? controller.ktpAddressController.text
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    buildRow("NPWP", controller.npwpController.text),
                    buildRow("Phone", controller.phoneController.text),
                    buildRow("FAX", controller.faxController.text),
                    buildRow("Email Address",
                        controller.emailAddressController.text),
                    buildRow("Website", controller.websiteController.text),
                    buildRow("Sales Office", controller.selectedSalesOffice),
                    buildRow("Business Unit", controller.selectedBusinessUnit),
                    buildRow("Category 1", controller.selectedCategory),
                    buildRow("Category 2", controller.selectedCategory1),
                    buildRow("AX Regional", controller.selectedAXRegional),
                    buildRow("Payment Mode", controller.selectedPaymentMode),
                    buildRow("Segment", controller.selectedSegment),
                    buildRow("Sub Segment", controller.selectedSubSegment),
                    buildRow("Class", controller.selectedClass),
                    buildRow(
                        "Company Status", controller.selectedCompanyStatus),
                    buildRow("Currency", controller.selectedCurrency),
                    buildRow("Price Group", controller.selectedPriceGroup),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Company Details",
                        style: TextStyle(
                          fontSize: 24,
                          color: colorAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildRow(
                        "Company Name", controller.companyNameController.text),
                    buildRow("Street", controller.streetCompanyController.text),
                    buildRow("Kelurahan", controller.kelurahanController.text),
                    buildRow("Kecamatan", controller.kecamatanController.text),
                    buildRow("City", controller.cityController.text),
                    buildRow("Province", controller.provinceController.text),
                    buildRow("Country", controller.countryController.text),
                    buildRow("Zip Code", controller.zipCodeController.text),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "TAX Details",
                        style: TextStyle(
                          fontSize: 24,
                          color: colorAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildRow("Tax Name", controller.taxNameController.text),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tax Street",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            controller.taxStreetController.text.isNotEmpty ==
                                    true
                                ? controller.taxStreetController.text
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Delivery Details",
                        style: TextStyle(
                          fontSize: 24,
                          color: colorAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildRow("Delivery Name",
                        controller.deliveryNameController.text),
                    buildRow("Street",
                        controller.streetCompanyControllerDelivery.text),
                    buildRow("Kelurahan",
                        controller.kelurahanControllerDelivery.text),
                    buildRow("Kecamatan",
                        controller.kecamatanControllerDelivery.text),
                    buildRow("City", controller.cityControllerDelivery.text),
                    buildRow(
                        "Province", controller.provinceControllerDelivery.text),
                    buildRow(
                        "Country", controller.countryControllerDelivery.text),
                    buildRow(
                        "Zip Code", controller.zipCodeControllerDelivery.text),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: colorAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value?.isNotEmpty == true ? value! : 'N/A',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
