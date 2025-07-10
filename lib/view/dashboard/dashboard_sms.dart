import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
      appBar: _buildAppBar(context),
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isIPad = ResponsiveUtil.isIPad(context);

    return AppBar(
      elevation: 0,
      backgroundColor: colorAccent,
      toolbarHeight: isIPad ? 64.rs(context) : null,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: isIPad ? 40.ri(context) : 35.ri(context),
        ),
        onPressed: _handleBackPress,
      ),
      title: Text(
        'Promotion Program',
        style: TextStyle(
          fontSize: isIPad ? 20.rt(context) : 18.rt(context),
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

  Widget _buildBottomNav(BuildContext context) {
    final isIPad = ResponsiveUtil.isIPad(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.rs(context),
            offset: Offset(0, -5.rs(context)),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: colorAccent,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isIPad ? 18.rt(context) : 14.rt(context),
          height: 1.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isIPad ? 16.rt(context) : 14.rt(context),
          height: 1.5,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.rp(context)),
              child: Icon(
                item.icon,
                size: isIPad ? 28.ri(context) : 24.ri(context),
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.rp(context)),
              child: Icon(
                item.icon,
                size: isIPad ? 28.ri(context) : 24.ri(context),
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
