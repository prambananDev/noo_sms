import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesPendingController extends GetxController {
  // String numberPP = Get.arguments['numberPP'];
  final String numberPP;
  HistoryLinesPendingController({required this.numberPP});

  final listHistorySO = <Promotion>[].obs;
  dynamic listHistorySOEncode;
  final RxMap<dynamic, dynamic> dataHeader = <dynamic, dynamic>{}.obs;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  var user = User().obs;
  final User _user = User();
  final isLoading = true.obs;
  var valueSelectAll = false.obs;
  bool startApp = false;
  var addToLines = <Map<String, dynamic>>[].obs;
  int? code;

  // TextEditingControllers for inputs
  List<TextEditingController> disc1Controller = [];
  List<TextEditingController> disc2Controller = [];
  List<TextEditingController> disc3Controller = [];
  List<TextEditingController> disc4Controller = [];
  List<TextEditingController> value1Controller = [];
  List<TextEditingController> value2Controller = [];
  List<TextEditingController> suppQtyController = [];
  List<TextEditingController> qtyToController = [];
  List<TextEditingController> qtyFromController = [];
  TextEditingController fromDateHeaderController = TextEditingController();
  TextEditingController toDateHeaderController = TextEditingController();

  List dataSupplyItem = [];
  List<dynamic> unitController = [];
  List suppItemController = [];
  List suppUnitController = [];
  List warehouseController = [];

  @override
  void onInit() {
    super.onInit();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    getSharedPreference();
    getSupplyItem();
    // listHistoryPendingSO();
    // initializeDataAndControllers();
    Future.delayed(const Duration(seconds: 2), () {
      startApp = true;
      listHistoryPendingSO();
      initializeDataAndControllers();
    });
  }

  void initializeDataAndControllers() {
    List<Promotion> data = listHistorySO.cast<Promotion>();
    List<double?> qtyFrom = extractData(data, (e) => e.qty);
    List<double?> qtyTo = extractData(data, (e) => e.qtyTo);

    initializeTextControllers(
        qtyFromController, qtyFrom.map((e) => e?.toString() ?? '').toList());
    initializeTextControllers(
        qtyToController, qtyTo.map((e) => e?.toString() ?? '').toList());
  }

  void initializeTextControllers(
      List<TextEditingController> controllers, List<String?> values) {
    for (int i = 0; i < values.length; i++) {
      controllers.add(TextEditingController()..text = values[i] ?? '');
    }
  }

  List<T?> extractData<T>(
      List<Promotion> data, T? Function(Promotion) extractor) {
    return data.map(extractor).toList();
  }

  Future<void> listHistoryPendingSO() async {
    isLoading.value = true;
    try {
      final value = await Promotion.getListLinesPending(
        numberPP,
        user.value.token ?? '',
        user.value.username ?? '',
      );
      listHistorySO.assignAll(value);
      listHistorySOEncode = jsonEncode(listHistorySO);
      if (listHistorySO.isNotEmpty) {
        dataHeader.assignAll(listHistorySO[0].toJson());
      }

      // qtyFromController =
      //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // qtyToController =
      //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // disc1Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // disc2Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // disc3Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // disc4Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // value1Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // value2Controller =
      // //     List.generate(listHistorySO.length, (_) => TextEditingController());
      // // unitController = List.generate(listHistorySO.length, (_) => '');

      debugPrint('Successfully fetched data: ${dataHeader.toString()}');
    } catch (error) {
      print('Error fetching history: $error');
    } finally {
      isLoading.value = false;
    }
  }

  void getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();
    user.value = listUser.isNotEmpty ? listUser[0] : User();
    code = pref.getInt("code") ?? 0;
  }

  Future<void> getSupplyItem() async {
    var url = "$apiCons/api/PrbItemTables";
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final listData = jsonDecode(response.body);
      dataSupplyItem.assignAll(listData);
    }
  }

  Future<void> getUnit(String itemId) async {
    var url = "$apiCons/api/Unit?item=$itemId";
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final listData = jsonDecode(response.body);
      unitController.assignAll(listData);
    }
  }

  Future<void> getSupplyUnit(String itemId) async {
    var url = "$apiCons/api/Unit?item=$itemId";
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final listData = jsonDecode(response.body);
      suppUnitController.assignAll(listData);
    }
  }

  Future<void> getWarehouse() async {
    var url = "$apiCons/api/Warehouse";
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final listData = jsonDecode(response.body);
      warehouseController.assignAll(listData);
    }
  }

  Future<void> approveNew(String approveOrReject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic id = prefs.getInt("userid");
    String url = "$apiCons/api/Approve/$id";

    List<Promotion> data = listHistorySO.cast<Promotion>();

    List<Map<String, dynamic>> lines = [];
    for (int i = 0; i < data.length; i++) {
      lines.add({
        "id": data[i].id,
        "qtyFrom": qtyFromController[i].text.isEmpty
            ? data[i].qty
            : double.parse(qtyFromController[i].text),
        "qtyTo": qtyToController[i].text.isEmpty
            ? data[i].qtyTo
            : double.parse(qtyToController[i].text),
        "unit": unitController[i] ?? data[i].unitId,
        "disc1": disc1Controller[i].text.isEmpty
            ? data[i].disc1
            : double.parse(disc1Controller[i].text),
        "disc2": disc2Controller[i].text.isEmpty
            ? data[i].disc2
            : double.parse(disc2Controller[i].text),
        "disc3": disc3Controller[i].text.isEmpty
            ? data[i].disc3
            : double.parse(disc3Controller[i].text),
        "disc4": disc4Controller[i].text.isEmpty
            ? data[i].disc4
            : double.parse(disc4Controller[i].text),
        "value1": value1Controller[i].text.isEmpty
            ? data[i].value1
            : double.parse(value1Controller[i]
                .text
                .replaceAll(",", "")
                .replaceAll(".", "")),
        "value2": value2Controller[i].text.isEmpty
            ? data[i].value2
            : double.parse(value2Controller[i]
                .text
                .replaceAll(",", "")
                .replaceAll(".", "")),
        "suppQty": suppQtyController[i].text.isEmpty
            ? data[i].suppQty
            : double.parse(suppQtyController[i].text),
        "suppItem": suppItemController[i] ?? data[i].suppItem,
        "suppUnit": suppUnitController[i] ?? data[i].suppUnit,
        "warehouse": warehouseController[i] ?? data[i].warehouse,
        "fromDate": fromDateHeaderController.text.isEmpty
            ? data[i].fromDate
            : fromDateHeaderController.text,
        "toDate": toDateHeaderController.text.isEmpty
            ? data[i].toDate
            : toDateHeaderController.text,
      });
    }

    dynamic isiBody = jsonEncode(<String, dynamic>{
      "status": approveOrReject == "Approve" ? 1 : 2,
      'lines': lines,
    });

    final response = await put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: isiBody,
    );

    if (response.statusCode == 200) {
      Get.off(const DashboardApprovalPP(initialIndex: 0));
    } else {
      Get.dialog(Center(child: Text("${response.statusCode}")));
    }
  }

  void toggleSelectAll() {
    valueSelectAll.value = !valueSelectAll.value;
    for (var promo in listHistorySO) {
      promo.status = valueSelectAll.value;
      if (promo.status!) {
        addToLines.add(promo.toJson());
      } else {
        addToLines.removeWhere((item) => item['id'] == promo.id);
      }
    }
  }
}
