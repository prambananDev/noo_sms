// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noo_sms/assets/constant/splash_screen.dart';
import 'package:noo_sms/controllers/login/location_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/controllers/sfa/sfa_controller.dart';
import 'package:noo_sms/models/noo_user.dart';
import 'package:noo_sms/models/order_tracking_model.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard.dart';
import 'package:noo_sms/view/dashboard/dashboard_asset_submission.dart';
import 'package:noo_sms/view/dashboard/dashboard_noo.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:noo_sms/view/dashboard/dashboard_sfa.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:noo_sms/view/edit_customer/edit_cust_dashboard.dart';
import 'package:noo_sms/view/edit_customer/edit_detail_cust.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form_coba.dart';
import 'package:noo_sms/view/order_tracking/delivery_detail.dart';
import 'package:noo_sms/view/order_tracking/detail_order.dart';
import 'package:noo_sms/view/order_tracking/order_history_tracking.dart';
import 'package:noo_sms/view/order_tracking/order_tracking_dashboard.dart';
import 'package:noo_sms/view/order_tracking/profil_order.dart';
import 'package:noo_sms/view/order_tracking/view_tracking_detail.dart';
import 'package:noo_sms/view/product/product_search_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noo_sms/assets/constant/app_id.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeCoreServices();

  runApp(const MainApp());
}

Future<void> _initializeCoreServices() async {
  try {
    await _initializeStorage();

    await _registerHiveAdapters();

    _initializePermanentControllers();

    await _initializeOneSignal();
  } catch (e) {}
}

Future<void> _initializeStorage() async {
  await GetStorage.init();
  await Hive.initFlutter();
}

Future<void> _registerHiveAdapters() async {
  try {
    if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
      Hive.registerAdapter(UserAdapter());
    }

    if (!Hive.isAdapterRegistered(SCSUserAdapter().typeId)) {
      Hive.registerAdapter(SCSUserAdapter());
      debugPrint(
          "📦 SCSUserAdapter registered (typeId: ${SCSUserAdapter().typeId})");
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OrderTrackingUserAdapter());
    }
  } catch (e) {}
}

void _initializePermanentControllers() {
  Get.put(LocationController(), permanent: true);
  Get.put(CustomerFormController(), permanent: true);
  Get.put<SfaController>(SfaController(), permanent: true);
}

Future<void> _initializeOneSignal() async {
  try {
    OneSignal.initialize(appId);
  } catch (e) {}
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with WidgetsBindingObserver {
  String? _onesignalUserID;

  CustomerFormController get customerFormController =>
      Get.find<CustomerFormController>();
  SfaController get sfaController => Get.find<SfaController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await _setupHiveBoxes();

      await _setupOneSignalNotifications();

      await _checkAutoLogin();

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _setupHiveBoxes() async {
    try {
      final boxNames = ['users', 'scs_users', 'order_tracking_users'];

      for (String boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          await Hive.openBox(boxName);
          await Hive.box(boxName).clear();
        }
      }
    } catch (e) {}
  }

  Future<void> _setupOneSignalNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await OneSignal.Notifications.requestPermission(true);

      final pushSubscription = OneSignal.User.pushSubscription;
      if (pushSubscription.id != null) {
        _onesignalUserID = pushSubscription.id;
        await prefs.setString("idDevice", _onesignalUserID!);
      }

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });

      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event);
      });

      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (e) {}
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    final data = event.notification.additionalData;
    if (data != null) {}
  }

  Future<void> _checkAutoLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? userToken = prefs.getString('userToken');
      String? token = prefs.getString('token');
      String? username = prefs.getString('Username');
      prefs.getString('token');

      bool hasValidToken = userToken != null ||
          token != null ||
          (username != null && username.isNotEmpty);

      if (hasValidToken) {
        return;
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOO SMS',
      theme: _buildAppTheme(),
      home: const SplashScreen(),
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: widget!,
        );
      },
      getPages: _buildAppRoutes(),
      unknownRoute: GetPage(
        name: '/404',
        page: () => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Page not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/splash'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color.fromRGBO(215, 250, 255, 1),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  List<GetPage> _buildAppRoutes() {
    return [
      ..._buildCoreRoutes(),
      ..._buildSMSRoutes(),
      ..._buildSampleRoutes(),
      ..._buildNOORoutes(),
      ..._buildSFARoutes(),
      ..._buildOrderTrackingRoutes(),
      ..._buildOtherRoutes(),
    ];
  }

  List<GetPage> _buildCoreRoutes() {
    return [
      GetPage(
        name: '/splash',
        page: () => const SplashScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/login',
        page: () => const LoginView(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/dashboard',
        page: () => const DashboardMain(),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildSMSRoutes() {
    return [
      GetPage(
        name: '/sms',
        page: () => const DashboardPage(initialIndex: 0),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sms_create',
        page: () => const DashboardPP(initialIndex: 0),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sms_history',
        page: () => const DashboardPP(initialIndex: 1),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildSampleRoutes() {
    return [
      GetPage(
        name: '/sample',
        page: () => const DashboardOrderSample(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sample_create',
        page: () => const DashboardOrderSample(initialIndex: 0),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sample_history',
        page: () => const DashboardOrderSample(initialIndex: 1),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sample_pending',
        page: () => const DashboardOrderSample(initialIndex: 2),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sample_approved',
        page: () => const DashboardOrderSample(initialIndex: 3),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildNOORoutes() {
    return [
      GetPage(
        name: '/noo',
        page: () => const DashboardNoo(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/noo_new',
        page: () => CustomerForm(controller: customerFormController),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/noo_list',
        page: () => const DashboardNoo(initialIndex: 1),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/noo_pending',
        page: () => const DashboardNoo(initialIndex: 2),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/noo_approve',
        page: () => const DashboardNoo(initialIndex: 3),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildSFARoutes() {
    return [
      GetPage(
        name: '/sfa_dashboard',
        page: () => const DashboardSfa(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sfa_new',
        page: () => const DashboardSfa(initialIndex: 0),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/sfa_list',
        page: () => const DashboardSfa(initialIndex: 1),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildOrderTrackingRoutes() {
    return [
      GetPage(
        name: '/order_dashboard',
        page: () => const DashboardOrderTrack(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/order_detail',
        page: () => DetailOrderTrack(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/profile_order',
        page: () => const ProfileOrderPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/order_history_tracking',
        page: () => const OrderHistoryPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/delivery-detail',
        page: () => const DeliveryDetailPage(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/order-tracking-detail',
        page: () => const OrderTrackingDetailPage(),
        transition: Transition.fadeIn,
      ),
    ];
  }

  List<GetPage> _buildOtherRoutes() {
    return [
      GetPage(
        name: '/asset_dashboard',
        page: () => const DashboardAsset(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/catalog_dashboard',
        page: () => ProductSearchScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/edit_cust',
        page: () => EditCustScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: '/customer-detail-form',
        page: () => const CustomerDetailFormScreen(),
        transition: Transition.fadeIn,
      ),
    ];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
