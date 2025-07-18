import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64.ri(context),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.rs(context)),
                      Text(
                        'No approved data found',
                        style: TextStyle(
                          fontSize: 18.rt(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.rs(context)),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14.rt(context),
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 24.rs(context)),
                      ElevatedButton.icon(
                        onPressed: () => presenter.refreshData(),
                        icon: Icon(
                          Icons.refresh,
                          size: 20.ri(context),
                        ),
                        label: Text(
                          'Refresh',
                          style: TextStyle(fontSize: 16.rt(context)),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.rp(context),
                            vertical: 12.rp(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.rr(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: presenter.approvedList.length,
                  itemBuilder: (context, index) {
                    final approved = presenter.approvedList[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.rp(context),
                        vertical: 8.rp(context),
                      ),
                      padding: EdgeInsets.all(16.rp(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.rr(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8.rs(context),
                            spreadRadius: 1.rs(context),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.description,
                          color: colorAccent,
                          size: 24.ri(context),
                        ),
                        title: Text(
                          approved.salesOrder,
                          style: TextStyle(
                            fontSize: 16.rt(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.rs(context)),
                            Text(
                              'Customer : ${approved.customer}',
                              style: TextStyle(fontSize: 16.rt(context)),
                            ),
                            SizedBox(height: 2.rs(context)),
                            Text(
                              'Date : ${approved.getFormattedDate()}',
                              style: TextStyle(fontSize: 16.rt(context)),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 24.ri(context),
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
