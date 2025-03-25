import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/textfield_sfa.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';
import 'package:noo_sms/models/sfa_model.dart';

class SfaDetail extends StatefulWidget {
  final int recordId;
  final String status;
  const SfaDetail({Key? key, required this.recordId, required this.status})
      : super(key: key);

  @override
  State<SfaDetail> createState() => _SfaDetailState();
}

class _SfaDetailState extends State<SfaDetail> {
  late final SfaController controller;

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController contactTitleController = TextEditingController();
  final TextEditingController purposeTypeController = TextEditingController();
  final TextEditingController resultsController = TextEditingController();
  final TextEditingController followupController = TextEditingController();
  final TextEditingController followupDateController = TextEditingController();
  final TextEditingController checkinTimeController = TextEditingController();
  final TextEditingController checkoutTimeController = TextEditingController();

  bool isCheckoutAllowed = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SfaController>();
    isCheckoutAllowed = _isCheckInStatus(widget.status);

    debugPrint(
        "Status: ${widget.status}, Checkout allowed: $isCheckoutAllowed");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });

    debugPrint("Status " + widget.status);
  }

  bool _isCheckInStatus(String status) {
    final String lowerStatus = status.toLowerCase();

    return lowerStatus.contains('check-in') ||
        lowerStatus.contains('check in') ||
        lowerStatus.contains('checked in') ||
        lowerStatus == 'checkin';
  }

  Future<void> _initData() async {
    await controller.fetchSfaDetails(widget.recordId);
    if (controller.sfaDetailRecord.value != null) {
      _populateTextControllers(controller.sfaDetailRecord.value!);
    }
  }

  void _populateTextControllers(SfaRecordDetail detail) {
    idController.text = detail.id?.toString() ?? 'N/A';
    nameController.text = detail.customerName ?? 'N/A';
    addressController.text = detail.address ?? 'N/A';
    contactPersonController.text = detail.contactPerson ?? 'N/A';
    contactNumberController.text = detail.contactNumber ?? 'N/A';
    contactTitleController.text = detail.contactTitle ?? 'N/A';
    purposeTypeController.text = detail.typeName ?? 'N/A';

    // For controllers managed by SfaController, copy values
    controller.resultsController.text = detail.result ?? '';
    controller.followupController.text = detail.followup ?? '';
    controller.followupDateController.text =
        controller.formatDateString(detail.followupDate);

    // For display-only date fields
    checkinTimeController.text = _formatDate(detail.checkIn);
    checkoutTimeController.text = _formatDate(detail.checkOut);
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks
    idController.dispose();
    nameController.dispose();
    addressController.dispose();
    contactPersonController.dispose();
    contactNumberController.dispose();
    contactTitleController.dispose();
    purposeTypeController.dispose();
    resultsController.dispose();
    followupController.dispose();
    followupDateController.dispose();
    checkinTimeController.dispose();
    checkoutTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          'SFA Detail',
          style: TextStyle(
              color: colorNetral, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorAccent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sfaDetailRecord.value == null) {
          return const Center(
            child: Text('No detail found for this record'),
          );
        }

        // Display the detail record
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildDetailCard(controller.sfaDetailRecord.value!),
        );
      }),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed:
              controller.isSubmitting.value ? null : () => _handleCheckOut(),
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            controller.isSubmitting.value ? 'PROCESSING...' : 'CHECK OUT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            elevation: 2,
          ),
        ),
      ),
    );
  }

  void _handleCheckOut() async {
    if (controller.sfaDetailRecord.value == null) return;

    final detail = controller.sfaDetailRecord.value!;

    // Setup data needed for checkout
    controller.currentVisitId.value = detail.id ?? -1;
    controller.selectedCustomerId.value = detail.customer?.toString() ?? "";
    controller.selectedCustomerName.value = detail.customerName ?? "";
    controller.uploadedPhotoName.value = detail.checkInFoto ?? "";

    // Get values from text fields
    controller.purposeController.text = purposeTypeController.text;
    // resultsController and followupController already set via _populateTextControllers
    // followupDateController already set via _populateTextControllers

    // Set this so the controller knows we're checked in
    controller.isCheckedIn.value = true;

    // Execute checkout
    final success = await controller.submitCheckOut(context);
    if (success) {
      // Refresh the detail after checkout
      await controller.fetchSfaDetails(widget.recordId);

      // Hide the checkout button since status has changed
      setState(() {
        isCheckoutAllowed = false;
      });

      // Show success message
      Get.snackbar(
        'Success',
        'Check-out completed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildDetailCard(SfaRecordDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Transaction Information'),
          _buildDetailItem('ID', '${detail.id ?? 'N/A'}'),
          _buildDetailItem('Customer', detail.customerName ?? 'N/A'),
          _buildTextFieldItem('Address', addressController),
          _buildDetailItem('Purpose', detail.typeName ?? 'N/A'),
          const SizedBox(height: 16),
          _buildSectionTitle('Customer Information'),
          _buildTextFieldItem('Contact Person', contactPersonController),
          _buildTextFieldItem('Contact Number', contactNumberController),
          _buildTextFieldItem('Contact Title', contactTitleController),
          const SizedBox(height: 16),
          _buildSectionTitle('Visit Details'),
          _buildTextFieldItem(
              'Purpose Description', controller.purposeController,
              maxLines: 3),
          _buildTextFieldItem('Results', controller.resultsController,
              maxLines: 3),
          _buildDatePickerField(),
          _buildTextFieldItem('Follow-up', controller.followupController,
              maxLines: 3),
          if (detail.checkInFoto != null && detail.checkInFoto!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Check-in Photo'),
            _buildPhotoPreview(detail.checkInFoto!),
          ],
          const SizedBox(height: 24),
          isCheckoutAllowed ? _buildCheckoutButton() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    if (dateString.contains('1900-01-01')) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorAccent,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextFieldItem(String label, TextEditingController controller,
      {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label :",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: StableTextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: maxLines,
              hintText: readOnly ? "" : "Enter $label",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              "Follow-up Date:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: StableTextField(
              controller: controller.followupDateController,
              readOnly: true,
              hintText: "Select date",
              style: const TextStyle(fontSize: 14),
              isCalendar: true,
              onTap: () async {
                final currentContext = context;

                final DateTime? pickedDate = await showDatePicker(
                  context: currentContext,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (pickedDate != null && mounted) {
                  controller.followupDateController.text =
                      DateFormat('dd-MM-yyyy').format(pickedDate);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(String photoName) {
    // Get the photo URL from the controller
    final String photoUrl = '$apiSMS/VisitCustomer/CheckIn?filename=$photoName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Error loading image',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    // Show full screen photo
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        insetPadding: const EdgeInsets.all(8),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(
                              photoUrl,
                              fit: BoxFit.contain,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Photo: $photoName',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
