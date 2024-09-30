import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/history_lines_all_controller.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesAll extends StatefulWidget {
  @override
  _HistoryLinesAllState createState() => _HistoryLinesAllState();
  String? numberPP;
  int? idEmp;

  HistoryLinesAll({super.key, this.numberPP, this.idEmp});
}

class _HistoryLinesAllState extends State<HistoryLinesAll> {
  List<Promotion>? _listHistorySO; // Ensure this is a list of Promotion
  dynamic _listHistorySOEncode;
  final bool _statusDisable = true;
  GlobalKey<RefreshIndicatorState>? refreshKey;
  List<Lines> listDisc = [];
  DateTime selectedDate = DateTime.now();
  DateTime? fromDate, toDate;
  DateTime? dateFrom, dateTo;
  double? discount;
  User? _user;
  int? code;
  bool valueSelectAll = false;
  var dataHeader;
  bool startApp = false;
  var listLines;
  final HistoryLinesController _controller = HistoryLinesController();

  void getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();
    Future.delayed(const Duration(milliseconds: 10));
    setState(() {
      _user = listUser[0];
      code = pref.getInt("code");
    });
  }

  Future<void> listHistorySO() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final value = await Promotion.getListLines(
        widget.numberPP ?? '0',
        code ?? 0,
        _user?.token ?? '',
        _user?.username ?? '',
      );
      setState(() {
        listLines = value ?? [];
        _listHistorySO = value ?? [];
        _listHistorySOEncode = jsonEncode(_listHistorySO);
        dataHeader = jsonDecode(_listHistorySOEncode);
      });
    } catch (error) {
      print('Error fetching history SO: $error');
    }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressLines,
      child: MaterialApp(
        theme: Theme.of(context),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(
              'List Lines',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colorNetral,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: colorNetral,
              ),
              onPressed: onBackPressLines,
            ),
          ),
          body: Scaffold(
            body: RefreshIndicator(
              onRefresh: listHistorySO,
              child: FutureBuilder<List<Promotion>>(
                future: Promotion.getListLines(
                  widget.numberPP ?? '',
                  code ?? 0,
                  _user?.token ?? '',
                  _user?.username ?? '',
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Promotion>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            semanticsLabel: "Loading..."));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    _listHistorySO = snapshot.data; // Assign the data

                    var firstItem = _listHistorySO![0]; // Ensure it's a list

                    return startApp == false
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("No. PP    : ${firstItem.nomorPP}"),
                                      Text("PP. Type  : ${firstItem.ppType}"),
                                      Text("Customer  : ${firstItem.customer}"),
                                      Text("Note      : ${firstItem.note}"),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: _listHistorySO?.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return CardLinesAdapter(
                                        widget.numberPP ?? '',
                                        _listHistorySO![index],
                                        index);
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
        ),
      ),
    );
  }

  Future<bool> onBackPressLines() async {
    Get.off(const DashboardPage());
    return true;
// return Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (context) {
    //   return HistoryNomorPP();
    // }));
  }

  Container CardLinesAdapter(String namePP, Promotion promotion, int index) {
    double price = double.parse(
        promotion.price!.replaceAll(RegExp("Rp"), "").replaceAll(".", ""));
    double disc1 = double.parse(promotion.disc1 ?? '0');
    double disc2 = double.parse(promotion.disc2 ?? '0');
    double disc3 = double.parse(promotion.disc3 ?? '0');
    double disc4 = double.parse(promotion.disc4 ?? '0');
    double discValue1 = double.parse(promotion.value1 ?? '0');
    double discValue2 = double.parse(promotion.value2 ?? '0');

    double totalPriceDiscOnly =
        price - (price * ((disc1 + disc2 + disc3 + disc4) / 100));
    double totalPriceDiscValue = price - (discValue1 + discValue2);

    List qtyFrom = _listHistorySO!.map((element) => element.qty).toList();
    List qtyTo = _listHistorySO!.map((element) => element.qtyTo).toList();

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorGray,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextResultCard(
            title: "Product",
            value: promotion.product ?? "",
          ),
          TextResultCard(
            title: "Qty From",
            value: qtyFrom[index].toString(),
          ),
          TextResultCard(
            title: "Qty To",
            value: qtyTo[index].toString(),
          ),
          TextResultCard(
            title: 'Unit',
            value: promotion.unitId ?? "",
          ),
          TextResultCard(
            title: "Price",
            value: promotion.price ?? "",
          ),
          // Add discount fields as needed
          if (promotion.ppType != "Bonus") ...[
            Row(
              children: <Widget>[
                SizedBox(
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
                    initialValue: promotion.disc1?.split(".").first ?? '',
                    onFieldSubmitted: (value) {
                      // Check if dateFrom and dateTo are not null before using them
                      if (dateFrom != null && dateTo != null) {
                        _controller.setBundleLines(promotion.id,
                            double.parse(value), dateFrom!, dateTo!);
                      } else {
                        // Handle the null case appropriately (e.g., show an error message)
                        print('Error: dateFrom or dateTo is null');
                      }
                    },
                  ),
                ),
                SizedBox(
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
                    initialValue: promotion.disc2?.split(".").first ?? "",
                    onFieldSubmitted: (value) {
                      // Check if dateFrom and dateTo are not null before using them
                      if (dateFrom != null && dateTo != null) {
                        _controller.setBundleLines(promotion.id,
                            double.parse(value), dateFrom!, dateTo!);
                      } else {
                        // Handle the null case appropriately
                        print('Error: dateFrom or dateTo is null');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
          TextResultCard(
            title: "Total",
            value: "Rp${CustomMoneyInputFormatter().formatEditUpdate(
                  TextEditingValue(text: totalPriceDiscOnly.toString()),
                  TextEditingValue(text: totalPriceDiscOnly.toString()),
                ).text.replaceAll(",", ".")}",
          ),
        ],
      ),
    );
  }
}
