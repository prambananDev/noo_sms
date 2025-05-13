import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/assets/widgets/textfield_sfa.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';
import 'package:noo_sms/models/sfa_model.dart';
import 'package:search_choices/search_choices.dart';

class SfaCreate extends StatefulWidget {
  final SfaRecord? record;
  final bool isDirectCheckIn;

  const SfaCreate({
    Key? key,
    this.record,
    this.isDirectCheckIn = false,
  }) : super(key: key);

  @override
  State<SfaCreate> createState() => _SfaCreateState();
}

class _SfaCreateState extends State<SfaCreate> {
  late final SfaController controller = Get.put(SfaController());

  late final bool isEditMode;
  bool get isCheckedOut =>
      isEditMode &&
      widget.record != null &&
      (widget.record!.status == 2 || widget.record!.status == 3);

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
        controller.isExisting.value = true;
        controller.toggleExistingVal.value = false;
        controller.initializeData();
      }

      if (widget.isDirectCheckIn && widget.record != null) {
        _initializeEditMode();
      }
    });
  }

  void _setupControllerListeners() {
    ever(controller.customerInfo, (CustomerInfo? info) {
      if (mounted && !isEditMode) {
        setState(() {
          controller.nameController.text = info?.name ?? "";
          controller.addressController.text = info?.address ?? "";
          controller.contactPersonController.text = info?.contact ?? "";
          controller.contactNumberController.text = info?.contactNum ?? "";
          controller.jobTitleController.text = info?.contactTitle ?? "";
        });
      }
    });
  }

  void _initializeEditMode() {
    controller.nameController.text = widget.record?.customerName ?? "";
    controller.addressController.text = widget.record?.address ?? "";
    controller.contactPersonController.text =
        widget.record?.contactPerson ?? "";
    controller.contactNumberController.text =
        widget.record?.contactNumber ?? "";
    controller.jobTitleController.text = widget.record?.contactTitle ?? "";

    controller.purposeController.text = widget.record?.purposeDesc ?? "";
    controller.resultsController.text = widget.record?.result ?? "";
    controller.followupController.text = widget.record?.followup ?? "";
    controller.followupDateController.text =
        controller.formatDateString(widget.record?.followupDate);

    controller.selectedCustomerId.value = widget.record?.customer ?? "";
    controller.selectedCustomerName.value = widget.record?.customerName ?? "";

    controller.fetchPurpose();

    if (widget.record?.checkInFoto != null &&
        widget.record!.checkInFoto!.isNotEmpty) {
      controller.uploadedPhotoName.value = widget.record!.checkInFoto!;
      controller.photoUploaded.value = true;
    }

    controller.customerInfo.value = CustomerInfo(
      name: widget.record?.customerName ?? "",
      address: widget.record?.address ?? "",
      contact: widget.record?.contactPerson ?? "",
      contactNum: widget.record?.contactNumber ?? "",
      contactTitle: widget.record?.contactTitle ?? "",
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      controller.loadRecordForEdit(widget.record!);
    });

    controller.isCheckedIn.value = widget.record?.status == 1;
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
                'Customer Visit Update',
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

            if (isEditMode &&
                widget.record!.status == 1 &&
                hasPhoto &&
                !isCheckedOut) {
              return _buildActionButton();
            } else if (isCheckedOut) {
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
        Row(
          children: [
            Text(
              'Prospect : ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 16),
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
      if (controller.isLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.scaleSize(context, 16.0)),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.customers.isEmpty) {
        if (controller.isLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtil.scaleSize(context, 16.0)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return const Center(
          child: Text('No customers available'),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Customer :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.scaleSize(context, 16),
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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaleSize(context, 14),
                    ),
                  ),
                );
              }).toList(),
              value: controller.selectedCustomer.value,
              onChanged: (VisitCustomer? value) {
                if (value != null) {
                  setState(() {
                    controller.saveSelectedCustomer(value);
                  });
                }
              },
              searchFn: (String keyword,
                  List<DropdownMenuItem<VisitCustomer>> items) {
                List<int> matchedIndexes = [];
                for (int i = 0; i < items.length; i++) {
                  VisitCustomer customer = items[i].value as VisitCustomer;
                  if (customer.customerName
                      .toLowerCase()
                      .contains(keyword.toLowerCase())) {
                    matchedIndexes.add(i);
                  }
                }
                return matchedIndexes;
              },
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 14),
              ),
            ),
          )
        ],
      );
    });
  }

  Widget _buildCheckedOutIndicator() {
    final String checkOutTime = widget.record?.checkOut ?? 'Unknown';

    return Container(
      margin:
          EdgeInsets.symmetric(vertical: ResponsiveUtil.scaleSize(context, 24)),
      padding: EdgeInsets.all(ResponsiveUtil.scaleSize(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            BorderRadius.circular(ResponsiveUtil.scaleSize(context, 8)),
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
                size: ResponsiveUtil.scaleSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaleSize(context, 8)),
              Text(
                'CHECKED OUT',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.scaleSize(context, 18),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
          Text(
            'Visit completed on ${_formatCheckoutTime(checkOutTime)}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: ResponsiveUtil.scaleSize(context, 14),
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

      if (controller.isLoadingCustomerInfo.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtil.scaleSize(context, 16.0)),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.scaleSize(context, 24),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
          isCheckedOut
              ? _buildInfoDisplay("Name", controller.nameController.text)
              : _buildInfoTextField("Name", controller.nameController,
                  readOnly: false),
          isCheckedOut
              ? _buildInfoDisplay("Address", controller.addressController.text)
              : _buildInfoTextField("Address", controller.addressController,
                  readOnly: false),
          isCheckedOut
              ? _buildInfoDisplay(
                  "Contact Person", controller.contactPersonController.text)
              : _buildInfoTextField(
                  "Contact Person", controller.contactPersonController,
                  readOnly: false),
          isCheckedOut
              ? _buildInfoDisplay(
                  "Contact Number", controller.contactNumberController.text)
              : _buildInfoTextField(
                  "Contact Number", controller.contactNumberController,
                  readOnly: false),
          isCheckedOut
              ? _buildInfoDisplay(
                  "Job Title", controller.jobTitleController.text)
              : _buildInfoTextField("Job Title", controller.jobTitleController,
                  readOnly: false),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 16)),
          if (isEditMode) ...[
            SizedBox(height: ResponsiveUtil.scaleSize(context, 16)),
            Text(
              'Visit Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 24),
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
            _buildPurposeDropdown(),
            SizedBox(height: ResponsiveUtil.scaleSize(context, 12)),
            isCheckedOut
                ? _buildInfoDisplay(
                    "Purpose Description", controller.purposeController.text)
                : _buildInfoSection(
                    "Purpose Description", controller.purposeController.text,
                    isCheckedOut: isCheckedOut),
            isCheckedOut
                ? _buildInfoDisplay(
                    "Results", controller.resultsController.text)
                : _buildInfoSection(
                    "Results", controller.resultsController.text,
                    isCheckedOut: isCheckedOut),
            isCheckedOut
                ? _buildInfoDisplay("Follow-up Plan Date",
                    controller.followupDateController.text)
                : _buildDatePickerField(),
            isCheckedOut
                ? _buildInfoDisplay(
                    "Follow-up Plan Action", controller.followupController.text)
                : _buildInfoSection(
                    "Follow-up Plan Action", controller.followupController.text,
                    isCheckedOut: isCheckedOut),
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
          SizedBox(
            width: ResponsiveUtil.scaleSize(context, 120),
            child: Text(
              "Purpose :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
          Expanded(
            child: isCheckedOut
                ? Text(
                    controller.selectedPurpose.value?.name ??
                        widget.record?.purposeDesc ??
                        "No purpose specified",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaleSize(context, 16),
                      color: Colors.black87,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtil.scaleSize(context, 12)),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtil.scaleSize(context, 4)),
                    ),
                    child: DropdownButton<VisitPurpose>(
                      value: controller.selectedPurpose.value,
                      isExpanded: true,
                      underline: Container(),
                      hint: Text(
                        "Select a purpose",
                        style: TextStyle(
                          fontSize: ResponsiveUtil.scaleSize(context, 14),
                        ),
                      ),
                      onChanged: (VisitPurpose? newValue) {
                        if (newValue != null) {
                          controller.selectedPurpose.value = newValue;
                        }
                      },
                      items: controller.purpose
                          .map<DropdownMenuItem<VisitPurpose>>(
                              (VisitPurpose purpose) {
                        return DropdownMenuItem<VisitPurpose>(
                          value: purpose,
                          child: Text(
                            purpose.name,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaleSize(context, 14),
                            ),
                          ),
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
          SizedBox(height: ResponsiveUtil.scaleSize(context, 24)),
          Text(
            'Visit Check-In Photo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.scaleSize(context, 18),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 16)),
          Container(
            width: double.infinity,
            height: ResponsiveUtil.scaleSize(context, 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius:
                  BorderRadius.circular(ResponsiveUtil.scaleSize(context, 16)),
            ),
            child: controller.image.value != null
                ? _buildLocalPhotoPreview()
                : controller.photoUploaded.value
                    ? _buildRemotePhotoPreview()
                    : _buildEmptyPhotoPlaceholder(),
          ),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
          if (controller.image.value != null) ...[
            Text(
              'File: ${controller.imageName.value}',
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 12),
                color: Colors.grey,
              ),
            ),
          ] else if (controller.photoUploaded.value) ...[
            Text(
              'File: ${controller.uploadedPhotoName.value}',
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 12),
                color: Colors.grey,
              ),
            ),
          ],
          if (!isCheckedOut && !controller.isCheckedIn.value) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () {
                            controller.takePhoto().then((_) {
                              if (controller.image.value != null) {
                                controller.uploadPhoto();
                              }
                            });
                          },
                    icon: Icon(
                      Icons.camera_alt,
                      color: colorNetral,
                      size: ResponsiveUtil.scaleSize(context, 18),
                    ),
                    label: Text(
                      'Camera',
                      style: TextStyle(
                        color: colorNetral,
                        fontSize: ResponsiveUtil.scaleSize(context, 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtil.scaleSize(context, 14)),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtil.scaleSize(context, 10)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () {
                            controller.pickImageFromGallery().then((_) {
                              if (controller.image.value != null) {
                                controller.uploadPhoto();
                              }
                            });
                          },
                    icon: Icon(
                      Icons.photo_library,
                      color: colorNetral,
                      size: ResponsiveUtil.scaleSize(context, 18),
                    ),
                    label: Text(
                      'Gallery',
                      style: TextStyle(
                        color: colorNetral,
                        fontSize: ResponsiveUtil.scaleSize(context, 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtil.scaleSize(context, 14)),
                    ),
                  ),
                ),
              ],
            ),
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
          borderRadius:
              BorderRadius.circular(ResponsiveUtil.scaleSize(context, 8)),
          child: Image.file(
            controller.image.value!,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: ResponsiveUtil.scaleSize(context, 8),
          right: ResponsiveUtil.scaleSize(context, 8),
          child: GestureDetector(
            onTap: () {
              _showFullScreenPhotoPreview(isLocal: true);
            },
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtil.scaleSize(context, 4)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: ResponsiveUtil.scaleSize(context, 20),
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
          borderRadius:
              BorderRadius.circular(ResponsiveUtil.scaleSize(context, 8)),
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
                      size: ResponsiveUtil.scaleSize(context, 48),
                      color: Colors.red[400],
                    ),
                    SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
                    Text(
                      'Error loading image',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: ResponsiveUtil.scaleSize(context, 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: ResponsiveUtil.scaleSize(context, 8),
          right: ResponsiveUtil.scaleSize(context, 8),
          child: GestureDetector(
            onTap: () {
              _showFullScreenPhotoPreview(isLocal: false);
            },
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtil.scaleSize(context, 4)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: ResponsiveUtil.scaleSize(context, 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenPhotoPreview({required bool isLocal}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(ResponsiveUtil.scaleSize(context, 8)),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin:
                  EdgeInsets.all(ResponsiveUtil.scaleSize(context, 20)),
              minScale: 0.5,
              maxScale: 4.0,
              child: isLocal
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
            ),
            Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.all(ResponsiveUtil.scaleSize(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: ResponsiveUtil.scaleSize(context, 24),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: ResponsiveUtil.scaleSize(context, 48),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtil.scaleSize(context, 8)),
          Text(
            'No photo selected',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveUtil.scaleSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        SizedBox(height: ResponsiveUtil.scaleSize(context, 24)),
        SizedBox(
          width: double.infinity,
          height: ResponsiveUtil.scaleSize(context, 50),
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
              size: ResponsiveUtil.scaleSize(context, 24),
            ),
            label: Text(
              (isEditMode || controller.isCheckedIn.value)
                  ? 'CHECK OUT'
                  : 'CHECK IN',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtil.scaleSize(context, 18),
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
        SizedBox(height: ResponsiveUtil.scaleSize(context, 24)),
      ],
    );
  }

  Widget _buildInfoDisplay(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtil.scaleSize(context, 8.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaleSize(context, 120),
            child: Text(
              "$label :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "No $label specified",
              style: TextStyle(
                fontSize: ResponsiveUtil.scaleSize(context, 16),
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTextField(String label, TextEditingController controller,
      {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtil.scaleSize(context, 8.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaleSize(context, 120),
            child: Text(
              "$label :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
          Expanded(
            child: StableTextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: maxLines,
              hintText: readOnly ? "" : "Enter $label",
              keyboardType: label.toLowerCase().contains("contact number")
                  ? TextInputType.phone
                  : TextInputType.text,
              inputFormatters: label.toLowerCase().contains("contact number")
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value,
      {bool isCheckedOut = false}) {
    if (isCheckedOut) {
      return Padding(
        padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtil.scaleSize(context, 8.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ResponsiveUtil.scaleSize(context, 120),
              child: Text(
                "$label : ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.scaleSize(context, 16),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : "No $label specified",
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaleSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    TextEditingController textController;
    if (label == "Purpose Description") {
      textController = controller.purposeController;
    } else if (label == "Results") {
      textController = controller.resultsController;
    } else if (label == "Follow-up Plan Action") {
      textController = controller.followupController;
    } else {
      textController = TextEditingController(text: value);
    }

    return _buildInfoTextField(
      label,
      textController,
      maxLines: 3,
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtil.scaleSize(context, 8.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaleSize(context, 120),
            child: Text(
              "Follow-up Plan Date : ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaleSize(context, 16),
              ),
            ),
          ),
          Expanded(
            child: StableTextField(
              controller: controller.followupDateController,
              readOnly: true,
              hintText: "Select date",
              style: TextStyle(fontSize: ResponsiveUtil.scaleSize(context, 16)),
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

  String _formatCheckoutTime(String checkOutTime) {
    final DateTime dateTime = DateTime.parse(checkOutTime).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
