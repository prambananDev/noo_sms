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

class BasicInfoSection extends StatelessWidget {
  final CustomerFormController controller;

  const BasicInfoSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
                  label: "Brand Name",
                  controller: controller.brandNameController,
                  validationText: "Please enter Brand Name",
                  capitalization: TextCapitalization.words,
                  inputType: TextInputType.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
              validationText: "Please select a Customer Group",
              items: controller.customerGroups
                  .map((group) => {'name': group.name})
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

class CompanyAndTaxSection extends StatelessWidget {
  final CustomerFormController controller;

  const CompanyAndTaxSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          GetBuilder<CustomerFormController>(
            id: 'companyAddress',
            builder: (_) => Column(
              children: [
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
                ProvinceDropdownField(
                  label: "Provinsi",
                  controller: controller.provinceController,
                  formController: controller,
                  cityController: controller.cityController,
                  addressType: 'main',
                ),
                CityDropdownField(
                  label: "City",
                  controller: controller.cityController,
                  formController: controller,
                  addressType: 'main',
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller: controller.kecamatanController,
                  formController: controller,
                  addressType: 'main',
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
          GetBuilder<CustomerFormController>(
            id: 'taxAddress',
            builder: (_) => Column(
              children: [
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
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.useKtpAddressForTax.value,
                          activeColor: colorAccent,
                          onChanged: (bool? value) {
                            if (value == true) {
                              controller.useCompanyAddressForTax.value = false;
                              controller.taxNameController.text =
                                  controller.contactPersonController.text;
                              controller.taxStreetController.text =
                                  controller.ktpAddressController.text;
                              controller.npwpController.text =
                                  controller.ktpController.text;
                            }
                            controller.useKtpAddressForTax.value =
                                value ?? false;
                            controller.ktpAddressController.text;
                          },
                        )),
                    const Text("Use KTP Data for Tax Data"),
                  ],
                ),
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.useCompanyAddressForTax.value,
                          activeColor: colorAccent,
                          onChanged: (bool? value) {
                            if (value == true) {
                              controller.useKtpAddressForTax.value = false;
                              controller.copyCompanyAddressToTax();
                            }
                            controller.useCompanyAddressForTax.value =
                                value ?? false;
                            controller.update(['taxAddress']);
                          },
                        )),
                    const Text("Use Company Address for Tax Data"),
                  ],
                ),
              ],
            ),
          ),
          LocationInfoCard(controller: controller),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                ),
                CityDropdownField(
                  label: "Kota",
                  controller: widget.controller.cityControllerDelivery,
                  formController: widget.controller,
                  addressType: 'delivery',
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller:
                      widget.controller.kecamatanControllerDelivery.value,
                  formController: widget.controller,
                  addressType: 'delivery',
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
                Row(
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
                    const Text("Use Company Address Data"),
                  ],
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
                ),
                CityDropdownField(
                  label: "Kota",
                  controller: widget.controller.cityControllerDelivery2,
                  formController: widget.controller,
                  addressType: 'delivery2',
                ),
                DistrictDropdownField(
                  label: "Kecamatan",
                  controller:
                      widget.controller.kecamatanControllerDelivery2.value,
                  formController: widget.controller,
                  addressType: 'delivery2',
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
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: widget
                              .controller.useCompanyAddressForDelivery2.value,
                          activeColor: colorAccent,
                          onChanged: (bool? value) {
                            widget.controller.useCompanyAddressForDelivery2
                                .value = value ?? false;
                            if (value == true) {
                              widget.controller.copyCompanyAddressToDelivery2();
                            }
                          },
                        )),
                    const Text("Use Company Address Data"),
                  ],
                ),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          DocumentsGallery(controller: controller),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            const Text(
              "Your Current\nLocation               :   ",
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFront = !_isFront;
                });
              },
              child: Container(
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
      ],
    );
  }

  Widget _buildFront() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Longitude: ${widget.controller.longitudeData}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Latitude: ${widget.controller.latitudeData}",
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
        widget.controller.addressDetail,
        maxLines: 3,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
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
          const SizedBox(width: 8),
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
                onCameraPress: controller.getImageBusinessPhotoFrontFromCamera,
                onGalleryPress:
                    controller.getImageBusinessPhotoFrontFromGallery,
                heroTagCamera: 'frontCamera',
                heroTagGallery: 'frontGallery',
              )),
          const SizedBox(width: 5),
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
          const SizedBox(width: 5),
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
    return Padding(
      padding: EdgeInsets.only(
        right: ResponsiveUtil.scaleSize(context, 16),
        left: ResponsiveUtil.scaleSize(context, 16),
        bottom: ResponsiveUtil.scaleSize(context, 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  side: BorderSide(color: colorAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _handlePreviewOrUpdate,
                child: Obx(() => Text(
                      controller.isEditMode.value ? 'Update' : 'Preview',
                      style: TextStyle(
                        color: colorAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  foregroundColor: colorNetral,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _handleSubmit,
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePreviewOrUpdate() async {
    if (controller.isEditMode.value) {
      Get.dialog(
        const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Updating customer...'),
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
