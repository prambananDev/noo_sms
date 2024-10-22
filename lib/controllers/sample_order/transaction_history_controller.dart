import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/feedback_detail.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/transaction_history_sample.dart';
import 'package:noo_sms/models/upload_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide FormData;

class TransactionHistorySampleController extends GetxController {
  var transactionHistory = <TransactionHistorySample>[].obs;
  RxList listDetail = [].obs;

  var isLoading = false.obs;

  Rx<TextEditingController> feedbackTextEditingControllerRx =
      TextEditingController().obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> feedList =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<InputPageDropdownState<IdAndValue<String>>> feedVal =
      InputPageDropdownState<IdAndValue<String>>(
              choiceList: [], loadingState: 0)
          .obs;

  Rx<FeedbackDetail> feedbackDetail = FeedbackDetail(
    feedbackId: null,
    feedbackName: '',
    notes: '',
  ).obs;

  RxString fileName = ''.obs;

  final promotionProgramInputStateRx = InputPageWrapper(
    promotionProgramInputState: [],
    isAddItem: false,
  ).obs;

  final promotionProgramInputState = PromotionProgramInputState().obs;

  @override
  void onInit() {
    super.onInit();
    getTransactionHistory();
    _loadFeed();
  }

  Future<void> submitFeedback(int index) async {
    final int? id = transactionHistory[index].id;
    final Map<String, dynamic> feedbackData = {
      "id": id,
      "feedback": feedList.value.selectedChoice?.id,
      "file": fileName.value,
      "notes": feedbackTextEditingControllerRx.value.text
    };
    final String feedbackJson = jsonEncode(feedbackData);
    debugPrint("value $feedbackJson");
    var url = '$apiCons2/api/SampleTransaction';
    final response = await http.put(
      Uri.parse(url),
      body: feedbackJson,
      headers: {
        "Content-Type": "application/json",
      },
    );
    debugPrint("response status: ${response.statusCode}");
    debugPrint("response body: ${response.body}");
  }

  Rx<InputPageDropdownState<IdAndValue<String>>>
      promotionTypeInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  Future<void> getTransactionHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int idEmp = int.tryParse(prefs.getString("getIdEmp") ?? '0') ?? 0;
    var urls = "$apiCons2/api/SampleTransaction/$idEmp";
    debugPrint("idemp $idEmp");
    try {
      final response = await http.get(Uri.parse(urls));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List;
        transactionHistory.value = jsonResponse
            .map((data) => TransactionHistorySample.fromJson(data))
            .toList();
      } else {
        Get.snackbar('Error',
            'Failed to fetch transaction history: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception occurred: $e');
    }
  }

  getTransactionHistoryDetail(String idTransaction) async {
    String url = "$apiCons2/api/SampleTransaction/detail?trx=$idTransaction";
    final response = await http.get(Uri.parse(url));
    final listData = jsonDecode(response.body);
    listDetail.value = listData['Product'];
    print("cek listDetail = ${listDetail.value}");
    update();
  }

  Future<File> resizeImage(File file, int width, String salesId) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Unable to decode image");
    }

    int height = (width * image.height / image.width).round();
    img.Image resized = img.copyResize(image, width: width, height: height);
    final tempDir = await Directory.systemTemp.createTemp();
    final resizedPath = '${tempDir.path}/$salesId.jpg';
    final resizedFile = File(resizedPath);
    await resizedFile.writeAsBytes(img.encodeJpg(resized));
    fileName.value = resizedPath.split('/').last;
    return resizedFile;
  }

  Future<UploadFileResponse> uploadsPOD(
      String salesId, ImageSource imageSource) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    if (pickedFile == null) {
      throw Exception('No image selected.');
    }
    final resizedFile = await resizeImage(File(pickedFile.path), 1000, salesId);
    dio.Dio dioClient = dio.Dio();
    dio.FormData formData = dio.FormData.fromMap({
      "attachmentName": await dio.MultipartFile.fromFile(resizedFile.path,
          filename: resizedFile.path.split('/').last)
    });
    String uploadURL = "$apiCons2/api/uploadPOD/?salesid=$salesId";
    var response = await dioClient.post(uploadURL, data: formData);

    if (response.statusCode == 200) {
      await Future.delayed(const Duration(seconds: 1));
      await getTransactionHistory();

      Get.snackbar(
        "Success",
        "Image Successfully Uploaded",
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue.withOpacity(0.7),
        colorText: Colors.white,
      );
      var jsonObject;
      try {
        jsonObject = jsonDecode(response.data);
      } catch (e) {
        throw Exception('Failed to parse response as JSON: $e');
      }
      print("Success: $jsonObject");
      var objects =
          UploadFileResponse.fromJson(jsonObject as Map<String, dynamic>);
      return objects;
    } else {
      throw Exception(
          'Failed to upload image with status code: ${response.statusCode}');
    }
  }

  Future<Uint8List?> fetchImagePOD(String salesId) async {
    dio.Dio dioClient = dio.Dio();
    String downloadURL = "$apiCons2/api/downloadPOD/?salesid=$salesId";
    try {
      dio.Response<List<int>> response = await dioClient.get<List<int>>(
        downloadURL,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        print("Image data fetched successfully");
        return Uint8List.fromList(response.data!);
      } else {
        print("Failed to download image: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception when downloading image: $e");
      return null;
    }
  }

  void _loadFeed() async {
    var urlGetDept = "$apiCons2/api/SampleFeedbackReasons";
    final response = await http.get(Uri.parse(urlGetDept));
    var listData = jsonDecode(response.body);
    debugPrint(listData.toString());
    List<IdAndValue<String>> mappedList =
        listData.map<IdAndValue<String>>((element) {
      return IdAndValue<String>(
        id: element["id"].toString(),
        value: element["description"],
      );
    }).toList();
    feedList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: mappedList,
      selectedChoice: mappedList.isNotEmpty ? mappedList[0] : null,
      loadingState: 2,
    );

    _updateState();
  }

  Future<void> loadFeedVal2(String salesId) async {
    final url = '$apiCons2/api/SampleFeedbackReasons/?salesid=$salesId';
    final response = await http.get(Uri.parse(url));
    debugPrint("feedval2 ${response.body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          json.decode(response.body) as Map<String, dynamic>;
      feedbackDetail.value = FeedbackDetail.fromJson(jsonResponse);
    } else {
      feedbackDetail.value = FeedbackDetail(
        feedbackId: null,
        feedbackName: '',
        notes: '',
      );
    }
    _updateState();
  }

  void changeFeed(IdAndValue<String>? newValue) {
    feedList.value = InputPageDropdownState<IdAndValue<String>>(
      choiceList: feedList.value.choiceList,
      selectedChoice: newValue,
      loadingState: 2,
    );
  }

  Future<void> uploadsFeedImage(String salesId, File imageFile) async {
    final resizedFile = await resizeImage(imageFile, 1000, salesId);
    dio.Dio dioClient = dio.Dio();
    dio.FormData formData = dio.FormData.fromMap({
      "attachmentName": await dio.MultipartFile.fromFile(resizedFile.path,
          filename: resizedFile.path.split('/').last)
    });
    String uploadURL = "$apiCons2/api/uploadFeedback/?salesid=$salesId";
    var response = await dioClient.post(uploadURL, data: formData);

    if (response.statusCode == 200) {
      Get.snackbar(
        "Success",
        "Image Successfully Uploaded",
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue.withOpacity(0.7),
        colorText: Colors.white,
      );
      try {
        var jsonObject = jsonDecode(response.data);
        print("Success: $jsonObject");
      } catch (e) {
        print("Failed to parse response as JSON: $e");
        print("Response: ${response.data}");
      }
    } else {
      throw Exception(
          'Failed to upload image with status code: ${response.statusCode}');
    }
  }

  Future<Uint8List?> fetchImageFeed(String salesId) async {
    loadFeedVal2(salesId);
    dio.Dio dioClient = dio.Dio();
    String downloadURL = "$apiCons2/api/downloadFeedback/?salesid=$salesId";
    try {
      dio.Response<List<int>> response = await dioClient.get<List<int>>(
        downloadURL,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        print("Image data fetched successfully");
        return Uint8List.fromList(response.data!);
      } else {
        print("Failed to download image: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception when downloading image: $e");
      return null;
    }
  }

  void updateFeedbackDetail(String salesId, FeedbackDetail newDetail) {
    feedbackDetail.value = newDetail;
    feedbackDetail.refresh();
  }

  void _updateState() {
    promotionTypeInputPageDropdownStateRx
        .valueFromLast((value) => value.copy());
    promotionProgramInputStateRx.valueFromLast((value) => value.copy());
    update();
  }
}
