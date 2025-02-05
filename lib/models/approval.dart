import 'package:intl/intl.dart';

class Approval {
  final int id;
  final String salesOrder;
  final String? customer;
  final String date;
  final String? custReff;
  final String? desc;
  final String status;
  final String purpose;
  final String purposeType;

  Approval({
    required this.id,
    required this.salesOrder,
    this.customer,
    required this.date,
    this.custReff,
    this.desc,
    required this.status,
    required this.purpose,
    required this.purposeType,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['Id'] as int,
      salesOrder: json['SalesOrder'] as String,
      customer: json['Customer'] as String?,
      date: json['Date'] as String,
      custReff: json['CustReff'] as String?,
      desc: json['Desc'] as String?,
      status: json['Status'] as String,
      purpose: json['Purpose'] as String,
      purposeType: json['PurposeType'] as String,
    );
  }

  String getFormattedDate() {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
}

class ApprovalDetail {
  final String productId;
  final String product;
  final int qty;
  final String unit;

  ApprovalDetail({
    required this.productId,
    required this.product,
    required this.qty,
    required this.unit,
  });

  ApprovalDetail copyWith({
    String? productId,
    String? product,
    int? qty,
    String? unit,
  }) {
    return ApprovalDetail(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
    );
  }

  factory ApprovalDetail.fromJson(Map<String, dynamic> json) {
    return ApprovalDetail(
      productId: json['ProductId'] as String,
      product: json['Product'] as String,
      qty: json['Qty'] as int,
      unit: json['Unit'] as String,
    );
  }
}
