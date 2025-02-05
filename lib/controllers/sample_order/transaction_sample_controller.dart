import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/wrapper.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionSampleController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  Rx<InputPageWrapper> promotionProgramInputStateRx =
      InputPageWrapper(promotionProgramInputState: [], isAddItem: false).obs;
  Rx<TextEditingController> transactionNumberTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> custNameTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> custPicTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> custPhoneTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> custAddressTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> purposeDescTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> transactionDateTextEditingControllerRx =
      TextEditingController().obs;
  Rx<TextEditingController> principalNameTextEditingControllerRx =
      TextEditingController().obs;
  Rx<bool> isClaim = false.obs;
  Rx<InputPageDropdownState<IdAndValue<String>>>
      promotionTypeInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  Rx<InputPageDropdownState<IdAndValue<String>>>
      customerNameInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  Rx<InputPageDropdownState<String>> statusTestingInputPageDropdownStateRx =
      InputPageDropdownState<String>().obs;

  WrappedInputPageDropdownState<IdAndValue<String>>
      productInputPageDropdownState =
      WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper: Wrapper(value: <IdAndValue<String>>[]),
          loadingStateWrapper: Wrapper(value: 0),
          selectedChoiceWrapper: Wrapper(value: null));

  Rx<InputPageDropdownState<IdAndValue<String>>> typesList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> purposeList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> deptList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> principalList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> distributionChannelList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> unitList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  RxBool isProspectValid = false.obs;

  final List<Map<String, dynamic>> types = [
    {"id": "0", "value": "Commercial"},
    {"id": "1", "value": "Non Commercial"},
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    loadInitialData();
    _loadProduct();
    _loadSampleType();
  }

  void loadInitialData() {
    _loadCustomerNameByUsername();
  }

  void _loadSampleType() {
    typesList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: types.map<IdAndValue<String>>((type) {
        return IdAndValue<String>(
          id: type["id"].toString(),
          value: type["value"],
        );
      }).toList(),
      loadingState: 2,
    );
    update();
  }

  void changeSampleType(IdAndValue<String>? selectedChoice) async {
    typesList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: typesList.value.choiceList,
      selectedChoice: selectedChoice,
    );
    update();
    await _loadPurpose();
    await _loadDept();
    await _loadPrincipal();
    update();
  }

  void validateProspectFields() {
    isProspectValid.value =
        custNameTextEditingControllerRx.value.text.isNotEmpty &&
            custPicTextEditingControllerRx.value.text.isNotEmpty &&
            custPhoneTextEditingControllerRx.value.text.isNotEmpty &&
            custAddressTextEditingControllerRx.value.text.isNotEmpty;
  }

  void changeSelectCustomer(IdAndValue<String>? selectedChoice) {
    customerNameInputPageDropdownStateRx.value.selectedChoice = selectedChoice;
    checkAddItemStatus();
    _loadDistrChannel();
    update();
    if (selectedChoice?.id == 'prospect') {
      validateProspectFields();
    }
    update();
  }

  void updateProspectField(String field) {
    if (customerNameInputPageDropdownStateRx.value.selectedChoice?.id ==
        'prospect') {
      validateProspectFields();
    }
    update();
  }

  _loadPurpose() async {
    final selectSampleType = typesList.value.selectedChoice?.id;
    var urlGetPurpose =
        "http://sms.prb.co.id/sample/SamplePurpose?type=$selectSampleType";

    var response = await Dio().get(urlGetPurpose);
    var listData = response.data;
    debugPrint(listData.toString());

    List<IdAndValue<String>> mappedList =
        (listData as List).map<IdAndValue<String>>((element) {
      return IdAndValue<String>(
        id: element["Value"].toString(),
        value: element["Text"],
      );
    }).toList();

    purposeList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: mappedList,
      selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
      loadingState: 2,
    );

    debugPrint(purposeList.value.selectedChoice?.id.toString());

    update();
  }

  void changePurpose(IdAndValue<String>? newValue) {
    purposeList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: purposeList.value.choiceList,
      selectedChoice: newValue,
      loadingState: 2,
    );
    update();
  }

  Future<void> _loadUnit(int index) async {
    final promotionProgram =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    final selectedProductId = promotionProgram
        .productTransactionPageDropdownState?.selectedChoiceWrapper?.value?.id;

    if (selectedProductId == null) return;

    final url = "http://sms.prb.co.id/Unit/Index/$selectedProductId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final listData = jsonDecode(response.body) as List;
        final mappedList = listData.map<String>((element) {
          return element["Text"].toString();
        }).toList();

        // Update the state immediately
        promotionProgramInputStateRx.value.promotionProgramInputState[index]
            .unitPageDropdownState = InputPageDropdownState<String>(
          choiceList: mappedList,
          loadingState: 2,
          selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
        );

        // Force refresh
        promotionProgramInputStateRx.refresh();
        update();
      }
    } catch (e) {}
  }

  void changeUnit(int index, String? selectedChoice) {
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .unitPageDropdownState?.selectedChoice = selectedChoice;
    update();
  }

  _loadDept() async {
    var urlGetDept = "http://sms.prb.co.id/sample/SampleDept";

    final response = await http.get(Uri.parse(urlGetDept));
    if (response.statusCode == 200) {
      var listData = jsonDecode(response.body);

      List<IdAndValue<String>> mappedList =
          listData.map<IdAndValue<String>>((element) {
        return IdAndValue<String>(
          id: element["Value"].toString(),
          value: element["Text"],
        );
      }).toList();

      deptList.value = InputPageDropdownState<IdAndValue<String>>(
        choiceList: mappedList,
        selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
        loadingState: 2,
      );
    } else {
      throw Exception('Failed to load department data');
    }

    update();
  }

  void changeDept(IdAndValue<String>? newValue) {
    deptList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: deptList.value.choiceList,
      selectedChoice: newValue,
      loadingState: 2,
    );
    update();
  }

  _loadPrincipal() async {
    var urlGetPrincipal = "http://sms.prb.co.id/sample/SamplePrincipals";
    final response = await http.get(Uri.parse(urlGetPrincipal));
    var listData = jsonDecode(response.body);
    debugPrint(listData.toString());
    List<IdAndValue<String>> mappedList =
        listData.map<IdAndValue<String>>((element) {
      return IdAndValue<String>(
        id: element["Value"].toString(),
        value: element["Text"],
      );
    }).toList();
    mappedList.insert(0, IdAndValue(id: '0', value: 'New Principal'));

    principalList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: mappedList,
      selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
      loadingState: 2,
    );

    update();
  }

  void changePrincipal(IdAndValue<String>? newValue) {
    principalList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: principalList.value.choiceList,
      selectedChoice: newValue,
      loadingState: 2,
    );
    update();
  }

  void _loadDistrChannel() async {
    var urlGetPrincipal = "http://sms.prb.co.id/sample/SampleDistChannel";
    final response = await http.get(Uri.parse(urlGetPrincipal));
    var listData = jsonDecode(response.body);
    debugPrint(listData.toString());
    List<IdAndValue<String>> mappedList =
        listData.map<IdAndValue<String>>((element) {
      return IdAndValue<String>(
        id: element["Value"].toString(),
        value: element["Text"],
      );
    }).toList();
    distributionChannelList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: mappedList,
      selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
      loadingState: 2,
    );

    update();
  }

  void changeDistributionChannel(IdAndValue<String>? newValue) {
    distributionChannelList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: distributionChannelList.value.choiceList,
      selectedChoice: newValue,
      loadingState: 2,
    );
    update();
  }

  void _loadCustomerNameByUsername() async {
    customerNameInputPageDropdownStateRx.value.loadingState = 1;
    update();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    try {
      var urlGetCustomer = "$apiCons2/api/AllCustomer?username=$username";
      final response = await http.get(Uri.parse(urlGetCustomer));
      var listData = jsonDecode(response.body);

      List<IdAndValue<String>> customers = listData
          .map<IdAndValue<String>>((element) => IdAndValue<String>(
              id: element["codeCust"], value: element["nameCust"]))
          .toList();
      customers.insert(0, IdAndValue(id: 'prospect', value: 'Prospect'));

      customerNameInputPageDropdownStateRx.value =
          InputPageDropdownState<IdAndValue<String>>(
        choiceList: customers,
        selectedChoice:
            customerNameInputPageDropdownStateRx.value.selectedChoice,
        loadingState: 2,
      );

      update();
    } catch (e) {
      customerNameInputPageDropdownStateRx.value =
          InputPageDropdownState<IdAndValue<String>>(
        choiceList: [],
        selectedChoice: null,
        loadingState: -1,
      );
    }
    update();
  }

  void checkAddItemStatus() {
    promotionProgramInputStateRx.value.isAddItem =
        customerNameInputPageDropdownStateRx.value.selectedChoice != null;
    update();
  }

  void _loadProduct() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    productInputPageDropdownState.loadingStateWrapper?.value = 1;
    update();
    var urlGetProduct = "$apiCons2/api/AllProduct?ID=$username&idSales=Sample";
    final response = await get(Uri.parse(urlGetProduct));
    var listData = jsonDecode(response.body);
    productInputPageDropdownState.loadingStateWrapper?.value = 2;
    productInputPageDropdownState.choiceListWrapper?.value = listData
        .map<IdAndValue<String>>((element) => IdAndValue<String>(
            id: element["itemId"].toString(), value: element["itemName"]))
        .toList();
    update();
  }

  List<String> originalPrice = [];
  Future<double> getQtyUnitPrice(
      String cusId, String idProduct, int qty, String unit) async {
    var urlPrice =
        "$apiCons2/api/AllPrice?cust=$cusId&item=$idProduct&unit=$unit&qty=$qty&type=1";
    final responsePrice = await http.get(Uri.parse(urlPrice));
    double listDataPrice = 0.0;
    if (responsePrice.statusCode == 200) {
      listDataPrice = jsonDecode(responsePrice.body);
    } else {
      listDataPrice = 0.0;
    }
    return listDataPrice;
  }

  void changeProduct(int index, IdAndValue<String> selectedChoice) async {
    promotionProgramInputStateRx
        .value
        .promotionProgramInputState[index]
        .productTransactionPageDropdownState
        ?.selectedChoiceWrapper
        ?.value = selectedChoice;

    promotionProgramInputStateRx.refresh();

    await _loadUnit(index);

    promotionProgramInputStateRx.refresh();
    update();
  }

  void changeBatch(int index, IdAndValue<String> selectedChoice) {
    promotionProgramInputStateRx
        .value
        .promotionProgramInputState[index]
        .batchTransactionDropdownState
        ?.selectedChoiceWrapper
        ?.value = selectedChoice;
    update();
  }

  void changeQty(int index, String qty) async {
    PromotionProgramInputState promotionProgramInputState =
        promotionProgramInputStateRx.value.promotionProgramInputState[index];
    promotionProgramInputState.qtyTransaction?.text = qty;
    update();
  }

  void totalTransaction(int index, int price, String qty) {
    int qtyTotal = int.parse(qty);
    String priceTotal = (price * qtyTotal).toString();
    promotionProgramInputStateRx.value.promotionProgramInputState[index]
        .totalTransaction?.text = priceTotal;
    update();
  }

  void addItem() {
    promotionProgramInputStateRx.value.promotionProgramInputState.add(
      PromotionProgramInputState(
        productTransactionPageDropdownState:
            WrappedInputPageDropdownState<IdAndValue<String>>(
          choiceListWrapper:
              productInputPageDropdownState.choiceListWrapper?.copy(),
          loadingStateWrapper:
              productInputPageDropdownState.loadingStateWrapper?.copy(),
          selectedChoiceWrapper: Wrapper<IdAndValue<String>>(value: null),
        ),
        unitPageDropdownState:
            InputPageDropdownState<String>(choiceList: [], loadingState: 0),
        qtyTransaction: TextEditingController(text: "1"),
      ),
    );
    promotionProgramInputStateRx.refresh();
  }

  void removeItem(int index) {
    promotionProgramInputStateRx.value.promotionProgramInputState
        .removeAt(index);
    update();
  }

  bool promotionProgramInputValidation() {
    return true;
  }

  bool validateSubmission() {
    if (typesList.value.selectedChoice == null) {
      Get.snackbar('Error', 'Please select Sample Type',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return false;
    }

    if (purposeList.value.selectedChoice == null) {
      Get.snackbar('Error', 'Please select Purpose',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return false;
    }

    if (purposeDescTextEditingControllerRx.value.text.isEmpty) {
      Get.snackbar('Error', 'Please enter Purpose Description',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return false;
    }

    if (promotionProgramInputStateRx.value.promotionProgramInputState.isEmpty) {
      Get.snackbar('Error', 'Please add at least one product',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
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
        Get.snackbar('Error', 'Please select product for line ${i + 1}',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return false;
      }

      if (element.qtyTransaction?.text.isEmpty == true ||
          element.qtyTransaction?.text == "0") {
        Get.snackbar('Error', 'Please enter quantity for line ${i + 1}',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return false;
      }

      if (element.unitPageDropdownState?.selectedChoice == null) {
        Get.snackbar('Error', 'Please select unit for line ${i + 1}',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return false;
      }
    }

    if (typesList.value.selectedChoice?.value == 'Commercial') {
      if (customerNameInputPageDropdownStateRx.value.selectedChoice == null) {
        Get.snackbar('Error', 'Please select Customer Name',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return false;
      }

      if (customerNameInputPageDropdownStateRx.value.selectedChoice?.id ==
          'prospect') {
        if (custNameTextEditingControllerRx.value.text.isEmpty ||
            custPicTextEditingControllerRx.value.text.isEmpty ||
            custPhoneTextEditingControllerRx.value.text.isEmpty ||
            custAddressTextEditingControllerRx.value.text.isEmpty) {
          Get.snackbar('Error', 'Please fill all prospect customer details',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
          return false;
        }

        if (distributionChannelList.value.selectedChoice == null) {
          Get.snackbar('Error', 'Please select Distribution Channel',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
          return false;
        }
      }

      if (isClaim.value) {
        if (principalList.value.selectedChoice == null) {
          Get.snackbar('Error', 'Please select Principal',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
          return false;
        }

        if (principalList.value.selectedChoice?.id == '0' &&
            principalNameTextEditingControllerRx.value.text.isEmpty) {
          Get.snackbar('Error', 'Please enter Principal Name',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
          return false;
        }
      }
    } else {
      if (deptList.value.selectedChoice == null) {
        Get.snackbar('Error', 'Please select Department',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return false;
      }
    }

    return true;
  }

  Future<void> submitPromotionProgram() async {
    if (!validateSubmission()) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    final int idEmp =
        int.tryParse(preferences.getString("getIdEmp") ?? '0') ?? 0;

    final isiBody = jsonEncode({
      "sampleType": typesList.value.selectedChoice?.id,
      "samplePurpose": purposeList.value.selectedChoice?.id,
      "description": purposeDescTextEditingControllerRx.value.text,
      "custid": customerNameInputPageDropdownStateRx.value.selectedChoice?.id,
      "custName":
          customerNameInputPageDropdownStateRx.value.selectedChoice?.value,
      "distrChannel": distributionChannelList.value.selectedChoice?.id,
      "custPIC": custPicTextEditingControllerRx.value.text,
      "custPhone": custPhoneTextEditingControllerRx.value.text,
      "custAddress": custAddressTextEditingControllerRx.value.text,
      "isClaim": isClaim.value ? 1 : 0,
      "principal": principalList.value.selectedChoice?.id,
      "principalName": (principalList.value.selectedChoice == null ||
              principalList.value.selectedChoice?.id == '0')
          ? principalNameTextEditingControllerRx.value.text
          : principalList.value.selectedChoice?.value,
      "idEmp": idEmp,
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

    var url = '$apiCons2/api/SampleTransaction';
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
        _resetAllControllers();
        DashboardOrderSampleState.tabController.animateTo(1);
      });
    } else {
      debugPrint(isiBody);
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

  void _resetAllControllers() {
    purposeDescTextEditingControllerRx.value.clear();
    custNameTextEditingControllerRx.value.clear();
    custPicTextEditingControllerRx.value.clear();
    custPhoneTextEditingControllerRx.value.clear();
    custAddressTextEditingControllerRx.value.clear();
    principalNameTextEditingControllerRx.value.clear();

    // Reset dropdown selections
    typesList.value.selectedChoice = null;
    purposeList.value.selectedChoice = null;
    customerNameInputPageDropdownStateRx.value.selectedChoice = null;
    distributionChannelList.value.selectedChoice = null;
    principalList.value.selectedChoice = null;
    deptList.value.selectedChoice = null;

    isClaim.value = false;

    isProspectValid.value = false;

    promotionProgramInputStateRx.value = InputPageWrapper(
      promotionProgramInputState: [],
      isAddItem: false,
    );

    update();
  }

  void updateState() {
    promotionTypeInputPageDropdownStateRx
        .valueFromLast((value) => value.copy());
    customerNameInputPageDropdownStateRx.valueFromLast((value) => value.copy());
    statusTestingInputPageDropdownStateRx
        .valueFromLast((value) => value.copy());
    promotionProgramInputStateRx.valueFromLast((value) => value.copy());
    update();
  }
}
