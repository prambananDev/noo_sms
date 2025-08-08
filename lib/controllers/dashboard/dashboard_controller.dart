import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:noo_sms/controllers/noo/cached_data.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/controllers/noo/customer_form_repo.dart';
import 'package:noo_sms/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DashboardController extends GetxController {
  RxString addressDetail = "".obs;
  RxString fullName = "".obs;
  RxList<Map<String, dynamic>> menuItems = <Map<String, dynamic>>[].obs;
  final customerFormRepository = CustomerFormRepository();

  static bool hasLoggedOut = false;

  @override
  void onInit() {
    super.onInit();
    loadSharedPreferences();
    loadMenuItems();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    addressDetail.value = (prefs.getString("getAddressDetail") ?? "");
    fullName.value = (prefs.getString("scs_name") ?? "");
  }

  void loadMenuItems() {
    menuItems.value = [
      {
        "title": "Promotion Program",
        "svgPath": "assets/icons/sms_icon.svg",
        "route": "/sms"
      },
      {"title": "NOO", "svgPath": "assets/icons/noo_icon.svg", "route": "/noo"},
      {
        "title": "Sample\nOrder",
        "svgPath": "assets/icons/sample_order_icon.svg",
        "route": "/sample"
      },
      {
        "title": "Customer\nVisit",
        "svgPath": "assets/icons/customer_visit.svg",
        "route": "/sfa_dashboard"
      },
      {
        "title": "Asset\nSubmission",
        "svgPath": "assets/icons/asset_submission_icon.svg",
        "route": "/asset_dashboard"
      },
      {
        "title": "Product\nCatalog",
        "svgPath": "assets/icons/catalog.svg",
        "route": "/catalog_dashboard"
      },
      {
        "title": "Edit\nCustomer",
        "svgPath": "assets/icons/edit_table.svg",
        "route": "/edit_cust"
      },
      {
        "title": "Order\nTracking",
        "svgPath": "assets/icons/order_tracking _icon.svg",
        "route": "/order_dashboard"
      },
      {
        "title": "Mobile\nApproval",
        "svgPath": "assets/icons/approve.svg",
        "route": "/sales_approve"
      },
    ];
  }

  Future<bool> logout() async {
    try {
      final context = Get.context;
      if (context == null) {
        return false;
      }

      DashboardController.hasLoggedOut = true;

      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File('${cacheDir.path}/logout_timestamp.txt');
      await cacheFile
          .writeAsString(DateTime.now().millisecondsSinceEpoch.toString());

      Map<String, String> locationData = await _preserveLocationData();

      if (Get.isRegistered<CustomerFormController>()) {
        Get.find<CustomerFormController>().clearForm();
        Get.delete<CustomerFormController>();
      }

      await customerFormRepository.clearCache();

      customerFormRepository.clearMemoryCache();

      await _clearRememberedCredentials();

      await CustomerFormController.resetForNewLogin();

      await CacheService.clearAllCache();

      await _clearHiveBoxes();

      await _clearSharedPreferencesWithLocationPreserved(locationData);

      await _clearTempFiles(exclude: [cacheFile.path]);

      await _forceMemoryFlush();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }

      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null && context.mounted) {
        try {
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        } catch (_) {
          SystemNavigator.pop();
        }
      }

      return false;
    }
  }

  Future<void> _clearRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool shouldRememberMe = prefs.getBool('rememberMe') ?? false;
    String? savedUsername;
    String? savedPassword;

    if (shouldRememberMe) {
      savedUsername = prefs.getString('username');
      savedPassword = prefs.getString('password');
    }

    await prefs.remove('token');
    await prefs.remove('userToken');
    await prefs.remove('scs_token');

    if (!shouldRememberMe) {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    } else if (savedUsername != null && savedPassword != null) {
      await prefs.setString('username', savedUsername);
      await prefs.setString('password', savedPassword);
      await prefs.setBool('rememberMe', true);
    }
  }

  Future<Map<String, String>> _preserveLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final locationKeys = [
      "getLongitude",
      "getLatitude",
      "getAddressDetail",
      "getStreetName",
      "getKelurahan",
      "getKecamatan",
      "getCity",
      "getProvince",
      "getCountry",
      "getZipCode",
    ];

    Map<String, String> savedData = {};

    for (String key in locationKeys) {
      String? value = prefs.getString(key);
      if (value != null) {
        savedData[key] = value;
      }
    }

    return savedData;
  }

  Future<void> _forceMemoryFlush() async {
    List<int> tempList = List.generate(1000000, (index) => index);
    tempList.clear();
    tempList = [];

    await Future.delayed(const Duration(milliseconds: 200));

    if (Platform.isAndroid) {
      await SystemChannels.platform
          .invokeMethod('SystemNavigator.routeUpdated');
    }
  }

  Future<void> _clearHiveBoxes() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    final boxesToClear = ['user', 'users', 'scs_users', 'draft_items'];

    for (var boxName in boxesToClear) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.clear();
        await box.close();
      }
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  Future<void> _clearSharedPreferencesWithLocationPreserved(
      Map<String, String> locationData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? deviceId = prefs.getString("idDevice");

      await prefs.clear();

      for (var entry in locationData.entries) {
        await prefs.setString(entry.key, entry.value);
      }

      if (deviceId != null) {
        await prefs.setString("idDevice", deviceId);
      }

      await prefs.setBool("has_logged_out", true);
    } catch (e) {}
  }

  Future<void> _clearTempFiles({List<String> exclude = const []}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (FileSystemEntity entity in tempDir.list()) {
          try {
            if (exclude.contains(entity.path)) {
              continue;
            }

            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {}
        }
      }
    } catch (e) {}
  }

  Future<void> deleteBoxUser() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    try {
      if (Hive.isBoxOpen('users')) {
        Box userBox = Hive.box('users');
        await userBox.clear();
        await userBox.close();
      }
      await Hive.deleteBoxFromDisk('users');
    } catch (e) {}

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("flag", 0);
    pref.setString("result", "");
  }
}
