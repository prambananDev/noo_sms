import 'package:hive/hive.dart';

part 'noo_user.g.dart';

@HiveType(typeId: 2)
class SCSUser extends HiveObject {
  @HiveField(0)
  final String? idEmp;

  @HiveField(1)
  final String? idSales;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? wh;

  @HiveField(4)
  final String? token;

  SCSUser({
    this.idEmp,
    this.idSales,
    this.name,
    this.wh,
    this.token,
  });

  factory SCSUser.fromJson(Map<String, dynamic> json) {
    return SCSUser(
      idEmp: json['idEmp'],
      idSales: json['idSales'],
      name: json['name'],
      wh: json['wh'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmp': idEmp,
      'idSales': idSales,
      'name': name,
      'wh': wh,
      'token': token,
    };
  }
}
