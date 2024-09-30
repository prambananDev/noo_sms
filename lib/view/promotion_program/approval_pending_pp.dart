import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/promotion_program/history_lines_all.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingPP extends StatefulWidget {
  const PendingPP({Key? key}) : super(key: key);

  @override
  _HistoryPendingState createState() => _HistoryPendingState();
}

class _HistoryPendingState extends State<PendingPP> {
  final _debouncer = Debounce(milliseconds: 500);
  TextEditingController filterController = TextEditingController();
  var _listHistory, listHistoryReal;
  late GlobalKey<RefreshIndicatorState> refreshKey;
  User? _user; // Make _user nullable
  int? code; // Make code nullable initially
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    getSharedPreference(); // Call to load the user and code
  }

  Future<void> getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Delay to ensure preferences are loaded
    await Future.delayed(const Duration(milliseconds: 20));

    setState(() {
      _user = listUser.isNotEmpty ? listUser[0] : null; // Ensure user is set
      code = pref.getInt("code") ?? 0; // Ensure code is set
      isLoading = false; // Loading complete
    });
  }

  Future<void> listHistory() async {
    await Future.delayed(const Duration(seconds: 5));
    if (_user != null && code != null) {
      Promotion.getListPromotion(
              0, code!, _user!.token ?? "token kosong", _user!.username)
          .then((value) {
        setState(() {
          listHistoryReal = value;
          _listHistory = listHistoryReal;
        });
      });
    }
    return;
  }

  Container CardAdapter(Promotion promosi) {
    return Container(
        margin: const EdgeInsets.all(10), // Adjusted margin
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
              title: "No. PP",
              value: promosi.nomorPP ?? '',
            ),
            TextResultCard(
              title: "Date",
              value: promosi.date,
            ),
            TextResultCard(
              title: "Type",
              value: promosi.customer ?? '',
            ),
            TextResultCard(
              title: "Salesman",
              value: promosi.salesman,
            ),
            TextResultCard(
              title: "Sales Office",
              value: promosi.salesOffice ?? '',
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return HistoryLinesAll(
                    numberPP: promosi.namePP,
                    idEmp: _user!.id, // Use _user safely
                  );
                }));
              },
              style: TextButton.styleFrom(
                backgroundColor: colorAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  // side: BorderSide(
                  //     color: Theme.of(context).primaryColor,
                  //     style: BorderStyle.solid,
                  //     width: 2),
                ),
                padding: const EdgeInsets.all(7),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(7),
                padding: const EdgeInsets.all(5),
                child: Center(
                  child: Text(
                    "View Lines",
                    style: TextStyle(
                        color: colorNetral,
                        fontSize: 13,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator until the data is initialized
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: TextField(
              controller: filterController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Enter customer, number PP or date',
                  suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: colorPrimary),
                      onPressed: () {
                        String value = filterController.text;
                        _debouncer.run(() {
                          setState(() {
                            _listHistory = listHistoryReal
                                .where((element) =>
                                    element.nomorPP
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.date
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.customer
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                .toList();
                            print(_listHistory);
                          });
                        });
                      })),
              onEditingComplete: () {
                String value = filterController.text;
                _debouncer.run(() {
                  setState(() {
                    _listHistory = listHistoryReal
                        .where((element) =>
                            element.nomorPP
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.date
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.customer
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                    print(_listHistory);
                  });
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: listHistory,
              child: FutureBuilder(
                future: Promotion.getListPromotion(0, code!, _user!.token ?? "",
                    _user!.username ?? ""), // Ensure safe access
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (!snapshot.hasError) {
                      _listHistory ??= listHistoryReal = snapshot.data;
                      if (_listHistory.isEmpty) {
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
                          itemCount: _listHistory.length,
                          itemBuilder: (BuildContext context, int index) =>
                              CardAdapter(
                                _listHistory[index],
                              ));
                    } else {
                      print(snapshot.error.toString());
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
