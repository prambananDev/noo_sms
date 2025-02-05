// controllers/dashboard_pp_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPPTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  int initialIndex;
  late TabController controller;

  DashboardPPTabController({this.initialIndex = 0});

  void initController(TickerProvider vsync) {
    controller =
        TabController(vsync: vsync, length: 4, initialIndex: initialIndex);
  }

  @override
  void onInit() {
    super.onInit();
    controller =
        TabController(vsync: this, length: 4, initialIndex: initialIndex);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
