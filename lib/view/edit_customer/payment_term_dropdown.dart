import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16.rt(context),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.rt(context),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.rs(context)),

          // Text Field with Dropdown functionality
          TextFormField(
            controller: controller.paymentTermController,
            readOnly: true, // Make it read-only so user must use dropdown
            style: TextStyle(fontSize: 16.rt(context)),
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: TextStyle(fontSize: 16.rt(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.rr(context)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.rr(context)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.rr(context)),
                borderSide:
                    BorderSide(color: Colors.blue, width: 2.rs(context)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.rp(context),
                vertical: 16.rp(context),
              ),
              suffixIcon: Obx(() => controller.isLoadingPaymentTerms.value
                  ? SizedBox(
                      width: 20.rs(context),
                      height: 20.rs(context),
                      child: Padding(
                        padding: EdgeInsets.all(12.rp(context)),
                        child: CircularProgressIndicator(
                            strokeWidth: 2.rs(context)),
                      ),
                    )
                  : Icon(
                      Icons.arrow_drop_down,
                      size: 24.ri(context),
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
                padding: EdgeInsets.only(top: 4.rs(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedTerm.desc} (${selectedTerm.numOfDays} days)',
                      style: TextStyle(
                        fontSize: 12.rt(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Segment: ${selectedTerm.segment}',
                      style: TextStyle(
                        fontSize: 11.rt(context),
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
                padding: EdgeInsets.only(top: 8.rs(context)),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 16.ri(context),
                    ),
                    SizedBox(width: 4.rp(context)),
                    Text(
                      'No payment terms available',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12.rt(context),
                      ),
                    ),
                    SizedBox(width: 8.rp(context)),
                    GestureDetector(
                      onTap: () => controller.fetchPaymentTerms(),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12.rt(context),
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
          title: Text(
            'Select $label',
            style: TextStyle(fontSize: 18.rt(context)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.rp(context),
            vertical: 12.rp(context),
          ),
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.rp(context),
                    vertical: 4.rp(context),
                  ),
                  title: Text(
                    term.paymTermId,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.rt(context),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${term.desc} (${term.numOfDays} days)',
                        style: TextStyle(fontSize: 12.rt(context)),
                      ),
                      Text(
                        'Segment: ${term.segment}',
                        style: TextStyle(
                          fontSize: 11.rt(context),
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
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16.rt(context)),
              ),
            ),
            if (controller.paymentTermController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  controller.updateSelectedPaymentTerm(null);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
          ],
        );
      },
    );
  }
}
