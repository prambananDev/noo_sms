import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noo_sms/models/user.dart';
import 'package:noo_sms/view/dashboard/dashboard.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:noo_sms/controllers/provider/login_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MainAppState extends State<MainApp> {
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
      Get.offAll(() => const DashboardMain());
    }
  }

  Future<void> getOneSignal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    OneSignal.initialize("ffad8398-fdf5-4aef-a16b-a33696f48630");

    OneSignal.Notifications.requestPermission(true);

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
