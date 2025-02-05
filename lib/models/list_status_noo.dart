class NOOModel {
  final int id;
  final String custName;
  final String custId;
  final String custStatus;
  final String brandName;
  final String category;
  final String? category1;
  final String? paymentMode;
  final String segment;
  final String subSegment;
  final String classField;
  final String phoneNo;
  final String companyStatus;
  final String faxNo;
  final String contactPerson;
  final String? regional;
  final String emailAddress;
  final String website;
  final String npwp;
  final String? sppkp;
  final String? siup;
  final String ktp;
  final String? ktpAddress;
  final String currency;
  final String priceGroup;
  final String salesman;
  final String salesOffice;
  final String businessUnit;
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
  final String? long;
  final String? lat;
  final String approval1;
  final String approval2;
  final String approval3;
  final String status;
  final String createdBy;
  final String? remark;
  final String createdDate;
  final String? approved1;
  final String? approved2;
  final String? approved3;
  final CompanyAddress? companyAddresses;
  final DeliveryAddress? deliveryAddresses;
  final TaxAddress? taxAddresses;
  final String? paymentTerm;
  final String? creditLimit;

  NOOModel({
    required this.id,
    required this.custName,
    required this.custId,
    required this.custStatus,
    required this.brandName,
    required this.category,
    this.category1,
    this.paymentMode,
    required this.segment,
    required this.subSegment,
    required this.classField,
    required this.phoneNo,
    required this.companyStatus,
    required this.faxNo,
    required this.contactPerson,
    this.regional,
    required this.emailAddress,
    required this.website,
    required this.npwp,
    this.sppkp,
    this.siup,
    required this.ktp,
    this.ktpAddress,
    required this.currency,
    required this.priceGroup,
    required this.salesman,
    required this.salesOffice,
    required this.businessUnit,
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
    this.long,
    this.lat,
    required this.approval1,
    required this.approval2,
    required this.approval3,
    required this.status,
    required this.createdBy,
    this.remark,
    required this.createdDate,
    this.approved1,
    this.approved2,
    this.approved3,
    this.companyAddresses,
    this.deliveryAddresses,
    this.taxAddresses,
    this.paymentTerm,
    this.creditLimit,
  });

  factory NOOModel.fromJson(Map<String, dynamic> json) {
    return NOOModel(
      id: json['id'] ?? 0,
      custName: json['CustName']?.toString() ?? '',
      custId: json['CustId']?.toString() ?? '',
      custStatus: json['CustStatus']?.toString() ?? '',
      brandName: json['BrandName']?.toString() ?? '',
      category: json['Category']?.toString() ?? '',
      category1: json['Category1']?.toString(),
      paymentMode: json['PaymMode']?.toString(),
      segment: json['Segment']?.toString() ?? '',
      subSegment: json['SubSegment']?.toString() ?? '',
      classField: json['Class']?.toString() ?? '',
      phoneNo: json['PhoneNo']?.toString() ?? '',
      companyStatus: json['CompanyStatus']?.toString() ?? '',
      faxNo: json['FaxNo']?.toString() ?? '',
      contactPerson: json['ContactPerson']?.toString() ?? '',
      regional: json['Regional']?.toString(),
      emailAddress: json['EmailAddress']?.toString() ?? '',
      website: json['Website']?.toString() ?? '',
      npwp: json['NPWP']?.toString() ?? '',
      sppkp: json['SPPKP']?.toString(),
      siup: json['SIUP']?.toString(),
      ktp: json['KTP']?.toString() ?? '',
      ktpAddress: json['KTPAddress']?.toString(),
      currency: json['Currency']?.toString() ?? '',
      priceGroup: json['PriceGroup']?.toString() ?? '',
      salesman: json['Salesman']?.toString() ?? '',
      salesOffice: json['SalesOffice']?.toString() ?? '',
      businessUnit: json['BusinessUnit']?.toString() ?? '',
      notes: json['Notes']?.toString(),
      fotoNPWP: json['FotoNPWP']?.toString(),
      fotoKTP: json['FotoKTP']?.toString(),
      fotoSIUP: json['FotoSIUP']?.toString(),
      fotoGedung: json['FotoGedung']?.toString(),
      fotoGedung1: json['FotoGedung1']?.toString(),
      fotoGedung2: json['FotoGedung2']?.toString(),
      fotoGedung3: json['FotoGedung3']?.toString(),
      fotoCompetitorTop: json['FotoCompetitorTop']?.toString(),
      custSignature: json['CustSignature']?.toString(),
      salesSignature: json['SalesSignature']?.toString(),
      approval1Signature: json['Approval1Signature']?.toString(),
      approval2Signature: json['Approval2Signature']?.toString(),
      approval3Signature: json['Approval3Signature']?.toString(),
      imported: json['Imported'] ?? 0,
      long: json['Long']?.toString(),
      lat: json['Lat']?.toString(),
      approval1: json['Approval1']?.toString() ?? '',
      approval2: json['Approval2']?.toString() ?? '',
      approval3: json['Approval3']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
      createdBy: json['CreatedBy']?.toString() ?? '',
      remark: json['Remark']?.toString(),
      createdDate: json['CreatedDate']?.toString() ?? '',
      approved1: json['Approved1']?.toString(),
      approved2: json['Approved2']?.toString(),
      approved3: json['Approved3']?.toString(),
      companyAddresses: json['CompanyAddresses'] != null
          ? CompanyAddress.fromJson(json['CompanyAddresses'])
          : null,
      deliveryAddresses: json['DeliveryAddresses'] != null
          ? DeliveryAddress.fromJson(json['DeliveryAddresses'])
          : null,
      taxAddresses: json['TaxAddresses'] != null
          ? TaxAddress.fromJson(json['TaxAddresses'])
          : null,
      paymentTerm: json['PaymentTerm']?.toString(),
      creditLimit: json['CreditLimit']?.toString(),
    );
  }
}

class CompanyAddress {
  final int id;
  final String name;
  final String streetName;
  final String city;
  final String country;
  final String kelurahan;
  final String kecamatan;
  final String state;
  final int zipCode;
  final int parentId;

  CompanyAddress({
    required this.id,
    required this.name,
    required this.streetName,
    required this.city,
    required this.country,
    required this.kelurahan,
    required this.kecamatan,
    required this.state,
    required this.zipCode,
    required this.parentId,
  });

  factory CompanyAddress.fromJson(Map<String, dynamic> json) {
    return CompanyAddress(
      id: json['id'] ?? 0,
      name: json['Name']?.toString() ?? '',
      streetName: json['StreetName']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      country: json['Country']?.toString() ?? '',
      kelurahan: json['Kelurahan']?.toString() ?? '',
      kecamatan: json['Kecamatan']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      zipCode: int.tryParse(json['ZipCode']?.toString() ?? '0') ?? 0,
      parentId: json['ParentId'] ?? 0,
    );
  }
}

class DeliveryAddress {
  final int id;
  final String name;
  final String streetName;
  final String city;
  final String country;
  final String kelurahan;
  final String kecamatan;
  final String state;
  final int zipCode;
  final int parentId;

  DeliveryAddress({
    required this.id,
    required this.name,
    required this.streetName,
    required this.city,
    required this.country,
    required this.kelurahan,
    required this.kecamatan,
    required this.state,
    required this.zipCode,
    required this.parentId,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] ?? 0,
      name: json['Name']?.toString() ?? '',
      streetName: json['StreetName']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      country: json['Country']?.toString() ?? '',
      kelurahan: json['Kelurahan']?.toString() ?? '',
      kecamatan: json['Kecamatan']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      zipCode: int.tryParse(json['ZipCode']?.toString() ?? '0') ?? 0,
      parentId: json['ParentId'] ?? 0,
    );
  }
}

class TaxAddress {
  final int id;
  final String name;
  final String streetName;
  final String? city;
  final String? country;
  final String? state;
  final String? kelurahan;
  final String? kecamatan;
  final int? zipCode;
  final int parentId;

  TaxAddress({
    required this.id,
    required this.name,
    required this.streetName,
    this.city,
    this.country,
    this.state,
    this.kelurahan,
    this.kecamatan,
    this.zipCode,
    required this.parentId,
  });

  factory TaxAddress.fromJson(Map<String, dynamic> json) {
    return TaxAddress(
      id: json['id'] ?? 0,
      name: json['Name']?.toString() ?? '',
      streetName: json['StreetName']?.toString() ?? '',
      city: json['City']?.toString(),
      country: json['Country']?.toString(),
      state: json['State']?.toString(),
      kelurahan: json['Kelurahan']?.toString(),
      kecamatan: json['Kecamatan']?.toString(),
      zipCode: int.tryParse(json['ZipCode']?.toString() ?? '0'),
      parentId: json['ParentId'] ?? 0,
    );
  }
}
