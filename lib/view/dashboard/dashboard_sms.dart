// views/main_dashboard.dart
import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_sms_controller.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:noo_sms/view/dashboard/dashboard_ordertaking.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({Key? key, required this.initialIndex}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();
  final DashboardController _controller = DashboardController();
  int _currentIndex = 0;

  // Define pages for each menu item
  final List<Widget> _pages = [
    const DashboardPP(initialIndex: 0),
    const DashboardApprovalPP(initialIndex: 0),
    const DashboardOrderTaking(initialIndex: 0),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAccent,
        title: Text(
          'Dashboard SMS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colorNetral,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _controller.logout();
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.discount_outlined),
            label: 'Program Promotioon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            label: 'Approval PP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Order Taking',
          ),
        ],
      ),
    );
  }
}


// d51e7b74-eebc-48e9-8af6-a2d1cbd58e33