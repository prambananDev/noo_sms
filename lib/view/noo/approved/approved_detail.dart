import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/image_detail.dart';
import 'package:noo_sms/controllers/noo/approved_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';

class ApprovalDetailView extends StatefulWidget {
  final int? id;

  const ApprovalDetailView({Key? key, this.id}) : super(key: key);

  @override
  ApprovalDetailViewState createState() => ApprovalDetailViewState();
}

class ApprovalDetailViewState extends State<ApprovalDetailView> {
  late final ApprovedController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ApprovedController());
    if (widget.id != null) {
      controller.getStatusDetail(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Approved Detail",
          style: TextStyle(
            color: colorNetral,
            fontSize: 18.rt(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtil.isIPad(context)
                ? 24.rp(context)
                : 16.rp(context)),
            child: Column(
              children: [
                _buildCustomCard(
                    _buildBasicInformationSection("Basic Information")),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildAddressSection(
                  "Company Address",
                  controller.companyAddress.value,
                )),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildAddressSection(
                  "TAX Address",
                  controller.taxAddress.value,
                )),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildAddressSection(
                  "Delivery Address",
                  controller.deliveryAddress.value,
                )),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildDocumentsSection()),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildSignaturesSection()),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(_buildFinalDetailsSection()),
                SizedBox(height: 16.rs(context)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomCard(Widget child) {
    return Container(
      padding: EdgeInsets.all(
          ResponsiveUtil.isIPad(context) ? 20.rp(context) : 16.rp(context)),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(16.rr(context)),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 48.rs(context),
            spreadRadius: 1.rs(context),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBasicInformationSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.rp(context)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.rt(context),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        detailRow("Customer Name", controller.currentApproval.value.custName),
        detailRow("Brand Name", controller.currentApproval.value.brandName),
        detailRow("Sales Office", controller.currentApproval.value.salesOffice),
        detailRow(
            "Customer Group", controller.currentApproval.value.customerGroup),
        detailRow(
            "Business Unit", controller.currentApproval.value.businessUnit),
        detailRow("Category", controller.currentApproval.value.category),
        detailRow(
            "Distribution Channels", controller.currentApproval.value.segment),
        detailRow("Channel Segmentation",
            controller.currentApproval.value.subSegment),
        detailRow("Class", controller.currentApproval.value.classField),
        detailRow(
            "Company Status", controller.currentApproval.value.companyStatus),
        detailRow("Currency", controller.currentApproval.value.currency),
        detailRow("Price Group", controller.currentApproval.value.priceGroup),
        detailRow("AX Category", controller.currentApproval.value.category1),
        detailRow("Regional", controller.currentApproval.value.regional),
        detailRow("AX Payment Mode", controller.currentApproval.value.paymMode),
        detailRow(
            "Contact Person", controller.currentApproval.value.contactPerson),
        detailRow("KTP", controller.currentApproval.value.ktp),
        detailRow("KTP Address", controller.currentApproval.value.ktpAddress),
        detailRow("NPWP", controller.currentApproval.value.npwp),
        detailRow("Phone No", controller.currentApproval.value.phoneNo),
        detailRow("Fax No", controller.currentApproval.value.faxNo),
        detailRow(
            "Email Address", controller.currentApproval.value.emailAddress),
        detailRow("Website", controller.currentApproval.value.website),
      ],
    );
  }

  Widget _buildAddressSection(String title, Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.rp(context)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.rt(context),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
        detailRow("Name", address.name),
        detailRow("Street Name", address.streetName),
        detailRow("Village", address.kelurahan),
        detailRow("Districts", address.kecamatan),
        detailRow("City", address.city),
        detailRow("Province", address.state),
        detailRow("Country", address.country),
        detailRow("ZIP Code", address.zipCode?.toString()),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      children: [
        ImageDetailRow(
          title: "Foto NPWP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoNPWP}",
        ),
        ImageDetailRow(
          title: "Foto KTP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoKTP}",
        ),
        ImageDetailRow(
          title: "Foto SIUP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoSIUP}",
        ),
        ImageDetailRow(
          title: "Foto Gedung\nDepan",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoGedung1}",
        ),
        ImageDetailRow(
          title: "Foto Gedung\nDalam",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoGedung2}",
        ),
        ImageDetailRow(
          title: "Foto SPPKP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoGedung3}",
        ),
        ImageDetailRow(
          title: "Foto Competitor\nTop",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.fotoCompetitorTop}",
        ),
      ],
    );
  }

  Widget _buildSignaturesSection() {
    return Column(
      children: [
        ImageDetailRow(
          title: "Customer\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.custSignature}",
        ),
        ImageDetailRow(
          title: "Sales\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.salesSignature}",
        ),
        ImageDetailRow(
          title: "Approval 1\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.approval1Signature}",
        ),
        ImageDetailRow(
          title: "Approval 2\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.approval2Signature}",
        ),
        ImageDetailRow(
          title: "Approval 3\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.currentApproval.value.approval3Signature}",
        ),
      ],
    );
  }

  Widget _buildFinalDetailsSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              "Remark                     :    ",
              style: TextStyle(fontSize: 17),
            ),
            Flexible(
              child: Text(
                controller.currentApproval.value.remark ?? "-",
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        detailRow(
          "Payment Term",
          controller.currentApproval.value.paymentTerm,
        ),
        detailRow(
          "Credit Limit",
          controller.currentApproval.value.creditLimit.toString(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              "Status",
              style: TextStyle(fontSize: 17),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(98, 0, 20, 0),
              child: Text(":"),
            ),
            Flexible(
              child: Text(
                controller.currentApproval.value.status ?? "-",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.grey,
            ),
          ),
          Text(
            value ?? '',
            style: TextStyle(
              fontSize: 16.rt(context),
            ),
          ),
          Divider(
            height: 8.rs(context),
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
