import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import 'package:mobile_sms/view/HistoryLinesApproved.dart';
import 'package:noo_sms/assets/widgets/debounce.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';
import 'package:noo_sms/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedPP extends StatefulWidget {
  const ApprovedPP({Key? key}) : super(key: key);

  @override
  _HistoryApprovedState createState() => _HistoryApprovedState();
}

class _HistoryApprovedState extends State<ApprovedPP> {
  final _debouncer = Debounce(milliseconds: 500);
  final TextEditingController filterController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  User _user = User();
  late int code;
  List<Promotion>? _listHistory = [];
  List<Promotion>? listHistoryReal = [];

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    Box<User> userBox = await Hive.openBox('users');
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      _user = userBox.getAt(0) ?? User();
      code = preferences.getInt('code') ?? 0;
    });

    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    await Future.delayed(const Duration(seconds: 5));
    Promotion.getListPromotionApproved(
      0,
      code,
      _user.token ?? "token kosong",
      _user.username,
    ).then((value) {
      setState(() {
        listHistoryReal = value;
        _listHistory = listHistoryReal;
      });
    });
  }

  void _filterList(String query) {
    _debouncer.run(() {
      setState(() {
        _listHistory = listHistoryReal!.where((element) {
          final lowerQuery = query.toLowerCase();
          return element.nomorPP!.toLowerCase().contains(lowerQuery) ||
              element.date!.toLowerCase().contains(lowerQuery) ||
              element.customer!.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    });
  }

  Widget _buildCard(Promotion promotion) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextResultCard(title: "No. PP", value: promotion.nomorPP!),
          TextResultCard(title: "Date", value: promotion.date!),
          TextResultCard(title: "Type", value: promotion.customer!),
          TextResultCard(title: "Salesman", value: promotion.salesman!),
          TextResultCard(title: "Sales Office", value: promotion.salesOffice!),
          _buildViewLinesButton(promotion),
        ],
      ),
    );
  }

  Widget _buildViewLinesButton(Promotion promotion) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return const Text("data");
            // return HistoryLinesApproved(
            //   numberPP: promotion.namePP,
            //   idEmp: _user.id,
            // );
          }),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(7),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            "VIEW LINES",
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: TextField(
              controller: filterController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Enter customer, number PP or date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _filterList(filterController.text),
                ),
              ),
              onEditingComplete: () => _filterList(filterController.text),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHistory,
              child: _listHistory == null || _listHistory!.isEmpty
                  ? const Center(
                      child: Text('No Data'),
                    )
                  : ListView.builder(
                      itemCount: _listHistory!.length,
                      itemBuilder: (context, index) {
                        return _buildCard(_listHistory![index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
