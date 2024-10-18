import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboadOrderTakingTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  int initialIndex;
  late TabController controller;

  DashboadOrderTakingTabController({this.initialIndex = 0});

  void initController(TickerProvider vsync) {
    controller =
        TabController(vsync: vsync, length: 2, initialIndex: initialIndex);
  }

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      controller =
          TabController(vsync: this, length: 2, initialIndex: initialIndex);
    });
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
