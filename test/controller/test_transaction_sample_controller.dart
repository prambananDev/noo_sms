import 'package:noo_sms/controllers/sample_order/transaction_sample_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';

// Custom subclass of TransactionSampleController for testing
class TestTransactionSampleController extends TransactionSampleController {
  // Store validation messages for verification in tests
  List<String> validationMessages = [];

  @override
  bool validateSubmission() {
    if (typesList.value.selectedChoice == null) {
      validationMessages.add('Please select Sample Type');
      return false;
    }

    if (purposeList.value.selectedChoice == null) {
      validationMessages.add('Please select Purpose');
      return false;
    }

    if (purposeDescTextEditingControllerRx.value.text.isEmpty) {
      validationMessages.add('Please enter Purpose Description');
      return false;
    }

    if (promotionProgramInputStateRx.value.promotionProgramInputState.isEmpty) {
      validationMessages.add('Please add at least one product');
      return false;
    }

    for (var i = 0;
        i <
            promotionProgramInputStateRx
                .value.promotionProgramInputState.length;
        i++) {
      var element =
          promotionProgramInputStateRx.value.promotionProgramInputState[i];

      if (element.productTransactionPageDropdownState?.selectedChoiceWrapper
              ?.value ==
          null) {
        validationMessages.add('Please select product for line ${i + 1}');
        return false;
      }

      if (element.qtyTransaction?.text.isEmpty == true ||
          element.qtyTransaction?.text == "0") {
        validationMessages.add('Please enter quantity for line ${i + 1}');
        return false;
      }

      if (element.unitPageDropdownState?.selectedChoice == null) {
        validationMessages.add('Please select unit for line ${i + 1}');
        return false;
      }
    }

    if (typesList.value.selectedChoice?.value == 'Commercial') {
      if (customerNameInputPageDropdownStateRx.value.selectedChoice == null) {
        validationMessages.add('Please select Customer Name');
        return false;
      }

      if (customerNameInputPageDropdownStateRx.value.selectedChoice?.id ==
          'prospect') {
        if (custNameTextEditingControllerRx.value.text.isEmpty ||
            custPicTextEditingControllerRx.value.text.isEmpty ||
            custPhoneTextEditingControllerRx.value.text.isEmpty ||
            custAddressTextEditingControllerRx.value.text.isEmpty) {
          validationMessages.add('Please fill all prospect customer details');
          return false;
        }

        if (distributionChannelList.value.selectedChoice == null) {
          validationMessages.add('Please select Distribution Channel');
          return false;
        }
      }
    } else {
      if (deptList.value.selectedChoice == null) {
        validationMessages.add('Please select Department');
        return false;
      }
    }

    return true;
  }

  // Override other methods that use Get.snackbar if needed
  // For example, submitPromotionProgram if it shows dialogs or snackbars

  // Make _resetAllControllers accessible for testing
  @override
  void resetAllControllers() {
    super.resetAllControllers();
  }
}
