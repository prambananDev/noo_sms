import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';

class HistoryLinesController extends GetxController {
  final programNameController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  var isInitialized = false.obs;

  var customerGroupOptions = ['Customer', 'Group'].obs;
  var selectedCustomerGroup = ''.obs;

  var promotionLines = <PromotionProgramInputState>[].obs;

  void initialize(String? numberPP) {
    // Initialize your data here
    fetchActivity(numberPP);
  }

  void fetchActivity(String? numberPP) async {
    // Fetch activity and populate fields here
    // Simulating API call and setting initial values
    programNameController.text = "Fetched Program Name";
    selectedCustomerGroup.value = "Customer";

    fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Simulate fetching lines
    promotionLines.add(PromotionProgramInputState());
    isInitialized.value = true;
  }

  void onCustomerGroupChanged(String? value) {
    selectedCustomerGroup.value = value!;
  }

  void submitForm() {
    // Form submission logic
  }

  void onBackPress() {
    Get.back(); // Goes back to the previous page
  }
}
