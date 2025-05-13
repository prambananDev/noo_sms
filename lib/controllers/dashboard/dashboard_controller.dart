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
    ];
  }

  Future<bool> logout() async {
    try {
      final context = Get.context;
      if (context == null) {
        print('Context is null, cannot proceed with logout');
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
      print('Error during logout: $e');

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
      try {
        await SystemChannels.platform
            .invokeMethod('SystemNavigator.routeUpdated');
      } catch (e) {}
    }
  }

  Future<void> _clearHiveBoxes() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);

      final boxesToClear = ['user', 'users', 'scs_users', 'draft_items'];

      for (var boxName in boxesToClear) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
            await box.close();
          }
          await Hive.deleteBoxFromDisk(boxName);
        } catch (e) {
          print('Error clearing Hive box $boxName: $e');
        }
      }
    } catch (e) {
      print('Error clearing Hive data: $e');
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
    } catch (e) {
      print('Error clearing SharedPreferences: $e');
    }
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
          } catch (e) {
            print('Could not delete ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error clearing temp files: $e');
    }
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
    } catch (e) {
      print('Error deleting users box: $e');
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("flag", 0);
    pref.setString("result", "");
  }
}
