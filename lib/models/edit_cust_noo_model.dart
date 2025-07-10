class EditCustModel {
  final int id;
  final String custName;
  final String custId;
  final String? custStatus;
  final String? brandName;
  final String category;
  final String? category1;
  final String? paymMode;
  final String segment;
  final String subSegment;
  final String custClass;
  final String? phoneNo;
  final String companyStatus;
  final String? faxNo;
  final String? contactPerson;
  final String regional;
  final String? emailAddress;
  final String? website;
  final String? npwp;
  final String? sppkp;
  final String? siup;
  final String? ktp;
  final String? ktpAddress;
  final String? currency;
  final String priceGroup;
  final String? salesman;
  final String salesOffice;
  final String businessUnit;
  final String custSubGroup;
  final String? notes;
  final String? fotoNPWP;
  final String? fotoKTP;
  final String? fotoSIUP;
  final String? fotoGedung;
  final String? fotoGedung1;
  final String? fotoGedung2;
  final String? fotoGedung3;
  final String? fotoCompetitorTop;
  final String? custSignature;
  final String? salesSignature;
  final String? approval1Signature;
  final String? approval2Signature;
  final String? approval3Signature;
  final int imported;
  final String? longitude;
  final String? latitude;
  final String? approval1;
  final String? approval2;
  final String? approval3;
  final String? status;
  final String? createdBy;
  final String? remark;
  final String? createdDate;
  final String? approved1;
  final String? approved2;
  final String? approved3;
  final String? companyAddresses;
  final String? deliveryAddresses;
  final String? taxAddresses;
  final String paymentTerm;
  final String creditLimit;

  EditCustModel({
    required this.id,
    required this.custName,
    required this.custId,
    this.custStatus,
    this.brandName,
    required this.category,
    this.category1,
    this.paymMode,
    required this.segment,
    required this.subSegment,
    required this.custClass,
    this.phoneNo,
    required this.companyStatus,
    this.faxNo,
    this.contactPerson,
    required this.regional,
    this.emailAddress,
    this.website,
    this.npwp,
    this.sppkp,
    this.siup,
    this.ktp,
    this.ktpAddress,
    this.currency,
    required this.priceGroup,
    this.salesman,
    required this.salesOffice,
    required this.businessUnit,
    required this.custSubGroup,
    this.notes,
    this.fotoNPWP,
    this.fotoKTP,
    this.fotoSIUP,
    this.fotoGedung,
    this.fotoGedung1,
    this.fotoGedung2,
    this.fotoGedung3,
    this.fotoCompetitorTop,
    this.custSignature,
    this.salesSignature,
    this.approval1Signature,
    this.approval2Signature,
    this.approval3Signature,
    required this.imported,
    this.longitude,
    this.latitude,
    this.approval1,
    this.approval2,
    this.approval3,
    this.status,
    this.createdBy,
    this.remark,
    this.createdDate,
    this.approved1,
    this.approved2,
    this.approved3,
    this.companyAddresses,
    this.deliveryAddresses,
    this.taxAddresses,
    required this.paymentTerm,
    required this.creditLimit,
  });

  factory EditCustModel.fromJson(Map<String, dynamic> json) {
    return EditCustModel(
      id: json['id'] ?? 0,
      custName: json['CustName'] ?? '',
      custId: json['CustId'] ?? '',
      custStatus: json['CustStatus'],
      brandName: json['BrandName'],
      category: json['Category'] ?? '',
      category1: json['Category1'],
      paymMode: json['PaymMode'],
      segment: json['Segment'] ?? '',
      subSegment: json['SubSegment'] ?? '',
      custClass: json['Class'] ?? '',
      phoneNo: json['PhoneNo'],
      companyStatus: json['CompanyStatus'] ?? '',
      faxNo: json['FaxNo'],
      contactPerson: json['ContactPerson'],
      regional: json['Regional'] ?? '',
      emailAddress: json['EmailAddress'],
      website: json['Website'],
      npwp: json['NPWP'],
      sppkp: json['SPPKP'],
      siup: json['SIUP'],
      ktp: json['KTP'],
      ktpAddress: json['KTPAddress'],
      currency: json['Currency'],
      priceGroup: json['PriceGroup'] ?? '',
      salesman: json['Salesman'],
      salesOffice: json['SalesOffice'] ?? '',
      businessUnit: json['BusinessUnit'] ?? '',
      custSubGroup: json['CustSubGroup'] ?? '',
      notes: json['Notes'],
      fotoNPWP: json['FotoNPWP'],
      fotoKTP: json['FotoKTP'],
      fotoSIUP: json['FotoSIUP'],
      fotoGedung: json['FotoGedung'],
      fotoGedung1: json['FotoGedung1'],
      fotoGedung2: json['FotoGedung2'],
      fotoGedung3: json['FotoGedung3'],
      fotoCompetitorTop: json['FotoCompetitorTop'],
      custSignature: json['CustSignature'],
      salesSignature: json['SalesSignature'],
      approval1Signature: json['Approval1Signature'],
      approval2Signature: json['Approval2Signature'],
      approval3Signature: json['Approval3Signature'],
      imported: json['Imported'] ?? 0,
      longitude: json['Long'],
      latitude: json['Lat'],
      approval1: json['Approval1'],
      approval2: json['Approval2'],
      approval3: json['Approval3'],
      status: json['Status'],
      createdBy: json['CreatedBy'],
      remark: json['Remark'],
      createdDate: json['CreatedDate'],
      approved1: json['Approved1'],
      approved2: json['Approved2'],
      approved3: json['Approved3'],
      companyAddresses: json['CompanyAddresses'],
      deliveryAddresses: json['DeliveryAddresses'],
      taxAddresses: json['TaxAddresses'],
      paymentTerm: json['PaymentTerm'] ?? '',
      creditLimit: json['CreditLimit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'CustName': custName,
      'CustId': custId,
      'CustStatus': custStatus,
      'BrandName': brandName,
      'Category': category,
      'Category1': category1,
      'PaymMode': paymMode,
      'Segment': segment,
      'SubSegment': subSegment,
      'Class': custClass,
      'PhoneNo': phoneNo,
      'CompanyStatus': companyStatus,
      'FaxNo': faxNo,
      'ContactPerson': contactPerson,
      'Regional': regional,
      'EmailAddress': emailAddress,
      'Website': website,
      'NPWP': npwp,
      'SPPKP': sppkp,
      'SIUP': siup,
      'KTP': ktp,
      'KTPAddress': ktpAddress,
      'Currency': currency,
      'PriceGroup': priceGroup,
      'Salesman': salesman,
      'SalesOffice': salesOffice,
      'BusinessUnit': businessUnit,
      'CustSubGroup': custSubGroup,
      'Notes': notes,
      'FotoNPWP': fotoNPWP,
      'FotoKTP': fotoKTP,
      'FotoSIUP': fotoSIUP,
      'FotoGedung': fotoGedung,
      'FotoGedung1': fotoGedung1,
      'FotoGedung2': fotoGedung2,
      'FotoGedung3': fotoGedung3,
      'FotoCompetitorTop': fotoCompetitorTop,
      'CustSignature': custSignature,
      'SalesSignature': salesSignature,
      'Approval1Signature': approval1Signature,
      'Approval2Signature': approval2Signature,
      'Approval3Signature': approval3Signature,
      'Imported': imported,
      'Long': longitude,
      'Lat': latitude,
      'Approval1': approval1,
      'Approval2': approval2,
      'Approval3': approval3,
      'Status': status,
      'CreatedBy': createdBy,
      'Remark': remark,
      'CreatedDate': createdDate,
      'Approved1': approved1,
      'Approved2': approved2,
      'Approved3': approved3,
      'CompanyAddresses': companyAddresses,
      'DeliveryAddresses': deliveryAddresses,
      'TaxAddresses': taxAddresses,
      'PaymentTerm': paymentTerm,
      'CreditLimit': creditLimit,
    };
  }
}

class EditCustResponse {
  final int page;
  final int pageSize;
  final List<EditCustModel> data;

  EditCustResponse({
    required this.page,
    required this.pageSize,
    required this.data,
  });

  factory EditCustResponse.fromJson(Map<String, dynamic> json) {
    return EditCustResponse(
      page: json['Page'] ?? 1,
      pageSize: json['PageSize'] ?? 20,
      data: (json['Data'] as List<dynamic>?)
              ?.map((item) => EditCustModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CustomerDetail {
  final int id;
  final String custName;
  final String custId;
  final String? custStatus;
  final String? brandName;
  final String category;
  final String? category1;
  final String? paymMode;
  final String segment;
  final String subSegment;
  final String classType;
  final String? phoneNo;
  final String companyStatus;
  final String? faxNo;
  final String? contactPerson;
  final String? regional;
  final String? emailAddress;
  final String? website;
  final String? npwp;
  final String? sppkp;
  final String? siup;
  final String? ktp;
  final String? ktpAddress;
  final String? currency;
  final String priceGroup;
  final String? salesman;
  final String salesOffice;
  final String businessUnit;
  final String? custSubGroup;
  final String? notes;
  final String? fotoNPWP;
  final String? fotoKTP;
  final String? fotoSIUP;
  final String? fotoGedung;
  final String? fotoGedung1;
  final String? fotoGedung2;
  final String? fotoGedung3;
  final String? fotoCompetitorTop;
  final String? custSignature;
  final String? salesSignature;
  final String? approval1Signature;
  final String? approval2Signature;
  final String? approval3Signature;
  final int imported;
  final String? longCoord;
  final String? lat;
  final int? approval1;
  final int? approval2;
  final int? approval3;
  final int? status;
  final int? createdBy;
  final String? remark;
  final String? createdDate;
  final bool? approved1;
  final bool? approved2;
  final bool? approved3;
  final Address? companyAddresses;
  final Address? deliveryAddresses;
  final Address? taxAddresses;
  final String paymentTerm;
  final String creditLimit;

  CustomerDetail({
    required this.id,
    required this.custName,
    required this.custId,
    this.custStatus,
    this.brandName,
    required this.category,
    this.category1,
    this.paymMode,
    required this.segment,
    required this.subSegment,
    required this.classType,
    this.phoneNo,
    required this.companyStatus,
    this.faxNo,
    this.contactPerson,
    this.regional,
    this.emailAddress,
    this.website,
    this.npwp,
    this.sppkp,
    this.siup,
    this.ktp,
    this.ktpAddress,
    this.currency,
    required this.priceGroup,
    this.salesman,
    required this.salesOffice,
    required this.businessUnit,
    this.custSubGroup,
    this.notes,
    this.fotoNPWP,
    this.fotoKTP,
    this.fotoSIUP,
    this.fotoGedung,
    this.fotoGedung1,
    this.fotoGedung2,
    this.fotoGedung3,
    this.fotoCompetitorTop,
    this.custSignature,
    this.salesSignature,
    this.approval1Signature,
    this.approval2Signature,
    this.approval3Signature,
    required this.imported,
    this.longCoord,
    this.lat,
    this.approval1,
    this.approval2,
    this.approval3,
    this.status,
    this.createdBy,
    this.remark,
    this.createdDate,
    this.approved1,
    this.approved2,
    this.approved3,
    this.companyAddresses,
    this.deliveryAddresses,
    this.taxAddresses,
    required this.paymentTerm,
    required this.creditLimit,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int from various types
    int? parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CustomerDetail(
      id: json['id'] ?? 0,
      custName: json['CustName'] ?? '',
      custId: json['CustId'] ?? '',
      custStatus: json['CustStatus'],
      brandName: json['BrandName'],
      category: json['Category'] ?? '',
      category1: json['Category1'],
      paymMode: json['PaymMode'],
      segment: json['Segment'] ?? '',
      subSegment: json['SubSegment'] ?? '',
      classType: json['Class'] ?? '',
      phoneNo: json['PhoneNo'],
      companyStatus: json['CompanyStatus'] ?? '',
      faxNo: json['FaxNo'],
      contactPerson: json['ContactPerson'],
      regional: json['Regional'],
      emailAddress: json['EmailAddress'],
      website: json['Website'],
      npwp: json['NPWP'],
      sppkp: json['SPPKP'],
      siup: json['SIUP'],
      ktp: json['KTP'],
      ktpAddress: json['KTPAddress'],
      currency: json['Currency'],
      priceGroup: json['PriceGroup'] ?? '',
      salesman: json['Salesman'],
      salesOffice: json['SalesOffice'] ?? '',
      businessUnit: json['BusinessUnit'] ?? '',
      custSubGroup: json['CustSubGroup'],
      notes: json['Notes'],
      fotoNPWP: json['FotoNPWP'],
      fotoKTP: json['FotoKTP'],
      fotoSIUP: json['FotoSIUP'],
      fotoGedung: json['FotoGedung'],
      fotoGedung1: json['FotoGedung1'],
      fotoGedung2: json['FotoGedung2'],
      fotoGedung3: json['FotoGedung3'],
      fotoCompetitorTop: json['FotoCompetitorTop'],
      custSignature: json['CustSignature'],
      salesSignature: json['SalesSignature'],
      approval1Signature: json['Approval1Signature'],
      approval2Signature: json['Approval2Signature'],
      approval3Signature: json['Approval3Signature'],
      imported: json['Imported'] ?? 0,
      longCoord: json['Long'],
      lat: json['Lat'],
      approval1: parseIntSafely(json['Approval1']),
      approval2: parseIntSafely(json['Approval2']),
      approval3: parseIntSafely(json['Approval3']),
      status: parseIntSafely(json['Status']),
      createdBy: parseIntSafely(json['CreatedBy']),
      remark: json['Remark'] ??
          json['Remarks'], // Handle both 'Remark' and 'Remarks'
      createdDate: json['CreatedDate'],
      approved1: json['Approved1'],
      approved2: json['Approved2'],
      approved3: json['Approved3'],
      companyAddresses: json['CompanyAddresses'] != null
          ? Address.fromJson(json['CompanyAddresses'])
          : null,
      deliveryAddresses: json['DeliveryAddresses'] != null
          ? Address.fromJson(json['DeliveryAddresses'])
          : null,
      taxAddresses: json['TaxAddresses'] != null
          ? Address.fromJson(json['TaxAddresses'])
          : null,
      paymentTerm: json['PaymentTerm'] ?? '',
      creditLimit: json['CreditLimit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'CustName': custName,
      'CustId': custId,
      'CustStatus': custStatus,
      'BrandName': brandName,
      'Category': category,
      'Category1': category1,
      'PaymMode': paymMode,
      'Segment': segment,
      'SubSegment': subSegment,
      'Class': classType,
      'PhoneNo': phoneNo,
      'CompanyStatus': companyStatus,
      'FaxNo': faxNo,
      'ContactPerson': contactPerson,
      'Regional': regional,
      'EmailAddress': emailAddress,
      'Website': website,
      'NPWP': npwp,
      'SPPKP': sppkp,
      'SIUP': siup,
      'KTP': ktp,
      'KTPAddress': ktpAddress,
      'Currency': currency,
      'PriceGroup': priceGroup,
      'Salesman': salesman,
      'SalesOffice': salesOffice,
      'BusinessUnit': businessUnit,
      'CustSubGroup': custSubGroup,
      'Notes': notes,
      'FotoNPWP': fotoNPWP,
      'FotoKTP': fotoKTP,
      'FotoSIUP': fotoSIUP,
      'FotoGedung': fotoGedung,
      'FotoGedung1': fotoGedung1,
      'FotoGedung2': fotoGedung2,
      'FotoGedung3': fotoGedung3,
      'FotoCompetitorTop': fotoCompetitorTop,
      'CustSignature': custSignature,
      'SalesSignature': salesSignature,
      'Approval1Signature': approval1Signature,
      'Approval2Signature': approval2Signature,
      'Approval3Signature': approval3Signature,
      'Imported': imported,
      'Long': longCoord,
      'Lat': lat,
      'Approval1': approval1,
      'Approval2': approval2,
      'Approval3': approval3,
      'Status': status,
      'CreatedBy': createdBy,
      'Remark': remark,
      'CreatedDate': createdDate,
      'Approved1': approved1,
      'Approved2': approved2,
      'Approved3': approved3,
      'CompanyAddresses': companyAddresses?.toJson(),
      'DeliveryAddresses': deliveryAddresses?.toJson(),
      'TaxAddresses': taxAddresses?.toJson(),
      'PaymentTerm': paymentTerm,
      'CreditLimit': creditLimit,
    };
  }

  String get companyAddressString {
    if (companyAddresses == null) return 'No address available';
    return companyAddresses!.getFullAddress();
  }

  String get deliveryAddressString {
    if (deliveryAddresses == null) return 'No address available';
    return deliveryAddresses!.getFullAddress();
  }

  String get taxAddressString {
    if (taxAddresses == null) return 'No address available';
    return taxAddresses!.getFullAddress();
  }
}

class Address {
  final int id;
  final String name;
  final String streetName;
  final String city;
  final String country;
  final String? kelurahan;
  final String? kecamatan;
  final String state;
  final int zipCode;
  final int? parentId;

  Address({
    required this.id,
    required this.name,
    required this.streetName,
    required this.city,
    required this.country,
    this.kelurahan,
    this.kecamatan,
    required this.state,
    required this.zipCode,
    this.parentId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int parseIntOrDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Address(
      id: parseIntOrDefault(json['id'], 0),
      name: json['Name'] ?? '',
      streetName: json['StreetName'] ?? '',
      city: json['City'] ?? '',
      country: json['Country'] ?? '',
      kelurahan: json['Kelurahan'],
      kecamatan: json['Kecamatan'],
      state: json['State'] ?? '',
      zipCode: parseIntOrDefault(json['ZipCode'], 0),
      parentId: parseIntNullable(json['ParentId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'StreetName': streetName,
      'City': city,
      'Country': country,
      'Kelurahan': kelurahan,
      'Kecamatan': kecamatan,
      'State': state,
      'ZipCode': zipCode,
      'ParentId': parentId,
    };
  }

  String getFullAddress() {
    List<String> addressParts = [];

    if (name.isNotEmpty) addressParts.add(name);
    if (streetName.isNotEmpty) addressParts.add(streetName);
    if (kelurahan != null && kelurahan!.isNotEmpty) {
      addressParts.add('Kel. $kelurahan');
    }
    if (kecamatan != null && kecamatan!.isNotEmpty) {
      addressParts.add('Kec. $kecamatan');
    }
    if (city.isNotEmpty) addressParts.add(city);
    if (state.isNotEmpty) addressParts.add(state);
    if (zipCode > 0) addressParts.add(zipCode.toString());
    if (country.isNotEmpty) addressParts.add(country);

    return addressParts.join(', ');
  }

  String getShortAddress() {
    List<String> addressParts = [];

    if (city.isNotEmpty) addressParts.add(city);
    if (state.isNotEmpty) addressParts.add(state);
    if (zipCode > 0) addressParts.add(zipCode.toString());

    return addressParts.join(', ');
  }
}

class PaymentTerm {
  final int id;
  final String paymTermId;
  final String desc;
  final int numOfDays;
  final String segment;

  PaymentTerm({
    required this.id,
    required this.paymTermId,
    required this.desc,
    required this.numOfDays,
    required this.segment,
  });

  factory PaymentTerm.fromJson(Map<String, dynamic> json) {
    return PaymentTerm(
      id: json['id'],
      paymTermId: json['PaymTermId'],
      desc: json['Desc'],
      numOfDays: json['NumOfDays'],
      segment: json['Segment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'PaymTermId': paymTermId,
      'Desc': desc,
      'NumOfDays': numOfDays,
      'Segment': segment,
    };
  }

  @override
  String toString() {
    return 'PaymentTerm{paymTermId: $paymTermId, desc: $desc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentTerm && other.paymTermId == paymTermId;
  }

  @override
  int get hashCode => paymTermId.hashCode;
}
