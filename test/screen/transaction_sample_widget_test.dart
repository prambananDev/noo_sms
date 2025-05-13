import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/controllers/sample_order/transaction_sample_controller.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/wrapper.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:noo_sms/view/sample_order/transaction_sample.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Adjust path as needed

// Creating a mock class for the controller
class MockTransactionSampleController extends GetxService
    with Mock
    implements TransactionSampleController {
  // Override reactive properties
  @override
  final Rx<InputPageWrapper> promotionProgramInputStateRx =
      InputPageWrapper(promotionProgramInputState: [], isAddItem: false).obs;

  @override
  final Rx<TextEditingController> purposeDescTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> custNameTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> custPicTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> custPhoneTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> custAddressTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> salesIdTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<TextEditingController> invoiceIdTextEditingControllerRx =
      TextEditingController().obs;

  @override
  final Rx<InputPageDropdownState<IdAndValue<String>>> typesList =
      InputPageDropdownState<IdAndValue<String>>(choiceList: [
    IdAndValue<String>(id: "0", value: "Commercial"),
    IdAndValue<String>(id: "1", value: "Non Commercial")
  ], loadingState: 2)
          .obs;

  @override
  final Rx<InputPageDropdownState<IdAndValue<String>>> purposeList =
      InputPageDropdownState<IdAndValue<String>>(choiceList: [
    IdAndValue<String>(id: "0", value: "Purpose 1"),
    IdAndValue<String>(id: "1", value: "Purpose 2")
  ], loadingState: 2)
          .obs;

  @override
  final Rx<InputPageDropdownState<IdAndValue<String>>> deptList =
      InputPageDropdownState<IdAndValue<String>>(choiceList: [
    IdAndValue<String>(id: "0", value: "Department 1"),
    IdAndValue<String>(id: "1", value: "Department 2")
  ], loadingState: 2)
          .obs;

  @override
  final Rx<InputPageDropdownState<IdAndValue<String>>>
      customerNameInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>(choiceList: [
    IdAndValue<String>(id: "prospect", value: "Prospect"),
    IdAndValue<String>(id: "1", value: "Customer 1")
  ], loadingState: 2)
          .obs;

  @override
  final Rx<InputPageDropdownState<IdAndValue<String>>> distributionChannelList =
      InputPageDropdownState<IdAndValue<String>>(choiceList: [
    IdAndValue<String>(id: "0", value: "Channel 1"),
    IdAndValue<String>(id: "1", value: "Channel 2")
  ], loadingState: 2)
          .obs;

  @override
  final RxBool isProspectValid = false.obs;

  @override
  final RxString uploadedFileName = ''.obs;

  // Mock methods
  @override
  Future<void> requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
    } else {}

    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
    } else if (storageStatus.isDenied) {
    } else if (storageStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void addItem() {
    promotionProgramInputStateRx.value.promotionProgramInputState.add(
        PromotionProgramInputState(
            productTransactionPageDropdownState:
                WrappedInputPageDropdownState<IdAndValue<String>>(
                    choiceListWrapper: Wrapper<List<IdAndValue<String>>>(
                        value: [
                          IdAndValue<String>(id: "1", value: "Product 1")
                        ]),
                    loadingStateWrapper: Wrapper<int>(value: 2),
                    selectedChoiceWrapper:
                        Wrapper<IdAndValue<String>>(value: null)),
            unitPageDropdownState: InputPageDropdownState<String>(
                choiceList: ["Unit 1", "Unit 2"], loadingState: 2),
            qtyTransaction: TextEditingController(text: "1")));
    promotionProgramInputStateRx.refresh();
  }

  @override
  void removeItem(int index) {
    if (index <
        promotionProgramInputStateRx.value.promotionProgramInputState.length) {
      promotionProgramInputStateRx.value.promotionProgramInputState
          .removeAt(index);
      promotionProgramInputStateRx.refresh();
    }
  }

  @override
  void changeQty(int index, String qty) {
    if (index <
        promotionProgramInputStateRx.value.promotionProgramInputState.length) {
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].qtyTransaction?.text = qty;
      promotionProgramInputStateRx.refresh();
    }
  }

  @override
  void changeProduct(int index, IdAndValue<String> selectedChoice) {
    if (index <
        promotionProgramInputStateRx.value.promotionProgramInputState.length) {
      promotionProgramInputStateRx
          .value
          .promotionProgramInputState[index]
          .productTransactionPageDropdownState
          ?.selectedChoiceWrapper
          ?.value = selectedChoice;
      promotionProgramInputStateRx.refresh();
    }
  }

  @override
  void changeUnit(int index, String? selectedChoice) {
    if (index <
        promotionProgramInputStateRx.value.promotionProgramInputState.length) {
      promotionProgramInputStateRx.value.promotionProgramInputState[index]
          .unitPageDropdownState?.selectedChoice = selectedChoice;
      promotionProgramInputStateRx.refresh();
    }
  }

  @override
  void changeSampleType(IdAndValue<String>? selectedChoice) {
    typesList.value.selectedChoice = selectedChoice;
    typesList.refresh();
  }

  @override
  void changePurpose(IdAndValue<String>? newValue) {
    purposeList.value.selectedChoice = newValue;
    purposeList.refresh();
  }

  @override
  void changeDept(IdAndValue<String>? newValue) {
    deptList.value.selectedChoice = newValue;
    deptList.refresh();
  }

  @override
  void changeSelectCustomer(IdAndValue<String>? selectedChoice) {
    customerNameInputPageDropdownStateRx.value.selectedChoice = selectedChoice;
    customerNameInputPageDropdownStateRx.refresh();
  }

  @override
  Future<void> submitPromotionProgram() async {
    if (!validateSubmission()) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    final int idEmp =
        int.tryParse(preferences.getString("scs_idEmp") ?? '0') ?? 0;

    final isiBody = jsonEncode({
      "sampleType": typesList.value.selectedChoice?.id,
      "samplePurpose": purposeList.value.selectedChoice?.id,
      "description": purposeDescTextEditingControllerRx.value.text,
      "custid": customerNameInputPageDropdownStateRx.value.selectedChoice?.id,
      "custName": customerNameInputPageDropdownStateRx
                  .value.selectedChoice?.id ==
              'prospect'
          ? custNameTextEditingControllerRx.value.text
          : customerNameInputPageDropdownStateRx.value.selectedChoice?.value,
      "distrChannel": distributionChannelList.value.selectedChoice?.id,
      "custPIC": custPicTextEditingControllerRx.value.text,
      "custPhone": custPhoneTextEditingControllerRx.value.text,
      "custAddress": custAddressTextEditingControllerRx.value.text,
      "idEmp": idEmp,
      "dept": deptList.value.selectedChoice?.id,
      "salesIdAX": custPicTextEditingControllerRx.value.text,
      "invoiceIdAX": custPicTextEditingControllerRx.value.text,
      "attachment": uploadedFileName.value,
      "lines": promotionProgramInputStateRx.value.promotionProgramInputState
          .map((element) => {
                "itemId": element.productTransactionPageDropdownState
                    ?.selectedChoiceWrapper?.value?.id,
                "qty": element.qtyTransaction!.text.isEmpty
                    ? 0
                    : element.qtyTransaction!.text,
                "unit": element.unitPageDropdownState?.selectedChoice,
              })
          .toList(),
    });

    var url = '$apiSCS/api/SampleTransaction';
    final response = await post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        'Authorization': '$token',
      },
      body: isiBody,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      Get.dialog(
        const SimpleDialog(
          title: Text("Success"),
          children: [
            Center(child: CircularProgressIndicator()),
          ],
        ),
        barrierDismissible: false,
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
        resetAllControllers();
        DashboardOrderSampleState.tabController.animateTo(1);
      });
    } else {
      Get.dialog(
        SimpleDialog(
          title: const Text("Error"),
          children: [
            Center(
              child: Text(
                "${response.statusCode}\n${response.body.replaceAll(r"\'", "'")}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const Center(child: Icon(Icons.error)),
          ],
        ),
      );
    }
  }

  // Mock validateSubmission to avoid snackbar errors
  @override
  bool validateSubmission() {
    return true;
  }
}

void main() {
  // Initialize Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTransactionSampleController mockController;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;

    // Override snackbar to avoid issues
    // Create mock controller
    mockController = MockTransactionSampleController();

    // Register the mock controller with GetX
    Get.put<TransactionSampleController>(mockController);

    // Create mock controller
    mockController = MockTransactionSampleController();

    // Register the mock controller with GetX
    Get.put<TransactionSampleController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('TransactionSample initializes with basic UI elements',
      (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(
      const GetMaterialApp(
        home: TransactionSample(),
      ),
    );

    // Wait for all animations to complete
    await tester.pumpAndSettle();

    // Verify basic elements exist
    expect(find.text("Create New Sample Order"), findsOneWidget);
    expect(find.text("Sample Types"), findsOneWidget);
    expect(find.text("Purpose Description"), findsOneWidget);

    // Verify "Add New Data" button exists
    expect(find.text("Add New Data"), findsOneWidget);
  });
}
