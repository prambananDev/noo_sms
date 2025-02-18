import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/provider/lines_provider.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:noo_sms/models/promotion.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLinesApproved extends StatefulWidget {
  @override
  HistoryLinesApprovedState createState() => HistoryLinesApprovedState();
  String numberPP;

  HistoryLinesApproved({
    super.key,
    required this.numberPP,
  });
}

class HistoryLinesApprovedState extends State<HistoryLinesApproved> {
  List? _listHistorySO;
  dynamic _listHistorySOEncode;
  final bool _statusDisable = true;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

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

  bool valueSelectAll = false;
  List<dynamic>? dataHeader;
  bool startApp = false;
  Future<void> listHistorySO() async {
    await Future.delayed(const Duration(seconds: 1));
    Promotion.getListLines(widget.numberPP).then((value) {
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

    Future.delayed(const Duration(milliseconds: 100), () {
      startApp = true;
      listHistorySO();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: ChangeNotifierProvider<LinesProvider>(
        create: (ctx) => LinesProvider(),
        child: Scaffold(
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
          body: _listHistorySO == null
              ? const Center(child: CircularProgressIndicator())
              : _listHistorySO!.isEmpty
                  ? const Center(child: Text('No data available'))
                  : RefreshIndicator(
                      onRefresh: listHistorySO,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                TextResultCard(
                                  title: "No. PP",
                                  value: dataHeader != null
                                      ? _safeString(dataHeader?[0]["nomorPP"])
                                      : '',
                                ),
                                TextResultCard(
                                  title: "PP. Type",
                                  value: dataHeader != null
                                      ? _safeString(dataHeader?[0]["type"])
                                      : '',
                                ),
                                TextResultCard(
                                  title: "Customer",
                                  value: dataHeader != null
                                      ? _safeString(dataHeader?[0]["customer"])
                                      : '',
                                ),
                                TextResultCard(
                                  title: "Note",
                                  value: dataHeader != null
                                      ? _safeString(dataHeader?[0]["note"])
                                      : '',
                                ),
                                Consumer<LinesProvider>(
                                  builder: (context, linesProv, _) =>
                                      TextFormField(
                                    readOnly: true,
                                    initialValue: dataHeader != null &&
                                            dataHeader!.isNotEmpty &&
                                            dataHeader?[0]["fromDate"] != null
                                        ? formatDisplayDate(
                                            dataHeader?[0]["fromDate"])
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
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Consumer<LinesProvider>(
                                    builder: (context, linesProv, _) =>
                                        TextFormField(
                                      readOnly: true,
                                      initialValue: dataHeader != null &&
                                              dataHeader!.isNotEmpty &&
                                              dataHeader?[0]["toDate"] != null
                                          ? formatDisplayDate(
                                              dataHeader?[0]["toDate"])
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListView.builder(
                              itemCount: _listHistorySO!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return cardLinesAdapter(widget.numberPP,
                                    _listHistorySO![index], index);
                              },
                            ),
                          ],
                        ),
                      )),
        ),
      ),
    );
  }

  Container cardLinesAdapter(String namePP, Promotion? promosi, int index) {
    if (promosi == null) {
      return Container();
    }

    List<Promotion> data = (_listHistorySO ?? []).cast<Promotion>();
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
            // Discount rows with null safety
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
                  child: Consumer<LinesProvider>(
                    builder: (context, linesProv, _) => TextFormField(
                      readOnly: _statusDisable,
                      keyboardType: TextInputType.text,
                      initialValue: (promosi.disc1 ?? "0").split(".").first,
                      inputFormatters: [CustomMoneyInputFormatter()],
                      onFieldSubmitted: (value) {
                        setBundleLines(promosi.id ?? 0,
                            double.tryParse(value) ?? 0, null, null);
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
                      initialValue: (promosi.disc2 ?? "0").split(".").first,
                      inputFormatters: [CustomMoneyInputFormatter()],
                      onFieldSubmitted: (value) {
                        setBundleLines(
                            promosi.id, double.parse(value), null, null);
                      },
                    ),
                  ),
                ),

                // Similar updates for other discount fields...
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
                            initialValue:
                                (promosi.disc3 ?? "0").split(".").first,
                            inputFormatters: [CustomMoneyInputFormatter()],
                            onFieldSubmitted: (value) {
                              setBundleLines(promosi.id ?? 0,
                                  double.tryParse(value) ?? 0, null, null);
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
                            initialValue:
                                (promosi.disc4 ?? "0").split(".").first,
                            inputFormatters: [CustomMoneyInputFormatter()],
                            onFieldSubmitted: (value) {
                              setBundleLines(promosi.id ?? 0,
                                  double.tryParse(value) ?? 0, null, null);
                            },
                          ),
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
                        child: Consumer<LinesProvider>(
                          builder: (context, linesProv, _) => TextFormField(
                            readOnly: _statusDisable,
                            keyboardType: TextInputType.text,
                            initialValue:
                                (promosi.value1 ?? "0").split(".").first,
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
                            initialValue:
                                (promosi.value2 ?? "0").split(".").first,
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
}
