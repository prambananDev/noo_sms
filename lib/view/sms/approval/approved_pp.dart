import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/view/sms/approval/approved_pp_lines.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedPP extends StatefulWidget {
  const ApprovedPP({Key? key}) : super(key: key);

  @override
  ApprovedPPState createState() => ApprovedPPState();
}

class ApprovedPPState extends State<ApprovedPP> {
  final _debouncer = Debounce(milliseconds: 500);
  final filterController = TextEditingController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  List<Promotion>? _listHistory;
  List<Promotion>? _listHistoryReal;
  bool _isLoading = true;
  int? code;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isDisposed) return;

    try {
      await _loadUserData();
      if (!_isDisposed) {
        await _loadHistory();
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    if (_isDisposed) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);

      final prefs = await SharedPreferences.getInstance();

      if (!_isDisposed) {
        setState(() {
          code = prefs.getInt("code");
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHistory() async {
    if (_isDisposed) return;

    try {
      final value = await Promotion.getListPromotionApproved();
      if (!_isDisposed) {
        setState(() {
          _listHistoryReal = value;
          _listHistory = value;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _listHistory = [];
          _listHistoryReal = [];
        });
      }
    }
  }

  void _filterData(String query) {
    if (_isDisposed || _listHistoryReal == null) return;

    _debouncer.run(() {
      if (!_isDisposed) {
        setState(() {
          _listHistory = _listHistoryReal!.where((element) {
            final nomorPP = element.nomorPP?.toLowerCase() ?? '';
            final date = element.date.toLowerCase();
            final customer = element.customer?.toLowerCase() ?? '';
            final searchQuery = query.toLowerCase();

            return nomorPP.contains(searchQuery) ||
                date.contains(searchQuery) ||
                customer.contains(searchQuery);
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: colorNetral,
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildPromotionList()),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: colorNetral,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: filterController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          hintText: 'Enter customer, number PP or dates',
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: colorPrimary),
            onPressed: () => _filterData(filterController.text),
          ),
        ),
        onSubmitted: _filterData,
      ),
    );
  }

  Widget _buildPromotionList() {
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: _loadHistory,
      child: _listHistory == null
          ? const Center(child: CircularProgressIndicator())
          : _listHistory!.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _listHistory!.length,
                  itemBuilder: (context, index) =>
                      _buildPromotionCard(_listHistory![index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Approved PP Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextResultCard(
            title: "No. PP",
            value: promotion.nomorPP ?? 'N/A',
          ),
          TextResultCard(
            title: "Date",
            value: promotion.date,
          ),
          TextResultCard(
            title: "Type",
            value: promotion.customer ?? 'N/A',
          ),
          TextResultCard(
            title: "Salesman",
            value: promotion.salesman ?? 'N/A',
          ),
          TextResultCard(
            title: "Sales Office",
            value: promotion.salesOffice ?? 'N/A',
          ),
          _buildViewLinesButton(promotion),
        ],
      ),
    );
  }

  Widget _buildViewLinesButton(Promotion promotion) {
    return TextButton(
      onPressed: () {
        if (!_isDisposed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryLinesApproved(
                numberPP: promotion.namePP,
              ),
            ),
          );
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: colorAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Center(
        child: Text(
          "View Lines",
          style: TextStyle(
            color: colorNetral,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
