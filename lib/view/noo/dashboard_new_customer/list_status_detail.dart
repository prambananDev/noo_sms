import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
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
      appBar: _buildAppBar(controller),
      body: _buildBody(controller),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(StatusDetailController controller) {
    return AppBar(
      backgroundColor: colorAccent,
      title: Text(
        "Status Detail",
        style: TextStyle(color: colorNetral),
      ),
    );
  }

  Widget _buildBody(StatusDetailController controller) {
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
                _buildBasicInfo(data),
                const SizedBox(height: 16),
                _buildAddressInfo(data),
                const SizedBox(height: 16),
                _buildApprovalStatus(controller),
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: controller.navigateToEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBasicInfo(StatusModel data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            _buildDetailRow('Customer Name', data.custName),
            _buildDetailRow('Customer ID', data.custId),
            _buildDetailRow('Brand Name', data.brandName),
            _buildDetailRow('Status', data.status),
            _buildDetailRow('Business Unit', data.businessUnit),
            _buildDetailRow('Sales Office', data.salesOffice),
            _buildDetailRow('Phone', data.phoneNo),
            _buildDetailRow('Email', data.emailAddress),
            if (data.website.isNotEmpty)
              _buildDetailRow('Website', data.website),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfo(StatusModel data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildApprovalStatus(StatusDetailController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Approval Status'),
            ...controller.approvalStatusList.map((status) {
              return _buildDetailRow(
                status['level']?.toString() ?? 'Unknown Level',
                status['status']?.toString() ?? 'Pending',
              );
            }).toList(),
          ],
        ),
      ),
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
          fontWeight: FontWeight.w500,
          color: Colors.blue,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.streetName),
        if (address.kelurahan.isNotEmpty) Text(address.kelurahan),
        if (address.kecamatan.isNotEmpty) Text(address.kecamatan),
        Text('${address.city}, ${address.state} ${address.zipCode}'),
        Text(address.country),
      ],
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
