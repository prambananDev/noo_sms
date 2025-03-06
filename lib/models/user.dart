import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? username;

  @HiveField(2)
  final String? Username;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? fullname;

  @HiveField(5)
  final String? token;

  @HiveField(6)
  final String? message;

  @HiveField(7)
  final int? code;

  @HiveField(8)
  final dynamic so;

  @HiveField(9)
  final String? bu;

  @HiveField(10)
  final dynamic SO;

  @HiveField(11)
  final String? BU;

  @HiveField(12)
  final String? role;

  @HiveField(13)
  final int? editApproval;

  @HiveField(14)
  final int? approvalRole;

  User({
    this.id,
    this.username,
    this.Username,
    this.password,
    this.fullname,
    this.token,
    this.message,
    this.code,
    this.so,
    this.bu,
    this.SO,
    this.BU,
    this.role,
    this.editApproval,
    this.approvalRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      Username: json['Username'],
      password: json['password'],
      fullname: json['fullname'],
      token: json['token'],
      message: json['message'],
      code: json['code'],
      so: json['so'],
      bu: json['bu'] ?? json['BU'],
      SO: json['SO'],
      BU: json['BU'],
      role: json['Role'] ?? json['role'],
      editApproval: json['EditApproval'],
      approvalRole: json['ApprovalRole'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'Username': Username,
      'fullname': fullname,
      'token': token,
      'message': message,
      'code': code,
      'so': so,
      'bu': bu,
      'SO': SO,
      'BU': BU,
      'role': role,
      'editApproval': editApproval,
      'approvalRole': approvalRole,
    };
  }
}
