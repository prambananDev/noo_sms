import 'package:flutter/material.dart';
import 'package:noo_sms/assets/widgets/text_result_card.dart';
import 'package:noo_sms/models/promotion.dart';

class SalesOrderAdapter extends StatelessWidget {
  final Promotion models;

  // Ensure models is required to maintain null safety
  const SalesOrderAdapter({Key? key, required this.models}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextResultCard(
            title: 'No. Sales Order',
            value: models.nomorPP ?? "",
          ),
          TextResultCard(
            title: 'Product',
            value: models.product ?? "",
          ),
          TextResultCard(
            title: 'Qty',
            value: models.qty.toString(),
          ),
          TextResultCard(
            title: 'Unit',
            value: models.unitId ?? "",
          ),
          TextResultCard(
            title: 'Price',
            value: models.price ?? "",
          ),
          TextResultCard(
            title: 'Disc(%)',
            value: models.disc1 ?? "",
          ),
          TextResultCard(
            title: "Total",
            value: models.totalAmount ?? "",
          ),
        ],
      ),
    );
  }
}
