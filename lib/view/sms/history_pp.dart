import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:noo_sms/service/api_constant.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_controller.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    getSharedPreference();
  }

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }

  Future<void> listHistory() async {
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final value = await Promotion.getAllListPromotion();
      if (!mounted) return;

      setState(() {
        listHistoryReal = value;
        _listHistory = listHistoryReal;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> getSharedPreference() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);

      SharedPreferences pref = await SharedPreferences.getInstance();
      int? prefCode = pref.getInt("code");

      if (!mounted) return;

      try {
        Box userBox = await Hive.openBox('users');
        if (userBox.isNotEmpty) {
          final userData = userBox.getAt(0);
          if (userData is User) {
            setState(() {
              _user = userData;
              code = prefCode ?? 0;
              _isLoading = false;
            });
            await listHistory();
            return;
          }
        }
      } catch (hiveError) {
        await Hive.deleteBoxFromDisk('users');
        Box userBox = await Hive.openBox('users');

        String? token = pref.getString("token");
        int? userId = pref.getInt("userid");
        String? username = pref.getString("username");

        if (token != null && userId != null && username != null) {
          final fallbackUser = User(
            id: userId,
            token: token,
            username: username,
          );
          await userBox.add(fallbackUser);

          setState(() {
            _user = fallbackUser;
            code = prefCode ?? 0;
            _isLoading = false;
          });
          await listHistory();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to load user data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<List<dynamic>?> _fetchStatusData(String noPP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url =
        "$apiSMS/PromosiHeader?username=${prefs.getString("username")}&NoPP=$noPP";

    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': _user.token!,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache'
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception(
            'Failed to load status data. Status code: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw TimeoutException(
          'Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to fetch status data: $e');
    }
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
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Enter customer, number PP or date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: colorPrimary),
                  onPressed: () => _filterList(filterController.text),
                ),
              ),
              onEditingComplete: () => _filterList(filterController.text),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: listHistory,
              child: _buildListContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_listHistory == null || _listHistory!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('No Data'),
            SizedBox(height: 8),
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

  void _filterList(String value) {
    _debouncer.run(() {
      if (!mounted) return;
      setState(() {
        _listHistory = listHistoryReal
            ?.where((element) =>
                element.nomorPP!.toLowerCase().contains(value.toLowerCase()) ||
                element.date.toLowerCase().contains(value.toLowerCase()) ||
                element.customer!.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    });
  }
}
