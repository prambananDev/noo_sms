import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:noo_sms/view/promotion_program/history_lines_all.dart';
import 'package:noo_sms/view/promotion_program/history_lines_all_edit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryAll extends StatefulWidget {
  const HistoryAll({Key? key}) : super(key: key);

  @override
  HistoryAllState createState() => HistoryAllState();
}

class HistoryAllState extends State<HistoryAll> {
  final _debouncer = Debounce(milliseconds: 5);
  TextEditingController filterController = TextEditingController();
  List<Promotion>? _listHistory, listHistoryReal;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  User _user = User();
  late int code;
  bool _isLoading = true;

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }

  Future<void> listHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    Promotion.getAllListPromotion().then((value) {
      if (mounted) {
        setState(() {
          listHistoryReal = value;
          _listHistory = listHistoryReal;
        });
      }
    });
  }

  Container cardAdapter(Promotion promotion) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorGray,
          width: 0.7,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: <Widget>[
          TextResultCard(
            title: "No. PP",
            value: promotion.nomorPP ?? "No data",
          ),
          TextResultCard(
            title: "Date",
            value: promotion.date ?? "No data",
          ),
          TextResultCard(
            title: "Type",
            value: promotion.customer ?? "No data",
          ),
          TextResultCard(
            title: "AXStatus",
            value: promotion.axStatus == ""
                ? "-"
                : promotion.axStatus ?? "No data",
          ),
          const SizedBox(height: 4), // Simple space without ScreenUtil
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return HistoryLinesAll(
                        numberPP: promotion.namePP,
                        idEmp: _user.id!,
                      );
                    }));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(7),
                  ),
                  child: Center(
                    child: Text(
                      "View Lines",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorNetral,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Simple space for spacing buttons
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var url =
                        "$apiCons/api/PromosiHeader?username=${prefs.getString("username")}&NoPP=${promotion.namePP}";

                    final response = await get(Uri.parse(url),
                        headers: <String, String>{
                          'authorization': _user.token!
                        });

                    final listData = jsonDecode(response.body);
                    if (listData != null && response.statusCode == 200) {
                      Get.defaultDialog(
                        title: "Approval Status",
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: Get.width,
                            height: Get.height - 630,
                            child: ListView.builder(
                              itemCount: listData.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Approval ${index + 1} :"),
                                          Text("${listData[index]['User']}"),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Status :"),
                                          Text(listData[index]['Status']
                                              .toString()
                                              .replaceAll(
                                                  "Approve", "Approved")),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      // side: BorderSide(
                      //   color: Theme.of(context).primaryColor,
                      //   style: BorderStyle.solid,
                      //   width: 2,
                      // ),
                    ),
                    padding: const EdgeInsets.all(7),
                  ),
                  child: Center(
                    child: Text(
                      "View Status",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorNetral,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Simple space for spacing buttons
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (!Get.isRegistered<InputPageController>()) {
                      Get.put(InputPageController());
                    }

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return HistoryLinesAllEdit(
                        numberPP: promotion.namePP,
                        idEmp: _user.id,
                      );
                    }));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      // side: const BorderSide(
                      //   style: BorderStyle.solid,
                      //   width: 0.5,
                      // ),
                    ),
                    padding: const EdgeInsets.all(7),
                  ),
                  child: Center(
                    child: Text(
                      "Edit Lines",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorNetral,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getSharedPreference() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    List<User> listUser = userBox.values.map((e) => e as User).toList();
    SharedPreferences pref = await SharedPreferences.getInstance();
    Future.delayed(const Duration(milliseconds: 20));
    setState(() {
      _user = listUser[0];
      code = pref.getInt("code")!;
      _isLoading = false;
    });
  }

  Future<bool> onBackPress() {
    deleteBoxUser();
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return const LoginView();
      }),
    ).then((_) => true);
  }

  void deleteBoxUser() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box userBox = await Hive.openBox('users');
    SharedPreferences pref = await SharedPreferences.getInstance();

    Future.delayed(const Duration(milliseconds: 10));
    await userBox.deleteFromDisk();
    pref.setInt("flag", 0);
    pref.setString("result", "");
  }

  void logOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure log out ?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel')),
          TextButton(onPressed: onBackPress, child: const Text('Ok')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getSharedPreference().then((_) {
      listHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorNetral,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
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
                contentPadding: const EdgeInsets.all(10), // Standard padding
                hintText: 'Enter customer, number PP or date',
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
                future: Promotion.getAllListPromotion(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (!snapshot.hasError && mounted) {
                      _listHistory ??= listHistoryReal = snapshot.data;
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
                        itemCount: _listHistory!.length,
                        itemBuilder: (BuildContext context, int index) =>
                            cardAdapter(_listHistory![index]),
                      );
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(semanticsLabel: 'Loading'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
