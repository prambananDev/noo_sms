import 'dart:async';
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
import 'package:noo_sms/view/sms/history_lines_all.dart';
import 'package:noo_sms/view/sms/history_lines_all_edit.dart';
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

  Future<List<dynamic>?> _fetchStatusData(String noPP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url =
        "$apiCons/api/PromosiHeader?username=${prefs.getString("username")}&NoPP=$noPP";

    final response =
        await get(Uri.parse(url), headers: {'authorization': _user.token!})
            .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Request timed out');
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Widget _buildStatusItem(dynamic data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Approval ${index + 1} :",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${data['User']}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Status :",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                data['Status'].toString().replaceAll("Approve", "Approved"),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container cardAdapter(Promotion promotion) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                      "Lines",
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
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Loading status..."),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    try {
                      final listData =
                          await _fetchStatusData(promotion.namePP!);

                      Navigator.pop(context);

                      if (listData == null) {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Data not loaded. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Show status dialog with data
                      Get.dialog(
                        Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxHeight: Get.height * 0.6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Approval Status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: listData.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (context, index) =>
                                        _buildStatusItem(
                                            listData[index], index),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      // Remove loading dialog and show timeout dialog
                      Navigator.pop(context);
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Timeout'),
                          content: const Text(
                              'Data not loaded after 10 seconds. Please check your connection and try again.'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(7),
                  ),
                  child: Text(
                    "Status",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorNetral,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
