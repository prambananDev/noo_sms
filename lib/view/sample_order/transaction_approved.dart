import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/sample_order/transaction_approved_controller.dart';

class TransactionApprovedPage extends StatefulWidget {
  const TransactionApprovedPage({super.key});

  @override
  State<TransactionApprovedPage> createState() =>
      _TransactionApprovedPageState();
}

class _TransactionApprovedPageState extends State<TransactionApprovedPage> {
  late TransactionApprovedController presenter;

  @override
  void initState() {
    super.initState();
    presenter = Get.put(TransactionApprovedController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      body: RefreshIndicator(
        onRefresh: () => presenter.refreshData(),
        child: Obx(() {
          return Stack(
            children: [
              if (presenter.isLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (presenter.approvedList.isEmpty)
                const Center(child: Text('No approved data found'))
              else
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: presenter.approvedList.length,
                  itemBuilder: (context, index) {
                    final approved = presenter.approvedList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(Icons.description, color: colorAccent),
                        title: Text(
                          approved.salesOrder,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer : ${approved.customer}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Date : ${approved.getFormattedDate()}',
                              style: const TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        onTap: () =>
                            presenter.showApprovedDetail(context, approved.id),
                      ),
                    );
                  },
                ),
            ],
          );
        }),
      ),
    );
  }
}
