import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_pp.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/input_pp_model.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/wrapper.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InputPageController extends GetxController {
  var inputItems = <InputPageModel>[].obs;
  RxBool onTap = false.obs;
  RxList listDataPrincipal = [].obs;
  RxList<int> selectedDataPrincipal = <int>[].obs;
  RxString valPrincipal = "".obs;
  RxBool isProspectValid = false.obs;
  Rx<bool> isClaim = false.obs;
  final Map<String, List<IdAndValue<String>>> _productCache = {};

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

  WrappedInputPageDropdownState<IdAndValue<String>>
      productInputPageDropdownState =
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
    promotionTypeInputPageDropdownStateRx
        .valueFromLast((value) => value.copy(choiceList: <IdAndValue<String>>[
              IdAndValue<String>(id: "1", value: "Discount"),
              IdAndValue<String>(id: "2", value: "Bonus"),
              IdAndValue<String>(id: "9", value: "Discount & Bonus"),
            ], loadingState: 2));

    statusTestingInputPageDropdownStateRx
        .valueFromLast((value) => value.copy(choiceList: <String>[
              "Live",
              "Testing",
            ], loadingState: 2));
    _multiplyInputPageDropdownState.selectedChoice =
        _multiplyInputPageDropdownState.choiceList?[1];
    _currencyInputPageDropdownState.selectedChoice =
        _currencyInputPageDropdownState.choiceList?[0];
    _loadLocation();
    _loadVendor();
    _loadWarehouse();
    _loadPrincipal();
    _loadCustomerOrGroupHeader();
    _loadCustomerNameByUsername();
  }

  void _loadPrincipal() async {
    var urlPrincipal = "$apiSMS/Principals";
    final response = await get(Uri.parse(urlPrincipal));
    final listData = jsonDecode(response.body);

    listData.removeWhere((item) => item == null);
    listDataPrincipal.value = listData;
    update();
  }

  Future<void> loadProgramData(String programNumber) async {
    var url = '$apiSMS/activity/$programNumber';
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

  void _loadLocation() async {
    locationInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    try {
      var urlGetLocation = "$apiSMS/SalesOffices";
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

  void _loadVendor() async {
    vendorInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    try {
      var urlGetVendor = "$apiSMS/Vendors";
      final response = await get(Uri.parse(urlGetVendor));
      var listData = jsonDecode(response.body);
      vendorInputPageDropdownStateRx.value.loadingState = 2;
      vendorInputPageDropdownStateRx.value.choiceList = listData
          .map<IdAndValue<String>>((element) => IdAndValue<String>(
              id: element["ACCOUNTNUM"], value: element["VENDNAME"]))
          .toList();
      _updateState();
    } catch (e) {
      vendorInputPageDropdownStateRx.value.loadingState = -1;
      _updateState();
    }
  }

  void _loadWarehouse() async {
    _warehouseInputPageDropdownState.loadingStateWrapper?.value = 1;
    _updateState();
    var urlGetWarehouse = "$apiSMS/Warehouse";
    final response = await get(Uri.parse(urlGetWarehouse));
    var listData = jsonDecode(response.body);
    _warehouseInputPageDropdownState.loadingStateWrapper?.value = 2;
    _warehouseInputPageDropdownState.choiceListWrapper?.value = listData
        .map<IdAndValue<String>>((element) => IdAndValue<String>(
            id: element["INVENTLOCATIONID"].toString(), value: element["NAME"]))
        .toList();
    _updateState();
  }

  void _loadProduct(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");

    PromotionProgramInputState? promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];

    InputPageDropdownState<String>? itemGroupInputPageDropdownState =
        promotionProgramInputState.itemGroupInputPageDropdownState;

    InputPageDropdownState<IdAndValue<String>>? selectProductPageDropdownState =
        promotionProgramInputState.selectProductPageDropdownState;

    String? selectedChoice = itemGroupInputPageDropdownState?.selectedChoice;

    if (selectedChoice == null ||
        itemGroupInputPageDropdownState?.choiceList == null) {
      return;
    }

    String cacheKey = selectedChoice;

    if (_productCache.containsKey(cacheKey)) {
      selectProductPageDropdownState?.loadingState = 2;
      selectProductPageDropdownState?.choiceList = _productCache[cacheKey];
      _updateState();
      return;
    }

    if (selectedChoice == itemGroupInputPageDropdownState!.choiceList?[0]) {
      var urlGetProduct = "$apiSCS/api/AllProduct?ID=$username&idSales=Sample";

      final response = await get(
        Uri.parse(urlGetProduct),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var listData = jsonDecode(response.body);
        var productList = listData
            .map<IdAndValue<String>>((element) => IdAndValue<String>(
                id: element["itemId"].toString(), value: element["itemName"]))
            .toList();

        _productCache[cacheKey] = productList;

        selectProductPageDropdownState?.loadingState = 2;
        selectProductPageDropdownState?.choiceList = productList;
        _updateState();
      }
    } else if (selectedChoice ==
        itemGroupInputPageDropdownState.choiceList?[1]) {
      var urlGetDiscGroup = "$apiSMS/ItemGroup";
      final response = await get(Uri.parse(urlGetDiscGroup));

      if (response.statusCode == 200) {
        var listData = jsonDecode(response.body);
        var productList = listData
            .map<IdAndValue<String>>((element) => IdAndValue<String>(
                id: element["GROUPID"].toString(), value: element["NAME"]))
            .toList();

        _productCache[cacheKey] = productList;

        selectProductPageDropdownState?.loadingState = 2;
        selectProductPageDropdownState?.choiceList = productList;
        _updateState();
      }
    }
  }

  void _loadSupplyItem(int index) async {
    PromotionProgramInputState? promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    // InputPageDropdownState<IdAndValue<String>>?
    //     customerNameOrDiscountGroupInputPageDropdownState =
    //     promotionProgramInputState
    //         .customerNameOrDiscountGroupInputPageDropdownState;
    InputPageDropdownState<IdAndValue<String>>? supplyItemPageDropdownState =
        promotionProgramInputState.supplyItem;
    var urlGetSupplyItem = "$apiSMS/PrbItemTables";

    final response = await get(
      Uri.parse(urlGetSupplyItem),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var listData = jsonDecode(response.body);
    supplyItemPageDropdownState?.loadingState = 2;
    supplyItemPageDropdownState?.choiceList = listData
        .map<IdAndValue<String>>((element) => IdAndValue<String>(
            id: element["ITEMID"],
            value:
                "${element["ITEMID"]}-${element["PK_BRAND"]}-${element["ITEMNAME"]}-${element["PK_PACKING"]}"))
        .toList();
    _updateState();
  }

  void _loadCustomerNameByUsername() async {
    customerNameInputPageDropdownStateRx.value.loadingState = 1;
    _updateState();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    try {
      var urlGetCustomer = "$apiSCS/api/AllCustomer?username=$username";

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

  void _loadUnit(int index) async {
    await _loadDropdownData(
      index: index,
      selectProductState: promotionProgramInputStateRx.value
          .promotionProgramInputState[index].selectProductPageDropdownState,
      unitState: promotionProgramInputStateRx
          .value.promotionProgramInputState[index].unitPageDropdownState,
    );
  }

  void _loadSupplyItemProductUnit(int index) async {
    await _loadDropdownData(
      index: index,
      selectProductState: promotionProgramInputStateRx
          .value.promotionProgramInputState[index].supplyItem,
      unitState: promotionProgramInputStateRx
          .value.promotionProgramInputState[index].unitSupplyItem,
    );
  }

  Future<void> _loadDropdownData({
    required int index,
    required InputPageDropdownState<IdAndValue<String>>? selectProductState,
    required InputPageDropdownState<String>? unitState,
  }) async {
    if (selectProductState == null || unitState == null) return;

    unitState.loadingState = 1;
    _updateState();

    final urlGetUnit =
        "$apiSCS/api/Unit?item=${selectProductState.selectedChoice?.id}";
    final response = await get(Uri.parse(urlGetUnit));
    final listData = jsonDecode(response.body);

    unitState.loadingState = 2;
    unitState.choiceList =
        listData.map<String>((element) => element.toString()).toList();

    if (unitState.choiceList != null && unitState.choiceList!.isNotEmpty) {
      unitState.selectedChoice = unitState.choiceList![0];
    }

    _updateState();
  }

  void changePromotionType(IdAndValue<String>? selectedChoice) {
    promotionTypeInputPageDropdownStateRx.value.selectedChoice = selectedChoice;
    checkAddItemStatus();
  }

  void changeSelectCustomer(IdAndValue<String> selectedChoice) {
    customerNameInputPageDropdownStateRx.value.selectedChoice = selectedChoice;

    checkAddItemStatus();
  }

  void changeVendor(IdAndValue<String> selectedChoice) {
    vendorInputPageDropdownStateRx.value.selectedChoice = selectedChoice;
    checkAddItemStatus();
  }

  void changeLocation(IdAndValue<String> selectedChoice) {
    locationInputPageDropdownStateRx.value.selectedChoice = selectedChoice;

    checkAddItemStatus();
  }

  void changeStatusTesting(String selectedChoice) {
    statusTestingInputPageDropdownStateRx.value.selectedChoice = selectedChoice;
    checkAddItemStatus();
  }

  void addItem() {
    List<PromotionProgramInputState>? promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState;
    promotionProgramInputState.add(PromotionProgramInputState(
      customerGroupInputPageDropdownState:
          customerGroupInputPageDropdownState.value.copy(),
      customerNameOrDiscountGroupInputPageDropdownState:
          InputPageDropdownState<IdAndValue<String>>(),
      itemGroupInputPageDropdownState: _itemGroupInputPageDropdownState.copy(),
      selectProductPageDropdownState:
          InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0),
      wareHousePageDropdownState: _warehouseInputPageDropdownState.copy(
          choiceListWrapper: _warehouseInputPageDropdownState.choiceListWrapper,
          loadingStateWrapper:
              _warehouseInputPageDropdownState.loadingStateWrapper,
          selectedChoiceWrapper: Wrapper<IdAndValue<String>>(value: null)),
      qtyFrom: TextEditingController(),
      qtyTo: TextEditingController(),
      qtyTransaction: TextEditingController(),
      unitPageDropdownState:
          InputPageDropdownState<String>(choiceList: [], loadingState: 0),
      multiplyInputPageDropdownState: _multiplyInputPageDropdownState.copy(),
      currencyInputPageDropdownState: _currencyInputPageDropdownState.copy(),
      percentValueInputPageDropdownState:
          _percentValueInputPageDropdownState.copy(),
      fromDate: TextEditingController(),
      toDate: TextEditingController(),
      percent1: TextEditingController(),
      percent2: TextEditingController(),
      percent3: TextEditingController(),
      percent4: TextEditingController(),
      salesPrice: TextEditingController(),
      priceToCustomer: TextEditingController(),
      value1: TextEditingController(),
      value2: TextEditingController(),
      supplyItem: InputPageDropdownState<IdAndValue<String>>(
          choiceList: [], loadingState: 0),
      qtyItem: TextEditingController(),
      unitSupplyItem:
          InputPageDropdownState<String>(choiceList: [], loadingState: 0),
    ));
    _updateState();
  }

  void changeCustomerGroup(int index, String? selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .customerGroupInputPageDropdownState?.selectedChoice = selectedChoice;
    _updateState();
    // _loadCustomerOrGroup(index);
  }

  void changeCustomerGroupHeader(String selectedChoice) {
    customerGroupInputPageDropdownState.value.selectedChoice = selectedChoice;

    _updateState();
  }

  void _loadCustomerOrGroupHeader() async {
    custNameHeaderValueDropdownStateRx.value.loadingState = 1;
    _updateState();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    try {
      var urlGetCustomer = "$apiSCS/api/AllCustomer?username=$username";
      final response = await get(Uri.parse(urlGetCustomer));
      var listData = jsonDecode(response.body);
      custNameHeaderValueDropdownStateRx.value.loadingState = 2;
      custNameHeaderValueDropdownStateRx.value.choiceList = listData
          .map<IdAndValue<String>>((element) => IdAndValue<String>(
              id: element["codeCust"], value: element["nameCust"]))
          .toList();
      _updateState();
    } catch (e) {
      custNameHeaderValueDropdownStateRx.value.loadingState = -1;
      _updateState();
    }
  }

  void changeCustomerNameOrDiscountGroup(
      int index, IdAndValue<String> selectedChoice) {
    PromotionProgramInputState? promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    InputPageDropdownState<IdAndValue<String>>?
        customerNameOrDiscountGroupInputPageDropdownState =
        promotionProgramInputState
            .customerNameOrDiscountGroupInputPageDropdownState;
    customerNameOrDiscountGroupInputPageDropdownState?.selectedChoice =
        selectedChoice;
    _updateState();
    // _loadSupplyItem(index);
  }

  void changeCustomerNameOrDiscountGroupHeader(
      IdAndValue<String> selectedChoice) {
    custNameHeaderValueDropdownStateRx.value.selectedChoice = selectedChoice;
    _updateState();
  }

  void changeItemGroup(int index, String selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .itemGroupInputPageDropdownState?.selectedChoice = selectedChoice;

    _updateState();
    _loadProduct(index);
    _loadSupplyItem(index);
    // _loadProductByOrderSample(index);
  }

  void changeProduct(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .selectProductPageDropdownState?.selectedChoice = selectedChoice;

    _loadUnit(index);

    _updateState();
  }

  void changeWarehouse(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx
        .value
        .promotionProgramInputState[index]
        .wareHousePageDropdownState
        ?.selectedChoiceWrapper
        ?.value = selectedChoice;

    _updateState();
  }

  void changeUnit(int index, String selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .unitPageDropdownState?.selectedChoice = selectedChoice;
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

  void changeMultiply(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .multiplyInputPageDropdownState?.selectedChoice = selectedChoice;
    _updateState();
  }

  void changeCurrency(int index, String selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .currencyInputPageDropdownState?.selectedChoice = selectedChoice;
    _updateState();
  }

  void changePercentValue(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .percentValueInputPageDropdownState?.selectedChoice = selectedChoice;

    if (selectedChoice.value == "Value") {
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].percent1
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].percent2
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].percent3
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].percent4
          ?.clear();
    } else {
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].value1
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].value2
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].salesPrice
          ?.clear();
      promotionProgramInputStateRx
          .value.promotionProgramInputState[index].priceToCustomer
          ?.clear();
    }
    _updateState();
  }

  double _parseAndSanitizeNumber(String input,
      {String replaceChar = ".", String defaultValue = "0.0"}) {
    return double.parse(input.isEmpty
        ? defaultValue
        : input.replaceAll(replaceChar, "").replaceAll(",", ""));
  }

  void getPriceToCustomer(int index) {
    int percent1 = 0;
    int percent2 = 0;
    int percent3 = 0;
    int percent4 = 0;
    var promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];

    double salesPrice = _parseAndSanitizeNumber(
        promotionProgramInputState.salesPrice!.text,
        replaceChar: ".");

    double value1 = _parseAndSanitizeNumber(
        promotionProgramInputState.value1!.text,
        replaceChar: ".");

    double value2 = _parseAndSanitizeNumber(
        promotionProgramInputState.value2!.text,
        replaceChar: ".");

    percent1 = promotionProgramInputState.percent1?.text != null &&
            RegExp(r'^\d+$').hasMatch(promotionProgramInputState.percent1!.text)
        ? int.parse(promotionProgramInputState.percent1!.text)
        : 0;

    percent2 = promotionProgramInputState.percent2?.text != null &&
            RegExp(r'^\d+$').hasMatch(promotionProgramInputState.percent2!.text)
        ? int.parse(promotionProgramInputState.percent2!.text)
        : 0;

    percent3 = promotionProgramInputState.percent3?.text != null &&
            RegExp(r'^\d+$').hasMatch(promotionProgramInputState.percent3!.text)
        ? int.parse(promotionProgramInputState.percent3!.text)
        : 0;

    percent4 = promotionProgramInputState.percent4?.text != null &&
            RegExp(r'^\d+$').hasMatch(promotionProgramInputState.percent4!.text)
        ? int.parse(promotionProgramInputState.percent4!.text)
        : 0;

    double countPriceToCustomerValue = salesPrice - (value1 + value2);
    dynamic totalDiscount = ((salesPrice * percent1 / 100) +
        (salesPrice * percent2 / 100) +
        (salesPrice * percent3 / 100) +
        (salesPrice * percent4 / 100));
    double countPriceToCustomerPercent = salesPrice - totalDiscount;

    promotionProgramInputState.priceToCustomer?.text = MoneyFormatter(
            amount: value1 != 0.0
                ? countPriceToCustomerValue
                : countPriceToCustomerPercent)
        .output
        .withoutFractionDigits;
    update();
  }

  void changeFromDateValue(int index, var value) {
    promotionProgramInputStateRx
        .value.promotionProgramInputState[index].fromDate?.text = value;
    _updateState();
  }

  void changeFromDateValueAlt() {
    _updateState();
  }

  void changetoDateValue() {
    _updateState();
  }

  void changeSupplyItem(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .supplyItem?.selectedChoice = selectedChoice;
    _updateState();
    _loadSupplyItemProductUnit(index);
  }

  void changeUnitSupplyItem(int index, String selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .unitSupplyItem?.selectedChoice = selectedChoice;
    _updateState();
  }

  bool promotionProgramInputValidation() {
    return true;
  }

  Future<void> submitPromotionProgram(BuildContext context) async {
    // if (!await _validateSubmission()) return;

    onTap.value = true;
    final credentials = await _getCredentials();
    if (credentials == null) return;

    final response = await _submitRequest(credentials);
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _handleSuccess();
    } else {
      _handleError("Submission failed");
    }
  }

  // Future<bool> _validateSubmission() async {
  //   if (!promotionProgramInputValidation()) return false;

  //   if (promotionProgramInputStateRx.value.promotionProgramInputState.any(
  //       (element) =>
  //           element.selectProductPageDropdownState?.selectedChoice == null ||
  //           element.qtyFrom?.text.isEmpty == true ||
  //           element.unitPageDropdownState?.selectedChoice == null)) {
  //     debugPrint(promotionProgramInputStateRx
  //         .value.promotionProgramInputState.length
  //         .toString());
  //     Get.snackbar(
  //       "Error",
  //       "Found empty fields in Lines",
  //       backgroundColor: Colors.red,
  //       icon: const Icon(Icons.error),
  //     );
  //     return false;
  //   }
  //   return true;
  // }

  Future<({String username, String token})?> _getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username");
    final token = prefs.getString("token");

    if (username == null || token == null || token.isEmpty) {
      _handleError("Authentication token is missing. Please login again.");
      return null;
    }

    return (username: username, token: token);
  }

  Future<http.Response> _submitRequest(
      ({String username, String token}) credentials) async {
    final requestBody = await _prepareRequestBody();
    return await http.post(
      Uri.parse('$apiSMS/activity?username=${credentials.username}'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': credentials.token,
      },
      body: jsonEncode(requestBody),
    );
  }

  Future<Map<String, dynamic>> _prepareRequestBody() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "PPtype": int.parse(
          promotionTypeInputPageDropdownStateRx.value.selectedChoice!.id),
      "PPname": programNameTextEditingControllerRx.value.text,
      "Note": programNoteTextEditingControllerRx.value.text,
      "FromDateHeader":
          formatDateForAPI(programFromDateTextEditingControllerRx.value.text),
      "ToDateHeader":
          formatDateForAPI(programToDateTextEditingControllerRx.value.text),
      "Location": prefs.getString("so"),
      "Vendor": _formatVendorList(),
      "customerId": custNameHeaderValueDropdownStateRx.value.selectedChoice?.id,
      "Lines": _prepareLines(),
    };
  }

  String _formatVendorList() {
    return selectedDataPrincipal
        .map((index) => listDataPrincipal[index])
        .toList()
        .toString()
        .replaceAll(RegExp(r'[\[\]]'), '');
  }

  Future<void> _handleSuccess() async {
    Get.snackbar(
      "Success",
      "Promotion program submitted successfully",
      backgroundColor: Colors.green,
      icon: const Icon(Icons.check_circle),
    );
    await Future.delayed(const Duration(seconds: 1));
    DashboardPPState.tabController.animateTo(1);
  }

  void _handleError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      icon: const Icon(Icons.error),
    );
  }

  String formatDateForAPI(String date) {
    final parts = date.split('-');
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  List<Map<String, dynamic>> _prepareLines() {
    final lines = promotionProgramInputStateRx.value.promotionProgramInputState
        .map<Map<String, dynamic>>((element) {
          if (element.supplyItem?.selectedChoice == null ||
              element.qtyFrom?.text.isEmpty == true ||
              element.unitSupplyItem?.selectedChoice == null) {
            onTap.value = false;
            Get.snackbar(
              "Error",
              "Please fill all required fields (Product, Quantity, and Unit)",
              backgroundColor: Colors.red,
              icon: const Icon(Icons.error),
            );
            return {};
          }

          // Prepare the line data
          return {
            "Customer":
                custNameHeaderValueDropdownStateRx.value.selectedChoice?.id,
            "ItemId": element.supplyItem?.selectedChoice?.id,
            "QtyFrom":
                element.qtyFrom!.text.isEmpty ? 0 : element.qtyFrom?.text,
            "QtyTo": element.qtyTo!.text.isEmpty ? 0 : element.qtyTo?.text,
            "Unit": element.unitSupplyItem?.selectedChoice ?? "",
            "Multiply":
                element.multiplyInputPageDropdownState?.selectedChoice?.id ??
                    "0",
            "FromDate": formatDateForAPI(
                programFromDateTextEditingControllerRx.value.text),
            "ToDate": formatDateForAPI(
                programToDateTextEditingControllerRx.value.text),
            "Currency":
                element.currencyInputPageDropdownState?.selectedChoice ?? "IDR",
            "type": element
                    .percentValueInputPageDropdownState?.selectedChoice?.id ??
                "1",
            "Pct1":
                element.percent1!.text.isEmpty ? 0.0 : element.percent1?.text,
            "Pct2":
                element.percent2!.text.isEmpty ? 0.0 : element.percent2?.text,
            "Pct3":
                element.percent3!.text.isEmpty ? 0.0 : element.percent3?.text,
            "Pct4":
                element.percent4!.text.isEmpty ? 0.0 : element.percent4?.text,
            "Value1": element.value1!.text.isEmpty
                ? 0.0
                : element.value1?.text.replaceAll('.', ''),
            "Value2": element.value2!.text.isEmpty
                ? 0.0
                : element.value2?.text.replaceAll('.', ''),
            "SupplyItem": element.supplyItem?.selectedChoice?.id ?? "",
            "QtySupply":
                element.qtyItem!.text.isEmpty ? 0 : element.qtyItem?.text,
            "UnitSupply": element.unitSupplyItem?.selectedChoice ?? "",
            "SalesPrice": element.salesPrice!.text.isEmpty
                ? "0"
                : element.salesPrice?.text.replaceAll(RegExp(r"[.,]"), ""),
            "Warehouse": element.wareHousePageDropdownState
                    ?.selectedChoiceWrapper?.value?.id ??
                "DC01K-B",
            "PriceTo": element.priceToCustomer!.text.isEmpty
                ? "0"
                : element.priceToCustomer?.text.replaceAll(RegExp(r"[.,]"), "")
          };
        })
        .where((line) => line.isNotEmpty)
        .toList();

    return lines;
  }

  void submitEditPromotionProgram(
      int idHeader, List idLines, String ppnum) async {
    if (!promotionProgramInputValidation()) {
      return;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    String? token = preferences.getString("token");

    int ppTypeConvert = int.parse(
        promotionTypeInputPageDropdownStateRx.value.selectedChoice!.id);
    final isiBody = jsonEncode(<String, dynamic>{
      //baru
      "id": idHeader,
      "PPtype": ppTypeConvert,
      "PPname": programNameTextEditingControllerRx.value.text,
      "PPnum": ppnum,
      "Note": programNoteTextEditingControllerRx.value.text,
      "CustomerId": custNameHeaderValueDropdownStateRx.value.selectedChoice?.id,
      "FromDateHeader": programFromDateTextEditingControllerRx.value.text == ""
          ? "${DateTime.now()}"
          : programFromDateTextEditingControllerRx.value.text.replaceAll(
              programFromDateTextEditingControllerRx.value.text,
              "${programFromDateTextEditingControllerRx.value.text.split('-')[2]}-${programFromDateTextEditingControllerRx.value.text.split('-')[1]}-${programFromDateTextEditingControllerRx.value.text.split('-')[0]}"),
      "ToDateHeader": programToDateTextEditingControllerRx.value.text == ""
          ? "${DateTime.now()}"
          : programToDateTextEditingControllerRx.value.text.replaceAll(
              programToDateTextEditingControllerRx.value.text,
              "${programToDateTextEditingControllerRx.value.text.split('-')[2]}-${programToDateTextEditingControllerRx.value.text.split('-')[1]}-${programToDateTextEditingControllerRx.value.text.split('-')[0]}"),
      "Lines": promotionProgramInputStateRx.value.promotionProgramInputState
          .asMap()
          .entries
          .map<Map<String, dynamic>>((entry) {
        int index = entry.key;
        var element = entry.value;

        return <String, dynamic>{
          "Id": idLines[index],
          "ItemId": element.selectProductPageDropdownState?.selectedChoice?.id,
          "QtyFrom": element.qtyFrom!.text.isEmpty ? 0 : element.qtyFrom?.text,
          "QtyTo": element.qtyTo!.text.isEmpty ? 0 : element.qtyTo?.text,
          "Unit": element.unitPageDropdownState?.selectedChoice ?? "",
          "Multiply":
              element.multiplyInputPageDropdownState?.selectedChoice?.id,
          "Currency": element.currencyInputPageDropdownState?.selectedChoice,
          "type": element.percentValueInputPageDropdownState!.selectedChoice ==
                  null
              ? 0
              : element.percentValueInputPageDropdownState?.selectedChoice?.id,
          "Pct1": element.percent1!.text.isEmpty ? 0.0 : element.percent1?.text,
          "Pct2": element.percent2!.text.isEmpty ? 0.0 : element.percent2?.text,
          "Pct3": element.percent3!.text.isEmpty ? 0.0 : element.percent3?.text,
          "Pct4": element.percent4!.text.isEmpty ? 0.0 : element.percent4?.text,
          "Value1": element.value1!.text.isEmpty
              ? 0.0
              : element.value1?.text.replaceAll('.', ''),
          "Value2": element.value2!.text.isEmpty
              ? 0.0
              : element.value2?.text.replaceAll('.', ''),
          // "SupplyItemOnlyOnce":"",
          "SupplyItem": element.supplyItem!.selectedChoice == null
              ? ""
              : element.supplyItem?.selectedChoice?.id,
          "QtySupply":
              element.qtyItem!.text.isEmpty ? 0 : element.qtyItem?.text,
          "UnitSupply": element.unitSupplyItem?.selectedChoice,
          "SalesPrice":
              element.salesPrice?.text.replaceAll(RegExp(r"[.,]"), ""),
          "PriceTo":
              element.priceToCustomer?.text.replaceAll(RegExp(r"[.,]"), ""),
        };
      }).toList(),
    });

    final response = await put(Uri.parse('$apiSMS/activity?username=$username'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': '$token',
        },
        body: isiBody);

    final tabController = Get.put(DashboardPPTabController());
    Future.delayed(const Duration(seconds: 2), () {
      if (response.statusCode == 201) {
        onTap.value = true;
        Future.delayed(const Duration(seconds: 2), () {
          tabController.initialIndex = 1;
          Get.delete<InputPageController>();
          Get.offAll(
            const DashboardPage(
              initialIndex: 2,
            ),
          );
          Get.to(const DashboardPP(
            initialIndex: 1,
          ));
          onTap.value = false;
          update();
          // Get.offAll(HistoryNomorPP());
        });
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
