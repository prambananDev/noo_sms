import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_sms_controller.dart';
import 'package:noo_sms/view/dashboard/dashboard_noo.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({Key? key}) : super(key: key);

  @override
  DashboardMainState createState() => DashboardMainState();
}

class DashboardMainState extends State<DashboardMain> {
  final DashboardController _controller = DashboardController();

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(
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
                onPressed: () => _navigateTo(
                    context,
                    const DashboardPage(
                      initialIndex: 0,
                    )),
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
                onPressed: () =>
                    _navigateTo(context, const DashboardOrderSample()),
                child:
                    Text("Sample Order", style: TextStyle(color: colorNetral)),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                onPressed: () => _navigateTo(context, const DashboardNoo()),
                child:
                    Text("NOO Dashboard", style: TextStyle(color: colorNetral)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
