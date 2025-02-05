import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noo_sms/controllers/login/location_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard.dart';
import 'package:noo_sms/view/dashboard/dashboard_noo.dart';
import 'package:noo_sms/view/dashboard/dashboard_pp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:noo_sms/view/noo/dashboard_new_customer/customer_form.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(LocationController(), permanent: true);

  await GetStorage.init();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
    Hive.registerAdapter(UserAdapter());
  }

  OneSignal.initialize("ffad8398-fdf5-4aef-a16b-a33696f48630");

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State {
  String? onesignalUserID;
  String? role;
  final customerFormController =
      Get.put(CustomerFormController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future _initializeApp() async {
    await registeredAdapter();
    await checkAutoLogin();
    await getOneSignal();
  }

  Future checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      Get.offAllNamed('/dashboard');
    }
  }

  Future getOneSignal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    OneSignal.initialize("ffad8398-fdf5-4aef-a16b-a33696f48630");

    await OneSignal.Notifications.requestPermission(true);

    final pushSubscription = OneSignal.User.pushSubscription;
    if (pushSubscription.id != null) {
      onesignalUserID = pushSubscription.id;

      await prefs.setString("idDevice", onesignalUserID!);
    }

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {});

    OneSignal.User.pushSubscription.addObserver((state) {});
  }

  Future registeredAdapter() async {
    if (!Hive.isBoxOpen('users')) {
      if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
        Hive.registerAdapter(UserAdapter());
      }
      await Hive.openBox('users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color.fromRGBO(215, 250, 255, 1),
              ),
            ),
          ),
        ),
        home: const LoginView(),
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        getPages: [
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
          GetPage(
            name: '/sms',
            page: () => const DashboardPage(
              initialIndex: 0,
            ),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/sms_create',
            page: () => const DashboardPP(
              initialIndex: 0,
            ),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/sms_history',
            page: () => const DashboardPP(
              initialIndex: 1,
            ),
            transition: Transition.fadeIn,
          ),
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
          GetPage(
            name: '/noo',
            page: () => const DashboardNoo(),
            transition: Transition.fadeIn,
            binding: BindingsBuilder(
              () {
                Get.put(CustomerFormController(), permanent: false);
              },
            ),
          ),
          GetPage(
            name: '/noo_new',
            page: () => CustomerForm(
              controller: customerFormController,
            ),
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
          // Add other routes here as needed
        ],
      ),
    );
  }
}
