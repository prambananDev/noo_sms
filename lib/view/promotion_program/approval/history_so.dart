import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/promotion_program/approval/approval_pending_line.dart';
import 'package:noo_sms/view/promotion_program/approval/sales_order_adp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorySO extends StatefulWidget {
  @override
  _HistorySOState createState() => _HistorySOState();
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

class _HistorySOState extends State<HistorySO> {
  var _listHistory;
  late GlobalKey<RefreshIndicatorState> refreshKey;
  late User _user;
  late int code;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    getSharedPreference();
  }

  Future<void> listHistory() async {
    await Future.delayed(const Duration(seconds: 5));
    Promotion.getListSalesOrder(
            widget.idProduct, widget.idCustomer, _user.token!, _user.username)
        .then((value) {
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
            body: RefreshIndicator(
              onRefresh: listHistory,
              child: FutureBuilder(
                future: Promotion.getListSalesOrder(widget.idProduct,
                    widget.idCustomer, _user.token!, _user.username),
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

  Future<bool> onBackPressSalesOrder() {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return HistoryLines(numberPP: widget.namePP, idEmp: widget.idEmp);
      }),
    ).then((_) => true);
  }
}
