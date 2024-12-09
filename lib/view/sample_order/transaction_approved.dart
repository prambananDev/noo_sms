import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/sample_order/transaction_approved_controller.dart';

class TransactionApprovedPage extends StatelessWidget {
  const TransactionApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionApprovedController presenter =
        Get.put(TransactionApprovedController());

    return Scaffold(
      backgroundColor: colorNetral,
      body: Obx(() {
        if (presenter.approvedList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: presenter.approvedList.length,
          itemBuilder: (context, index) {
            final approved = presenter.approvedList[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: Text(
                  approved.salesOrder,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer : ${approved.customer}'),
                    Text('Date : ${approved.getFormattedDate()}')
                  ],
                ),
                onTap: () => presenter.showApprovedDetail(context, approved.id),
              ),
            );
          },
        );
      }),
    );
  }
}
