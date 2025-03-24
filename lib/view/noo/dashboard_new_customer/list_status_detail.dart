import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/image_detail.dart';
import 'package:noo_sms/controllers/noo/list_status_detail_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';

class StatusDetailView extends GetView<StatusDetailController> {
  final int id;
  final String so;
  final String bu;
  final String name;
  final String status;

  const StatusDetailView({
    Key? key,
    required this.id,
    required this.bu,
    required this.so,
    required this.name,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatusDetailController());

    controller.initializeData(id);

    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Status Detail",
          style: TextStyle(color: colorNetral),
        ),
      ),
      body: _buildBody(controller, context),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  Widget _buildBody(StatusDetailController controller, BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.initializeData(id),
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }

      final data = controller.statusData.value;
      if (data == null) {
        return const Center(child: Text("No data available"));
      }

      return RefreshIndicator(
        onRefresh: () => controller.initializeData(id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomCard(
                  _buildBasicInfo(data),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildCustomCard(
                  _buildAddressInfo(data),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildCustomCard(
                  _buildApprovalStatus(controller),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildCustomCard(
                  _buildDocumentsSection(),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildCustomCard(
                  _buildSignaturesSection(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomButton(StatusDetailController controller) {
    return Obx(() {
      if (!controller.isLoading.value &&
          controller.statusApproval.value == controller.statusRejected) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: controller.navigateToEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBasicInfo(NOOModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        _buildDetailRow('Customer Name', data.custName),
        _buildDetailRow('Brand Name', data.brandName),
        _buildDetailRow('Sales Office', data.salesOffice),
        _buildDetailRow('Business Unit', data.businessUnit),
        _buildDetailRow('Category', data.category),
        _buildDetailRow('Distribution Channels', data.segment),
        _buildDetailRow('Class', data.classField),
        _buildDetailRow('Company Status', data.companyStatus),
        _buildDetailRow('Currency', data.currency),
        _buildDetailRow('Price Group', data.priceGroup),
        if (data.category1 != null)
          _buildDetailRow('AX Category', data.category1!),
        if (data.regional != null) _buildDetailRow('Regional', data.regional!),
        if (data.paymentMode != null)
          _buildDetailRow('Payment Mode', data.paymentMode!),
        _buildDetailRow('Contact Person', data.contactPerson),
        _buildDetailRow('KTP', data.ktp),
        if (data.ktpAddress != null)
          _buildDetailRow('KTP Address', data.ktpAddress!),
        _buildDetailRow('NPWP', data.npwp),
        _buildDetailRow('FAX', data.faxNo),
        _buildDetailRow('Phone', data.phoneNo),
        _buildDetailRow('Email', data.emailAddress),
        if (data.website.isNotEmpty) _buildDetailRow('Website', data.website),
        _buildDetailRow('Status', data.status),
      ],
    );
  }

  Widget _buildSignaturesSection() {
    return Column(
      children: [
        ImageDetailRow(
          title: "Customer\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.custSignature}",
        ),
        ImageDetailRow(
          title: "Sales\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.salesSignature}",
        ),
        ImageDetailRow(
          title: "Approval 1\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval1Signature}",
        ),
        ImageDetailRow(
          title: "Approval 2\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval2Signature}",
        ),
        ImageDetailRow(
          title: "Approval 3\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval3Signature}",
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      children: [
        ImageDetailRow(
          title: "Foto NPWP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoNPWP}",
        ),
        ImageDetailRow(
          title: "Foto KTP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoKTP}",
        ),
        ImageDetailRow(
          title: "Foto SIUP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoSIUP}",
        ),
        ImageDetailRow(
          title: "Foto Gedung\nDepan",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung1}",
        ),
        ImageDetailRow(
          title: "Foto Gedung\n Dalam",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung2}",
        ),
        ImageDetailRow(
          title: "Foto SPPKP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung3}",
        ),
        ImageDetailRow(
          title: "Foto Competitor\nTop",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoCompetitorTop}",
        ),
      ],
    );
  }

  Widget _buildAddressInfo(NOOModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Address Information'),
        if (data.companyAddresses != null) ...[
          _buildSectionSubtitle('Company Address'),
          _buildAddressDetails(data.companyAddresses!),
        ],
        if (data.deliveryAddresses != null) ...[
          const SizedBox(height: 16),
          _buildSectionSubtitle('Delivery Address'),
          _buildAddressDetails(data.deliveryAddresses!),
        ],
        if (data.taxAddresses != null) ...[
          const SizedBox(height: 16),
          _buildSectionSubtitle('Tax Address'),
          _buildTaxAddressDetails(data.taxAddresses!),
        ],
      ],
    );
  }

  Widget _buildApprovalStatus(StatusDetailController controller) {
    Color getStatusColor(String? status) {
      if (status == null) return Colors.red;

      switch (status.toLowerCase().trim()) {
        case 'pending':
          return Colors.orange;
        case 'approved':
          return Colors.green;
        case 'rejected':
        case 'reject':
          return Colors.red;
        default:
          return Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Approval Status'),
        if (controller.approvalStatusList.isEmpty)
          // Add an empty container with full width
          Container(
            width: double.infinity,
            height: 60, // Provide some height for the empty space
            color: Colors.white, // Ensure it's white
          )
        else
          // If not empty, map through and display as before
          ...controller.approvalStatusList.map((status) {
            final level = status['Level']?.toString() ?? '';
            final statusText = status['Status']?.toString() ?? '';
            final statusColor = getStatusColor(statusText);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 16),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Divider(height: 8),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(dynamic address) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.streetName),
          if (address.kelurahan.isNotEmpty) Text(address.kelurahan),
          if (address.kecamatan.isNotEmpty) Text(address.kecamatan),
          Text('${address.city}, ${address.state} ${address.zipCode}'),
          Text(address.country),
        ],
      ),
    );
  }

  Widget _buildCustomCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 48,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTaxAddressDetails(TaxAddress address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.streetName),
        if (address.kelurahan?.isNotEmpty ?? false) Text(address.kelurahan!),
        if (address.kecamatan?.isNotEmpty ?? false) Text(address.kecamatan!),
        if (address.city != null || address.state != null)
          Text([address.city, address.state, address.zipCode?.toString()]
              .where((e) => e != null)
              .join(', ')),
        if (address.country?.isNotEmpty ?? false) Text(address.country!),
      ],
    );
  }
}
