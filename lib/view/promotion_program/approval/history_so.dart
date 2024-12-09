import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/view/promotion_program/approval/approval_pending_line.dart';
import 'package:noo_sms/view/promotion_program/approval/sales_order_adp.dart';

class HistorySO extends StatefulWidget {
  @override
  HistorySOState createState() => HistorySOState();
  int idEmp;
  String namePP;
  String idProduct;
  String idCustomer;
  HistorySO(
      {super.key,
      required this.idEmp,
      required this.namePP,
      required this.idProduct,
      required this.idCustomer});
}

class HistorySOState extends State<HistorySO> {
  var _listHistory;
  late GlobalKey<RefreshIndicatorState> refreshKey;
  late int code;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<void> listHistory() async {
    await Future.delayed(const Duration(seconds: 5));
    Promotion.getListSalesOrder(
      widget.idProduct,
      widget.idCustomer,
    ).then((value) {
      setState(() {
        _listHistory = value;
      });
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressSalesOrder,
      child: MaterialApp(
        theme: Theme.of(context),
        home: Scaffold(
          backgroundColor: colorNetral,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorDark,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: onBackPressSalesOrder,
            ),
            title: Text(
              "List Sales Order",
              style: TextStyle(
                  fontSize: 20, color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          body: Scaffold(
            backgroundColor: colorNetral,
            body: RefreshIndicator(
              onRefresh: listHistory,
              child: FutureBuilder(
                future: Promotion.getListSalesOrder(
                  widget.idProduct,
                  widget.idCustomer,
                ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  _listHistory == null
                      ? _listHistory = snapshot.data
                      : _listHistory = _listHistory;
                  if (_listHistory == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: "Loading...",
                      ),
                    );
                  } else {
                    if (_listHistory[0].codeError != 404 ||
                        _listHistory[0].codeError != 303) {
                      return ListView.builder(
                        itemCount: _listHistory?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SalesOrderAdapter(
                            models: _listHistory[index],
                          );
                        },
                      );
                    } else {
                      return Text(_listHistory[0].message);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onBackPressSalesOrder() {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return HistoryLines(numberPP: widget.namePP, idEmp: widget.idEmp);
      }),
    ).then((_) => true);
  }
}
