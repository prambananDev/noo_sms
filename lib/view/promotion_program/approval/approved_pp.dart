import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/promotion_program/approval/approved_pp_lines.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedPP extends StatefulWidget {
  const ApprovedPP({Key? key}) : super(key: key);

  @override
  ApprovedPPState createState() => ApprovedPPState();
}

class ApprovedPPState extends State<ApprovedPP> {
  final _debouncer = Debounce(milliseconds: 500);
  TextEditingController filterController = TextEditingController();
  List<Promotion>? _listHistory, listHistoryReal;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  User _user = User();
  late int code;
  bool isLoading = true; // Loading state to handle initialization

  Future<void> listHistory() async {
    await Future.delayed(const Duration(seconds: 5));
    Promotion.getListPromotionApproved().then((value) {
      setState(() {
        listHistoryReal = value;
        _listHistory = listHistoryReal;
      });
    });
  }

  Widget cardAdapter(Promotion promosi) {
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
            title: "No. PP",
            value: promosi.nomorPP!,
          ),
          TextResultCard(
            title: "Date",
            value: promosi.date,
          ),
          TextResultCard(
            title: "Type",
            value: promosi.customer!,
          ),
          TextResultCard(
            title: "Salesman",
            value: promosi.salesman,
          ),
          TextResultCard(
            title: "Sales Office",
            value: promosi.salesOffice!,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return HistoryLinesApproved(
                  numberPP: promosi.namePP,
                  idEmp: _user.id!,
                );
              }));
            },
            style: TextButton.styleFrom(
              backgroundColor: colorAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(
                  "View Lines",
                  style: TextStyle(
                      color: colorNetral,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      _user = userBox.getAt(0) ?? User();
      code = pref.getInt("code") ?? 0;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: colorNetral,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorNetral,
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: TextField(
              controller: filterController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Enter customer, number PP or dates',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: colorPrimary),
                  onPressed: () {
                    String value = filterController.text;
                    _debouncer.run(() {
                      setState(() {
                        _listHistory = listHistoryReal!
                            .where((element) =>
                                element.nomorPP!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                element.date
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                element.customer!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                            .toList();
                      });
                    });
                  },
                ),
              ),
              onEditingComplete: () {
                String value = filterController.text;
                _debouncer.run(() {
                  setState(() {
                    _listHistory = listHistoryReal!
                        .where((element) =>
                            element.nomorPP!
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.date
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.customer!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: listHistory,
              child: FutureBuilder(
                future: Promotion.getListPromotionApproved(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (!snapshot.hasError) {
                      _listHistory = listHistoryReal = snapshot.data;
                      if (_listHistory!.isEmpty) {
                        return const Center(
                          child: Column(
                            children: <Widget>[
                              Text('No Data'),
                              Text('Swipe down for refresh item'),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                          itemCount: _listHistory?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              cardAdapter(_listHistory![index]));
                    }
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return const Center(
                      child: Column(
                        children: <Widget>[
                          Text('No Data'),
                          Text('Swipe down for refresh item'),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Loading',
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
