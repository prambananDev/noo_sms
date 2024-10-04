import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';

import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesApproved extends StatefulWidget {
  @override
  _HistoryLinesApprovedState createState() => _HistoryLinesApprovedState();
  final String numberPP;
  final int idEmp;

  const HistoryLinesApproved(
      {super.key, required this.numberPP, required this.idEmp});
}

class _HistoryLinesApprovedState extends State<HistoryLinesApproved> {
  late List _listHistorySO;
  dynamic _listHistorySOEncode;
  final bool _statusDisable = true;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Lines> listId = [];
  List<Lines> listDisc = [];
  DateTime selectedDate = DateTime.now();
  DateTime fromDate = DateTime.now(), toDate = DateTime.now();
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now().add(const Duration(days: 180));
  Promotion promosi = Promotion();
  User _user = User();
  late int code;
  bool startApp = false;

  Future<void> listHistorySO() async {
    await Future.delayed(const Duration(seconds: 1));
    Promotion.getListLines(widget.numberPP, code, _user.token!, _user.username)
        .then((value) {
      setState(() {
        _listHistorySO = value;
        _listHistorySOEncode = jsonEncode(_listHistorySO);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    getSharedPreference();
    Future.delayed(const Duration(seconds: 2), () {
      startApp = true;
      listHistorySO();
    });
  }

  Future<void> getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      _user = userBox.get(0);
      code = pref.getInt("code")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return WillPopScope(
      onWillPop: onBackPressLines,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: onBackPressLines,
          ),
          title: Text(
            "List Lines",
            style: TextStyle(
              fontSize:
                  screenWidth * 0.05, // Dynamic text size based on screen width
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: listHistorySO,
          child: FutureBuilder(
            future: Promotion.getListLines(
                widget.numberPP, code, _user.token!, _user.username),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              _listHistorySO = _listHistorySO ?? snapshot.data;

              if (_listHistorySO[0].codeError == 404 ||
                  _listHistorySO[0].codeError == 303) {
                return Text(_listHistorySO[0].message);
              } else {
                return startApp == false
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextResultCard(
                                    title: "No. PP",
                                    value: _formatPPNumber(
                                        _listHistorySO[0]["nomorPP"]),
                                  ),
                                  TextResultCard(
                                    title: "PP. Type",
                                    value: "${_listHistorySO[0]["type"]}",
                                  ),
                                  TextResultCard(
                                    title: "Customer",
                                    value: "${_listHistorySO[0]["customer"]}",
                                  ),
                                  TextResultCard(
                                    title: "Note",
                                    value: "${_listHistorySO[0]["note"]}",
                                  ),
                                  // Example of using MediaQuery for a dynamic width
                                  Container(
                                    width: screenWidth * 0.9,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: _listHistorySO[0]
                                              ["fromDate"]
                                          .split(" ")[0],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        labelText: 'From Date',
                                        hintStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                        errorStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.9,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: _listHistorySO[0]["toDate"]
                                          .split(" ")[0],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        labelText: 'To Date',
                                        hintStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                        errorStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              itemCount: _listHistorySO.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return CardLinesAdapter(widget.numberPP,
                                    _listHistorySO[index], index);
                              },
                            ),
                          ],
                        ),
                      );
              }
            },
          ),
        ),
      ),
    );
  }

  String _formatPPNumber(String numberPP) {
    return RegExp(r"\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}").hasMatch(numberPP)
        ? numberPP.replaceRange(34, null, "")
        : numberPP;
  }

  Container CardLinesAdapter(String namePP, Promotion promosi, int index) {
    double price = double.parse(
        promosi.price!.replaceAll(RegExp("Rp"), "").replaceAll(".", ""));
    double disc1 = double.parse(promosi.disc1!);
    double disc2 = double.parse(promosi.disc2!);
    double disc3 = double.parse(promosi.disc3!);
    double disc4 = double.parse(promosi.disc4!);
    double discValue1 = double.parse(promosi.value1!);
    double discValue2 = double.parse(promosi.value2!);
    double totalPriceDiscOnly =
        price - (price * ((disc1 + disc2 + disc3 + disc4) / 100));
    double totalPriceDiscValue = price - (discValue1 + discValue2);

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextResultCard(title: "Product", value: promosi.product!),
          Row(
            children: [
              Expanded(
                child: TextResultCard(
                  title: "Qty From",
                  value: promosi.qty.toString(),
                ),
              ),
              Expanded(
                child: TextResultCard(
                  title: "Qty To",
                  value: promosi.qtyTo.toString(),
                ),
              ),
            ],
          ),
          TextResultCard(title: 'Unit', value: promosi.unitId!),
          TextResultCard(title: "Price", value: promosi.price!),
          TextResultCard(
            title: "Total",
            value:
                "Rp${_formatTotalAmount(promosi.disc1 == "0.00" && promosi.disc2 == "0.00" && promosi.disc3 == "0.00" && promosi.disc4 == "0.00" ? totalPriceDiscValue : totalPriceDiscOnly)}",
          ),
        ],
      ),
    );
  }

  String _formatTotalAmount(double amount) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(amount);
  }

  Future<bool> onBackPressLines() async {
    Get.off(const DashboardPage());
    return true;
  }
}
