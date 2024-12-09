import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/approval_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:signature/signature.dart';

class ApprovalDetailPage extends StatefulWidget {
  final int? id;
  final String? role;

  const ApprovalDetailPage({
    Key? key,
    this.id,
    this.role,
  }) : super(key: key);

  @override
  ApprovalDetailPageState createState() => ApprovalDetailPageState();
}

class ApprovalDetailPageState extends State<ApprovalDetailPage> {
  late final ApprovalController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ApprovalController());
    if (widget.id != null) {
      controller.fetchApprovalDetail(widget.id!);
    }
    debugPrint(widget.role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white60,
        title: const Text(
          "Approval Detail",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInformation(),
              _buildDivider(),
              _buildCompanyAddress(),
              _buildDivider(),
              _buildTaxAddress(),
              _buildDivider(),
              _buildDeliveryAddress(),
              _buildDivider(),
              _buildDocuments(),
              if (widget.role != "2") ...[
                _buildDivider(),
                _buildSignatureSection(),
                _buildRemarkSection(),
                _buildPaymentAndCreditSection(),
                _buildApprovalButtons(context),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        _buildDetailRow(
            'Customer Name', controller.currentApproval.value.custName),
        _buildDetailRow(
            'Brand Name', controller.currentApproval.value.brandName),
        _buildDetailRow('Category', controller.currentApproval.value.category),
        _buildDetailRow('Segment', controller.currentApproval.value.segment),
        _buildDetailRow(
            'SubSegment', controller.currentApproval.value.subSegment),
        _buildDetailRow('Class', controller.currentApproval.value.classField),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.black12,
      height: 20,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCompanyAddress() {
    return _buildAddressSection(
        "Company Address", controller.companyAddress.value);
  }

  Widget _buildTaxAddress() {
    return _buildAddressSection("Tax Address", controller.taxAddress.value);
  }

  Widget _buildDeliveryAddress() {
    return _buildAddressSection(
        "Delivery Address", controller.deliveryAddress.value);
  }

  Widget _buildAddressSection(String title, Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        _buildDetailRow("Street", address.streetName),
        _buildDetailRow("City", address.city),
        _buildDetailRow("Postal Code", address.zipCode.toString()),
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Documents'),
        _buildImageViewer('NPWP', controller.currentApproval.value.fotoNPWP),
        _buildImageViewer('KTP', controller.currentApproval.value.fotoKTP),
        _buildImageViewer('SIUP', controller.currentApproval.value.fotoSIUP),
        _buildImageViewer(
            'Foto Gedung', controller.currentApproval.value.fotoGedung),
      ],
    );
  }

  Widget _buildImageViewer(String title, String? imageUrl) {
    if (imageUrl == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Image.network(
        '$baseURLDevelopment/Files/GetFiles?fileName=$imageUrl',
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Signature'),
        _buildSignatureWidget(controller.signatureController),
      ],
    );
  }

  Widget _buildSignatureWidget(SignatureController signatureController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Signature(
        controller: signatureController,
        height: 150,
        width: double.infinity,
        backgroundColor: Colors.grey[200]!,
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Remark'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.remarkController,
            decoration: const InputDecoration(hintText: "Enter remark here"),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAndCreditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment and Credit'),
        _buildDetailRow('Credit Limit',
            controller.currentApproval.value.creditLimit.toString()),
        _buildDetailRow('Payment Term', controller.selectedPaymentTerm.value),
      ],
    );
  }

  Widget _buildApprovalButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            _showRejectConfirmation();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'Reject',
            style: TextStyle(color: colorNetral),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showApproveConfirmation();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(
            'Approve',
            style: TextStyle(color: colorNetral),
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmation() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Approval'),
          content: const Text('Are you sure you want to approve this request?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final signature =
                    await controller.signatureController.toPngBytes();
                if (signature == null) {
                  Get.snackbar('Error', 'Please provide signature');
                  return;
                }
                await controller.uploadSignature(signature);
                await controller.processApproval(
                  widget.id!,
                  controller.signatureApprovalFromServer.value,
                  controller.remarkController.text,
                  true,
                );
                Navigator.of(context).pop();
              },
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRejectConfirmation() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection'),
          content: const Text('Are you sure you want to reject this request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await controller.processReject(
                    widget.id!, controller.remarkController.text);

                Navigator.of(context).pop();
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
