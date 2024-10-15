import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/card_line_adapter.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/approval_pending_line_controller.dart';
import 'package:noo_sms/controllers/promotion_program/history_lines_all_controller.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/view/dashboard/dashboard_approvalpp.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';

class HistoryLines extends StatefulWidget {
  final String numberPP;
  final int idEmp;

  const HistoryLines({super.key, required this.numberPP, required this.idEmp});

  @override
  _HistoryLinesState createState() => _HistoryLinesState();
}

class _HistoryLinesState extends State<HistoryLines> {
  late HistoryLinesPendingController _controller;
  Promotion promotion = Promotion();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
        HistoryLinesPendingController(numberPP: widget.numberPP),
        tag: widget.numberPP);
    _controller.getSharedPreference();
    _controller.listHistoryPendingSO();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: onBackPressLines,
      child: Scaffold(
        floatingActionButton: _controller.startApp == false
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    label: const Text("Select All"),
                    onPressed: () {
                      setState(() {
                        _controller.toggleSelectAll();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _controller.startApp == false
                      ? Container() // Widget kosong ketika startApp adalah false
                      : Padding(
                          padding: const EdgeInsets.only(left: 60, right: 20),
                          child: SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.03),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      'Reject',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_controller.addToLines.isEmpty) {
                                        Get.snackbar(
                                            "Error", "Checklist for reject!!",
                                            backgroundColor: Colors.red,
                                            icon: const Icon(Icons.error));
                                      } else {
                                        _controller.approveNew("Reject");
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.03),
                                      backgroundColor:
                                          Theme.of(context).primaryColorDark,
                                    ),
                                    child: Text(
                                      'Approve',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_controller.addToLines.isEmpty) {
                                        Get.snackbar(
                                            "Error", "Checklist for approve!!",
                                            backgroundColor: Colors.red,
                                            icon: const Icon(Icons.error));
                                      } else {
                                        _controller.approveNew("Approve");
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
        appBar: AppBar(
          backgroundColor: colorAccent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: colorNetral,
            ),
            onPressed: onBackPressLines,
          ),
          title: Text(
            "List Lines",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              color: colorNetral,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _controller.listHistoryPendingSO,
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const CircularProgressIndicator();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextResultCard(
                          title: "No. PP",
                          value: _controller.dataHeader['nomorPP'] ??
                              'Unknown', // Default or fallback value
                        ),
                        TextResultCard(
                          title: "PP Type",
                          value: _controller.dataHeader['type'] ?? 'Unknown',
                        ),
                        TextResultCard(
                          title: "Customer",
                          value:
                              _controller.dataHeader['customer'] ?? 'Unknown',
                        ),
                        TextResultCard(
                          title: "Note",
                          value: _controller.dataHeader.isNotEmpty &&
                                  _controller.dataHeader.containsKey("note")
                              ? _controller.dataHeader["note"]
                              : "Loading...", // Default or fallback value
                        ),
                        Container(
                          width: screenWidth,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: CustomDatePickerField(
                            controller: _controller.fromDateHeaderController,
                            labelText: 'From Date',
                            initialValue: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: CustomDatePickerField(
                            controller: _controller.toDateHeaderController,
                            labelText: 'To Date',
                            initialValue: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text(_controller.qtyFromController.toString()),
                  ListView.builder(
                    itemCount: _controller.listHistorySO.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      debugPrint("zz${_controller.disc1Controller}");
                      // return Text(_controller.dataHeader["qty"].toString());
                      return CardLinesAdapter(
                        namePP: widget.numberPP,
                        idEmp: widget.idEmp,
                        promotion: _controller.listHistorySO[index],
                        index: index,
                        startApp: true,
                        valueSelectAll: false,
                        statusDisable: false,
                        showSalesHistory: true,
                        // qtyFromController: _controller.qtyFromController,
                        // qtyToController: _controller.qtyToController,
                        disc1Controller: _controller.disc1Controller,
                        disc2Controller: _controller.disc2Controller,
                        disc3Controller: _controller.disc3Controller,
                        disc4Controller: _controller.disc4Controller,
                        // value1Controller: _controller.value1Controller,
                        // value2Controller: _controller.value2Controller,
                        unitController: _controller.unitController,
                        // suppItemController: _controller.suppItemController,
                        // suppUnitController: _controller.suppUnitController,
                        // warehouseController: _controller.warehouseController,
                        // addToLines: _controller.addToLines,
                        dataUnit: _controller.unitController,
                        // dataSupplyUnit: _controller.dataSupplyItem,
                        // dataWarehouse: _controller.warehouseController,
                        // dataSupplyItem: _controller.dataSupplyItem,
                        getUnit: (String itemId) {
                          _controller.getUnit(itemId);
                        },
                        // getSupplyUnit: (String itemId) {
                        //   _controller.getSupplyUnit(itemId);
                        // },
                        // getWarehouse: (String itemId) {
                        //   _controller.getWarehouse();
                        // },
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<bool> onBackPressLines() async {
    Get.off(const DashboardPage(initialIndex: 0));
    return true;
  }
}
