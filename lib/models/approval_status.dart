class ApprovalStatus {
  String? level;
  String? status;

  ApprovalStatus({this.level, this.status});

  factory ApprovalStatus.fromJson(Map<String, dynamic> json) {
    return ApprovalStatus(
      level: json['Level']?.toString().trim(),
      status: json['Status']?.toString().trim(),
    );
  }

  // A method to convert an ApprovalStatus object into JSON
  Map<String, dynamic> toJson() {
    return {
      'Level': level,
      'Status': status,
    };
  }
}
