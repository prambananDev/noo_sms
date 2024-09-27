class ActivityEdit {
  List<ActivityLinesEdit>? activityLinesEdit;
  int? id;
  String? number;
  String? customerId;
  dynamic vendor;
  String? name;
  String? type;
  String? relation;
  String? date;
  String? location;
  String? statusKlaim;
  int? status;
  dynamic totalListing;
  dynamic totalPOListing;
  String? createdDate;
  String? createdBy;
  dynamic attachment;
  dynamic approve1;
  dynamic approve2;
  dynamic approve3;
  dynamic requirement;
  dynamic description;
  dynamic title;
  dynamic productId;
  dynamic approve1By;
  dynamic approve2By;
  dynamic approve3By;
  int? imported;
  String? bU;
  int? ack;
  dynamic vendId;
  int? testing;
  dynamic fromDate;
  dynamic toDate;
  int? notif;
  String? note;

  ActivityEdit(
      {this.activityLinesEdit,
      this.id,
      this.number,
      this.customerId,
      this.vendor,
      this.name,
      this.type,
      this.relation,
      this.date,
      this.location,
      this.statusKlaim,
      this.status,
      this.totalListing,
      this.totalPOListing,
      this.createdDate,
      this.createdBy,
      this.attachment,
      this.approve1,
      this.approve2,
      this.approve3,
      this.requirement,
      this.description,
      this.title,
      this.productId,
      this.approve1By,
      this.approve2By,
      this.approve3By,
      this.imported,
      this.bU,
      this.ack,
      this.vendId,
      this.testing,
      this.fromDate,
      this.toDate,
      this.notif,
      this.note});

  ActivityEdit.fromJson(Map<String, dynamic> json) {
    if (json['activityLines'] != null) {
      activityLinesEdit = <ActivityLinesEdit>[];
      json['activityLines'].forEach((v) {
        activityLinesEdit?.add(ActivityLinesEdit.fromJson(v));
      });
    }
    id = json['Id'];
    number = json['Number'];
    customerId = json['CustomerId'];
    vendor = json['Vendor'];
    name = json['Name'];
    type = json['Type'];
    relation = json['Relation'];
    date = json['Date'];
    location = json['Location'];
    statusKlaim = json['StatusKlaim'];
    status = json['Status'];
    totalListing = json['TotalListing'];
    totalPOListing = json['TotalPOListing'];
    createdDate = json['CreatedDate'];
    createdBy = json['CreatedBy'];
    attachment = json['Attachment'];
    approve1 = json['Approve1'];
    approve2 = json['Approve2'];
    approve3 = json['Approve3'];
    requirement = json['Requirement'];
    description = json['Description'];
    title = json['Title'];
    productId = json['ProductId'];
    approve1By = json['Approve1By'];
    approve2By = json['Approve2By'];
    approve3By = json['Approve3By'];
    imported = json['Imported'];
    bU = json['BU'];
    ack = json['Ack'];
    vendId = json['VendId'];
    testing = json['Testing'];
    fromDate = json['FromDate'];
    toDate = json['ToDate'];
    notif = json['Notif'];
    note = json['Note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final activityLinesEdit = this.activityLinesEdit;
    if (activityLinesEdit != null) {
      data['activityLines'] = activityLinesEdit.map((v) => v.toJson()).toList();
    }
    data['Id'] = id;
    data['Number'] = number;
    data['CustomerId'] = customerId;
    data['Vendor'] = vendor;
    data['Name'] = name;
    data['Type'] = type;
    data['Relation'] = relation;
    data['Date'] = date;
    data['Location'] = location;
    data['StatusKlaim'] = statusKlaim;
    data['Status'] = status;
    data['TotalListing'] = totalListing;
    data['TotalPOListing'] = totalPOListing;
    data['CreatedDate'] = createdDate;
    data['CreatedBy'] = createdBy;
    data['Attachment'] = attachment;
    data['Approve1'] = approve1;
    data['Approve2'] = approve2;
    data['Approve3'] = approve3;
    data['Requirement'] = requirement;
    data['Description'] = description;
    data['Title'] = title;
    data['ProductId'] = productId;
    data['Approve1By'] = approve1By;
    data['Approve2By'] = approve2By;
    data['Approve3By'] = approve3By;
    data['Imported'] = imported;
    data['BU'] = bU;
    data['Ack'] = ack;
    data['VendId'] = vendId;
    data['Testing'] = testing;
    data['FromDate'] = fromDate;
    data['ToDate'] = toDate;
    data['Notif'] = notif;
    data['Note'] = note;
    return data;
  }
}

class ActivityLinesEdit {
  int? id;
  String? headerNumber;
  dynamic relation;
  dynamic activityNumber;
  dynamic activityName;
  dynamic customerRelation;
  String? itemRelation;
  String? item;
  String? customer;
  dynamic custSegment;
  dynamic custSubSegment;
  double? minQty;
  double? qtyFrom;
  double? qtyTo;
  dynamic priceListing;
  dynamic total;
  String? unitID;
  String? fromDate;
  String? toDate;
  String? currency;
  dynamic percent1;
  dynamic percent2;
  dynamic percent3;
  dynamic percent4;
  dynamic value1;
  dynamic value2;
  String? suppItemOnlyOnce;
  String? suppItemId;
  dynamic suppItemQty;
  String? supplementaryUnitId;
  dynamic location;
  dynamic purchaseOrder;
  dynamic status;
  dynamic approval1;
  dynamic approval2;
  dynamic approval3;
  dynamic costRatio;
  dynamic parentId;
  dynamic brandId;
  dynamic imported;
  dynamic countCustomerID;
  dynamic estimatedPOAmount;
  int? typeClaim;
  dynamic description;
  dynamic listCustomer;
  dynamic keterangan;
  dynamic cost;
  dynamic quota;
  dynamic itemGroup;
  int? multiply;
  dynamic itemMultiDisc;
  String? warehouse;
  int? headerId;
  String? salesPrice;
  String? priceTo;

  ActivityLinesEdit(
      {this.id,
      this.headerNumber,
      this.relation,
      this.activityNumber,
      this.activityName,
      this.customerRelation,
      this.itemRelation,
      this.item,
      this.customer,
      this.custSegment,
      this.custSubSegment,
      this.minQty,
      this.qtyFrom,
      this.qtyTo,
      this.priceListing,
      this.total,
      this.unitID,
      this.fromDate,
      this.toDate,
      this.currency,
      this.percent1,
      this.percent2,
      this.percent3,
      this.percent4,
      this.value1,
      this.value2,
      this.suppItemOnlyOnce,
      this.suppItemId,
      this.suppItemQty,
      this.supplementaryUnitId,
      this.location,
      this.purchaseOrder,
      this.status,
      this.approval1,
      this.approval2,
      this.approval3,
      this.costRatio,
      this.parentId,
      this.brandId,
      this.imported,
      this.countCustomerID,
      this.estimatedPOAmount,
      this.typeClaim,
      this.description,
      this.listCustomer,
      this.keterangan,
      this.cost,
      this.quota,
      this.itemGroup,
      this.multiply,
      this.itemMultiDisc,
      this.warehouse,
      this.headerId,
      this.salesPrice,
      this.priceTo});

  ActivityLinesEdit.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    headerNumber = json['HeaderNumber'];
    relation = json['Relation'];
    activityNumber = json['ActivityNumber'];
    activityName = json['ActivityName'];
    customerRelation = json['CustomerRelation'];
    itemRelation = json['ItemRelation'];
    item = json['Item'];
    customer = json['Customer'];
    custSegment = json['CustSegment'];
    custSubSegment = json['CustSubSegment'];
    minQty = json['MinQty'];
    qtyFrom = json['QtyFrom'];
    qtyTo = json['QtyTo'];
    priceListing = json['PriceListing'];
    total = json['total'];
    unitID = json['UnitID'];
    fromDate = json['FromDate'];
    toDate = json['ToDate'];
    currency = json['Currency'];
    percent1 = json['Percent1'];
    percent2 = json['Percent2'];
    percent3 = json['Percent3'];
    percent4 = json['Percent4'];
    value1 = json['value1'];
    value2 = json['value2'];
    suppItemOnlyOnce = json['SuppItemOnlyOnce'];
    suppItemId = json['SuppItemId'];
    suppItemQty = json['SuppItemQty'];
    supplementaryUnitId = json['SupplementaryUnitId'];
    location = json['Location'];
    purchaseOrder = json['PurchaseOrder'];
    status = json['Status'];
    approval1 = json['Approval1'];
    approval2 = json['Approval2'];
    approval3 = json['Approval3'];
    costRatio = json['costRatio'];
    parentId = json['ParentId'];
    brandId = json['BrandId'];
    imported = json['Imported'];
    countCustomerID = json['CountCustomerID'];
    estimatedPOAmount = json['EstimatedPOAmount'];
    typeClaim = json['typeClaim'];
    description = json['description'];
    listCustomer = json['listCustomer'];
    keterangan = json['keterangan'];
    cost = json['cost'];
    quota = json['quota'];
    itemGroup = json['ItemGroup'];
    multiply = json['multiply'];
    itemMultiDisc = json['ItemMultiDisc'];
    warehouse = json['warehouse'];
    headerId = json['headerId'];
    salesPrice = json['salesPrice'];
    priceTo = json['priceTo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['HeaderNumber'] = headerNumber;
    data['Relation'] = relation;
    data['ActivityNumber'] = activityNumber;
    data['ActivityName'] = activityName;
    data['CustomerRelation'] = customerRelation;
    data['ItemRelation'] = itemRelation;
    data['Item'] = item;
    data['Customer'] = customer;
    data['CustSegment'] = custSegment;
    data['CustSubSegment'] = custSubSegment;
    data['MinQty'] = minQty;
    data['QtyFrom'] = qtyFrom;
    data['QtyTo'] = qtyTo;
    data['PriceListing'] = priceListing;
    data['total'] = total;
    data['UnitID'] = unitID;
    data['FromDate'] = fromDate;
    data['ToDate'] = toDate;
    data['Currency'] = currency;
    data['Percent1'] = percent1;
    data['Percent2'] = percent2;
    data['Percent3'] = percent3;
    data['Percent4'] = percent4;
    data['value1'] = value1;
    data['value2'] = value2;
    data['SuppItemOnlyOnce'] = suppItemOnlyOnce;
    data['SuppItemId'] = suppItemId;
    data['SuppItemQty'] = suppItemQty;
    data['SupplementaryUnitId'] = supplementaryUnitId;
    data['Location'] = location;
    data['PurchaseOrder'] = purchaseOrder;
    data['Status'] = status;
    data['Approval1'] = approval1;
    data['Approval2'] = approval2;
    data['Approval3'] = approval3;
    data['costRatio'] = costRatio;
    data['ParentId'] = parentId;
    data['BrandId'] = brandId;
    data['Imported'] = imported;
    data['CountCustomerID'] = countCustomerID;
    data['EstimatedPOAmount'] = estimatedPOAmount;
    data['typeClaim'] = typeClaim;
    data['description'] = description;
    data['listCustomer'] = listCustomer;
    data['keterangan'] = keterangan;
    data['cost'] = cost;
    data['quota'] = quota;
    data['ItemGroup'] = itemGroup;
    data['multiply'] = multiply;
    data['ItemMultiDisc'] = itemMultiDisc;
    data['warehouse'] = warehouse;
    data['headerId'] = headerId;
    data['salesPrice'] = salesPrice;
    data['priceTo'] = priceTo;
    return data;
  }
}
