import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/models/edit_cust_noo_model.dart';
import 'package:noo_sms/controllers/edit_customer/customer_detail_controller.dart';

class PaymentTermDropdownField extends StatelessWidget {
  final String label;
  final CustomerDetailFormController controller;
  final bool isRequired;
  final String? validationText;

  const PaymentTermDropdownField({
    Key? key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.validationText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Text Field with Dropdown functionality
          TextFormField(
            controller: controller.paymentTermController,
            readOnly: true, // Make it read-only so user must use dropdown
            decoration: InputDecoration(
              hintText: 'Select $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              suffixIcon: Obx(() => controller.isLoadingPaymentTerms.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      Icons.arrow_drop_down,
                      color: controller.paymentTerms.isNotEmpty
                          ? Colors.grey.shade600
                          : Colors.orange,
                    )),
            ),
            onTap: () => _showPaymentTermDialog(context),
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return validationText ?? 'Please select $label';
                    }
                    return null;
                  }
                : null,
          ),

          // Show selected payment term description
          Obx(() {
            final selectedTerm = controller.selectedPaymentTerm.value;
            if (selectedTerm != null && selectedTerm.desc.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedTerm.desc} (${selectedTerm.numOfDays} days)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Segment: ${selectedTerm.segment}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Error message for empty list
          Obx(() {
            if (!controller.isLoadingPaymentTerms.value &&
                controller.paymentTerms.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'No payment terms available',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.fetchPaymentTerms(),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showPaymentTermDialog(BuildContext context) {
    if (controller.paymentTerms.isEmpty) {
      // Show message if no payment terms available
      Get.snackbar(
        'No Data',
        'No payment terms available. Please try refreshing.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.paymentTerms.length,
              itemBuilder: (context, index) {
                final term = controller.paymentTerms[index];
                final isSelected =
                    controller.paymentTermController.text == term.paymTermId;

                return ListTile(
                  title: Text(
                    term.paymTermId,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${term.desc} (${term.numOfDays} days)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Segment: ${term.segment}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    controller.updateSelectedPaymentTerm(term);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (controller.paymentTermController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  controller.updateSelectedPaymentTerm(null);
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
          ],
        );
      },
    );
  }
}
