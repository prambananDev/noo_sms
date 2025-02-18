class TransactionHistorySample {
  final int? id;
  final String? salesId;
  final String? customer;
  final String? date;
  final String? custReff;
  final String? status;
  final int? docStatus;
  final String? desc;
  final String? address;
  final String? pic;
  final String? phone;
  final String? principal;
  final String? segment;
  final String? notes;
  final String? salesoffice;
  final String? businessUnit;
  final String? dept;
  final String? isClaimed;
  final String? feedback;
  final String? docStatusName;
  final String? purpose;
  final String? purposeType;

  TransactionHistorySample({
    this.id,
    this.salesId,
    this.customer,
    this.date,
    this.custReff,
    this.status,
    this.docStatus,
    this.desc,
    this.address,
    this.pic,
    this.phone,
    this.principal,
    this.segment,
    this.notes,
    this.salesoffice,
    this.businessUnit,
    this.dept,
    this.isClaimed,
    this.feedback,
    this.docStatusName,
    this.purpose,
    this.purposeType,
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
      desc: json['Desc'] as String?,
      address: json['Address'] as String?,
      pic: json['PIC'] as String?,
      phone: json['Phone'] as String?,
      principal: json['Principal'] as String?,
      segment: json['Segment'] as String?,
      notes: json['Notes'] as String?,
      salesoffice: json['salesoffice'] as String?,
      businessUnit: json['BusinessUnit'] as String?,
      dept: json['Dept'] as String?,
      isClaimed: json['isClaimed'] as String?,
      feedback: json['Feedback'] as String?,
      docStatusName: json['DocStatusName'] as String?,
      purpose: json['Purpose'] as String?,
      purposeType: json['PurposeType'] as String?,
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

class ApprovalInfo {
  final int level;
  final String name;
  final String status;
  final String? message;
  final DateTime? time;

  ApprovalInfo({
    required this.level,
    required this.name,
    required this.status,
    this.message,
    this.time,
  });

  factory ApprovalInfo.fromJson(Map<String, dynamic> json) {
    return ApprovalInfo(
      level: json['Level'] as int,
      name: json['Name'] as String,
      status: json['Status'] as String,
      message: json['Message'] as String?,
      time:
          json['Time'] != null ? DateTime.parse(json['Time'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Level': level,
      'Name': name,
      'Status': status,
      'Message': message,
      'Time': time?.toIso8601String(),
    };
  }
}
