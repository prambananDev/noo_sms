class DraftModel {
  final String custName;
  final String brandName;
  final String? salesOffice;
  final String? customerGroup;
  final String? businessUnit;
  final String? category;
  final String? category1;
  final String? regional;
  final String? segment;
  final String? subSegment;
  final String? classField;
  final String? companyStatus;
  final String? currency;
  final String? priceGroup;
  final String? paymMode;
  final String? contactPerson;
  final String? ktp;
  final String? ktpAddress;
  final String? npwp;
  final String? phoneNo;
  final String? faxNo;
  final String? emailAddress;
  final String? website;
  final String? fotoKTP;
  final String? fotoNPWP;
  final String? fotoSIUP;
  final String? custSignature;
  final String? salesSignature;
  final String? longitude;
  final String? latitude;
  final String? fotoGedung1;
  final String? fotoGedung2;
  final String? fotoGedung3;
  final String? createdBy;
  final Map<String, dynamic>? companyAddresses;
  final Map<String, dynamic>? taxAddresses;
  final List<Map<String, dynamic>>? deliveryAddresses;

  DraftModel({
    required this.custName,
    required this.brandName,
    this.salesOffice,
    this.customerGroup,
    this.businessUnit,
    this.category,
    this.category1,
    this.regional,
    this.segment,
    this.subSegment,
    this.classField,
    this.companyStatus,
    this.currency,
    this.priceGroup,
    this.paymMode,
    this.contactPerson,
    this.ktp,
    this.ktpAddress,
    this.npwp,
    this.phoneNo,
    this.faxNo,
    this.emailAddress,
    this.website,
    this.fotoKTP,
    this.fotoNPWP,
    this.fotoSIUP,
    this.custSignature,
    this.salesSignature,
    this.longitude,
    this.latitude,
    this.fotoGedung1,
    this.fotoGedung2,
    this.fotoGedung3,
    this.createdBy,
    this.companyAddresses,
    this.taxAddresses,
    this.deliveryAddresses,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      custName: json['CustName'] ?? '',
      brandName: json['BrandName'] ?? '',
      salesOffice: json['SalesOffice'],
      customerGroup: json['CustSubGroup'],
      businessUnit: json['BusinessUnit'],
      category: json['Category'],
      category1: json['Category1'],
      regional: json['Regional'],
      segment: json['Segment'],
      subSegment: json['SubSegment'],
      classField: json['Class'],
      companyStatus: json['CompanyStatus'],
      currency: json['Currency'],
      priceGroup: json['PriceGroup'],
      paymMode: json['PaymMode'],
      contactPerson: json['ContactPerson'],
      ktp: json['KTP'],
      ktpAddress: json['KTPAddress'],
      npwp: json['NPWP'],
      phoneNo: json['PhoneNo'],
      faxNo: json['FaxNo'],
      emailAddress: json['EmailAddress'],
      website: json['Website'],
      fotoKTP: json['FotoKTP'],
      fotoNPWP: json['FotoNPWP'],
      fotoSIUP: json['FotoSIUP'],
      custSignature: json['CustSignature'],
      salesSignature: json['SalesSignature'],
      longitude: json['Long'],
      latitude: json['Lat'],
      fotoGedung1: json['FotoGedung1'],
      fotoGedung2: json['FotoGedung2'],
      fotoGedung3: json['FotoGedung3'],
      createdBy: json['CreatedBy'],
      companyAddresses: json['CompanyAddresses']?[0],
      taxAddresses: json['TaxAddresses']?[0],
      deliveryAddresses:
          List<Map<String, dynamic>>.from(json['DeliveryAddresses'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustName': custName,
      'BrandName': brandName,
      'SalesOffice': salesOffice,
      'BusinessUnit': businessUnit,
      'Category': category,
      'Category1': category1,
      'Regional': regional,
      'Segment': segment,
      'SubSegment': subSegment,
      'Class': classField,
      'CompanyStatus': companyStatus,
      'Currency': currency,
      'PriceGroup': priceGroup,
      'PaymMode': paymMode,
      'ContactPerson': contactPerson,
      'KTP': ktp,
      'KTPAddress': ktpAddress,
      'NPWP': npwp,
      'PhoneNo': phoneNo,
      'FaxNo': faxNo,
      'EmailAddress': emailAddress,
      'Website': website,
      'FotoKTP': fotoKTP,
      'FotoNPWP': fotoNPWP,
      'FotoSIUP': fotoSIUP,
      'CustSignature': custSignature,
      'SalesSignature': salesSignature,
      'Long': longitude,
      'Lat': latitude,
      'FotoGedung1': fotoGedung1,
      'FotoGedung2': fotoGedung2,
      'FotoGedung3': fotoGedung3,
      'CreatedBy': createdBy,
      'CompanyAddresses': [companyAddresses],
      'TaxAddresses': [taxAddresses],
      'DeliveryAddresses': deliveryAddresses,
    };
  }
}
