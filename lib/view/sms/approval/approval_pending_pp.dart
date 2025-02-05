import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/controllers/promotion_program/approval_pending_line_controller.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/view/sms/approval/approval_pending_line.dart';

class PendingPP extends StatefulWidget {
  const PendingPP({Key? key}) : super(key: key);

  @override
  State<PendingPP> createState() => _PendingPPState();
}

class _PendingPPState extends State<PendingPP> {
  final _debouncer = Debounce(milliseconds: 500);
  final _filterController = TextEditingController();

  List<dynamic>? _listHistory;
  List<dynamic>? _listHistoryReal;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      final value = await Promotion.getListPromotion();
      if (!mounted) return;

      setState(() {
        _listHistoryReal = value;
        _listHistory = value;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    if (_isDisposed || !mounted) return;

    _debouncer.run(() {
      if (_listHistoryReal == null || !mounted) return;

      setState(() {
        _listHistory = _listHistoryReal!
            .where((element) =>
                (element.nomorPP?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) ||
                (element.date?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) ||
                (element.customer?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _filterController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildListView()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _filterController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          hintText: 'Enter customer, number PP or date',
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: colorPrimary),
            onPressed: () => _filterData(_filterController.text),
          ),
        ),
        onEditingComplete: () => _filterData(_filterController.text),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (!_isDisposed && mounted) {
          await _loadData();
        }
      },
      child: _listHistory == null || _listHistory!.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _listHistory?.length ?? 0,
              itemBuilder: (context, index) =>
                  _buildPromotionCard(_listHistory![index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No Data'),
          Text('Swipe down to refresh'),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(dynamic promotion) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          TextResultCard(
            title: "No. PP",
            value: promotion.nomorPP ?? '',
          ),
          TextResultCard(
            title: "Date",
            value: promotion.date ?? '',
          ),
          TextResultCard(
            title: "Type",
            value: promotion.customer ?? '',
          ),
          TextResultCard(
            title: "Salesman",
            value: promotion.salesman ?? '',
          ),
          TextResultCard(
            title: "Sales Office",
            value: promotion.salesOffice ?? '',
          ),
          _buildViewLinesButton(promotion),
        ],
      ),
    );
  }

  Widget _buildViewLinesButton(dynamic promotion) {
    return TextButton(
      onPressed: () {
        if (_isDisposed || !mounted) return;
        Get.delete<HistoryLinesPendingController>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryLines(
              numberPP: promotion.namePP,
              idEmp: 0,
              promotion: promotion,
            ),
          ),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: colorAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(7),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(7),
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            "View Lines",
            style: TextStyle(
              color: colorNetral,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
