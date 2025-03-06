import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/noo/approval_controller.dart';
import 'package:noo_sms/models/noo_approval.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    Future.microtask(() {
      if (widget.id != null) {
        controller.fetchApprovalDetail(widget.id!);
      }
      _initializeCreditLimit();
    });
  }

  Future<void> _initializeCreditLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final editApproval = prefs.getInt("EditApproval") ?? 0;

    if (editApproval == 1) {
      await Future.delayed(Duration.zero);
      controller.creditLimitController.text =
          controller.currentApproval.value.creditLimit?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Approval Detail",
          style: TextStyle(color: colorNetral),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomCard(_buildBasicInformation()),
              _buildCustomCard(_buildCompanyAddress()),
              _buildCustomCard(_buildTaxAddress()),
              _buildCustomCard(_buildDeliveryAddress()),
              _buildCustomCard(_buildDocuments()),
              if (widget.role != "2") ...[
                _buildDivider(),
                _buildCustomCard(Column(
                  children: [
                    _buildSignatureSection(),
                    _buildRemarkSection(),
                    _buildPaymentAndCreditSection(),
                  ],
                )),
                const SizedBox(height: 16),
                _buildApprovalButtons(context),
              ],
            ],
          ),
        );
      }),
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

  Widget _buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        detailRow("Customer Name", controller.currentApproval.value.custName),
        detailRow("Brand Name", controller.currentApproval.value.brandName),
        detailRow("Sales Office", controller.currentApproval.value.salesOffice),
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

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Divider(height: 8),
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
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        detailRow("Street", address.streetName),
        detailRow("City", address.city),
        detailRow("Postal Code", address.zipCode.toString()),
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
            'Foto Gedung Depan', controller.currentApproval.value.fotoGedung1),
        _buildImageViewer(
            'Foto Gedung Dalam', controller.currentApproval.value.fotoGedung2),
        _buildImageViewer(
            'Foto SPPKP', controller.currentApproval.value.fotoGedung3),
        _buildImageViewer('Foto Competitor TOP',
            controller.currentApproval.value.fotoCompetitorTop),
      ],
    );
  }

  Widget _buildImageViewer(String title, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Text(
          'Image not found',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colorBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Image.network(
            '${apiNOO}Files/GetFiles?fileName=$imageUrl',
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Image not found',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Signature'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Signature(
            controller: controller.getSignatureController(widget.id!),
            height: 150,
            width: double.infinity,
            backgroundColor: Colors.grey[200]!,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Remark'),
        TextField(
          controller: controller.getRemarkController(widget.id!),
          decoration: const InputDecoration(hintText: "Enter remark here"),
        ),
      ],
    );
  }

  Widget _buildPaymentAndCreditSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment and Credit'),
          GetBuilder<ApprovalController>(
            builder: (controller) {
              return FutureBuilder<int>(
                future: _getEditApproval(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data == 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit Limit',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextField(
                          controller:
                              controller.getCreditLimitController(widget.id!),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              if (newValue.text.isEmpty) {
                                return newValue;
                              }
                              String formatted = controller
                                  .formatNumberForDisplay(newValue.text);
                              return TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                    offset: formatted.length),
                              );
                            }),
                          ],
                          decoration: const InputDecoration(
                            hintText: "Enter credit limit",
                          ),
                        ),
                        GetBuilder<ApprovalController>(
                          id: 'credit-range-info',
                          builder: (controller) {
                            final isLoading =
                                controller.isCreditLimitLoading.value;
                            if (!isLoading) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Credit limit range ${controller.formatCurrency(controller.minCreditLimit.value)} - ${controller.formatCurrency(controller.maxCreditLimit.value)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Loading credit limit range...",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        GetBuilder<ApprovalController>(
                          id: 'credit-limit-error${widget.id}',
                          builder: (controller) {
                            final error =
                                controller.getCreditLimitError(widget.id!);
                            if (error.isNotEmpty) {
                              return Text(
                                error,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GetBuilder<ApprovalController>(
                            id: 'payment-terms-${widget.id}',
                            builder: (controller) {
                              final selectedTerm =
                                  controller.getSelectedPaymentTerm(widget.id!);
                              final paymentTermsList = controller.paymentTerms;
                              final bool isValidSelection =
                                  selectedTerm.isEmpty ||
                                      paymentTermsList.contains(selectedTerm);

                              if (!isValidSelection &&
                                  controller.paymentTerms.isNotEmpty) {
                                Future.microtask(() {
                                  controller.setSelectedPaymentTerm(
                                      widget.id!,
                                      controller.paymentTerms.isNotEmpty
                                          ? controller.paymentTerms.first
                                          : "");
                                });
                              }

                              return DropdownButtonFormField<String>(
                                value:
                                    isValidSelection && selectedTerm.isNotEmpty
                                        ? selectedTerm
                                        : null,
                                items: paymentTermsList.map((term) {
                                  return DropdownMenuItem(
                                    value: term,
                                    child: Text(term),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.setSelectedPaymentTerm(
                                        widget.id!, value);
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Payment Terms',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    );
                  } else {
                    return detailRow(
                      'Credit Limit',
                      controller.currentApproval.value.creditLimit.toString(),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<int> _getEditApproval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("EditApproval") ?? 0;
  }

  Widget _buildApprovalButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRejectConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reject',
              style: TextStyle(
                color: colorNetral,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showApproveConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Approve',
              style: TextStyle(
                color: colorNetral,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmation() {
    final isLoading = controller.isCreditLimitLoading.value;

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Approval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to approve this request?'),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Warning: Credit limit range validation is still loading.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorAccent),
              ),
            ),
            TextButton(
              onPressed: () async {
                final creditLimitText =
                    controller.getCreditLimitController(widget.id!).text;

                // Use captured loading state
                bool skipValidation = isLoading;

                if (!skipValidation) {
                  bool isValid = controller.validateCreditLimitForSubmission(
                      widget.id!, creditLimitText);

                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please correct the credit limit value'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                await controller.processApproval(
                  context,
                  widget.id!,
                  controller.getRemarkController(widget.id!).text,
                  skipValidation,
                );

                Navigator.of(context).pop();
              },
              child: Text(
                'Approve',
                style: TextStyle(color: colorAccent),
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
