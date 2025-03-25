import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/textfield_sfa.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';
import 'package:noo_sms/models/sfa_model.dart';
import 'package:search_choices/search_choices.dart';

class SfaCreate extends StatefulWidget {
  final SfaRecord? record;

  const SfaCreate({Key? key, this.record}) : super(key: key);

  @override
  State<SfaCreate> createState() => _SfaCreateState();
}

class _SfaCreateState extends State<SfaCreate> {
  late final SfaController controller = Get.put(SfaController());

  late final bool isEditMode;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEditMode = widget.record != null;

    _setupControllerListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEditMode) {
        _initializeEditMode();
      } else {
        controller.clearForm();
        controller.fetchCustomers();
      }
    });
  }

  void _setupControllerListeners() {
    ever(controller.customerInfo, (CustomerInfo? info) {
      if (info != null) {
        nameController.text = info.name ?? "";
        addressController.text = info.address ?? "";
        contactPersonController.text = info.contact ?? "";
        contactNumberController.text = info.contactNum ?? "";
      } else {
        nameController.text = "";
        addressController.text = "";
        contactPersonController.text = "";
        contactNumberController.text = "";
      }
    });
  }

  void _initializeEditMode() {
    nameController.text = widget.record!.customerName ?? "";
    addressController.text = widget.record!.address ?? "";
    contactPersonController.text = widget.record!.contactPerson ?? "";
    contactNumberController.text = widget.record!.contactNumber ?? "";
    jobTitleController.text = widget.record!.contactTitle ?? "";

    controller.purposeController.text = widget.record!.purposeDesc ?? "";
    controller.resultsController.text = widget.record!.result ?? "";
    controller.followupController.text = widget.record!.followup ?? "";
    controller.followupDateController.text =
        controller.formatDateString(widget.record!.followupDate);

    controller.fetchPurpose();

    if (widget.record!.checkInFoto != null &&
        widget.record!.checkInFoto!.isNotEmpty) {
      controller.uploadedPhotoName.value = widget.record!.checkInFoto!;
      controller.photoUploaded.value = true;
    }

    Future.microtask(() {
      controller.loadRecordForEdit(widget.record!);
    });

    if (widget.record!.status == 1) {
      controller.isCheckedIn.value = true;
    } else if (widget.record!.status == 2) {
      controller.isCheckedIn.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: isEditMode
          ? AppBar(
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
                'Edit Visit Record',
                style: TextStyle(
                    color: colorNetral,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: colorAccent,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isEditMode) _buildToggleSection(),
          const SizedBox(height: 16),
          if (!isEditMode) _buildCustomerDropdown(),
          _buildCustomerInfo(),
          _buildPhotoUploadSection(),
          Obx(() {
            final bool hasPhoto = controller.image.value != null ||
                controller.photoUploaded.value;

            final bool isEditModeAndCheckedOut = isEditMode &&
                widget.record != null &&
                widget.record!.status == 2;

            if (isEditMode && widget.record!.status == 1 && hasPhoto) {
              return _buildActionButton();
            } else if (isEditModeAndCheckedOut) {
              return _buildCheckedOutIndicator();
            } else if (!isEditMode && hasPhoto) {
              return _buildActionButton();
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Text(
              'Prospect : ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Obx(() => Switch(
              value: controller.toggleExistingVal.value,
              activeColor: colorAccent,
              onChanged: (value) {
                controller.toggleExisting(value);
              },
            )),
      ],
    );
  }

  Widget _buildCustomerDropdown() {
    return Obx(() {
      if (controller.customers.isEmpty) {
        return const Center(
          child: Text('No customers available'),
        );
      }

      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Customer :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: SearchChoices.single(
              isExpanded: true,
              items: controller.customers.map((VisitCustomer customer) {
                return DropdownMenuItem<VisitCustomer>(
                  value: customer,
                  child: Text(
                    customer.customerName,
                    overflow: TextOverflow.fade,
                  ),
                );
              }).toList(),
              value: controller.selectedCustomer.value,
              onChanged: (value) {
                setState(() {
                  controller.saveSelectedCustomer(value);
                });
              },
            ),
          )
        ],
      );
    });
  }

  Widget _buildCheckedOutIndicator() {
    final String checkOutTime = widget.record?.checkOut ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'CHECKED OUT',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Visit completed on ${_formatCheckoutTime(checkOutTime)}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Obx(() {
      if (!isEditMode && controller.selectedCustomer.value == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Customer Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          if (controller.isLoadingCustomerInfo.value) ...[
            // const Center(child: CircularProgressIndicator()),
          ] else ...[
            _buildInfoTextField("Name", nameController, readOnly: true),
            _buildInfoTextField("Address", addressController, readOnly: true),
            _buildInfoTextField("Contact Person", contactPersonController),
            _buildInfoTextField("Contact Number", contactNumberController),
            const SizedBox(height: 16),
            const Text(
              'Visit Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            _buildPurposeDropdown(),
            const SizedBox(height: 12),
            _buildInfoTextField(
              "Purpose",
              controller.purposeController,
              maxLines: 3,
            ),
            _buildInfoTextField(
              "Results",
              controller.resultsController,
              maxLines: 3,
            ),
            _buildDatePickerField(),
            _buildInfoTextField(
              "Follow-up",
              controller.followupController,
              maxLines: 3,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildPurposeDropdown() {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              "Purpose :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<VisitPurpose>(
                value: controller.selectedPurpose.value,
                isExpanded: true,
                underline: Container(),
                hint: const Text("Select a purpose"),
                onChanged: (VisitPurpose? newValue) {
                  if (newValue != null) {
                    controller.selectedPurpose.value = newValue;
                  }
                },
                items: controller.purpose.map<DropdownMenuItem<VisitPurpose>>(
                    (VisitPurpose purpose) {
                  return DropdownMenuItem<VisitPurpose>(
                    value: purpose,
                    child: Text(purpose.name),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhotoUploadSection() {
    return Obx(() {
      if (!isEditMode && controller.selectedCustomer.value == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Visit Check-In Photo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: controller.image.value != null
                ? _buildLocalPhotoPreview()
                : controller.photoUploaded.value
                    ? _buildRemotePhotoPreview()
                    : _buildEmptyPhotoPlaceholder(),
          ),
          const SizedBox(height: 8),
          if (controller.image.value != null) ...[
            Text(
              'File: ${controller.imageName.value}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ] else if (controller.photoUploaded.value) ...[
            Text(
              'File: ${controller.uploadedPhotoName.value}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (!controller.isCheckedIn.value) ...[
            if (!controller.photoUploaded.value) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () {
                          if (controller.image.value == null) {
                            _showPhotoOptionsDialog();
                          } else {
                            controller.uploadPhoto();
                          }
                        },
                  icon: Icon(
                    controller.image.value == null
                        ? Icons.add_photo_alternate
                        : Icons.cloud_upload,
                    color: colorNetral,
                  ),
                  label: Text(
                    controller.isSubmitting.value
                        ? 'Uploading...'
                        : controller.image.value == null
                            ? 'Select Photo'
                            : 'Upload Photo',
                    style: TextStyle(
                      color: colorNetral,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            if (controller.image.value != null &&
                !controller.photoUploaded.value) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        controller.image.value = null;
                        controller.imageName.value = '';
                      },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ],
      );
    });
  }

  Widget _buildLocalPhotoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            controller.image.value!,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              _showFullScreenPhotoPreview(isLocal: true);
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
    );
  }

  Widget _buildRemotePhotoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            controller.getPhotoUrl(),
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
              _showFullScreenPhotoPreview(isLocal: false);
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
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No photo selected',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhotoPreview({required bool isLocal}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            isLocal
                ? Image.file(
                    controller.image.value!,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    controller.getPhotoUrl(),
                    fit: BoxFit.contain,
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
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: controller.isSubmitting.value
                ? null
                : () {
                    if (isEditMode || controller.isCheckedIn.value) {
                      controller.submitCheckOut(context);
                    } else {
                      if (!controller.photoUploaded.value) {
                        controller.uploadPhoto().then((success) {
                          if (success) {
                            controller.submitCheckIn();
                          }
                        });
                      } else {
                        controller.submitCheckIn();
                      }
                    }
                  },
            icon: Icon(
              (isEditMode || controller.isCheckedIn.value)
                  ? Icons.logout
                  : Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              (isEditMode || controller.isCheckedIn.value)
                  ? 'CHECK OUT'
                  : 'CHECK IN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (isEditMode || controller.isCheckedIn.value)
                  ? Colors.orange
                  : Colors.green,
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTextField(String label, TextEditingController controller,
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

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              "Follow-up Date :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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

  void _showPhotoOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Photo Source',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: colorBlack,
              ),
              title: Text(
                'Take a photo',
                style: TextStyle(
                  fontSize: 16,
                  color: colorBlack,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.takePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: colorBlack),
              title: Text(
                'Choose from gallery',
                style: TextStyle(
                  fontSize: 16,
                  color: colorBlack,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatCheckoutTime(String checkOutTime) {
    final DateTime dateTime = DateTime.parse(checkOutTime).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    contactPersonController.dispose();
    contactNumberController.dispose();
    jobTitleController.dispose();
    super.dispose();
  }
}
