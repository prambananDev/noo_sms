class SalesOffice {
  final String name;
  final String code;

  SalesOffice({required this.name, required this.code});

  factory SalesOffice.fromJson(Map<String, dynamic> json) {
    return SalesOffice(
      name: json['NameSO'] ?? '',
      code: json['CodeSO'] ?? '',
    );
  }
}

class BusinessUnit {
  final String name;

  BusinessUnit({required this.name});

  factory BusinessUnit.fromJson(Map<String, dynamic> json) {
    return BusinessUnit(name: json['NameBU'] ?? 'Unknown');
  }
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] ?? 'Unknown');
  }
}

class Category2 {
  final String master;

  Category2({required this.master});

  factory Category2.fromJson(Map<String, dynamic> json) {
    return Category2(master: json['MASTER_SETUP'] ?? 'Unknown');
  }
}

class AXRegional {
  final String regional;

  AXRegional({required this.regional});

  factory AXRegional.fromJson(Map<String, dynamic> json) {
    return AXRegional(regional: json['REGIONAL'] ?? 'Unknown');
  }
}

class Segment {
  final String segmentId;

  Segment({required this.segmentId});

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(segmentId: json['SEGMENTID'] ?? 'Unknown');
  }
}

class SubSegment {
  final String subSegmentId;

  SubSegment({required this.subSegmentId});

  factory SubSegment.fromJson(Map<String, dynamic> json) {
    return SubSegment(subSegmentId: json['SUBSEGMENTID'] ?? 'Unknown');
  }
}

class ClassModel {
  final String className;

  ClassModel({required this.className});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(className: json['CLASS'] ?? 'Unknown');
  }
}

class CompanyStatus {
  final String chainId;

  CompanyStatus({required this.chainId});

  factory CompanyStatus.fromJson(Map<String, dynamic> json) {
    return CompanyStatus(chainId: json['CHAINID'] ?? 'Unknown');
  }
}

class PriceGroup {
  final String groupId;

  PriceGroup({required this.groupId});

  factory PriceGroup.fromJson(Map<String, dynamic> json) {
    return PriceGroup(groupId: json['GROUPID'] ?? 'Unknown');
  }
}

class Currency {
  final String currencyCode;

  Currency({required this.currencyCode});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(currencyCode: json['CurrencyCode'] ?? 'Unknown');
  }
}

class CustomerPaymentMode {
  final String paymentMode;

  CustomerPaymentMode({required this.paymentMode});

  factory CustomerPaymentMode.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentMode(paymentMode: json['PAYMMODE'] ?? 'Unknown');
  }
}
