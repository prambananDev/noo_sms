import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_pp.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/input_pp_model.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  final InputPageDropdownState<String> _itemGroupInputPageDropdownState =
      InputPageDropdownState<String>(
          choiceList: <String>["Item", "Disc Group"], loadingState: 0);

  final WrappedInputPageDropdownState<IdAndValue<String>>
      _productInputPageDropdownState =
      WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper: Wrapper(value: <IdAndValue<String>>[]),
          loadingStateWrapper: Wrapper(value: 0),
          selectedChoiceWrapper: Wrapper(value: null));

  final WrappedInputPageDropdownState<IdAndValue<String>>
      _warehouseInputPageDropdownState =
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
  final InputPageDropdownState<IdAndValue<String>>
      _multiplyInputPageDropdownState =
      InputPageDropdownState<IdAndValue<String>>(
    choiceList: <IdAndValue<String>>[
      IdAndValue<String>(id: "0", value: "No"),
      IdAndValue<String>(id: "1", value: "Yes"),
    ],
    loadingState: 0,
  );
  final InputPageDropdownState<String> _currencyInputPageDropdownState =
      InputPageDropdownState<String>(
          choiceList: <String>["IDR", "Dollar"], loadingState: 0);
  final InputPageDropdownState<IdAndValue<String>>
      _percentValueInputPageDropdownState =
      InputPageDropdownState<IdAndValue<String>>(
          choiceList: <IdAndValue<String>>[
        IdAndValue<String>(id: "1", value: "Percent"),
        IdAndValue<String>(id: "2", value: "Value"),
      ],
          loadingState: 0);

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
      print("ini url getLocation : $urlGetLocation");
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
    } else {
      debugPrint('Failed to load program data');
    }
  }

  void _loadCustomerNameByUsername() async {
    customerNameInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    try {
      var urlGetCustomer =
          "http://api-scs.prb.co.id/api/AllCustomer?username=$username";
      print("url get customer :$urlGetCustomer");
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

  void _loadProduct() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? ID = preferences.getString("username");
    _productInputPageDropdownState.loadingStateWrapper?.value = 1;
    _updateState();
    var urlGetProduct =
        "http://api-scs.prb.co.id/api/AllProduct?ID=$ID&idSales=Sample";
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
    debugPrint('response Fetching data from: $urlGetUnit');

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

  void addItem2() {
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
    debugPrint("response ${selectedChoice.id}");
    update();
    _loadUnit(index);
  }

  List<String> originalPrice = [];
  getQtyUnitPrice(int index, String idProduct, int qty, String unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PromotionProgramInputState promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    var url =
        "http://119.18.157.236:8877/api/Product/cekStok?item=$idProduct&qty=$qty&unit=$unit&wh=DC01-X";
    var urlPrice =
        "http://api-scs.prb.co.id/api/AllPrice?cust=${customerNameInputPageDropdownStateRx.value.choiceList![index].id}&item=$idProduct&unit=$unit&qty=$qty&type=1";
    var urlDiscount =
        "http://api-scs.prb.co.id/api/AllDiscount?cust=${customerNameInputPageDropdownStateRx.value.choiceList![index].id}&item=$idProduct&unit=$unit&qty=$qty";

    final response = await get(Uri.parse(url));
    final responsePrice = await get(Uri.parse(urlPrice));
    final responseDiscount = await get(Uri.parse(urlDiscount));
    final listData = jsonDecode(response.body);
    double listDataPrice = 0.0;
    int listDataDiscount = 0;
    if (responsePrice.statusCode == 200) {
      listDataPrice = jsonDecode(responsePrice.body);
    } else {
      listDataPrice = 0.0;
    }
    if (responseDiscount.statusCode == 200) {
      double discount = jsonDecode(responseDiscount.body);
      listDataDiscount = discount.toInt();
    } else {
      listDataDiscount = 0;
    }

    promotionProgramInputState.qtyTransaction?.text =
        1.toString() /*listData['qty'].toString().split(".").first*/;
    promotionProgramInputState.priceTransaction?.text =
        MoneyFormatter(amount: listDataPrice ?? 0).output.withoutFractionDigits;
    String originalPrices = MoneyFormatter(amount: listDataPrice ?? 0.0)
        .output
        .withoutFractionDigits;
    promotionProgramInputState.totalTransaction?.text =
        listDataPrice.toString().split(".").first;
    print("object :${promotionProgramInputState.totalTransaction?.text}");
    originalPrice.add(originalPrices);
    promotionProgramInputState.discTransaction?.text =
        listDataDiscount.toString();
    // if(listData['message']!='Available'){
    //   Get.snackbar("Out of Stock", "Please choose another product",backgroundColor: Colors.red,icon: Icon(Icons.error));
    // };
  }

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
    String? username = preferences.getString("username");
    String? token = preferences.getString("token");
    int ppTypeConvert = int.parse(
        promotionTypeInputPageDropdownStateRx.value.selectedChoice!.id);
    // int multiplyConvert = int.parse(element.multiplyInputPageDropdownState.selectedChoice.id);
    int typeConvert = int.parse(
        promotionTypeInputPageDropdownStateRx.value.selectedChoice!.id);
    final selectedItemsPrincipal = selectedDataPrincipal
        .map((index) => listDataPrincipal[index])
        .toList()
        .toString()
        .replaceAll(RegExp(r'[\[\]]'), '');
    final isiBody = jsonEncode(<String, dynamic>{
      "PPtype": ppTypeConvert,
      "PPname": programNameTextEditingControllerRx.value.text,
      "Note": programNoteTextEditingControllerRx.value.text,
      "FromDateHeader": programFromDateTextEditingControllerRx.value.text
          .replaceAll(programFromDateTextEditingControllerRx.value.text,
              "${programFromDateTextEditingControllerRx.value.text.split('-')[2]}-${programFromDateTextEditingControllerRx.value.text.split('-')[1]}-${programFromDateTextEditingControllerRx.value.text.split('-')[0]}"),
      "ToDateHeader": programToDateTextEditingControllerRx.value.text.replaceAll(
          programToDateTextEditingControllerRx.value.text,
          "${programToDateTextEditingControllerRx.value.text.split('-')[2]}-${programToDateTextEditingControllerRx.value.text.split('-')[1]}-${programToDateTextEditingControllerRx.value.text.split('-')[0]}"),
      "Location": preferences.getString("so"),
      "Vendor": selectedItemsPrincipal,
      "customerId": custNameHeaderValueDropdownStateRx.value.selectedChoice?.id,
      "Lines": promotionProgramInputStateRx.value.promotionProgramInputState
          .map<Map<String, dynamic>>((element) => <String, dynamic>{
                "Customer":
                    custNameHeaderValueDropdownStateRx.value.selectedChoice?.id,
                "ItemId":
                    element.selectProductPageDropdownState?.selectedChoice?.id,
                "QtyFrom":
                    element.qtyFrom!.text.isEmpty ? 0 : element.qtyFrom?.text,
                "QtyTo": element.qtyTo!.text.isEmpty ? 0 : element.qtyTo?.text,
                "Unit": element.unitPageDropdownState?.selectedChoice,
                "Multiply":
                    element.multiplyInputPageDropdownState?.selectedChoice?.id,
                "FromDate": programFromDateTextEditingControllerRx.value.text
                    .replaceAll(
                        programFromDateTextEditingControllerRx.value.text,
                        "${programFromDateTextEditingControllerRx.value.text.split('-')[2]}-${programFromDateTextEditingControllerRx.value.text.split('-')[1]}-${programFromDateTextEditingControllerRx.value.text.split('-')[0]}"),
                "ToDate": programToDateTextEditingControllerRx.value.text
                    .replaceAll(programToDateTextEditingControllerRx.value.text,
                        "${programToDateTextEditingControllerRx.value.text.split('-')[2]}-${programToDateTextEditingControllerRx.value.text.split('-')[1]}-${programToDateTextEditingControllerRx.value.text.split('-')[0]}"),
                "Currency":
                    element.currencyInputPageDropdownState?.selectedChoice,
                "type": element.percentValueInputPageDropdownState!
                        .selectedChoice.isNull
                    ? 0
                    : element.percentValueInputPageDropdownState?.selectedChoice
                        ?.id, //
                "Pct1": element.percent1!.text.isEmpty
                    ? 0.0
                    : element.percent1?.text,
                "Pct2": element.percent2!.text.isEmpty
                    ? 0.0
                    : element.percent2?.text,
                "Pct3": element.percent3!.text.isEmpty
                    ? 0.0
                    : element.percent3?.text,
                "Pct4": element.percent4!.text.isEmpty
                    ? 0.0
                    : element.percent4?.text,
                "Value1": element.value1!.text.isEmpty
                    ? 0.0
                    : element.value1?.text.replaceAll('.', ''),
                "Value2": element.value2!.text.isEmpty
                    ? 0.0
                    : element.value2?.text.replaceAll('.', ''),
                //"SupplyItemOnlyOnce": "",
                "SupplyItem": element.supplyItem!.selectedChoice.isNull
                    ? ""
                    : element.supplyItem?.selectedChoice?.id,
                "QtySupply":
                    element.qtyItem!.text.isEmpty ? 0 : element.qtyItem?.text,
                "UnitSupply": element.unitSupplyItem?.selectedChoice,
                "SalesPrice":
                    element.salesPrice?.text.replaceAll(RegExp(r"[.,]"), ""),
                // element.supplyItem.selectedChoice.isNull ? "" : element.supplyItem.selectedChoice.id
                "Warehouse": element.wareHousePageDropdownState
                            ?.selectedChoiceWrapper?.value ==
                        null
                    ? "DC01K-B"
                    : element.wareHousePageDropdownState?.selectedChoiceWrapper
                        ?.value?.id,
                "PriceTo": element.priceToCustomer?.text
                    .replaceAll(RegExp(r"[.,]"), "")
              })
          .toList()
    });

    final response =
        await post(Uri.parse('$apiCons/api/activity?username=$username'),
            headers: {
              "Content-Type": "application/json",
              'Authorization': '$token',
            },
            body: isiBody);
    final tabController = Get.put(DashboardPPTabController());
    Future.delayed(const Duration(seconds: 2), () {
      if (response.statusCode == 200 & 201) {
        // Future.delayed(const Duration(seconds: 2), () {
        //   tabController.initialIndex = 1;
        //   onTap.value = true;
        //   Get.offAll(
        //     const DashboardPage(),
        //   );
        //   Get.to(const DashboardPP(
        //     initialIndex: 1,
        //   ));
        //   update();
        //   // Get.offAll(HistoryNomorPP());
        // });
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
        onTap.value = false;

        Get.dialog(
            SimpleDialog(
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
                ),
              ],
            ),
            barrierDismissible: false);
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
