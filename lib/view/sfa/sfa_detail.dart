import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/service/api_constant.dart';
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

    controller.resultsController.text = detail.result ?? '';
    controller.followupController.text = detail.followup ?? '';
    controller.followupDateController.text =
        controller.formatDateString(detail.followupDate);

    checkinTimeController.text = _formatDate(detail.checkIn);
    checkoutTimeController.text = _formatDate(detail.checkOut);
  }

  @override
  void dispose() {
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
        elevation: 0,
        toolbarHeight: 56.rs(context),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
        ),
        title: Text(
          'SFA Detail',
          style: TextStyle(
            color: colorNetral,
            fontSize: 18.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorAccent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sfaDetailRecord.value == null) {
          return Center(
            child: Text(
              'No detail found for this record',
              style: TextStyle(
                fontSize: 16.rt(context),
                color: colorBlack,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.rp(context)),
          child: _buildDetailCard(controller.sfaDetailRecord.value!),
        );
      }),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rp(context)),
      child: SizedBox(
        width: double.infinity,
        height: 50.rs(context),
        child: ElevatedButton.icon(
          onPressed:
              controller.isSubmitting.value ? null : () => _handleCheckOut(),
          icon: Icon(
            Icons.logout,
            color: Colors.white,
            size: 24.ri(context),
          ),
          label: Text(
            controller.isSubmitting.value ? 'PROCESSING...' : 'CHECK OUT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            elevation: 2.rs(context),
          ),
        ),
      ),
    );
  }

  void _handleCheckOut() async {
    if (controller.sfaDetailRecord.value == null) return;

    final detail = controller.sfaDetailRecord.value!;

    controller.currentVisitId.value = detail.id ?? -1;
    controller.selectedCustomerId.value = detail.customer?.toString() ?? "";
    controller.selectedCustomerName.value = detail.customerName ?? "";
    controller.uploadedPhotoName.value = detail.checkInFoto ?? "";

    controller.purposeController.text = purposeTypeController.text;

    controller.isCheckedIn.value = true;

    final success = await controller.submitCheckOut(context);
    if (success) {
      await controller.fetchSfaDetails(widget.recordId);

      setState(() {
        isCheckoutAllowed = false;
      });

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
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Transaction Information'),
          _buildDetailItem('ID', '${detail.id ?? 'N/A'}'),
          _buildDetailItem('Customer', detail.customerName ?? 'N/A'),
          _buildTextFieldItem('Address', addressController,
              readOnly: !isCheckoutAllowed),
          _buildDetailItem('Purpose', detail.typeName ?? 'N/A'),
          SizedBox(height: 16.rs(context)),
          _buildSectionTitle('Customer Information'),
          _buildTextFieldItem('Contact Person', contactPersonController,
              readOnly: !isCheckoutAllowed),
          _buildTextFieldItem('Contact Number', contactNumberController,
              readOnly: !isCheckoutAllowed),
          _buildTextFieldItem('Contact Title', contactTitleController,
              readOnly: !isCheckoutAllowed),
          SizedBox(height: 16.rs(context)),
          _buildSectionTitle('Visit Details'),
          _buildTextFieldItem(
              'Purpose Description', controller.purposeController,
              maxLines: 3, readOnly: !isCheckoutAllowed),
          _buildTextFieldItem('Results', controller.resultsController,
              maxLines: 3, readOnly: !isCheckoutAllowed),
          _buildDatePickerField(!isCheckoutAllowed),
          _buildTextFieldItem('Follow-up', controller.followupController,
              maxLines: 3, readOnly: !isCheckoutAllowed),
          if (detail.checkInFoto != null && detail.checkInFoto!.isNotEmpty) ...[
            SizedBox(height: 16.rs(context)),
            _buildSectionTitle('Check-in Photo'),
            _buildPhotoPreview(detail.checkInFoto!),
          ],
          SizedBox(height: 24.rs(context)),
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
            fontSize: 18.rt(context),
            fontWeight: FontWeight.bold,
            color: colorAccent,
          ),
        ),
        SizedBox(height: 8.rs(context)),
      ],
    );
  }

  Widget _buildTextFieldItem(String label, TextEditingController controller,
      {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.rs(context),
            child: Text(
              "$label :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.rt(context),
              ),
            ),
          ),
          Expanded(
            child: readOnly
                ? Text(
                    controller.text.isEmpty ? 'N/A' : controller.text,
                    style: TextStyle(fontSize: 14.rt(context)),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  )
                : StableTextField(
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
      padding: EdgeInsets.only(bottom: 8.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.rs(context),
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.rt(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField([bool isReadOnly = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120.rs(context),
            child: Text(
              "Follow-up Date:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.rt(context),
              ),
            ),
          ),
          Expanded(
            child: isReadOnly
                ? Text(
                    controller.followupDateController.text.isEmpty
                        ? 'N/A'
                        : controller.followupDateController.text,
                    style: TextStyle(fontSize: 14.rt(context)),
                  )
                : StableTextField(
                    controller: controller.followupDateController,
                    readOnly: true,
                    hintText: "Select date",
                    style: TextStyle(fontSize: 14.rt(context)),
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
    final String photoUrl = '$apiSMS/VisitCustomer/CheckIn?filename=$photoName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200.rs(context),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.rr(context)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.rr(context)),
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
                            size: 48.ri(context),
                            color: Colors.red[400],
                          ),
                          SizedBox(height: 8.rs(context)),
                          Text(
                            'Error loading image',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.rt(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8.rp(context),
                right: 8.rp(context),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        insetPadding: EdgeInsets.all(8.rp(context)),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(
                              photoUrl,
                              fit: BoxFit.contain,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30.ri(context),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.rp(context)),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 20.ri(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.rs(context)),
        Text(
          'Photo: $photoName',
          style: TextStyle(
            fontSize: 12.rt(context),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
