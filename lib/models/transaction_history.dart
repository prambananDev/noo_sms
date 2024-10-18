class TransactionHistory {
  List<TransactionLines>? transactionLines;
  int? id;
  String? customerName;
  String? date;
  String? transactionId;
  String? customerId;

  TransactionHistory(
      {this.transactionLines,
      this.id,
      this.customerName,
      this.date,
      this.transactionId,
      this.customerId});

  TransactionHistory.fromJson(Map<String, dynamic> json) {
    if (json['transactionLines'] != null) {
      transactionLines = <TransactionLines>[];
      json['transactionLines'].forEach((v) {
        transactionLines?.add(TransactionLines.fromJson(v));
      });
    }
    id = json['id'];
    customerName = json['customerName'];
    date = json['date'];
    transactionId = json['transactionId'];
    customerId = json['customerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final transactionLines = this.transactionLines;
    if (transactionLines != null) {
      data['transactionLines'] =
          transactionLines.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['customerName'] = customerName;
    data['date'] = date;
    data['transactionId'] = transactionId;
    data['customerId'] = customerId;
    return data;
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
