import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesPendingController extends GetxController {
  final String numberPP;
  final RxBool isDataLoaded = false.obs;
  final RxList<Promotion> listHistorySO = <Promotion>[].obs;
  final RxMap<dynamic, dynamic> dataHeader = <dynamic, dynamic>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool valueSelectAll = false.obs;
  final RxList<Map<String, dynamic>> selectedLines =
      <Map<String, dynamic>>[].obs;
  dynamic listHistorySOEncode;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  var user = User().obs;
  bool startApp = false;
  var addToLines = <Map<String, dynamic>>[].obs;

  Rx<Promotion> dataApprovalDetails = Promotion().obs;

  final fromDateHeaderController = TextEditingController();
  final toDateHeaderController = TextEditingController();
  final qtyFromController = TextEditingController();
  final qtyToController = TextEditingController();
  final List<TextEditingController> discControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> valueControllers =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> suppQtyControllers = [];

  HistoryLinesPendingController({required this.numberPP});

  List<TextEditingController> disc1Controller = [];
  List<TextEditingController> disc2Controller = [];
  List<TextEditingController> disc3Controller = [];
  List<TextEditingController> disc4Controller = [];
  List<TextEditingController> value1Controller = [];
  List<TextEditingController> value2Controller = [];
  List<TextEditingController> suppQtyController = [];

  List dataSupplyItem = [];
  List unitController = [];
  List suppItemController = [];
  List suppUnitController = [];
  List warehouseController = [];
  var promotion = Promotion().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final value = await Promotion.getListLinesPending(numberPP);
      listHistorySO.assignAll(value);

      if (listHistorySO.isNotEmpty) {
        dataHeader.assignAll(listHistorySO[0].toJson());
        _initializeControllers();
      }
      isDataLoaded.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeControllers() {
    for (var promotion in listHistorySO) {
      suppQtyControllers.add(
          TextEditingController(text: promotion.suppQty?.toString() ?? ''));
    }
  }

  void toggleSelectAll() {
    valueSelectAll.toggle();
    selectedLines.clear();

    if (valueSelectAll.value) {
      selectedLines.addAll(listHistorySO
          .map((promotion) => _createLineData(promotion))
          .toList());
    }
    update();
  }

  void toggleLineSelection(Promotion promotion, bool isSelected) {
    if (isSelected) {
      selectedLines.add(_createLineData(promotion));
    } else {
      selectedLines.removeWhere((item) => item['id'] == promotion.id);
    }
    update();
  }

  Map<String, dynamic> _createLineData(Promotion promotion) {
    // Helper function to format date
    String formatDate(String? dateStr, String? defaultDate) {
      if (dateStr == null || dateStr.isEmpty) {
        return defaultDate ?? '';
      }
      try {
        // Try parsing with different formats
        DateTime date;
        try {
          date = DateFormat('MM-dd-yyyy').parse(dateStr);
        } catch (e) {
          try {
            date = DateTime.parse(dateStr);
          } catch (e) {
            return defaultDate ?? '';
          }
        }
        return DateFormat('MM-dd-yyyy').format(date);
      } catch (e) {
        return defaultDate ?? '';
      }
    }

    String extractItemCode(String? fullItem) {
      if (fullItem == null || fullItem.isEmpty) return '';

      final itemCodeMatch = RegExp(r'^[A-Z]\d+').firstMatch(fullItem);
      return itemCodeMatch?.group(0) ?? fullItem;
    }

    return {
      "id": promotion.id,
      "qtyFrom": qtyFromController.text.isEmpty
          ? promotion.qty
          : double.parse(qtyFromController.text),
      "qtyTo": qtyToController.text.isEmpty
          ? promotion.qtyTo
          : double.parse(qtyToController.text),
      "unit": promotion.unitId,
      "disc1": _getDiscValue(0, promotion.disc1),
      "disc2": _getDiscValue(1, promotion.disc2),
      "disc3": _getDiscValue(2, promotion.disc3),
      "disc4": _getDiscValue(3, promotion.disc4),
      "value1": _getValueAmount(0, promotion.value1),
      "value2": _getValueAmount(1, promotion.value2),
      "suppQty": _getSuppQtyValue(promotion),
      "suppItem": extractItemCode(promotion.suppItem),
      "suppUnit": promotion.suppUnit,
      "warehouse": promotion.warehouse,
      "fromDate": formatDate(fromDateHeaderController.text, promotion.fromDate),
      "toDate": formatDate(toDateHeaderController.text, promotion.toDate),
    };
  }

  double _getDiscValue(int index, String? defaultValue) {
    final text = discControllers[index].text;
    return text.isEmpty
        ? double.parse(defaultValue ?? '0')
        : double.parse(text);
  }

  double _getValueAmount(int index, String? defaultValue) {
    final text =
        valueControllers[index].text.replaceAll(',', '').replaceAll('.', '');
    return text.isEmpty
        ? double.parse(defaultValue ?? '0')
        : double.parse(text);
  }

  double _getSuppQtyValue(Promotion promotion) {
    final index = listHistorySO.indexOf(promotion);
    if (index >= 0 && index < suppQtyControllers.length) {
      final text = suppQtyControllers[index].text;
      return text.isEmpty
          ? double.parse(promotion.suppQty ?? '0')
          : double.parse(text);
    }
    return 0;
  }

  Future<void> approveOrReject(String action) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userid");

      if (selectedLines.isEmpty) {
        selectedLines.addAll(listHistorySO
            .map((promotion) => _createLineData(promotion))
            .toList());
      }

      final requestBody = {
        "status": action == "Approve" ? 1 : 2,
        "lines": selectedLines
      };
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await put(Uri.parse("$apiCons/api/Approve/$userId"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        Get.off(() => const DashboardApprovalPP(initialIndex: 0));
      } else {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during ${action.toLowerCase()}: $e');
      Get.snackbar(
        "Error",
        "Failed to ${action.toLowerCase()}: $e",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
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

  final dataLines = <Lines>[].obs;
  Future<void> listHistoryPendingSO() async {
    isLoading.value = true;
    try {
      final value = await Promotion.getListLinesPending(
        numberPP,
      );

      listHistorySO.assignAll(value);
      listHistorySOEncode = jsonEncode(listHistorySO);

      if (listHistorySO.isNotEmpty) {
        dataHeader.assignAll(listHistorySO[0].toJson());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSupplyItem() async {
    var url = "$apiCons/api/PrbItemTables";
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final listData = jsonDecode(response.body);
      dataSupplyItem.assignAll(listData);
    }
  }

  Future<void> getUnit(String? itemId) async {
    var url = "$apiCons2/api/Unit?item=$itemId";
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
        "qtyFrom": qtyFromController.text.isEmpty
            ? data[i].qty
            : double.parse(qtyFromController.text),
        "qtyTo": qtyToController.text.isEmpty
            ? data[i].qtyTo
            : double.parse(qtyToController.text),
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

  @override
  void onClose() {
    fromDateHeaderController.dispose();
    toDateHeaderController.dispose();
    qtyFromController.dispose();
    qtyToController.dispose();
    for (var controller in [
      ...discControllers,
      ...valueControllers,
      ...suppQtyControllers
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}
