import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class OrderTrackingUser extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final int? salesId;

  @HiveField(4)
  final int? role;

  @HiveField(5)
  final String? password;

  OrderTrackingUser({
    required this.userId,
    this.name,
    this.email,
    this.salesId,
    this.role,
    this.password,
  });

  factory OrderTrackingUser.fromJson(Map<String, dynamic> json) {
    return OrderTrackingUser(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      salesId: safeParseInt(json['salesId']),
      role: safeParseInt(json['role']),
      password: json['password']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'salesId': salesId,
      'role': role,
      'password': password,
    };
  }

  static int? safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool get isCustomer => role == 1;
  bool get isSalesman => role != 1;

  String get displayName => name ?? 'Unknown User';
  String get displayEmail => email ?? 'No email';

  @override
  String toString() {
    return 'OrderTrackingUser(userId: $userId, name: $name, email: $email, salesId: $salesId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTrackingUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

class OrderTrackingUserAdapter extends TypeAdapter<OrderTrackingUser> {
  @override
  final int typeId = 3;

  @override
  OrderTrackingUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderTrackingUser(
      userId: fields[0] as String,
      name: fields[1] as String?,
      email: fields[2] as String?,
      salesId: fields[3] as int?,
      role: fields[4] as int?,
      password: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderTrackingUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.salesId)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.password);
  }

  bool get hasValidTypeId => typeId >= 0 && typeId <= 223;
}

class OrderTrackingResponse {
  final List<OrderTrackingModel> data;

  OrderTrackingResponse({
    required this.data,
  });

  factory OrderTrackingResponse.fromJson(List<dynamic> jsonList) {
    List<OrderTrackingModel> orders =
        jsonList.map((item) => OrderTrackingModel.fromJson(item)).toList();

    return OrderTrackingResponse(
      data: orders,
    );
  }
}

class OrderTrackingModel {
  final String custId;
  final String custName;
  final String custAlias;

  OrderTrackingModel({
    required this.custId,
    required this.custName,
    required this.custAlias,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      custId: json['custId']?.toString() ?? '',
      custName: json['custName']?.toString() ?? '',
      custAlias: json['custAlias']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custId': custId,
      'custName': custName,
      'custAlias': custAlias,
    };
  }

  String get displayName => custName;
  String get displayAlias => custAlias;
  String get displayId => custId;

  @override
  String toString() {
    return 'OrderTrackingModel(custId: $custId, custName: $custName, custAlias: $custAlias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTrackingModel && other.custId == custId;
  }

  @override
  int get hashCode => custId.hashCode;
}

@HiveType(typeId: 4)
class CustomerProfile extends HiveObject {
  @HiveField(0)
  final String custName;

  @HiveField(1)
  final String amount;

  @HiveField(2)
  final String creditLine;

  @HiveField(3)
  final double purchased;

  @HiveField(4)
  final String? officeAddress;

  @HiveField(5)
  final String top;

  @HiveField(6)
  final String? deliveryAddress;

  @HiveField(7)
  final String? contactName;

  @HiveField(8)
  final String? contactNum;

  @HiveField(9)
  final String? npwpAddress;

  CustomerProfile({
    required this.custName,
    required this.amount,
    required this.creditLine,
    required this.purchased,
    this.officeAddress,
    required this.top,
    this.deliveryAddress,
    this.contactName,
    this.contactNum,
    this.npwpAddress,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      custName: json['CustName']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      creditLine: json['CreditLine']?.toString() ?? '0',
      purchased: _safeParseDouble(json['Purchased']) ?? 0.0,
      officeAddress: json['OfficeAddress']?.toString(),
      top: json['TOP']?.toString() ?? '',
      deliveryAddress: json['DeliveryAddress']?.toString(),
      contactName: json['ContactName']?.toString(),
      contactNum: json['ContactNum']?.toString(),
      npwpAddress: json['NPWPAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustName': custName,
      'amount': amount,
      'CreditLine': creditLine,
      'Purchased': purchased,
      'OfficeAddress': officeAddress,
      'TOP': top,
      'DeliveryAddress': deliveryAddress,
      'ContactName': contactName,
      'ContactNum': contactNum,
      'NPWPAddress': npwpAddress,
    };
  }

  static double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get displayName => custName.isNotEmpty ? custName : 'Unknown Customer';
  String get displayCreditLine => creditLine;
  String get displayAmount => amount;
  String get displayPurchased => purchased.toStringAsFixed(2);
  String get displayTOP => top.isNotEmpty ? top : 'N/A';
  String get displayOfficeAddress => officeAddress ?? 'Not provided';
  String get displayDeliveryAddress => deliveryAddress ?? 'Not provided';
  String get displayContactName => contactName ?? 'Not provided';
  String get displayContactNum => contactNum ?? 'Not provided';
  String get displayNPWPAddress => npwpAddress ?? 'Not provided';

  double get availableCredit {
    double credit = double.tryParse(creditLine) ?? 0;
    return credit - purchased;
  }

  String get formattedAvailableCredit => availableCredit.toStringAsFixed(2);

  String formatCurrency(double value) {
    return 'IDR ${value.toStringAsFixed(2)}';
  }

  String get formattedCreditLine =>
      formatCurrency(double.tryParse(creditLine) ?? 0);
  String get formattedPurchased => formatCurrency(purchased);
  String get formattedAvailableCreditCurrency =>
      formatCurrency(availableCredit);

  @override
  String toString() {
    return 'CustomerProfile(custName: $custName, creditLine: $creditLine, purchased: $purchased, top: $top)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerProfile &&
        other.custName == custName &&
        other.creditLine == creditLine;
  }

  @override
  int get hashCode => custName.hashCode ^ creditLine.hashCode;
}

class CustomerProfileAdapter extends TypeAdapter<CustomerProfile> {
  @override
  final int typeId = 4;

  @override
  CustomerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerProfile(
      custName: fields[0] as String,
      amount: fields[1] as String,
      creditLine: fields[2] as String,
      purchased: fields[3] as double,
      officeAddress: fields[4] as String?,
      top: fields[5] as String,
      deliveryAddress: fields[6] as String?,
      contactName: fields[7] as String?,
      contactNum: fields[8] as String?,
      npwpAddress: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.custName)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.creditLine)
      ..writeByte(3)
      ..write(obj.purchased)
      ..writeByte(4)
      ..write(obj.officeAddress)
      ..writeByte(5)
      ..write(obj.top)
      ..writeByte(6)
      ..write(obj.deliveryAddress)
      ..writeByte(7)
      ..write(obj.contactName)
      ..writeByte(8)
      ..write(obj.contactNum)
      ..writeByte(9)
      ..write(obj.npwpAddress);
  }

  bool get hasValidTypeId => typeId >= 0 && typeId <= 223;
}

class OrderHistoryResponse {
  final List<OrderHistoryModel> orders;

  OrderHistoryResponse({required this.orders});

  factory OrderHistoryResponse.fromJson(List<dynamic> jsonList) {
    List<OrderHistoryModel> orders =
        jsonList.map((item) => OrderHistoryModel.fromJson(item)).toList();

    return OrderHistoryResponse(orders: orders);
  }

  List<Map<String, dynamic>> toJson() {
    return orders.map((order) => order.toJson()).toList();
  }
}

class OrderHistoryModel {
  final String poNum;
  final String orderStatus;
  final String paymStatus;
  final String orderDate;
  final String? invoiceDate;
  final String salesId;
  final String? dueDate;
  final String? closedDate;
  final String? invoice;
  final List<OrderLineItem> lines;

  OrderHistoryModel({
    required this.poNum,
    required this.orderStatus,
    required this.paymStatus,
    required this.orderDate,
    this.invoiceDate,
    required this.salesId,
    this.dueDate,
    this.closedDate,
    this.invoice,
    required this.lines,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      poNum: json['PONum']?.toString() ?? '',
      orderStatus: json['OrderStatus']?.toString() ?? '',
      paymStatus: json['PaymStatus']?.toString() ?? '',
      orderDate: json['OrderDate']?.toString() ?? '',
      invoiceDate: json['InvoiceDate']?.toString(),
      salesId: json['SalesId']?.toString() ?? '',
      dueDate: json['DueDate']?.toString(),
      closedDate: json['ClosedDate']?.toString(),
      invoice: json['Invoice']?.toString(),
      lines: (json['Lines'] as List<dynamic>?)
              ?.map((item) => OrderLineItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PONum': poNum,
      'OrderStatus': orderStatus,
      'PaymStatus': paymStatus,
      'OrderDate': orderDate,
      'InvoiceDate': invoiceDate,
      'SalesId': salesId,
      'DueDate': dueDate,
      'ClosedDate': closedDate,
      'Invoice': invoice,
      'Lines': lines.map((line) => line.toJson()).toList(),
    };
  }

  double get totalPrice {
    if (lines.isEmpty) return 0.0;
    return lines.map((line) => line.total).reduce((a, b) => a + b);
  }

  String get displayPONum => poNum;
  String get displayOrderStatus => orderStatus;
  String get displayPaymStatus => paymStatus;
  String get displaySalesId => salesId;
  String get displayInvoice => invoice ?? '';

  String get formattedOrderDate {
    try {
      final date = DateTime.parse(orderDate.split('/').reversed.join('-'));
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return orderDate;
    }
  }

  String get formattedInvoiceDate {
    if (invoiceDate == null || invoiceDate == "01/01/0001") {
      return "Not available";
    }
    try {
      final date = DateTime.parse(invoiceDate!.split('/').reversed.join('-'));
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return invoiceDate ?? "Not available";
    }
  }

  bool get isPaid => paymStatus.toLowerCase() == 'paid';
  bool get isOverdue => paymStatus.toLowerCase() == 'overdue';

  @override
  String toString() {
    return 'OrderHistoryModel(poNum: $poNum, orderStatus: $orderStatus, paymStatus: $paymStatus, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderHistoryModel && other.poNum == poNum;
  }

  @override
  int get hashCode => poNum.hashCode;
}

class OrderLineItem {
  final String item;
  final double qty;
  final String unit;
  final double price;
  final String discType;
  final double disc;
  final double total;

  OrderLineItem({
    required this.item,
    required this.qty,
    required this.unit,
    required this.price,
    required this.discType,
    required this.disc,
    required this.total,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      item: json['item']?.toString() ?? '',
      qty: _safeParseDouble(json['qty']),
      unit: json['unit']?.toString() ?? '',
      price: _safeParseDouble(json['price']),
      discType: json['discType']?.toString() ?? '',
      disc: _safeParseDouble(json['disc']),
      total: _safeParseDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'qty': qty,
      'unit': unit,
      'price': price,
      'discType': discType,
      'disc': disc,
      'total': total,
    };
  }

  static double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get displayItem => item;
  String get displayQty => qty.toStringAsFixed(0);
  String get displayUnit => unit;
  String get displayPrice => price.toStringAsFixed(2);
  String get displayDisc => disc.toStringAsFixed(2);
  String get displayTotal => total.toStringAsFixed(2);
  String get displayQtyWithUnit => '$displayQty $unit';

  @override
  String toString() {
    return 'OrderLineItem(item: $item, qty: $qty, unit: $unit, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderLineItem && other.item == item && other.qty == qty;
  }

  @override
  int get hashCode => item.hashCode ^ qty.hashCode;
}

class DeliveryDetailModel {
  final String plId;
  final String poNum;
  final String date;
  final List<DeliveryLineItem> lines;

  DeliveryDetailModel({
    required this.plId,
    required this.poNum,
    required this.date,
    required this.lines,
  });

  factory DeliveryDetailModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDetailModel(
      plId: json['PLId']?.toString() ?? '',
      poNum: json['PONum']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      lines: (json['Lines'] as List<dynamic>?)
              ?.map((item) => DeliveryLineItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PLId': plId,
      'PONum': poNum,
      'date': date,
      'Lines': lines.map((item) => item.toJson()).toList(),
    };
  }

  String get displayPlId => plId.isNotEmpty ? plId : 'No PL ID';
  String get displayPoNum => poNum.isNotEmpty ? poNum : 'No PO Number';
  String get formattedDate {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return "${dateTime.day.toString().padLeft(2, '0')}-${_getMonthAbbr(dateTime.month)}-${dateTime.year}";
    } catch (e) {
      return date;
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  int get itemCount => lines.length;
}

class DeliveryLineItem {
  final String item;
  final double qty;
  final String salesUnit;

  DeliveryLineItem({
    required this.item,
    required this.qty,
    required this.salesUnit,
  });

  factory DeliveryLineItem.fromJson(Map<String, dynamic> json) {
    return DeliveryLineItem(
      item: json['Item']?.toString() ?? '',
      qty: double.tryParse(json['Qty']?.toString() ?? '0') ?? 0.0,
      salesUnit: json['SalesUnit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'Qty': qty,
      'SalesUnit': salesUnit,
    };
  }

  String get displayItem => item.isNotEmpty ? item : 'No Item Name';
  String get displayQtyWithUnit {
    final qtyStr = qty.toString().split('.').first;
    final unitStr = salesUnit.split('.').first;
    return '$qtyStr $unitStr';
  }
}

class OrderTrackingDetailResponse {
  final String status;
  final OrderTrackingDetailData? data;
  final String? error;

  OrderTrackingDetailResponse({
    required this.status,
    this.data,
    this.error,
  });

  factory OrderTrackingDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingDetailResponse(
      status: json['status']?.toString() ?? '',
      data: json['data'] != null
          ? OrderTrackingDetailData.fromJson(json['data'])
          : null,
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'error': error,
    };
  }

  bool get isSuccess => status.toLowerCase() == 'success';
  bool get hasError => error != null || !isSuccess;
  bool get hasData => data != null && isSuccess;
}

class OrderTrackingDetailData {
  final String salesId;
  final String pickingId;
  final String custId;
  final String custName;
  final String destId;
  final String companyName;
  final List<TrackingItem> items;
  final List<TrackingDeliveryStatus> deliveryStatus;
  final TrackingDriverInfo? driverInfo;
  final String dateTime;

  OrderTrackingDetailData({
    required this.salesId,
    required this.pickingId,
    required this.custId,
    required this.custName,
    required this.destId,
    required this.companyName,
    required this.items,
    required this.deliveryStatus,
    this.driverInfo,
    required this.dateTime,
  });

  factory OrderTrackingDetailData.fromJson(Map<String, dynamic> json) {
    return OrderTrackingDetailData(
      salesId: json['SalesId']?.toString() ?? '',
      pickingId: json['PickingId']?.toString() ?? '',
      custId: json['CustId']?.toString() ?? '',
      custName: json['CustName']?.toString() ?? '',
      destId: json['DestId']?.toString() ?? '',
      companyName: json['CompanyName']?.toString() ?? '',
      items: (json['Items'] as List<dynamic>?)
              ?.map((item) => TrackingItem.fromJson(item))
              .toList() ??
          [],
      deliveryStatus: (json['DeliveryStatus'] as List<dynamic>?)
              ?.map((status) => TrackingDeliveryStatus.fromJson(status))
              .toList() ??
          [],
      driverInfo: json['DriverInfo'] != null
          ? TrackingDriverInfo.fromJson(json['DriverInfo'])
          : null,
      dateTime: json['DateTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SalesId': salesId,
      'PickingId': pickingId,
      'CustId': custId,
      'CustName': custName,
      'DestId': destId,
      'CompanyName': companyName,
      'Items': items.map((item) => item.toJson()).toList(),
      'DeliveryStatus':
          deliveryStatus.map((status) => status.toJson()).toList(),
      'DriverInfo': driverInfo?.toJson(),
      'DateTime': dateTime,
    };
  }

  // Helper properties
  String get displaySalesId => salesId.isNotEmpty ? salesId : 'N/A';
  String get displayPickingId => pickingId.isNotEmpty ? pickingId : 'N/A';
  String get displayCustName =>
      custName.isNotEmpty ? custName : 'Unknown Customer';
  String get displayCompanyName => companyName.isNotEmpty ? companyName : 'N/A';

  bool get hasDeliveryStatus => deliveryStatus.isNotEmpty;
  bool get hasDriverInfo => driverInfo != null;
  bool get hasItems => items.isNotEmpty;

  TrackingDeliveryStatus? get latestStatus {
    if (deliveryStatus.isEmpty) return null;
    return deliveryStatus.last;
  }

  bool get isDelivered {
    return deliveryStatus.any((status) =>
        status.name.toLowerCase().contains("paket sudah diterima customer"));
  }

  String get currentStatusText {
    if (deliveryStatus.isEmpty) return "Processing Order";
    if (deliveryStatus.length == 1) return "Order Registered";
    if (deliveryStatus.length == 2) return "Ready to be shipped";
    if (deliveryStatus.length >= 3 && deliveryStatus.length < 6)
      return "Out for delivery";
    if (isDelivered) return "Delivered";
    return "In Transit";
  }

  String get expectedDeliveryDate {
    try {
      final estimationStatus = deliveryStatus.firstWhere(
        (status) => status.name.toLowerCase().contains("estimasi"),
        orElse: () => TrackingDeliveryStatus(datetime: '', name: ''),
      );

      if (estimationStatus.name.isNotEmpty) {
        final parts = estimationStatus.name.split("tiba ");
        if (parts.length > 1) {
          return parts.last.trim();
        }
      }
    } catch (e) {
      // Handle any parsing errors
    }
    return "N/A";
  }
}

class TrackingItem {
  final String? itemId;
  final String? itemName;
  final double? quantity;
  final String? unit;

  TrackingItem({
    this.itemId,
    this.itemName,
    this.quantity,
    this.unit,
  });

  factory TrackingItem.fromJson(Map<String, dynamic> json) {
    return TrackingItem(
      itemId: json['itemId']?.toString(),
      itemName: json['itemName']?.toString(),
      quantity: _safeParseDouble(json['quantity']),
      unit: json['unit']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  static double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get displayItemName => itemName ?? 'Unknown Item';
  String get displayQuantity => quantity?.toStringAsFixed(0) ?? '0';
  String get displayUnit => unit ?? '';
  String get displayQuantityWithUnit => '$displayQuantity $displayUnit'.trim();
}

class TrackingDeliveryStatus {
  final String datetime;
  final String name;
  final TrackingDeliveryData? data;

  TrackingDeliveryStatus({
    required this.datetime,
    required this.name,
    this.data,
  });

  factory TrackingDeliveryStatus.fromJson(Map<String, dynamic> json) {
    return TrackingDeliveryStatus(
      datetime: json['datetime']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      data: json['data'] != null
          ? TrackingDeliveryData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'name': name,
      'data': data?.toJson(),
    };
  }

  DateTime get parsedDateTime {
    try {
      return DateTime.parse(datetime);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDateTime {
    try {
      final date = DateTime.parse(datetime);
      return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return datetime;
    }
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(datetime);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return datetime.split(' ').first;
    }
  }

  String get formattedTime {
    try {
      final date = DateTime.parse(datetime);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      final parts = datetime.split(' ');
      return parts.length > 1 ? parts.last : '';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String get statusTitle {
    if (name.contains("Paket sudah diterima customer")) {
      return "Delivered / Sampai Tujuan";
    } else if (name.contains("Paket didaftarkan ke dalam system")) {
      return "Order Registered / Pesanan Terdaftar";
    } else if (name.contains("Pesanan telah dijadwalkan pengirimannya")) {
      return "Scheduled for Delivery / Dijadwalkan Pengiriman";
    } else if (name.contains("Truk sudah dialokasikan")) {
      return "Truck Allocated / Truk Dialokasikan";
    } else if (name.contains("Paket sudah keluar dari gudang")) {
      return "Out from Warehouse / Keluar dari Gudang";
    } else if (name.contains("Paket sudah tiba di area pengiriman")) {
      return "Arrived at Delivery Area / Tiba di Area Pengiriman";
    }
    return name;
  }

  TrackingStatusIcon get statusIcon {
    if (name.contains("Paket sudah diterima customer")) {
      return TrackingStatusIcon.delivered;
    } else if (name.contains("Paket didaftarkan ke dalam system")) {
      return TrackingStatusIcon.registered;
    } else if (name.contains("Pesanan telah dijadwalkan pengirimannya")) {
      return TrackingStatusIcon.scheduled;
    } else if (name.contains("Truk sudah dialokasikan")) {
      return TrackingStatusIcon.allocated;
    } else if (name.contains("Paket sudah keluar dari gudang")) {
      return TrackingStatusIcon.shipped;
    } else if (name.contains("Paket sudah tiba di area pengiriman")) {
      return TrackingStatusIcon.inTransit;
    }
    return TrackingStatusIcon.info;
  }

  bool get isDelivered =>
      name.toLowerCase().contains("paket sudah diterima customer");
  bool get hasDeliveryData => data != null;
  bool get hasImages => data?.images?.isNotEmpty == true;
}

enum TrackingStatusIcon {
  delivered,
  registered,
  scheduled,
  allocated,
  shipped,
  inTransit,
  info,
}

class TrackingDeliveryData {
  final String? receiveName;
  final List<String>? images;

  TrackingDeliveryData({
    this.receiveName,
    this.images,
  });

  factory TrackingDeliveryData.fromJson(Map<String, dynamic> json) {
    return TrackingDeliveryData(
      receiveName: json['receive_name']?.toString(),
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receive_name': receiveName,
      'images': images,
    };
  }

  String get displayReceiverName {
    if (receiveName == null || receiveName!.isEmpty) return 'N/A';
    return receiveName!
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String? get latestImage {
    if (images == null || images!.isEmpty) return null;
    return images!.last;
  }

  bool get hasReceiver => receiveName != null && receiveName!.isNotEmpty;
  bool get hasImages => images != null && images!.isNotEmpty;
}

class TrackingDriverInfo {
  final String? name;
  final String? telp;
  final String? platNumber;
  final TrackingLastPosition? lastPosition;

  TrackingDriverInfo({
    this.name,
    this.telp,
    this.platNumber,
    this.lastPosition,
  });

  factory TrackingDriverInfo.fromJson(Map<String, dynamic> json) {
    return TrackingDriverInfo(
      name: json['name']?.toString(),
      telp: json['telp']?.toString(),
      platNumber: json['plat_number']?.toString(),
      lastPosition: json['last_position'] != null
          ? TrackingLastPosition.fromJson(json['last_position'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'telp': telp,
      'plat_number': platNumber,
      'last_position': lastPosition?.toJson(),
    };
  }

  String get displayName {
    if (name == null || name!.isEmpty) return 'N/A';
    return name!
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String get displayPlatNumber => platNumber ?? 'N/A';
  String get displayTelp => telp ?? 'N/A';

  bool get hasLocation =>
      lastPosition != null && lastPosition!.isValidCoordinates;
  bool get hasContactInfo => telp != null && telp!.isNotEmpty;
}

class TrackingLastPosition {
  final String longitude;
  final String latitude;
  final String datetime;

  TrackingLastPosition({
    required this.longitude,
    required this.latitude,
    required this.datetime,
  });

  factory TrackingLastPosition.fromJson(Map<String, dynamic> json) {
    return TrackingLastPosition(
      longitude: json['longitude']?.toString() ?? '0',
      latitude: json['latitude']?.toString() ?? '0',
      datetime: json['datetime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'longitude': longitude,
      'latitude': latitude,
      'datetime': datetime,
    };
  }

  double get latitudeDouble => double.tryParse(latitude) ?? 0.0;
  double get longitudeDouble => double.tryParse(longitude) ?? 0.0;

  bool get isValidCoordinates {
    final lat = latitudeDouble;
    final lng = longitudeDouble;
    return lat != 0.0 &&
        lng != 0.0 &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  String get coordinatesString => '$latitude, $longitude';

  DateTime get parsedDateTime {
    try {
      return DateTime.parse(datetime);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDateTime {
    try {
      final date = DateTime.parse(datetime);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return datetime;
    }
  }

  Map<String, double> get locationMap {
    return {
      'latitude': latitudeDouble,
      'longitude': longitudeDouble,
    };
  }
}
