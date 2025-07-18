import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Status Detail",
          style: TextStyle(
            color: colorNetral,
            fontSize: 18.rt(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(controller, context),
      bottomNavigationBar: _buildBottomButton(controller, context),
    );
  }

  Widget _buildBody(StatusDetailController controller, BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 3.rs(context),
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.rp(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.ri(context),
                  color: Colors.red,
                ),
                SizedBox(height: 16.rs(context)),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16.rt(context)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.rs(context)),
                ElevatedButton(
                  onPressed: () => controller.initializeData(id),
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
                  child: Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: 16.rt(context),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final data = controller.statusData.value;
      if (data == null) {
        return Center(
          child: Text(
            "No data available",
            style: TextStyle(fontSize: 16.rt(context)),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.initializeData(id),
        strokeWidth: 2.5.rs(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtil.isIPad(context)
                ? 24.rp(context)
                : 16.rp(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomCard(
                  context,
                  _buildBasicInfo(data, context),
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  context,
                  _buildAddressInfo(data, context),
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  context,
                  _buildApprovalStatus(controller, context),
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  context,
                  _buildDocumentsSection(context),
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  context,
                  _buildSignaturesSection(context),
                ),
                SizedBox(height: 16.rs(context)), // Bottom spacing
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomButton(
      StatusDetailController controller, BuildContext context) {
    return Obx(() {
      if (!controller.isLoading.value &&
          controller.statusApproval.value == controller.statusRejected) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.rp(context)),
            child: ElevatedButton(
              onPressed: controller.navigateToEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                padding: EdgeInsets.symmetric(vertical: 16.rp(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.rr(context)),
                ),
                elevation: 2.rs(context),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 16.rt(context),
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

  Widget _buildBasicInfo(NOOModel data, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', context),
        _buildDetailRow('Customer Name', data.custName, context),
        _buildDetailRow('Brand Name', data.brandName, context),
        _buildDetailRow('Sales Office', data.salesOffice, context),
        _buildDetailRow('Customer Group', data.customerGroup, context),
        _buildDetailRow('Business Unit', data.businessUnit, context),
        _buildDetailRow('Category', data.category, context),
        _buildDetailRow('Distribution Channels', data.segment, context),
        _buildDetailRow('Class', data.classField, context),
        _buildDetailRow('Company Status', data.companyStatus, context),
        _buildDetailRow('Currency', data.currency, context),
        _buildDetailRow('Price Group', data.priceGroup, context),
        if (data.category1 != null)
          _buildDetailRow('AX Category', data.category1!, context),
        if (data.regional != null)
          _buildDetailRow('Regional', data.regional!, context),
        if (data.paymentMode != null)
          _buildDetailRow('Payment Mode', data.paymentMode!, context),
        _buildDetailRow('Contact Person', data.contactPerson, context),
        _buildDetailRow('KTP', data.ktp, context),
        if (data.ktpAddress != null)
          _buildDetailRow('KTP Address', data.ktpAddress!, context),
        _buildDetailRow('NPWP', data.npwp, context),
        _buildDetailRow('FAX', data.faxNo, context),
        _buildDetailRow('Phone', data.phoneNo, context),
        _buildDetailRow('Email', data.emailAddress, context),
        if (data.website.isNotEmpty)
          _buildDetailRow('Website', data.website, context),
        _buildDetailRow('Status', data.status, context),
      ],
    );
  }

  Widget _buildSignaturesSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Signatures', context),
        ImageDetailRow(
          title: "Customer\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.custSignature}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Sales\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.salesSignature}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Approval 1\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval1Signature}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Approval 2\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval2Signature}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Approval 3\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval3Signature}",
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Documents', context),
        ImageDetailRow(
          title: "Foto NPWP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoNPWP}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto KTP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoKTP}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto SIUP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoSIUP}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto Gedung\nDepan",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung1}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto Gedung\n Dalam",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung2}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto SPPKP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung3}",
        ),
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto Competitor\nTop",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoCompetitorTop}",
        ),
      ],
    );
  }

  Widget _buildAddressInfo(NOOModel data, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Address Information', context),
        if (data.companyAddresses != null) ...[
          _buildSectionSubtitle('Company Address', context),
          _buildAddressDetails(data.companyAddresses!, context),
        ],
        if (data.deliveryAddresses != null) ...[
          SizedBox(height: 16.rs(context)),
          _buildSectionSubtitle('Delivery Address', context),
          _buildAddressDetails(data.deliveryAddresses!, context),
        ],
        if (data.taxAddresses != null) ...[
          SizedBox(height: 16.rs(context)),
          _buildSectionSubtitle('Tax Address', context),
          _buildTaxAddressDetails(data.taxAddresses!, context),
        ],
      ],
    );
  }

  Widget _buildApprovalStatus(
      StatusDetailController controller, BuildContext context) {
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
        _buildSectionTitle('Approval Status', context),
        if (controller.approvalStatusList.isEmpty)
          Container(
            width: double.infinity,
            height: 60.rs(context),
            color: Colors.white,
            child: Center(
              child: Text(
                'No approval status available',
                style: TextStyle(
                  fontSize: 14.rt(context),
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ...controller.approvalStatusList.map((status) {
            final level = status['Level']?.toString() ?? '';
            final statusText = status['Status']?.toString() ?? '';
            final statusColor = getStatusColor(statusText);

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.rp(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 16.rt(context),
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.rs(context)),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16.rt(context),
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(height: 16.rs(context)),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.rp(context)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.rt(context),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rp(context)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.rt(context),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.rt(context),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.rs(context)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.black87,
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

  Widget _buildAddressDetails(dynamic address, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.streetName,
            style: TextStyle(fontSize: 16.rt(context)),
          ),
          if (address.kelurahan.isNotEmpty) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              address.kelurahan,
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
          if (address.kecamatan.isNotEmpty) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              address.kecamatan,
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
          SizedBox(height: 4.rs(context)),
          Text(
            '${address.city}, ${address.state} ${address.zipCode}',
            style: TextStyle(fontSize: 16.rt(context)),
          ),
          SizedBox(height: 4.rs(context)),
          Text(
            address.country,
            style: TextStyle(fontSize: 16.rt(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCard(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
          ResponsiveUtil.isIPad(context) ? 20.rp(context) : 16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget _buildTaxAddressDetails(TaxAddress address, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.streetName,
            style: TextStyle(fontSize: 16.rt(context)),
          ),
          if (address.kelurahan?.isNotEmpty ?? false) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              address.kelurahan!,
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
          if (address.kecamatan?.isNotEmpty ?? false) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              address.kecamatan!,
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
          if (address.city != null || address.state != null) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              [address.city, address.state, address.zipCode?.toString()]
                  .where((e) => e != null)
                  .join(', '),
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
          if (address.country?.isNotEmpty ?? false) ...[
            SizedBox(height: 4.rs(context)),
            Text(
              address.country!,
              style: TextStyle(fontSize: 16.rt(context)),
            ),
          ],
        ],
      ),
    );
  }
}
