class SalesOrder {
  final int recId;
  final String salesId;
  final String custNameAlias;
  final String custName;
  final String custAccount;
  final String processDesc;
  final double dueAmount;
  final double salesAmount;
  final double salesAmountPpn;
  final double clAmt;
  final double creditExceedAmt;
  final int days;
  final String salesOffice;
  final String top;
  final String businessUnit;
  final String date;
  final String statusName;

  const SalesOrder({
    required this.recId,
    required this.salesId,
    required this.custNameAlias,
    required this.custName,
    required this.custAccount,
    required this.processDesc,
    required this.dueAmount,
    required this.salesAmount,
    required this.salesAmountPpn,
    required this.clAmt,
    required this.creditExceedAmt,
    required this.days,
    required this.salesOffice,
    required this.top,
    required this.businessUnit,
    required this.date,
    required this.statusName,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      recId: json['recid'] ?? 0,
      salesId: json['salesid'] ?? '',
      custNameAlias: json['custNameAlias'] ?? '',
      custName: json['custName'] ?? '',
      custAccount: json['custaccount'] ?? '',
      processDesc: json['processDesc'] ?? '',
      dueAmount: (json['dueamount'] ?? 0).toDouble(),
      salesAmount: (json['salesAmount'] ?? 0).toDouble(),
      salesAmountPpn: (json['salesAmountPpn'] ?? 0).toDouble(),
      clAmt: (json['clAmt'] ?? 0).toDouble(),
      creditExceedAmt: (json['creditexceedamt'] ?? 0).toDouble(),
      days: json['days'] ?? 0,
      salesOffice: json['wcsSalesoffice'] ?? '',
      top: json['top'] ?? '',
      businessUnit: json['wcsBusinessunit'] ?? '',
      date: _formatDate(json['date'] ?? ''),
      statusName: json['statusName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recid': recId,
      'salesid': salesId,
      'custNameAlias': custNameAlias,
      'custName': custName,
      'custaccount': custAccount,
      'processDesc': processDesc,
      'dueamount': dueAmount,
      'salesAmount': salesAmount,
      'salesAmountPpn': salesAmountPpn,
      'clAmt': clAmt,
      'creditexceedamt': creditExceedAmt,
      'days': days,
      'wcsSalesoffice': salesOffice,
      'top': top,
      'wcsBusinessunit': businessUnit,
      'date': date,
      'statusName': statusName,
    };
  }

  SalesOrder copyWith({
    int? recId,
    String? salesId,
    String? custNameAlias,
    String? custName,
    String? custAccount,
    String? processDesc,
    double? dueAmount,
    double? salesAmount,
    double? salesAmountPpn,
    double? clAmt,
    double? creditExceedAmt,
    int? days,
    String? salesOffice,
    String? top,
    String? businessUnit,
    String? date,
    String? statusName,
  }) {
    return SalesOrder(
      recId: recId ?? this.recId,
      salesId: salesId ?? this.salesId,
      custNameAlias: custNameAlias ?? this.custNameAlias,
      custName: custName ?? this.custName,
      custAccount: custAccount ?? this.custAccount,
      processDesc: processDesc ?? this.processDesc,
      dueAmount: dueAmount ?? this.dueAmount,
      salesAmount: salesAmount ?? this.salesAmount,
      salesAmountPpn: salesAmountPpn ?? this.salesAmountPpn,
      clAmt: clAmt ?? this.clAmt,
      creditExceedAmt: creditExceedAmt ?? this.creditExceedAmt,
      days: days ?? this.days,
      salesOffice: salesOffice ?? this.salesOffice,
      top: top ?? this.top,
      businessUnit: businessUnit ?? this.businessUnit,
      date: date ?? this.date,
      statusName: statusName ?? this.statusName,
    );
  }

  static String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  String toString() {
    return 'SalesOrder(recId: $recId, salesId: $salesId, custNameAlias: $custNameAlias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesOrder && other.recId == recId;
  }

  @override
  int get hashCode => recId.hashCode;
}

class SalesOrderDetail {
  final int recId;
  final String salesId;
  final String statusName;
  final String processDesc;
  final String date;
  final String submitter;
  final String userComments;
  final String approvalMessage;
  final int dueDays;
  final double dueAmount;
  final double creditExceedAmt;
  final double clAmt;
  final double clExcessPict;
  final String businessUnit;
  final String salesOffice;
  final String accountNum;
  final String custNameAlias;
  final String customerName;
  final String customerGroup;
  final String custCategory2;
  final String segment;
  final String priceGroup;
  final String paymentTermId;
  final double creditMax;
  final double salesAmount;
  final double salesAmountPpn;
  final int days;
  final String customerRef;

  const SalesOrderDetail({
    required this.recId,
    required this.salesId,
    required this.statusName,
    required this.processDesc,
    required this.date,
    required this.submitter,
    required this.userComments,
    required this.approvalMessage,
    required this.dueDays,
    required this.dueAmount,
    required this.creditExceedAmt,
    required this.clAmt,
    required this.clExcessPict,
    required this.businessUnit,
    required this.salesOffice,
    required this.accountNum,
    required this.custNameAlias,
    required this.customerName,
    required this.customerGroup,
    required this.custCategory2,
    required this.segment,
    required this.priceGroup,
    required this.paymentTermId,
    required this.creditMax,
    required this.salesAmount,
    required this.salesAmountPpn,
    required this.days,
    required this.customerRef,
  });

  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetail(
      recId: json['recid'] ?? 0,
      salesId: json['salesid'] ?? '',
      statusName: json['statusName'] ?? '',
      processDesc: json['processDesc'] ?? '',
      date: SalesOrder._formatDate(json['date'] ?? ''),
      submitter: json['submitter'] ?? '',
      userComments: json['usrcomments'] ?? '',
      approvalMessage: json['approvalmessage'] ?? '',
      dueDays: json['duedays'] ?? 0,
      dueAmount: (json['dueamount'] ?? 0).toDouble(),
      creditExceedAmt: (json['creditexceedamt'] ?? 0).toDouble(),
      clAmt: (json['clAmt'] ?? 0).toDouble(),
      clExcessPict: (json['clExcesspict'] ?? 0).toDouble(),
      businessUnit: json['wcsBusinessunit'] ?? '',
      salesOffice: json['wcsSalesoffice'] ?? '',
      accountNum: json['accountnum'] ?? '',
      custNameAlias: json['custnameAlias'] ?? '',
      customerName: json['customername'] ?? '',
      customerGroup: json['customerGroup'] ?? '',
      custCategory2: json['custCategory2'] ?? '',
      segment: json['segment'] ?? '',
      priceGroup: json['pricegroup'] ?? '',
      paymentTermId: json['paymtermid'] ?? '',
      creditMax: (json['creditMax'] ?? 0).toDouble(),
      salesAmount: 0.0,
      salesAmountPpn: 0.0,
      days: 0,
      customerRef: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recid': recId,
      'salesid': salesId,
      'statusName': statusName,
      'processDesc': processDesc,
      'date': date,
      'submitter': submitter,
      'usrcomments': userComments,
      'approvalmessage': approvalMessage,
      'duedays': dueDays,
      'dueamount': dueAmount,
      'creditexceedamt': creditExceedAmt,
      'clAmt': clAmt,
      'clExcesspict': clExcessPict,
      'wcsBusinessunit': businessUnit,
      'wcsSalesoffice': salesOffice,
      'accountnum': accountNum,
      'custnameAlias': custNameAlias,
      'customername': customerName,
      'customerGroup': customerGroup,
      'custCategory2': custCategory2,
      'segment': segment,
      'pricegroup': priceGroup,
      'paymtermid': paymentTermId,
      'creditMax': creditMax,
      'salesAmount': salesAmount,
      'salesAmountPpn': salesAmountPpn,
      'days': days,
      'customerRef': customerRef,
    };
  }

  SalesOrderDetail copyWith({
    int? recId,
    String? salesId,
    String? statusName,
    String? processDesc,
    String? date,
    String? submitter,
    String? userComments,
    String? approvalMessage,
    int? dueDays,
    double? dueAmount,
    double? creditExceedAmt,
    double? clAmt,
    double? clExcessPict,
    String? businessUnit,
    String? salesOffice,
    String? accountNum,
    String? custNameAlias,
    String? customerName,
    String? customerGroup,
    String? custCategory2,
    String? segment,
    String? priceGroup,
    String? paymentTermId,
    double? creditMax,
    double? salesAmount,
    double? salesAmountPpn,
    int? days,
    String? customerRef,
  }) {
    return SalesOrderDetail(
      recId: recId ?? this.recId,
      salesId: salesId ?? this.salesId,
      statusName: statusName ?? this.statusName,
      processDesc: processDesc ?? this.processDesc,
      date: date ?? this.date,
      submitter: submitter ?? this.submitter,
      userComments: userComments ?? this.userComments,
      approvalMessage: approvalMessage ?? this.approvalMessage,
      dueDays: dueDays ?? this.dueDays,
      dueAmount: dueAmount ?? this.dueAmount,
      creditExceedAmt: creditExceedAmt ?? this.creditExceedAmt,
      clAmt: clAmt ?? this.clAmt,
      clExcessPict: clExcessPict ?? this.clExcessPict,
      businessUnit: businessUnit ?? this.businessUnit,
      salesOffice: salesOffice ?? this.salesOffice,
      accountNum: accountNum ?? this.accountNum,
      custNameAlias: custNameAlias ?? this.custNameAlias,
      customerName: customerName ?? this.customerName,
      customerGroup: customerGroup ?? this.customerGroup,
      custCategory2: custCategory2 ?? this.custCategory2,
      segment: segment ?? this.segment,
      priceGroup: priceGroup ?? this.priceGroup,
      paymentTermId: paymentTermId ?? this.paymentTermId,
      creditMax: creditMax ?? this.creditMax,
      salesAmount: salesAmount ?? this.salesAmount,
      salesAmountPpn: salesAmountPpn ?? this.salesAmountPpn,
      days: days ?? this.days,
      customerRef: customerRef ?? this.customerRef,
    );
  }

  @override
  String toString() {
    return 'SalesOrderDetail(recId: $recId, salesId: $salesId, customerName: $customerName)';
  }
}

class ApprovalRequest {
  final int refRecId;
  final int status;
  final String comments;
  final String actionBy;
  final String documentNo;

  const ApprovalRequest({
    required this.refRecId,
    required this.status,
    required this.comments,
    required this.actionBy,
    required this.documentNo,
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      refRecId: json['RefRecid'] ?? 0,
      status: json['Status'] ?? 0,
      comments: json['Comments'] ?? '',
      actionBy: json['ActionBy'] ?? '',
      documentNo: json['DocumentNo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RefRecid': refRecId,
      'Status': status,
      'Comments': comments,
      'ActionBy': actionBy,
      'DocumentNo': documentNo,
    };
  }

  @override
  String toString() {
    return 'ApprovalRequest(refRecId: $refRecId, status: $status, documentNo: $documentNo)';
  }
}
