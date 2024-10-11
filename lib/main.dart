import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:noo_sms/controllers/provider/login_provider.dart'; // Import your LoginProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage and Hive
  await GetStorage.init();
  await Hive.initFlutter();

  // Register Hive Adapter for User if not already registered
  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Initialize OneSignal
  OneSignal.shared.setAppId("ffad8398-fdf5-4aef-a16b-a33696f48630");

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? onesignalUserID;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await registeredAdapter();
    await checkAutoLogin();
    await getOneSignal();
  }

  Future<void> checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      // Navigate to dashboard if token exists
      Get.offAll(() => const DashboardPage(
            initialIndex: 0,
          ));
    }
  }

  Future<void> getOneSignal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    OneSignal.shared.setAppId("ffad8398-fdf5-4aef-a16b-a33696f48630");

    OneSignal.shared.getDeviceState().then((value) async {
      onesignalUserID = value?.userId ?? "";
      prefs.setString("idDevice", onesignalUserID!);
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {});
  }

  Future<void> registeredAdapter() async {
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
        // Add other providers here if needed
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
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
      ),
    );
  }
}
