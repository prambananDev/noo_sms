import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DashboardApprovalPPTabController extends GetxController {
  late final TabController controller;
  final int initialIndex;

  DashboardApprovalPPTabController({required this.initialIndex});

  void initController(TickerProvider vsync) {
    controller =
        TabController(vsync: vsync, length: 2, initialIndex: initialIndex);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
