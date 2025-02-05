import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/constant/date_time_formatter.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/card_line_adapter.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/approval_pending_line_controller.dart';
import 'package:noo_sms/models/promotion.dart';

class HistoryLines extends StatefulWidget {
  final String numberPP;
  final int idEmp;
  final Promotion? promotion;

  const HistoryLines({
    super.key,
    required this.numberPP,
    required this.idEmp,
    this.promotion,
  });

  @override
  State<HistoryLines> createState() => _HistoryLinesState();
}

class _HistoryLinesState extends State<HistoryLines> {
  late final HistoryLinesPendingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      HistoryLinesPendingController(numberPP: widget.numberPP),
      tag: widget.numberPP,
    );
    _controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: colorAccent,
      title: Text(
        'List Lines',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: colorNetral,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: colorNetral,
          size: 35,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // Widget? _buildFloatingButton() {
  //   if (!_controller.startApp) return null;

  //   return FloatingActionButton.extended(
  //     label: const Text("Select All"),
  //     onPressed: () => setState(() => _controller.toggleSelectAll()),
  //   );
  // }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _controller.loadData,
      child: Obx(() {
        if (_controller.isLoading.value && !_controller.isDataLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            _buildContent(),
            if (_controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          _buildLinesList(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildHeaderInfo(),
          _buildDatePickers(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      children: [
        TextResultCard(
          title: "No. PP",
          value: _controller.dataHeader['nomorPP'] ?? 'Unknown',
        ),
        TextResultCard(
          title: "PP Type",
          value: _controller.dataHeader['type'] ?? 'Unknown',
        ),
        TextResultCard(
          title: "Customer",
          value: _controller.dataHeader['customer'] ?? 'Unknown',
        ),
        TextResultCard(
          title: "Note",
          value: _controller.dataHeader['note'] ?? " ",
        ),
      ],
    );
  }

  Widget _buildDatePickers() {
    return Column(
      children: [
        Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: CustomDatePickerField(
            controller: _controller.fromDateHeaderController,
            labelText: 'From Date',
            initialValue: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ),
        Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: CustomDatePickerField(
            controller: _controller.toDateHeaderController,
            labelText: 'To Date',
            initialValue: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ),
      ],
    );
  }

  Widget _buildLinesList() {
    return ListView.builder(
      itemCount: _controller.listHistorySO.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => CardLinesAdapter(
        namePP: widget.numberPP,
        idEmp: widget.idEmp,
        promotion: _controller.listHistorySO[index],
        index: index,
        startApp: true,
        valueSelectAll: false,
        statusDisable: false,
        showSalesHistory: true,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _controller.isLoading.value ? null : () => _onReject(),
              child: Text(
                'Reject',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed:
                  _controller.isLoading.value ? null : () => _onApprove(),
              child: Text(
                'Approve',
                style: TextStyle(
                  color: colorNetral,
                  fontSize: Get.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReject() {
    if (_controller.selectedLines.isEmpty) {
      Get.snackbar(
        "Error",
        "Checklist for reject!",
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error),
      );
    } else {
      _controller.approveOrReject("Reject");
    }
  }

  void _onApprove() {
    if (_controller.selectedLines.isEmpty) {
      _controller.toggleSelectAll();
    }
    _controller.approveOrReject("Approve");
  }
}
