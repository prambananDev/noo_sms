import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/provider/lines_provider.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:noo_sms/view/promotion_program/history_number_pp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesApproved extends StatefulWidget {
  @override
  _HistoryLinesApprovedState createState() => _HistoryLinesApprovedState();
  String numberPP;
  int idEmp;

  HistoryLinesApproved(
      {super.key, required this.numberPP, required this.idEmp});
}

class _HistoryLinesApprovedState extends State<HistoryLinesApproved> {
  List? _listHistorySO;
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
  double discount = 0;
  User _user = User();
  late int code;

  bool valueSelectAll = false;
  var dataHeader;
  bool startApp = false;
  Future<void> listHistorySO() async {
    await Future.delayed(const Duration(seconds: 1));
    Promotion.getListLines(widget.numberPP, _user.token!, _user.username)
        .then((value) {
      setState(() {
        _listHistorySO = value;
        _listHistorySOEncode = jsonEncode(_listHistorySO);
        dataHeader = jsonDecode(_listHistorySOEncode);
      });
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    getSharedPreference();
    Future.delayed(const Duration(milliseconds: 100), () {
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
        home: ChangeNotifierProvider<LinesProvider>(
          create: (ctx) => LinesProvider(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: colorAccent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: colorNetral,
                ),
                onPressed: onBackPressLines,
              ),
              title: Text(
                "List Lines",
                style: TextStyle(
                  fontSize: 20,
                  color: colorNetral,
                ),
              ),
            ),
            body: _listHistorySO == null
                ? const Center(child: CircularProgressIndicator())
                : _listHistorySO!.isEmpty
                    ? const Center(child: Text('No data available'))
                    : RefreshIndicator(
                        onRefresh: listHistorySO,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    TextResultCard(
                                      title: "No. PP",
                                      value:
                                          RegExp(r"\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}")
                                                      .hasMatch(dataHeader[0]
                                                          ["nomorPP"]) ==
                                                  true
                                              ? dataHeader[0]["nomorPP"]
                                                  .replaceRange(34, null, "")
                                              : dataHeader[0]["nomorPP"],
                                    ),
                                    TextResultCard(
                                      title: "PP. Type",
                                      value: "${dataHeader[0]["type"]}",
                                    ),
                                    TextResultCard(
                                      title: "Customer",
                                      value: "${dataHeader[0]["customer"]}",
                                    ),
                                    TextResultCard(
                                      title: "Note",
                                      value: "${dataHeader[0]["note"]}",
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Consumer<LinesProvider>(
                                          builder: (context, linesProv, _) =>
                                              TextFormField(
                                                readOnly: true,
                                                initialValue: dataHeader[0]
                                                        ["fromDate"]
                                                    .split(" ")[0]
                                                    .toString(),
                                                keyboardType:
                                                    TextInputType.datetime,
                                                decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(),
                                                  filled: true,
                                                  labelText: 'From Date',
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontSize: 15),
                                                  errorStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                      fontSize: 15),
                                                ),
                                              )),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Consumer<LinesProvider>(
                                          builder: (context, linesProv, _) =>
                                              TextFormField(
                                                readOnly: true,
                                                initialValue: dataHeader[0]
                                                        ["toDate"]
                                                    .split(" ")[0],
                                                keyboardType:
                                                    TextInputType.datetime,
                                                decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(),
                                                  filled: true,
                                                  labelText: 'To Date',
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontSize: 15),
                                                  errorStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                      fontSize: 15),
                                                ),
                                              )),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: _listHistorySO!.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return CardLinesAdapter(widget.numberPP,
                                      _listHistorySO![index], index);
                                },
                              ),
                            ],
                          ),
                        )),
          ),
        ),
      ),
    );
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
    List<Promotion> data = _listHistorySO!.cast<Promotion>();
    List qtyFrom = data.map((element) => element.qty).toList();
    List qtyTo = data.map((element) => element.qtyTo).toList();

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextResultCard(
            title: "Product",
            value: promosi.product!,
          ),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: TextResultCard(
                  title: "Qty From",
                  value: qtyFrom[index].toString(),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextResultCard(
                  title: "Qty To",
                  value: qtyTo[index].toString(),
                ),
              ),
            ],
          ),
          TextResultCard(
            title: 'Unit',
            value: promosi.unitId!,
          ),
          TextResultCard(
            title: "Price",
            value: promosi.price!,
          ),
          promosi.ppType == "Bonus"
              ? const SizedBox()
              : Row(
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
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.disc1!.split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
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
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.disc2!.split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
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
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.disc3!.split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
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
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.disc4!.split(".").first,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
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
                        "Disc Value1 ",
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.value1!,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
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
                      child: Consumer<LinesProvider>(
                        builder: (context, linesProv, _) => TextFormField(
                          readOnly: _statusDisable,
                          keyboardType: TextInputType.text,
                          initialValue: promosi.value2!,
                          inputFormatters: [CustomMoneyInputFormatter()],
                          onFieldSubmitted: (value) {
                            setBundleLines(
                                promosi.id, double.parse(value), null, null);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          promosi.ppType == "Diskon"
              ? const SizedBox()
              : TextResultCard(
                  title: 'Bonus Item',
                  value: promosi.suppItem!,
                ),
          promosi.ppType == "Diskon"
              ? const SizedBox()
              : TextResultCard(
                  title: 'Bonus Qty',
                  value: promosi.suppQty!,
                ),
          promosi.ppType == "Diskon"
              ? const SizedBox()
              : TextResultCard(
                  title: 'Bonus Unit',
                  value: promosi.suppUnit!,
                ),
          TextResultCard(
            title: "Total",
            value: "Rp${CustomMoneyInputFormatter().formatEditUpdate(
                  TextEditingValue(text: promosi.price!),
                  TextEditingValue(text: promosi.price!),
                ).text}",
          ),
        ],
      ),
    );
  }

  void setBundleLines(
      int id, double disc, DateTime? fromDate, DateTime? toDate) async {
    Lines model = Lines();
    List<Lines> listDisc = [];

    SharedPreferences preferences = await SharedPreferences.getInstance();
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
  }

  void getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();
    Future.delayed(const Duration(milliseconds: 10));
    setState(() {
      _user = listUser[0];
      code = pref.getInt("code")!;
    });
  }

  Future<bool> onBackPressLines() async {
    Get.off(const DashboardPage(
      initialIndex: 0,
    ));
    return true;
  }
}
