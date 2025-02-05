import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/input_pp_model.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/wrapper.dart';
import 'package:noo_sms/view/dashboard/dashboard_ordertaking.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TransactionController extends GetxController {
  var inputItems = <InputPageModel>[].obs;
  RxBool onTap = false.obs;
  RxList listDataPrincipal = [].obs;
  RxList<int> selectedDataPrincipal = <int>[].obs;
  RxString valPrincipal = "".obs;

  Rx<InputPageWrapper> promotionProgramInputStateRx =
      InputPageWrapper(promotionProgramInputState: [], isAddItem: false).obs;
  Rx<TextEditingController> transactionNumberTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> transactionDateTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programNumberTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programTestTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programNameTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programNoteTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programFromDateTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> programToDateTextEditingControllerRx =
      TextEditingController().obs;
  Rx<InputPageDropdownState<IdAndValue<String>>>
      promotionTypeInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;
  Rx<InputPageDropdownState<IdAndValue<String>>>
      locationInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;
  Rx<InputPageDropdownState<IdAndValue<String>>>
      vendorInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;
  Rx<InputPageDropdownState<String>> statusTestingInputPageDropdownStateRx =
      InputPageDropdownState<String>().obs;
  Rx<InputPageDropdownState<String>> customerGroupInputPageDropdownState =
      InputPageDropdownState<String>(choiceList: <String>[
    "Customer",
  ], loadingState: 2)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>>
      custNameHeaderValueDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  Rx<InputPageDropdownState<IdAndValue<String>>>
      customerNameInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  final WrappedInputPageDropdownState<IdAndValue<String>>
      _productInputPageDropdownState =
      WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper: Wrapper(value: <IdAndValue<String>>[]),
          loadingStateWrapper: Wrapper(value: 0),
          selectedChoiceWrapper: Wrapper(value: null));

  WrappedInputPageDropdownState<IdAndValue<String>>
      batchTransactionDropdownState =
      WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper: Wrapper(value: <IdAndValue<String>>[]),
          loadingStateWrapper: Wrapper(value: 0),
          selectedChoiceWrapper: Wrapper(value: null));
  WrappedInputPageDropdownState<IdAndValue<String>>
      unitTransactionDropdownState =
      WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper: Wrapper(value: <IdAndValue<String>>[]),
          loadingStateWrapper: Wrapper(value: 0),
          selectedChoiceWrapper: Wrapper(value: null));

  @override
  void onInit() {
    super.onInit();
    _loadCustomerNameByUsername();
    _loadProduct();
    _loadLocation();
  }

  void _loadLocation() async {
    locationInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    try {
      var urlGetLocation = "$apiCons/api/SalesOffices";
      final response = await get(Uri.parse(urlGetLocation));
      var listData = jsonDecode(response.body);

      locationInputPageDropdownStateRx.value.loadingState = 2;
      locationInputPageDropdownStateRx.value.choiceList = listData
          .map<IdAndValue<String>>((element) => IdAndValue<String>(
              id: element["CodeSO"], value: element["NameSO"]))
          .toList();
    } catch (e) {
      locationInputPageDropdownStateRx.value.loadingState = -1;
      _updateState();
    }
  }

  Future<void> loadProgramData(String programNumber) async {
    var url = '$apiCons/api/activity/$programNumber';
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      programNoteTextEditingControllerRx.value.text = data['note'] ?? '';
      programNameTextEditingControllerRx.value.text = data['number'] ?? '';

      if (data['fromDate'] != null) {
        programFromDateTextEditingControllerRx.value.text =
            DateFormat('dd-MM-yyyy').format(DateTime.parse(data['fromDate']));
      }

      if (data['toDate'] != null) {
        programToDateTextEditingControllerRx.value.text =
            DateFormat('dd-MM-yyyy').format(DateTime.parse(data['toDate']));
      }

      // Handling dropdowns, selected principal, etc.
      if (data['vendor'] != null) {
        int index = listDataPrincipal.indexOf(data['vendor']);
        if (index != -1) {
          selectedDataPrincipal.add(index);
        }
      }

      // If there are any lines or items to be prefilled for editing
      promotionProgramInputStateRx.value.promotionProgramInputState =
          data['activityLinesEdit'].map<PromotionProgramInputState>((line) {
        return PromotionProgramInputState(
          qtyFrom: TextEditingController(text: line['qtyFrom'].toString()),
          qtyTo: TextEditingController(text: line['qtyTo'].toString()),
          salesPrice:
              TextEditingController(text: line['salesPrice'].toString()),
          // Populate other form elements if needed
        );
      }).toList();

      update();
    } else {}
  }

  void _loadCustomerNameByUsername() async {
    customerNameInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    try {
      var urlGetCustomer = "$apiCons2/api/AllCustomer?username=$username";

      final response = await get(Uri.parse(urlGetCustomer));
      var listData = jsonDecode(response.body);

      customerNameInputPageDropdownStateRx.value.loadingState = 2;
      customerNameInputPageDropdownStateRx.value.choiceList = listData
          .map<IdAndValue<String>>((element) => IdAndValue<String>(
              id: element["codeCust"], value: element["nameCust"]))
          .toList();
      _updateState();
    } catch (e) {
      customerNameInputPageDropdownStateRx.value.loadingState = -1;
      _updateState();
    }
  }

  Future<void> _loadProduct() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    _productInputPageDropdownState.loadingStateWrapper?.value = 1;
    _updateState();
    var urlGetProduct = "$apiCons2/api/AllProduct?ID=$username&idSales=Sample";
    final response = await get(Uri.parse(urlGetProduct));
    var listData = jsonDecode(response.body);
    _productInputPageDropdownState.loadingStateWrapper?.value = 2;
    _productInputPageDropdownState.choiceListWrapper?.value = listData
        .map<IdAndValue<String>>((element) => IdAndValue<String>(
            id: element["itemId"].toString(), value: element["itemName"]))
        .toList();
    _updateState();
  }

  void _loadUnit(int index) async {
    PromotionProgramInputState promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    final selectProductPageDropdownState = promotionProgramInputState
        .productTransactionPageDropdownState?.selectedChoiceWrapper?.value?.id;
    InputPageDropdownState<String>? unitPageDropdownState =
        promotionProgramInputState.unitPageDropdownState;
    var urlGetUnit = "$apiCons2/api/Unit?item=$selectProductPageDropdownState";

    final response = await get(Uri.parse(urlGetUnit));

    var listData = jsonDecode(response.body);
    unitPageDropdownState!.choiceList = listData.map<String>((element) {
      return element.toString();
    }).toList();
    update();
  }

  void changeSelectCustomer2(IdAndValue<String> selectedChoice) {
    customerNameInputPageDropdownStateRx.value.selectedChoice = selectedChoice;

    checkAddItemStatus2();
  }

  void addItem() {
    List<PromotionProgramInputState> promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState;
    promotionProgramInputState.add(
      PromotionProgramInputState(
        productTransactionPageDropdownState:
            _productInputPageDropdownState.copy(
          choiceListWrapper: _productInputPageDropdownState.choiceListWrapper,
          loadingStateWrapper:
              _productInputPageDropdownState.loadingStateWrapper,
          selectedChoiceWrapper: Wrapper<IdAndValue<String>>(value: null),
        ),
        priceTransaction: TextEditingController(),
        discTransaction: TextEditingController(),
        qtyTransaction: TextEditingController(),
        totalTransaction: TextEditingController(),
        unitPageDropdownState:
            InputPageDropdownState<String>(choiceList: [], loadingState: 0),
      ),
    );
    _updateState();
  }

  void changeProduct(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx
        .value
        .promotionProgramInputState[index]
        .productTransactionPageDropdownState
        ?.selectedChoiceWrapper
        ?.value = selectedChoice;

    update();
    _loadUnit(index);
  }

  List<String> originalPrice = [];

  void changeUnit(int index, String selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .unitPageDropdownState!.selectedChoice = selectedChoice;
    _updateState();
  }

  void changeQty(int index, String qty) {
    double price = promotionProgramInputStateRx.value
            .promotionProgramInputState[index].priceTransaction!.text.isEmpty
        ? 0
        : double.parse(promotionProgramInputStateRx
            .value.promotionProgramInputState[index].priceTransaction!.text
            .replaceAll(RegExp(r"[.,]"), ""));
    double disc = double.parse(promotionProgramInputStateRx
        .value.promotionProgramInputState[index].discTransaction!.text);
    if (qty.isEmpty) {
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].totalTransaction!.text = "0";
    } else {
      double discPrice = (int.parse(qty) * price) * (disc / 100);
      double calculateTotalPrice = (int.parse(qty) * price) - discPrice;
      promotionProgramInputStateRx
          .value
          .promotionProgramInputState[index]
          .totalTransaction!
          .text = calculateTotalPrice.toString().split(".").first;
    }

    _updateState();
  }

  void changeDisc(int index, String disc) {
    int qty = promotionProgramInputStateRx.value
            .promotionProgramInputState[index].qtyTransaction!.text.isEmpty
        ? 0
        : int.parse(promotionProgramInputStateRx
            .value.promotionProgramInputState[index].qtyTransaction!.text);
    double price = promotionProgramInputStateRx.value
            .promotionProgramInputState[index].priceTransaction!.text.isEmpty
        ? 0
        : double.parse(promotionProgramInputStateRx
            .value.promotionProgramInputState[index].priceTransaction!.text
            .replaceAll(RegExp(r"[.,]"), ""));
    dynamic calculateTotalPrice;
    if (disc.isEmpty) {
      calculateTotalPrice = (qty * price);
      promotionProgramInputStateRx.value.promotionProgramInputState[index]
          .totalTransaction!.text = calculateTotalPrice.toString();
    } else {
      double discPrice = (qty * price) * (double.parse(disc) / 100);
      calculateTotalPrice = (qty * price) - discPrice;
      promotionProgramInputStateRx
          .value
          .promotionProgramInputState[index]
          .totalTransaction!
          .text = calculateTotalPrice.toString().split(".").first;
    }
    _updateState();
  }

  bool promotionProgramInputValidation() {
    return true;
  }

  void submitPromotionProgram() async {
    if (!promotionProgramInputValidation()) {
      return;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");

    int? userId = preferences.getInt("userid");
    final int idEmp =
        int.tryParse(preferences.getString("getIdEmp") ?? '0') ?? 0;

    final isiBody = jsonEncode(<String, dynamic>{
      "custid": customerNameInputPageDropdownStateRx.value.selectedChoice?.id,
      "description": "",
      "idEmp": idEmp,
      "lines": promotionProgramInputStateRx.value.promotionProgramInputState
          .map<Map<String, dynamic>>((element) => <String, dynamic>{
                "itemId": element.productTransactionPageDropdownState
                    ?.selectedChoiceWrapper?.value?.id,
                "qty": element.qtyTransaction!.text.isEmpty
                    ? 0
                    : element.qtyTransaction?.text,
                "unit": element.unitPageDropdownState?.selectedChoice,
                "price": element.priceTransaction!.text.isEmpty
                    ? 0
                    : int.parse(element.priceTransaction!.text
                        .replaceAll(RegExp(r"[.,]"), "")),
              })
          .toList()
    });

    List<PromotionProgramInputState>? promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState.toList();
    promotionProgramInputState.map((e) => e.totalTransaction?.text).toList();

    var url = 'http://sms-api.prb.co.id/api/transaction?idUser=$userId';
    final response = await post(
        // Uri.parse('http://119.18.157.236:8869/api/transaction?idUser=$userId'),
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': '$token',
        },
        body: isiBody);

    Future.delayed(const Duration(seconds: 2), () {
      if (response.statusCode == 201 || response.statusCode == 200) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.off(() => const DashboardOrderTaking(
                initialIndex: 1,
              ));
        });

        //         Get.off(const DashboardPage(
        //   initialIndex: 1,
        // ));
        Get.dialog(
            const SimpleDialog(
              title: Text("Success"),
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
            barrierDismissible: false);
      } else {
        Get.dialog(SimpleDialog(
          title: const Text("Error"),
          children: [
            Center(
              child: Text(
                  "${response.statusCode}\n${response.body.replaceAll(r"\'", "'")}",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
            const Center(
              child: Icon(Icons.error),
            )
          ],
        ));
      }
    });
  }

  void removeItem(int index) {
    promotionProgramInputStateRx.value.promotionProgramInputState
        .removeAt(index);
    _updateState();
  }

  void checkAddItemStatus() {
    promotionProgramInputStateRx.value.isAddItem =
        // programNumberTextEditingControllerRx.value.text.isBlank == false
        /*&&*/ programNameTextEditingControllerRx.value.text.isBlank == false &&
            promotionTypeInputPageDropdownStateRx.value.selectedChoice != null;
    // && vendorInputPageDropdownStateRx.value.selectedChoice != null;
    // && locationInputPageDropdownStateRx.value.selectedChoice != null
    // && statusTestingInputPageDropdownStateRx.value.selectedChoice != null;
    _updateState();
  }

  void checkAddItemStatus2() {
    promotionProgramInputStateRx.value.isAddItem =
        customerNameInputPageDropdownStateRx.value.selectedChoice != null;

    _updateState();
  }

  void _updateState() {
    promotionTypeInputPageDropdownStateRx
        .valueFromLast((value) => value.copy());
    locationInputPageDropdownStateRx.valueFromLast((value) => value.copy());
    vendorInputPageDropdownStateRx.valueFromLast((value) => value.copy());
    statusTestingInputPageDropdownStateRx
        .valueFromLast((value) => value.copy());
    promotionProgramInputStateRx.valueFromLast((value) => value.copy());
    update();
  }
}
