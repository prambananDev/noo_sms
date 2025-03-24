class SfaRecord {
  final int? id;
  final int? type;
  final String? typeName;
  final int? employees;
  final String? fullName;
  final int? status;
  final String? statusName;
  final String? createdDate;
  final String? modifiedDate;
  final String? customer;
  final String? customerName;
  final String? contactTitle;
  final String? contactPerson;
  final String? contactNumber;
  final String? purpose;
  final String? purposeDesc;
  final String? result;
  final String? followup;
  final String? followupDate;
  final String? address;
  final String? checkIn;
  final String? checkOut;
  final String? checkInFoto;
  final int? prospect;
  final String? long;
  final String? lat;
  final String? createdBy;
  final String? employee;
  final SfaType? sfaType;

  SfaRecord({
    this.id,
    this.type,
    this.typeName,
    this.employees,
    this.fullName,
    this.status,
    this.statusName,
    this.createdDate,
    this.modifiedDate,
    this.customer,
    this.customerName,
    this.contactTitle,
    this.contactPerson,
    this.contactNumber,
    this.purpose,
    this.purposeDesc,
    this.result,
    this.followup,
    this.followupDate,
    this.address,
    this.checkIn,
    this.checkOut,
    this.checkInFoto,
    this.prospect,
    this.long,
    this.lat,
    this.createdBy,
    this.employee,
    this.sfaType,
  });

  factory SfaRecord.fromJson(Map<String, dynamic> json) {
    return SfaRecord(
      id: json['id'],
      type: json['type'],
      typeName: json['typeName'],
      employees: json['employees'],
      fullName: json['fullName'],
      status: json['status'],
      statusName: json['statusName'],
      createdDate: json['createdDate'],
      modifiedDate: json['modifiedDate'],
      customer: json['customer'],
      customerName: json['customerName'],
      contactTitle: json['contactTitle'],
      contactPerson: json['contactPerson'],
      contactNumber: json['contactNumber'],
      purpose: json['purpose'],
      purposeDesc: json['purposeDesc'],
      result: json['result'],
      followup: json['followup'],
      followupDate: json['followupDate'],
      address: json['address'],
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      checkInFoto: json['checkInFoto'],
      prospect: json['prospect'],
      long: json['long'],
      lat: json['lat'],
      createdBy: json['createdBy'],
      employee: json['employee'],
      sfaType:
          json['sfaType'] != null ? SfaType.fromJson(json['sfaType']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'typeName': typeName,
      'employees': employees,
      'fullName': fullName,
      'status': status,
      'statusName': statusName,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
      'customer': customer,
      'customerName': customerName,
      'contactTitle': contactTitle,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'purpose': purpose,
      'purposeDesc': purposeDesc,
      'result': result,
      'followup': followup,
      'followupDate': followupDate,
      'address': address,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'checkInFoto': checkInFoto,
      'prospect': prospect,
      'long': long,
      'lat': lat,
      'createdBy': createdBy,
      'employee': employee,
      'sfaType': sfaType?.toJson(),
    };
  }
}

// class Customer {
//   final String name;
//   final String accountNum;
//   final String contactDesc;
//   final String address;
//   final int type;

//   Customer({
//     required this.name,
//     required this.accountNum,
//     required this.contactDesc,
//     required this.address,
//     required this.type,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       name: json['CUSTNAME'],
//       accountNum: json['ACCOUNTNUM'],
//       contactDesc: json['CONTACTDESCRIPTION'] ?? '',
//       address: json['ADDRESS'],
//       type: json['TYPE'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'CUSTNAME': name,
//       'ACCOUNTNUM': accountNum,
//       'CONTACTDESCRIPTION': contactDesc,
//       'ADDRESS': address,
//       'TYPE': type,
//     };
//   }
// }

class VisitCustomer {
  final dynamic id;
  final String customerName;

  VisitCustomer({
    required this.id,
    required this.customerName,
  });

  factory VisitCustomer.fromJson(Map<String, dynamic> json) {
    return VisitCustomer(
      id: json['id'],
      customerName: json['CustomerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'CustomerName': customerName,
    };
  }
}

class VisitPurpose {
  final dynamic id;
  final String name;

  VisitPurpose({
    required this.id,
    required this.name,
  });

  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CustomerInfo {
  final String? name;
  final String? alias;
  final String? address;
  final String? contact;
  final String? contactNum;

  CustomerInfo({
    this.name,
    this.alias,
    this.address,
    this.contact,
    this.contactNum,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['CustName'],
      alias: json['CustAlias'],
      address: json['CustAddress'],
      contact: json['CustContact'],
      contactNum: json['CustContactNum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'alias': alias,
      'address': address,
      'contact': contact,
      'contactNum': contactNum,
    };
  }
}

class SfaType {
  final int id;
  final String name;

  SfaType({
    required this.id,
    required this.name,
  });

  factory SfaType.fromJson(Map<String, dynamic> json) {
    return SfaType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
