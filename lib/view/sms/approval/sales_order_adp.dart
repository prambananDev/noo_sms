import 'package:flutter/material.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';

class SalesOrderAdapter extends StatelessWidget {
  final Promotion models;

  const SalesOrderAdapter({Key? key, required this.models}) : super(key: key);

  String formatCurrency(String? value) {
    if (value == null || value.isEmpty) return 'Rp0';

    String numericString = value.replaceAll('Rp', '').trim();
    return 'Rp$numericString';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColorDark.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          models.nomorPP ?? "-",
                          style: TextStyle(
                            color: colorAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: models.status == true
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        models.status == true ? 'Completed' : 'Pending',
                        style: TextStyle(
                          color: models.status == true
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextResultCard(
                  title: 'Product',
                  value: models.product ?? "N/A",
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextResultCard(
                        title: 'Qty',
                        value:
                            '${models.qty?.toStringAsFixed(0) ?? "0"} ${models.unitId ?? ""}',
                      ),
                    ),
                    Expanded(
                      child: TextResultCard(
                        title: 'Price',
                        value: formatCurrency(models.price),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextResultCard(
                        title: 'Disc(%)',
                        value: models.disc1 ?? "0%",
                      ),
                    ),
                    Expanded(
                      child: TextResultCard(
                        title: 'Sales Office',
                        value: models.salesOffice ?? "N/A",
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatCurrency(models.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ButtonBar(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Order Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('SO Number: ${models.nomorPP ?? "N/A"}'),
                              Text('Customer: ${models.customer ?? "N/A"}'),
                              Text(
                                  'Business Unit: ${models.businessUnit ?? "N/A"}'),
                              Text(
                                  'Sales Office: ${models.salesOffice ?? "N/A"}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 20),
                  label: const Text('Details'),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Order Status'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: const Text('Order Created'),
                              subtitle:
                                  Text(models.nomorPP?.split('-').last ?? ""),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 20),
                  label: const Text('Track'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
