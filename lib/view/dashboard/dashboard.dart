import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_sms_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({Key? key}) : super(key: key);

  @override
  DashboardMainState createState() => DashboardMainState();
}

class DashboardMainState extends State<DashboardMain> {
  final DashboardController _controller = DashboardController();
  String addressDetail = "";

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    addressDetail = (prefs.getString("getAddressDetail") ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _controller.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed: () => Get.toNamed('/sms'),
                      child: Text(
                        "Dashboard SMS",
                        style: TextStyle(color: colorNetral),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed: () => Get.toNamed('/sample'),
                      child: Text("Sample Order",
                          style: TextStyle(color: colorNetral)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccent,
                      ),
                      onPressed: () => Get.toNamed('/noo'),
                      child: Text("NOO Dashboard",
                          style: TextStyle(color: colorNetral)),
                    ),
                  ),
                  // Text(
                  //   addressDetail,
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     color: colorBlack,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
