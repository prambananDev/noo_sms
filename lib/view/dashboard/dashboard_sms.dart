// views/main_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/view/dashboard/dashboard_ordertaking.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;

  const DashboardPage({
    Key? key,
    required this.initialIndex,
  }) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late final PageController _pageController;

  int _currentIndex = 0;

  static const List<({IconData icon, String label})> _navigationItems = [
    (icon: Icons.discount_outlined, label: 'Program Promotion'),
    (icon: Icons.shopping_bag_outlined, label: 'Order Taking'),
  ];

  final List<Widget> _pages = const [
    DashboardPP(initialIndex: 0),
    DashboardOrderTaking(initialIndex: 0),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);
  void _onItemTapped(int index) => _pageController.jumpToPage(index);

  Future<void> _handleBackPress() async {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      await Get.offAllNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: _buildAppBar(),
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: colorAccent,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 35,
        ),
        onPressed: _handleBackPress,
      ),
      title: Text(
        'Promotion Program',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: colorNetral,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: _pages,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: colorAccent,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.5,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                item.icon,
                size: 24,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                item.icon,
                size: 28,
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
