import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/models/lines.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Promotion {
  dynamic id;
  String? nomorPP; // nullable if they can be null
  String? ppType;
  dynamic namePP;
  dynamic date;
  String? fromDate;
  String? toDate;
  dynamic group;
  String? idProduct;
  String? product;
  String? idCustomer;
  String? customer;
  dynamic salesman;
  dynamic qty;
  dynamic qtyTo;
  String? unitId;
  String? note;
  String? disc1;
  String? disc2;
  String? disc3;
  String? disc4;
  String? value1;
  String? value2;
  String? suppItem;
  String? suppUnit;
  String? warehouse;
  String? suppQty;
  String? salesOffice;
  dynamic businessUnit;
  String? price;
  String? totalAmount;
  bool? status; // nullable if they can be null
  dynamic codeError;
  dynamic message;
  dynamic listId;
  dynamic listLines;
  dynamic listPromotion;
  dynamic detailpromotion;
  String? axStatus;

  // Constructor
  Promotion({
    this.id,
    this.nomorPP,
    this.ppType,
    this.namePP,
    this.date,
    this.fromDate,
    this.toDate,
    this.group,
    this.idProduct,
    this.product,
    this.idCustomer,
    this.customer,
    this.salesman,
    this.qty,
    this.qtyTo,
    this.unitId,
    this.note,
    this.disc1,
    this.disc2,
    this.disc3,
    this.disc4,
    this.value1,
    this.value2,
    this.suppItem,
    this.suppUnit,
    this.warehouse,
    this.suppQty,
    this.salesOffice,
    this.businessUnit,
    this.price,
    this.totalAmount,
    this.status,
    this.codeError,
    this.message,
    this.listId,
    this.listLines,
    this.listPromotion,
    this.detailpromotion,
    this.axStatus,
  });

  Promotion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nomorPP = json['nomorPP'];
    ppType = json['type'];
    namePP = json['namePP'];
    date = json['date'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    group = json['group'];
    idProduct = json['idProduct'];
    product = json['product'];
    idCustomer = json['idCustomer'];
    customer = json['customer'];
    salesman = json['salesman'];
    qty = json['qty'];
    qtyTo = json['qtyTo'];
    unitId = json['unitId'];
    note = json['note'];
    disc1 = json['disc1'];
    disc2 = json['disc2'];
    disc3 = json['disc3'];
    disc4 = json['disc4'];
    value1 = json['value1'];
    value2 = json['value2'];
    suppItem = json['suppItem'];
    suppUnit = json['suppUnit'];
    warehouse = json['warehouse'];
    suppQty = json['suppQty'];
    salesOffice = json['salesOffice'];
    businessUnit = json['businessUnit'];
    price = json['price'];
    totalAmount = json['totalAmount'];
    status = json['status'];
    codeError = json['codeError'];
    message = json['message'];
    listId = json['listId'];
    listLines = json['listLines'];
    listPromotion = json['listPromosi'];
    detailpromotion = json['detailpromosi'];
    axStatus = json['AXStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nomorPP'] = nomorPP;
    data['type'] = ppType;
    data['namePP'] = namePP;
    data['date'] = date;
    data['fromDate'] = fromDate;
    data['toDate'] = toDate;
    data['group'] = group;
    data['idProduct'] = idProduct;
    data['product'] = product;
    data['idCustomer'] = idCustomer;
    data['customer'] = customer;
    data['salesman'] = salesman;
    data['qty'] = qty;
    data['qtyTo'] = qtyTo;
    data['unitId'] = unitId;
    data['note'] = note;
    data['disc1'] = disc1;
    data['disc2'] = disc2;
    data['disc3'] = disc3;
    data['disc4'] = disc4;
    data['value1'] = value1;
    data['value2'] = value2;
    data['suppItem'] = suppItem;
    data['suppUnit'] = suppUnit;
    data['warehouse'] = warehouse;
    data['suppQty'] = suppQty;
    data['salesOffice'] = salesOffice;
    data['businessUnit'] = businessUnit;
    data['price'] = price;
    data['totalAmount'] = totalAmount;
    data['status'] = status;
    data['codeError'] = codeError;
    data['message'] = message;
    data['listId'] = listId;
    data['listLines'] = listLines;
    data['listPromosi'] = listPromotion;
    data['detailpromosi'] = detailpromotion;
    data['AXStatus'] = axStatus;
    return data;
  }

  static Future<List<Promotion>> getListPromotion(
      int id, int code, String token, String username) async {
    // String url = ApiConstant(code).urlApi + "api/PromotionHeader/" + id.toString() + "?username=" + username;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        "$apiCons/api/PromosiHeader?username=${prefs.getString("username")}&userId=${prefs.getInt('userid')}";

    var dio = Dio();
    dio.options.headers['Authorization'] = token;
    Response response = await dio.get(url);
    var jsonObject = response.data;
    List<Promotion> models = [];
    for (var promotion in jsonObject) {
      var objects = Promotion.fromJson(promotion as Map<String, dynamic>);
      models.add(objects);
    }
    return models;
  }

  static Future<List<Promotion>> getListPromotionApproved(
      int id, int code, String token, String username) async {
    // String url = ApiConstant(code).urlApi + "api/PromotionHeader/" + id.toString() + "?username=" + username;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        "$apiCons/api/PromosiHeader?usernames=${prefs.getString("username")}&userIds=${prefs.getInt('userid')}";

    var dio = Dio();
    dio.options.headers['Authorization'] = token;
    Response response = await dio.get(url);
    var jsonObject = response.data;
    List<Promotion> models = [];
    for (var promotion in jsonObject) {
      var objects = Promotion.fromJson(promotion as Map<String, dynamic>);
      models.add(objects);
    }
    return models;
  }

  static Future<List<Promotion>> getAllListPromotion(
      int id, int code, String token, String username) async {
    // String url = ApiConstant(code).urlApi + "api/PromotionHeader/" + id.toString() + "?username=" + username;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        "$apiCons/api/Promosi?username=$username&userId=${prefs.getInt('userid')}";

    var dio = Dio();
    dio.options.headers['Authorization'] = token;
    Response response = await dio.get(url);
    var jsonObject = response.data;
    List<Promotion> models = [];
    for (var promotion in jsonObject) {
      var objects = Promotion.fromJson(promotion as Map<String, dynamic>);
      models.add(objects);
    }
    return models;
  }

  static Future<List<Promotion>> getListLines(
      String nomorPP, int code, String token, String username) async {
    final url = '$apiCons/api/PromosiLines/$nomorPP?username=$username';

    final dio = Dio()..options.headers['Authorization'] = token;
    final response = await dio.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to get list of lines');
    }

    final jsonObject = response.data;
    final promotionList = List<Promotion>.from(
        jsonObject.map((model) => Promotion.fromJson(model)));

    return promotionList;
  }

  static Future<List<Promotion>> getListLinesPending(
      String nomorPP, int code, String token, String username) async {
    final url = '$apiCons/api/PromosiLines/$nomorPP?username=$username&type=1';

    final dio = Dio()..options.headers['Authorization'] = token;
    final response = await dio.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to get list of lines');
    }

    // Extract the JSON data from the response
    final jsonObject = response.data;
    final promotionList = List<Promotion>.from(
        jsonObject.map((model) => Promotion.fromJson(model)));

    return promotionList;
  }

  static Future<List<Promotion>> getListActivity(
      String nomorPP, int code, String token, String username) async {
    final url = '$apiCons/api/PromosiLines/$nomorPP?username=$username';

    final dio = Dio()..options.headers['Authorization'] = token;
    final response = await dio.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to get list of lines');
    }

    // Extract the JSON data from the response
    final jsonObject = response.data;
    final promotionList = List<Promotion>.from(
        jsonObject.map((model) => Promotion.fromJson(model)));

    return promotionList;
  }

  // api/SalesOrder?idProduct={idProduct}&idCustomer={idCustomer}
  static Future<List<Promotion>> getListSalesOrder(String idProduct,
      String idCustomer, int code, String token, String username) async {
    String url =
        "$apiCons/api/SalesOrder?idProduct=$idProduct&idCustomer=$idCustomer&username=$username";

    var dio = Dio();
    dio.options.headers['Authorization'] = token;
    Response response = await dio.get(url);
    var jsonObject = response.data;
    List<Promotion> models = [];
    for (var salesOrder in jsonObject) {
      var objects = Promotion.fromJson(salesOrder as Map<String, dynamic>);
      models.add(objects);
    }
    return models;
  }

  // static Future<Promotion> approveSalesOrder(String nomorPP, int code) async {
  static Future<Promotion> approveSalesOrder(
      List<Lines> listLines, int code) async {
    String url = "$apiCons/api/PromosiHeader/";
    var dio = Dio();
    dio.options.headers['content-type'] = 'application/json';
    var jsonData = jsonEncode(
        {"listLines": listLines.map((f) => f.toJsonDisc()).toList()});

    var apiResult = await http.post(
      Uri.parse(url),
      body: jsonData,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    dynamic jsonObject = json.decode(apiResult.body);
    var data = jsonObject as Map<String, dynamic>;
    Promotion promotion = Promotion.fromJson(data);
    return promotion;
  }
}
