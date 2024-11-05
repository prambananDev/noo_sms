class TransactionHistorySample {
  final int? id;
  final String? salesId;
  final String? customer;
  final String? date;
  final String? custReff;
  final String? status;
  final int? docStatus;
  final String? docStatusName;

  TransactionHistorySample({
    this.id,
    this.salesId,
    this.customer,
    this.date,
    this.custReff,
    this.status,
    this.docStatus,
    this.docStatusName,
  });

  factory TransactionHistorySample.fromJson(Map<String, dynamic> json) {
    return TransactionHistorySample(
      id: json['id'] as int?,
      salesId: json['SalesId'] as String?,
      customer: json['Customer'] as String?,
      date: json['Date'] as String?,
      custReff: json['CustReff'] as String?,
      status: json['Status'] as String?,
      docStatus: json['DocStatus'] as int?,
      docStatusName: json['DocStatusName'] as String?,
    );
  }
}

class TransactionLines {
  int? id;
  String? productId;
  String? unit;
  int? qty;
  int? disc;
  int? price;
  int? transactionId;
  int? totalPrice;
  String? productName;

  TransactionLines(
      {this.id,
      this.productId,
      this.unit,
      this.qty,
      this.disc,
      this.price,
      this.transactionId,
      this.totalPrice,
      this.productName});

  TransactionLines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    unit = json['unit'];
    qty = json['qty'];
    disc = json['disc'];
    price = json['price'];
    transactionId = json['transactionId'];
    totalPrice = json['totalPrice'];
    productName = json['productName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productId'] = productId;
    data['unit'] = unit;
    data['qty'] = qty;
    data['disc'] = disc;
    data['price'] = price;
    data['transactionId'] = transactionId;
    data['totalPrice'] = totalPrice;
    data['productName'] = productName;
    return data;
  }
}
