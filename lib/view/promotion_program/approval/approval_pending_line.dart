import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/constant/money_formatter.dart';
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
  final Promotion? promotion;

  const HistoryLines(
      {super.key, required this.numberPP, required this.idEmp, this.promotion});

  @override
  _HistoryLinesState createState() => _HistoryLinesState();
}

class _HistoryLinesState extends State<HistoryLines> {
  late HistoryLinesPendingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
        HistoryLinesPendingController(numberPP: widget.numberPP),
        tag: widget.numberPP);
    // debugPrint("tezz ${_controller.promotion.value.customer}");
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
                      );
                    },
                  ),
                  _controller.startApp == false
                      ? Container() // Widget kosong ketika startApp adalah false
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: SizedBox(
                            width: screenWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      backgroundColor: colorAccent,
                                    ),
                                    child: Text(
                                      'Approve',
                                      style: TextStyle(
                                        color: colorNetral,
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
