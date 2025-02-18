import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_controller.dart';
import 'package:noo_sms/assets/constant/preview_cust_form/preview_dialog.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/customer_dropdownfield_noo.dart';
import 'package:noo_sms/assets/widgets/customer_textfield_noo.dart';
import 'package:noo_sms/assets/widgets/image_upload_card.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/controllers/noo/draft_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';
import 'package:noo_sms/view/noo/draft/draft_page.dart';
import 'package:signature/signature.dart';

class CustomerForm extends StatefulWidget {
  final NOOModel? editData;
  final bool isFromDraft;
  final CustomerFormController controller;

  const CustomerForm({
    Key? key,
    this.editData,
    this.isFromDraft = false,
    required this.controller,
  }) : super(key: key);

  @override
  CustomerFormState createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm> {
  late CustomerFormController controller;
  bool _showButtons = false;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CustomerFormController>()
        ? Get.find<CustomerFormController>()
        : Get.put(CustomerFormController());

    controller.requestPermissions();
    if (widget.editData != null) {
      controller.isEditMode.value = true;
    }
  }

  @override
  void dispose() {
    controller.clearForm();
    controller.isEditMode.value = false;
    Get.delete<CustomerFormController>();
    super.dispose();
  }

  void handleBack() {
    controller.clearForm();
    controller.isEditMode.value = false;
    Navigator.pop(context);
  }

  Widget _buildFront() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Longitude: ${controller.longitudeData}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Latitude: ${controller.latitudeData}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        controller.addressDetail,
        maxLines: 3,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerFormController>(builder: (controller) {
      return Scaffold(
        backgroundColor: colorNetral,
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isFromDraft || widget.editData != null)
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                          size: 35,
                        ),
                        onPressed: handleBack,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        widget.isFromDraft
                            ? 'Edit Draft'
                            : controller.isEditMode.value
                                ? 'Edit Customer'
                                : 'New Customer',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                      controller.update();
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
                      controller.update();
                    });
                  },
                ),
                CustomDropdownField(
                  label: "Category 1",
                  value: controller.selectedCategory,
                  validationText: "Please select Category 1",
                  items: controller.category
                      .map((cat) => {'name': cat.name})
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      controller.selectedCategory = value;
                      controller.update();
                    });
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
                    setState(() {
                      controller.selectedCategory1 = value;
                      controller.update();
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
                      controller.update();
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
                      controller.selectedSubSegment = null;
                      controller.fetchSubSegment();
                      controller.update();
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
                      controller.update();
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
                      controller.update();
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
                      controller.update();
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
                      controller.update();
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
                      controller.update();
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
                      controller.update();
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
                  maxLength: 100,
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
                          fontWeight: FontWeight.bold),
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
                          fontWeight: FontWeight.bold),
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
                  label: "TAX Name",
                  controller: controller.taxNameController,
                  inputType: TextInputType.text,
                ),
                CustomTextField(
                  label: "Tax Address",
                  controller: controller.taxStreetController,
                  inputType: TextInputType.text,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.useKtpAddressForTax.value,
                            onChanged: (bool? value) {
                              controller.useKtpAddressForTax.value =
                                  value ?? false;
                              if (value == true) {
                                controller.taxNameController.text =
                                    controller.customerNameController.text;
                                controller.taxStreetController.text =
                                    controller.ktpAddressController.text;
                              }
                            },
                          )),
                      const Text("Use KTP Address for Tax Address"),
                    ],
                  ),
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
                          fontWeight: FontWeight.bold),
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
                          fontWeight: FontWeight.bold),
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
                  children: <Widget>[
                    const Text(
                      "Your Current\nLocation               :   ",
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFront = !_isFront;
                        });
                      },
                      child: Container(
                        // padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: _isFront ? _buildFront() : _buildBack(),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
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
                      "Documents",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Obx(() => ImageUploadCard(
                            title: 'KTP',
                            image: controller.imageKTP,
                            webImage: controller.imageKTPWeb,
                            imageUrl: controller.ktpImageUrl,
                            onCameraPress: controller.getImageKTPFromCamera,
                            onGalleryPress: controller.getImageKTPFromGallery,
                            heroTagCamera: 'ktpCamera',
                            heroTagGallery: 'ktpGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'NPWP',
                            image: controller.imageNPWP,
                            imageUrl: controller.npwpImageUrl,
                            onCameraPress: controller.getImageNPWPFromCamera,
                            onGalleryPress: controller.getImageNPWPFromGallery,
                            heroTagCamera: 'npwpCamera',
                            heroTagGallery: 'npwpGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'NIB',
                            image: controller.imageSIUP,
                            imageUrl: controller.siupImageUrl,
                            onCameraPress: controller.getImageSIUPFromCamera,
                            onGalleryPress: controller.getImageSIUPFromGallery,
                            heroTagCamera: 'siupCamera',
                            heroTagGallery: 'siupGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'SPPKP',
                            image: controller.imageSPPKP,
                            imageUrl: controller.sppkpImageUrl,
                            onCameraPress: controller.getImageSPPKP,
                            onGalleryPress: controller.getImageSPPKPFromGallery,
                            heroTagCamera: 'sppkpCamera',
                            heroTagGallery: 'sppkpGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'Front View',
                            image: controller.imageBusinessPhotoFront,
                            imageUrl: controller.frontImageUrl,
                            onCameraPress:
                                controller.getImageBusinessPhotoFrontFromCamera,
                            onGalleryPress: controller
                                .getImageBusinessPhotoFrontFromGallery,
                            heroTagCamera: 'frontCamera',
                            heroTagGallery: 'frontGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'Inside View',
                            image: controller.imageBusinessPhotoInside,
                            imageUrl: controller.insideImageUrl,
                            onCameraPress: controller
                                .getImageBusinessPhotoInsideFromCamera,
                            onGalleryPress: controller
                                .getImageBusinessPhotoInsideFromGallery,
                            heroTagCamera: 'insideCamera',
                            heroTagGallery: 'insideGallery',
                          )),
                      const SizedBox(width: 5),
                      Obx(() => ImageUploadCard(
                            title: 'Competitor TOP (Optional)',
                            image: controller.imageCompetitorTop,
                            imageUrl: controller.competitorImageUrl,
                            onCameraPress:
                                controller.getImageCompetitorTopFromCamera,
                            onGalleryPress:
                                controller.getImageCompetitorTopFromGallery,
                            heroTagCamera: 'competitorCamera',
                            heroTagGallery: 'competitorGallery',
                          )),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                      color: Colors.black,
                      height: 0,
                      thickness: 1,
                      indent: 1,
                      endIndent: 1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      "Signature Form",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Sales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Signature(
                  controller: controller.signatureSalesController,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  backgroundColor: Colors.grey[200]!,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed: controller.signatureSalesController.clear,
                      child: Text(
                        'Clear',
                        style: TextStyle(color: colorNetral),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Signature(
                  controller: controller.signatureCustomerController,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  backgroundColor: Colors.grey[200]!,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed: controller.signatureCustomerController.clear,
                      child: Text(
                        'Clear',
                        style: TextStyle(color: colorNetral),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          if (controller.isEditMode.value) {
                            final success = await controller.updateCustomer();
                            if (success) {
                              Get.back(result: true);
                            }
                          } else {
                            final previewController =
                                Get.isRegistered<PreviewController>()
                                    ? Get.find<PreviewController>()
                                    : Get.put(PreviewController());
                            Get.dialog(
                                PreviewDialog(controller: previewController));
                          }
                        },
                        child: Text(
                          controller.isEditMode.value ? 'Update' : 'Preview',
                          style: TextStyle(
                            color: colorAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccent,
                        ),
                        onPressed: () async {
                          controller.handleSubmit();
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: colorNetral,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 60,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: colorAccent,
                onPressed: () {
                  setState(() {
                    _showButtons = !_showButtons;
                  });
                },
                child: Icon(
                  _showButtons ? Icons.close : Icons.menu,
                  color: colorNetral,
                ),
              ),
            ),
            if (_showButtons)
              Positioned(
                bottom: 120,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _showButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final draftController =
                              Get.isRegistered<DraftController>()
                                  ? Get.find<DraftController>()
                                  : Get.put(DraftController());

                          await draftController.saveDraft(controller);
                          controller.clearForm();
                          Get.to(() => const DraftPage());
                        },
                        child: Text(
                          'Save Draft',
                          style: TextStyle(
                            color: colorAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!widget.isFromDraft)
                        OutlinedButton(
                          onPressed: () async {
                            Get.isRegistered<DraftController>()
                                ? Get.find<DraftController>()
                                : Get.put(DraftController());
                            Get.to(() => const DraftPage());
                          },
                          child: Text(
                            'Draft List',
                            style: TextStyle(
                              color: colorAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
