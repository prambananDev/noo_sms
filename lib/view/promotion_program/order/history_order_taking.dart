import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/controllers/promotion_program/order/transaction_history_order_controller.dart';

class HistoryOrder extends StatelessWidget {
  const HistoryOrder({Key? key}) : super(key: key);

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transactionHistoryPresenter = Get.put(HistoryOrderController());
    return Obx(() => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        transactionHistoryPresenter.transactionHistory.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          int indexes = index;
                          Get.bottomSheet(ListView.builder(
                            shrinkWrap: true,
                            itemCount: transactionHistoryPresenter
                                .transactionHistory[index]
                                .transactionLines
                                ?.length,
                            itemBuilder: (context, index) {
                              final line = transactionHistoryPresenter
                                  .transactionHistory[indexes]
                                  .transactionLines?[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildRow(
                                          "Product Id", line?.productId ?? ''),
                                      buildRow("Product Name",
                                          line?.productName ?? ''),
                                      buildRow("Unit", line?.unit ?? ''),
                                      buildRow(
                                          "Qty", line?.qty.toString() ?? '0'),
                                      buildRow("Disc", "${line?.disc ?? 0} %"),
                                      buildRow(
                                        "Price",
                                        formatCurrency(double.parse(
                                            line?.price.toString() ?? '0')),
                                      ),
                                      buildRow(
                                        "Total Price",
                                        formatCurrency(
                                          double.parse(
                                            line?.totalPrice
                                                    .toString()
                                                    .replaceAll(
                                                        RegExp(r"[.,]"), "") ??
                                                '0',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ));
                        },
                        child: buildTransactionCard(
                            transactionHistoryPresenter, index),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget buildTransactionCard(HistoryOrderController presenter, int index) {
    final transaction = presenter.transactionHistory[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Customer Name", transaction.customerName ?? ''),
            const SizedBox(height: 20),
            buildRow(
              "Date",
              DateFormat("dd-MM-yyyy hh:mm").format(
                DateTime.parse(transaction.date!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
