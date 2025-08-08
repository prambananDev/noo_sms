import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/image_detail.dart';
import 'package:noo_sms/controllers/noo/list_status_detail_controller.dart';
import 'package:noo_sms/models/list_status_noo.dart';

class ViewAllListDetail extends GetView<StatusDetailController> {
  final int id;
  final String so;
  final String bu;
  final String name;
  final String status;

  const ViewAllListDetail({
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
    );
  }

  Widget _buildBody(StatusDetailController controller, BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: SizedBox(
            width: 40.rs(context),
            height: 40.rs(context),
            child: const CircularProgressIndicator(),
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
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16.rt(context)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.rs(context)),
                ElevatedButton(
                  onPressed: () => controller.initializeData(id),
                  style: ElevatedButton.styleFrom(
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
                    style: TextStyle(fontSize: 16.rt(context)),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.rp(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomCard(
                  _buildBasicInfo(data, context),
                  context,
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  _buildAddressInfo(data, context),
                  context,
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  _buildApprovalStatus(controller, context),
                  context,
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  _buildDocumentsSection(context),
                  context,
                ),
                SizedBox(height: 16.rs(context)),
                _buildCustomCard(
                  _buildSignaturesSection(context),
                  context,
                ),
                SizedBox(height: 20.rs(context)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBasicInfo(NOOModel data, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', context),
        _buildDetailRow('Customer Name', data.custName, context),
        _buildDetailRow('Alias Name', data.brandName, context),
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
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Customer\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.custSignature}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Sales\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.salesSignature}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Approval 1\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval1Signature}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Approval 2\nSignature",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.approval2Signature}",
        ),
        SizedBox(height: 12.rs(context)),
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
        SizedBox(height: 8.rs(context)),
        ImageDetailRow(
          title: "Foto NPWP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoNPWP}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Foto KTP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoKTP}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Foto SIUP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoSIUP}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Foto Gedung\nDepan",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung1}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Foto Gedung\nDalam",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung2}",
        ),
        SizedBox(height: 12.rs(context)),
        ImageDetailRow(
          title: "Foto SPPKP",
          imageUrl:
              "${apiNOO}Files/GetFiles?fileName=${controller.listDetail.value.fotoGedung3}",
        ),
        SizedBox(height: 12.rs(context)),
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
          SizedBox(height: 8.rs(context)),
          Row(
            children: [
              Text(
                "Latitude : ",
                style: TextStyle(
                  fontSize: 16.rt(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  data.lat!,
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.rs(context)),
          Row(
            children: [
              Text(
                "Longitude : ",
                style: TextStyle(
                  fontSize: 16.rt(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  data.long!,
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
            ],
          ),
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
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
                    child: const Divider(height: 1),
                  ),
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
          color: Colors.black87,
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
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rp(context)),
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
          SizedBox(height: 2.rs(context)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.rp(context)),
            child: const Divider(height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(dynamic address, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.rp(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.rr(context)),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.streetName,
            style: TextStyle(
              fontSize: 15.rt(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (address.kelurahan.isNotEmpty) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              address.kelurahan,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
          if (address.kecamatan.isNotEmpty) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              address.kecamatan,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
          SizedBox(height: 2.rs(context)),
          Text(
            '${address.city}, ${address.state} ${address.zipCode}',
            style: TextStyle(fontSize: 14.rt(context)),
          ),
          SizedBox(height: 2.rs(context)),
          Text(
            address.country,
            style: TextStyle(fontSize: 14.rt(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCard(Widget child, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.rp(context)),
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: colorNetral,
        borderRadius: BorderRadius.circular(16.rr(context)),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: ResponsiveUtil.isIPad(context)
                ? 20.rs(context)
                : 15.rs(context),
            spreadRadius: 1,
            offset: Offset(0, 2.rs(context)),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTaxAddressDetails(TaxAddress address, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.rp(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.rr(context)),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.streetName,
            style: TextStyle(
              fontSize: 15.rt(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (address.kelurahan?.isNotEmpty ?? false) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              address.kelurahan!,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
          if (address.kecamatan?.isNotEmpty ?? false) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              address.kecamatan!,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
          if (address.city != null || address.state != null) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              [address.city, address.state, address.zipCode?.toString()]
                  .where((e) => e != null)
                  .join(', '),
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
          if (address.country?.isNotEmpty ?? false) ...[
            SizedBox(height: 2.rs(context)),
            Text(
              address.country!,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ],
        ],
      ),
    );
  }
}
