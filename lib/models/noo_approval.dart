class ApprovalModel {
  final int? id;
  final String? custName;
  final String? custId;
  final String? custStatus;
  final String? brandName;
  final String? category;
  final String? category1;
  final String? paymMode;
  final String? segment;
  final String? subSegment;
  final String? classField;
  final String? phoneNo;
  final String? companyStatus;
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
  final String? priceGroup;
  final String? salesman;
  final String? salesOffice;
  final String? customerGroup;
  final String? businessUnit;
  final String? notes;
  final String? fotoNPWP;
  final String? fotoKTP;
  final String? fotoSIUP;
  final String? fotoGedung1;
  final String? fotoGedung2;
  final String? fotoGedung3;
  final String? fotoCompetitorTop;
  final String? custSignature;
  final String? salesSignature;
  final String? approval1Signature;
  final String? approval2Signature;
  final String? approval3Signature;
  final int? imported;
  final String? long;
  final String? lat;
  final String? approval1;
  final String? approval2;
  final String? approval3;
  final String? status;
  final String? createdBy;
  final String? remark;
  final DateTime? createdDate;
  final String? approved1;
  final String? approved2;
  final String? approved3;
  final Address? companyAddresses;
  final Address? deliveryAddresses;
  final Address? taxAddresses;
  final String? paymentTerm;
  final double? creditLimit;

  ApprovalModel({
    this.id,
    this.custName,
    this.custId,
    this.custStatus,
    this.brandName,
    this.category,
    this.category1,
    this.paymMode,
    this.segment,
    this.subSegment,
    this.classField,
    this.phoneNo,
    this.companyStatus,
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
    this.priceGroup,
    this.salesman,
    this.salesOffice,
    this.businessUnit,
    this.customerGroup,
    this.notes,
    this.fotoNPWP,
    this.fotoKTP,
    this.fotoSIUP,
    this.fotoGedung1,
    this.fotoGedung2,
    this.fotoGedung3,
    this.fotoCompetitorTop,
    this.custSignature,
    this.salesSignature,
    this.approval1Signature,
    this.approval2Signature,
    this.approval3Signature,
    this.imported,
    this.long,
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
    this.paymentTerm,
    this.creditLimit,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) => ApprovalModel(
        id: json['id'],
        custName: json['CustName'],
        custId: json['CustId'],
        custStatus: json['CustStatus'],
        brandName: json['BrandName'],
        category: json['Category'],
        category1: json['Category1'],
        paymMode: json['PaymMode'],
        segment: json['Segment'],
        subSegment: json['SubSegment'],
        classField: json['Class'],
        phoneNo: json['PhoneNo'],
        companyStatus: json['CompanyStatus'],
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
        priceGroup: json['PriceGroup'],
        salesman: json['Salesman'],
        salesOffice: json['SalesOffice'],
        businessUnit: json['BusinessUnit'],
        notes: json['Notes'],
        fotoNPWP: json['FotoNPWP'],
        fotoKTP: json['FotoKTP'],
        fotoSIUP: json['FotoSIUP'],
        fotoGedung1: json['FotoGedung1'],
        fotoGedung2: json['FotoGedung2'],
        fotoGedung3: json['FotoGedung3'],
        fotoCompetitorTop: json['FotoCompetitorTop'],
        custSignature: json['CustSignature'],
        salesSignature: json['SalesSignature'],
        approval1Signature: json['Approval1Signature'],
        approval2Signature: json['Approval2Signature'],
        approval3Signature: json['Approval3Signature'],
        imported: json['Imported'],
        long: json['Long'],
        lat: json['Lat'],
        approval1: json['Approval1'],
        approval2: json['Approval2'],
        approval3: json['Approval3'],
        status: json['Status'],
        customerGroup: json['CustSubGroup'],
        createdBy: json['CreatedBy'],
        remark: json['Remark'],
        createdDate: json['CreatedDate'] != null
            ? DateTime.parse(json['CreatedDate'])
            : null,
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
        paymentTerm: json['PaymentTerm'],
        creditLimit: _parseCreditLimit(json['CreditLimit']),
      );

  static double? _parseCreditLimit(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', ''));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
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
        'Class': classField,
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
        'Notes': notes,
        'FotoNPWP': fotoNPWP,
        'FotoKTP': fotoKTP,
        'FotoSIUP': fotoSIUP,
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
        'Long': long,
        'Lat': lat,
        'Approval1': approval1,
        'Approval2': approval2,
        'Approval3': approval3,
        'Status': status,
        'CreatedBy': createdBy,
        'Remark': remark,
        'CreatedDate': createdDate?.toIso8601String(),
        'Approved1': approved1,
        'Approved2': approved2,
        'Approved3': approved3,
        'CompanyAddresses': companyAddresses?.toJson(),
        'DeliveryAddresses': deliveryAddresses?.toJson(),
        'TaxAddresses': taxAddresses?.toJson(),
        'PaymentTerm': paymentTerm,
        'CreditLimit': creditLimit,
      };

  ApprovalModel copyWith({
    int? id,
    String? custName,
    String? custId,
    String? custStatus,
    String? brandName,
    String? category,
    String? category1,
    String? paymMode,
    String? segment,
    String? subSegment,
    String? classField,
    String? phoneNo,
    String? companyStatus,
    String? faxNo,
    String? contactPerson,
    String? regional,
    String? emailAddress,
    String? website,
    String? npwp,
    String? sppkp,
    String? siup,
    String? ktp,
    String? ktpAddress,
    String? currency,
    String? priceGroup,
    String? salesman,
    String? salesOffice,
    String? businessUnit,
    String? notes,
    String? fotoNPWP,
    String? fotoKTP,
    String? fotoSIUP,
    String? fotoGedung,
    String? fotoGedung1,
    String? fotoGedung2,
    String? fotoGedung3,
    String? fotoCompetitorTop,
    String? custSignature,
    String? salesSignature,
    String? approval1Signature,
    String? approval2Signature,
    String? approval3Signature,
    int? imported,
    String? long,
    String? lat,
    String? approval1,
    String? approval2,
    String? approval3,
    String? status,
    String? createdBy,
    String? remark,
    DateTime? createdDate,
    String? approved1,
    String? approved2,
    String? approved3,
    Address? companyAddresses,
    Address? deliveryAddresses,
    Address? taxAddresses,
    String? paymentTerm,
    double? creditLimit,
  }) =>
      ApprovalModel(
        id: id ?? this.id,
        custName: custName ?? this.custName,
        custId: custId ?? this.custId,
        custStatus: custStatus ?? this.custStatus,
        brandName: brandName ?? this.brandName,
        category: category ?? this.category,
        category1: category1 ?? this.category1,
        paymMode: paymMode ?? this.paymMode,
        segment: segment ?? this.segment,
        subSegment: subSegment ?? this.subSegment,
        classField: classField ?? this.classField,
        phoneNo: phoneNo ?? this.phoneNo,
        companyStatus: companyStatus ?? this.companyStatus,
        faxNo: faxNo ?? this.faxNo,
        contactPerson: contactPerson ?? this.contactPerson,
        regional: regional ?? this.regional,
        emailAddress: emailAddress ?? this.emailAddress,
        website: website ?? this.website,
        npwp: npwp ?? this.npwp,
        sppkp: sppkp ?? this.sppkp,
        siup: siup ?? this.siup,
        ktp: ktp ?? this.ktp,
        ktpAddress: ktpAddress ?? this.ktpAddress,
        currency: currency ?? this.currency,
        priceGroup: priceGroup ?? this.priceGroup,
        salesman: salesman ?? this.salesman,
        salesOffice: salesOffice ?? this.salesOffice,
        businessUnit: businessUnit ?? this.businessUnit,
        notes: notes ?? this.notes,
        fotoNPWP: fotoNPWP ?? this.fotoNPWP,
        fotoKTP: fotoKTP ?? this.fotoKTP,
        fotoSIUP: fotoSIUP ?? this.fotoSIUP,
        fotoGedung1: fotoGedung1 ?? this.fotoGedung1,
        fotoGedung2: fotoGedung2 ?? this.fotoGedung2,
        fotoGedung3: fotoGedung3 ?? this.fotoGedung3,
        fotoCompetitorTop: fotoCompetitorTop ?? this.fotoCompetitorTop,
        custSignature: custSignature ?? this.custSignature,
        salesSignature: salesSignature ?? this.salesSignature,
        approval1Signature: approval1Signature ?? this.approval1Signature,
        approval2Signature: approval2Signature ?? this.approval2Signature,
        approval3Signature: approval3Signature ?? this.approval3Signature,
        imported: imported ?? this.imported,
        long: long ?? this.long,
        lat: lat ?? this.lat,
        approval1: approval1 ?? this.approval1,
        approval2: approval2 ?? this.approval2,
        approval3: approval3 ?? this.approval3,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        remark: remark ?? this.remark,
        createdDate: createdDate ?? this.createdDate,
        approved1: approved1 ?? this.approved1,
        approved2: approved2 ?? this.approved2,
        approved3: approved3 ?? this.approved3,
        companyAddresses: companyAddresses ?? this.companyAddresses,
        deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
        taxAddresses: taxAddresses ?? this.taxAddresses,
        paymentTerm: paymentTerm ?? this.paymentTerm,
        creditLimit: creditLimit ?? this.creditLimit,
      );
}

class Address {
  final int? id;
  final String? name;
  final String? streetName;
  final String? city;
  final String? country;
  final String? kelurahan;
  final String? kecamatan;
  final String? state;
  final int? zipCode;
  final int? parentId;

  Address({
    this.id,
    this.name,
    this.streetName,
    this.city,
    this.country,
    this.kelurahan,
    this.kecamatan,
    this.state,
    this.zipCode,
    this.parentId,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        name: json['Name'],
        streetName: json['StreetName'],
        city: json['City'],
        country: json['Country'],
        kelurahan: json['Kelurahan'],
        kecamatan: json['Kecamatan'],
        state: json['State'],
        zipCode: json['ZipCode'],
        parentId: json['ParentId'],
      );

  Map<String, dynamic> toJson() => {
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

  Address copyWith({
    int? id,
    String? name,
    String? streetName,
    String? city,
    String? country,
    String? kelurahan,
    String? kecamatan,
    String? state,
    int? zipCode,
    int? parentId,
  }) =>
      Address(
        id: id ?? this.id,
        name: name ?? this.name,
        streetName: streetName ?? this.streetName,
        city: city ?? this.city,
        country: country ?? this.country,
        kelurahan: kelurahan ?? this.kelurahan,
        kecamatan: kecamatan ?? this.kecamatan,
        state: state ?? this.state,
        zipCode: zipCode ?? this.zipCode,
        parentId: parentId ?? this.parentId,
      );

  @override
  String toString() {
    return 'Address(id: $id, name: $name, streetName: $streetName, city: $city, country: $country, '
        'kelurahan: $kelurahan, kecamatan: $kecamatan, state: $state, zipCode: $zipCode, '
        'parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address &&
        other.id == id &&
        other.name == name &&
        other.streetName == streetName &&
        other.city == city &&
        other.country == country &&
        other.kelurahan == kelurahan &&
        other.kecamatan == kecamatan &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        streetName.hashCode ^
        city.hashCode ^
        country.hashCode ^
        kelurahan.hashCode ^
        kecamatan.hashCode ^
        state.hashCode ^
        zipCode.hashCode ^
        parentId.hashCode;
  }
}
