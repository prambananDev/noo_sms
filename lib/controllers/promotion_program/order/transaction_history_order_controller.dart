import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/transaction_history.dart';

class HistoryOrderController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      getTransactionHistory();
    });
  }

  var transactionHistory = <TransactionHistory>[].obs;
  TransactionLines transactionLines = TransactionLines();

  List data = [];

  getTransactionHistory() async {
    var url = "$apiSMS/transaction";
    final response = await get(Uri.parse(url));
    transactionHistory.value = (jsonDecode(response.body) as List)
        .map((data) => TransactionHistory.fromJson(data))
        .toList();

    update();
  }
}
