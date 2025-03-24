import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinesController extends GetxController {
  var isLoading = false.obs;

  Future<void> setBundleLines(
      int id, double disc, DateTime? fromDate, DateTime? toDate) async {
    Lines model = Lines();
    List<Lines> listDisc = [];

    final preferences = await SharedPreferences.getInstance();
    String? result = preferences.getString("result");

    if (result != null && result.isNotEmpty) {
      var listStringResult = json.decode(result);
      for (var objectResult in listStringResult) {
        var objects = Lines.fromJson(objectResult as Map<String, dynamic>);
        listDisc.add(objects);
      }
    }

    model.id = id;
    model.disc = disc;
    model.fromDate = fromDate != null
        ? DateFormat('MM-dd-yyyy').format(fromDate).toString()
        : null;
    model.toDate = toDate != null
        ? DateFormat('MM-dd-yyyy').format(toDate).toString()
        : null;

    listDisc.add(model);

    List<Map> listResult = listDisc.map((f) => f.toJson()).toList();
    result = jsonEncode(listResult);
    preferences.setString("result", result);

    update();
  }
}

class HistoryLinesApproved extends StatefulWidget {
  final String numberPP;

  const HistoryLinesApproved({
    Key? key,
    required this.numberPP,
  }) : super(key: key);

  @override
  HistoryLinesApprovedState createState() => HistoryLinesApprovedState();
}

class HistoryLinesApprovedState extends State<HistoryLinesApproved> {
  final linesController = Get.put(LinesController());
  final _listHistorySO = RxList<dynamic>([]);
  final dataHeader = Rx<List<dynamic>?>(null);
  final bool _statusDisable = true;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final isLoading = true.obs;
  final startApp = false.obs;

  String formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final datePart = dateStr.contains(" ") ? dateStr.split(" ")[0] : dateStr;
      final date = DateTime.parse(datePart);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Future<void> listHistorySO() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      final value = await Promotion.getListLines(widget.numberPP);
      _listHistorySO.value = value;
      final encoded = jsonEncode(value);
      dataHeader.value = jsonDecode(encoded);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      startApp.value = true;
      listHistorySO();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: colorNetral,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Lines Detail",
          style: TextStyle(
            fontSize: 20,
            color: colorNetral,
          ),
        ),
      ),
      body: Obx(() => isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _listHistorySO.isEmpty
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  key: refreshKey,
                  onRefresh: listHistorySO,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Obx(() => TextResultCard(
                                  title: "No. PP",
                                  value: dataHeader.value != null
                                      ? _safeString(
                                          dataHeader.value?[0]["nomorPP"])
                                      : '',
                                )),
                            Obx(() => TextResultCard(
                                  title: "PP. Type",
                                  value: dataHeader.value != null
                                      ? _safeString(
                                          dataHeader.value?[0]["type"])
                                      : '',
                                )),
                            Obx(() => TextResultCard(
                                  title: "Customer",
                                  value: dataHeader.value != null
                                      ? _safeString(
                                          dataHeader.value?[0]["customer"])
                                      : '',
                                )),
                            Obx(() => TextResultCard(
                                  title: "Note",
                                  value: dataHeader.value != null
                                      ? _safeString(
                                          dataHeader.value?[0]["note"])
                                      : '',
                                )),
                            Obx(() => TextFormField(
                                  readOnly: true,
                                  initialValue: dataHeader.value != null &&
                                          dataHeader.value!.isNotEmpty &&
                                          dataHeader.value?[0]["fromDate"] !=
                                              null
                                      ? formatDisplayDate(
                                          dataHeader.value?[0]["fromDate"])
                                      : '',
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    labelText: 'From Date',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15,
                                    ),
                                    errorStyle: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 15,
                                    ),
                                  ),
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Obx(() => TextFormField(
                                    readOnly: true,
                                    initialValue: dataHeader.value != null &&
                                            dataHeader.value!.isNotEmpty &&
                                            dataHeader.value?[0]["toDate"] !=
                                                null
                                        ? formatDisplayDate(
                                            dataHeader.value?[0]["toDate"])
                                        : '',
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      labelText: 'To Date',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 15,
                                      ),
                                      errorStyle: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Obx(() => ListView.builder(
                              itemCount: _listHistorySO.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return cardLinesAdapter(widget.numberPP,
                                    _listHistorySO[index], index);
                              },
                            )),
                      ],
                    ),
                  ))),
    );
  }

  Container cardLinesAdapter(String namePP, dynamic promosiData, int index) {
    final Promotion? promosi = promosiData is Promotion ? promosiData : null;

    if (promosi == null) {
      return Container();
    }

    List<Promotion> data = (_listHistorySO).cast<Promotion>();
    List qtyFrom = data.map((element) => element.qty ?? 0).toList();
    List qtyTo = data.map((element) => element.qtyTo ?? 0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          TextResultCard(
            title: "Product",
            value: promosi.product ?? '',
          ),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: TextResultCard(
                  title: "Qty From",
                  value:
                      index < qtyFrom.length ? qtyFrom[index].toString() : '0',
                ),
              ),
              SizedBox(
                width: 150,
                child: TextResultCard(
                  title: "Qty To",
                  value: index < qtyTo.length ? qtyTo[index].toString() : '0',
                ),
              ),
            ],
          ),
          TextResultCard(
            title: 'Unit',
            value: promosi.unitId ?? '',
          ),
          TextResultCard(
            title: "Price",
            value: promosi.price ?? '0',
          ),
          if ((promosi.ppType ?? "") != "Bonus") ...[
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width / 5,
                  child: Text(
                    "Disc1(%) PRB",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    readOnly: _statusDisable,
                    keyboardType: TextInputType.text,
                    initialValue: (promosi.disc1 ?? "0").split(".").first,
                    inputFormatters: [CustomMoneyInputFormatter()],
                    onFieldSubmitted: (value) {
                      linesController.setBundleLines(promosi.id ?? 0,
                          double.tryParse(value) ?? 0, null, null);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width / 5,
                  child: Text(
                    "Disc2(%) COD",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    readOnly: _statusDisable,
                    keyboardType: TextInputType.text,
                    initialValue: (promosi.disc2 ?? "0").split(".").first,
                    inputFormatters: [CustomMoneyInputFormatter()],
                    onFieldSubmitted: (value) {
                      linesController.setBundleLines(
                          promosi.id ?? 0, double.parse(value), null, null);
                    },
                  ),
                ),
              ],
            ),
            promosi.ppType == "Bonus"
                ? const SizedBox()
                : Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(
                          "Disc3(%) Principal1",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: (promosi.disc3 ?? "0").split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            linesController.setBundleLines(promosi.id ?? 0,
                                double.tryParse(value) ?? 0, null, null);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(
                          "Disc4(%) Principal2",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: (promosi.disc4 ?? "0").split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            linesController.setBundleLines(promosi.id ?? 0,
                                double.tryParse(value) ?? 0, null, null);
                          },
                        ),
                      ),
                    ],
                  ),
            promosi.ppType == "Bonus"
                ? const SizedBox()
                : Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(
                          "Disc Value1 ",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue:
                              (promosi.value1 ?? "0").split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            linesController.setBundleLines(promosi.id ?? 0,
                                double.parse(value), null, null);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(
                          "Disc Value2 ",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue:
                              (promosi.value2 ?? "0").split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            linesController.setBundleLines(promosi.id ?? 0,
                                double.parse(value), null, null);
                          },
                        ),
                      ),
                    ],
                  ),
          ],
          if ((promosi.ppType ?? "") != "Diskon") ...[
            TextResultCard(
              title: 'Bonus Item',
              value: promosi.suppItem ?? '',
            ),
            TextResultCard(
              title: 'Bonus Qty',
              value: promosi.suppQty ?? '',
            ),
            TextResultCard(
              title: 'Bonus Unit',
              value: promosi.suppUnit ?? '',
            ),
          ],
          TextResultCard(
            title: "Total",
            value: "Rp${CustomMoneyInputFormatter().formatEditUpdate(
                  TextEditingValue(text: promosi.price ?? "0"),
                  TextEditingValue(text: promosi.price ?? "0"),
                ).text}",
          ),
        ],
      ),
    );
  }
}
