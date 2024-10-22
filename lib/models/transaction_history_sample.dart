class TransactionHistorySample {
  final int? id;
  final String? SalesId;
  final String? Customer;
  final String? Date;
  final String? CustReff;
  final String? Status;
  final int? DocStatus;
  final String? DocStatusName;

  TransactionHistorySample({
    this.id,
    this.SalesId,
    this.Customer,
    this.Date,
    this.CustReff,
    this.Status,
    this.DocStatus,
    this.DocStatusName,
  });

  factory TransactionHistorySample.fromJson(Map<String, dynamic> json) {
    return TransactionHistorySample(
      id: json['id'] as int?,
      SalesId: json['SalesId'] as String?,
      Customer: json['Customer'] as String?,
      Date: json['Date'] as String?,
      CustReff: json['CustReff'] as String?,
      Status: json['Status'] as String?,
      DocStatus: json['DocStatus'] as int?,
      DocStatusName: json['DocStatusName'] as String?,
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
