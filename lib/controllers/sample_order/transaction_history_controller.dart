import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/promotion_program/input_pp_wrapper.dart';
import 'package:noo_sms/models/feedback_detail.dart';
import 'package:noo_sms/models/id_valaue.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_dropdown_state.dart';
import 'package:noo_sms/models/state_management/promotion_program/input_pp_state.dart';
import 'package:noo_sms/models/transaction_history_sample.dart';
import 'package:noo_sms/models/upload_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide FormData;
import 'package:url_launcher/url_launcher.dart';

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
    try {
      final int? id = transactionHistory[index].id;
      final Map<String, dynamic> feedbackData = {
        "id": id,
        "feedback": feedList.value.selectedChoice?.id,
        "file": fileName.value,
        "notes": feedbackTextEditingControllerRx.value.text
      };
      final String feedbackJson = jsonEncode(feedbackData);

      var url = '$apiSCS/api/SampleTransaction';
      final response = await http.put(
        Uri.parse(url),
        body: feedbackJson,
        headers: {
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit feedback: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Rx<InputPageDropdownState<IdAndValue<String>>>
      promotionTypeInputPageDropdownStateRx =
      InputPageDropdownState<IdAndValue<String>>().obs;

  Future<void> refreshData() async {
    isLoading.value = true;
    await getTransactionHistory();
  }

  Future<void> getTransactionHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int idEmp = int.tryParse(prefs.getString("scs_idEmp") ?? '0') ?? 0;
    var urls = "$apiSCS/api/SampleTransaction/$idEmp";

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
    String url = "$apiSCS/api/SampleTransaction/detail?trx=$idTransaction";

    final response = await http.get(Uri.parse(url));
    final listData = jsonDecode(response.body);
    listDetail.value = listData['Product'];

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
    String uploadURL = "$apiSCS/api/uploadPOD/?salesid=$salesId";
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
      Map<String, dynamic> jsonObject;
      try {
        jsonObject = jsonDecode(response.data);
      } catch (e) {
        throw Exception('Failed to parse response as JSON: $e');
      }

      var objects = UploadFileResponse.fromJson(jsonObject);
      return objects;
    } else {
      throw Exception(
          'Failed to upload image with status code: ${response.statusCode}');
    }
  }

  Future<Uint8List?> fetchImagePOD(String salesId) async {
    dio.Dio dioClient = dio.Dio();
    String downloadURL = "$apiSCS/api/downloadPOD/?salesid=$salesId";
    try {
      dio.Response<List<int>> response = await dioClient.get<List<int>>(
        downloadURL,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _loadFeed() async {
    var urlGetDept = "$apiSCS/api/SampleFeedbackReasons";
    final response = await http.get(Uri.parse(urlGetDept));
    var listData = jsonDecode(response.body);

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
    final url = '$apiSCS/api/SampleFeedbackReasons/?salesid=$salesId';
    final response = await http.get(Uri.parse(url));

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
    String uploadURL = "$apiSCS/api/uploadFeedback/?salesid=$salesId";
    var response = await dioClient.post(uploadURL, data: formData);

    if (response.statusCode == 200) {
      Get.snackbar(
        "Success",
        "Image Successfully Uploaded",
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue.withOpacity(0.7),
        colorText: Colors.white,
      );
    } else {
      throw Exception(
          'Failed to upload image with status code: ${response.statusCode}');
    }
  }

  Future<Uint8List?> fetchImageFeed(String salesId) async {
    loadFeedVal2(salesId);
    dio.Dio dioClient = dio.Dio();
    String downloadURL = "$apiSCS/api/downloadFeedback/?salesid=$salesId";
    try {
      dio.Response<List<int>> response = await dioClient.get<List<int>>(
        downloadURL,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _openFolder(String path) async {
    if (Platform.isAndroid) {
      final uri = Uri.parse(
          'content://com.android.externalstorage.documents/document/primary:Download');
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
      } catch (e) {
        final directUri = Uri.parse('file:///storage/emulated/0/Download');
        try {
          await launchUrl(
            directUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint('Could not open folder: $e');
        }
      }
    } else {
      final directory = Directory(path).parent;
      final uri = Uri.file(directory.path);
      try {
        await launchUrl(uri);
      } catch (e) {
        debugPrint('Could not open folder: $e');
      }
    }
  }

  Future<void> _showDownloadSuccessDialog(
      BuildContext context, String filePath) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const Text(
                  'Download Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text('Your file has been downloaded successfully at'),
                const SizedBox(height: 10),
                Text(
                  filePath,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _openFolder(filePath);
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open Folder'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> downloadFile({
    required int salesId,
    required BuildContext context,
  }) async {
    if (!await _requestStoragePermission()) {
      _showSnackBar(
          context, 'Storage permission is required to download files');
      return false;
    }

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
      } else {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          _showSnackBar(
              context, 'Storage permission is required to download files');
          return false;
        }
      }
    }

    dio.Dio dioClient = dio.Dio();
    try {
      _showLoadingDialog(context);
      final downloadUrl = '$apiSCS/api/downloadAttachment?salesid=$salesId';

      Directory? downloadDirectory;
      String filePath = '';

      if (Platform.isAndroid) {
        try {
          downloadDirectory = await getExternalStorageDirectory();
          if (downloadDirectory == null) {
            throw Exception('Could not access external storage');
          }
          String? downloadPath;
          List<String> paths = downloadDirectory.path.split('/');
          int index = paths.indexOf('Android');
          if (index > 0) {
            paths = paths.sublist(0, index);
            downloadPath = paths.join('/') + '/Download';
          }

          if (downloadPath != null) {
            final dir = Directory(downloadPath);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            downloadDirectory = dir;
          }
        } catch (e) {
          debugPrint('Error accessing download directory: $e');
          // Fallback to app's directory
          downloadDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        downloadDirectory = await getApplicationDocumentsDirectory();
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('ddMMyyyy').format(now);
      final fileName = 'AX_${salesId}_$formattedDate.pdf';
      filePath = '${downloadDirectory.path}/$fileName';

      await dioClient.download(
        downloadUrl,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            HttpHeaders.acceptEncodingHeader: '*',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download Progress: $progress%');
          }
        },
      );

      if (!context.mounted) return true;
      Navigator.of(context).pop();
      await _showDownloadSuccessDialog(context, filePath);

      return true;
    } catch (e) {
      debugPrint('Download error: $e');
      if (!context.mounted) return false;
      Navigator.of(context).pop();

      _showSnackBar(context, 'Download failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }

      if (await Permission.manageExternalStorage.isRestricted) {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }

      return storageStatus.isGranted;
    }
    return true;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading...'),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<List<ApprovalInfo>> fetchApprovalInfo(int id) async {
    final response = await http.get(
      Uri.parse('$apiSCS/api/SampleApprovalInfo/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    debugPrint(response.body);
    debugPrint(Uri.parse('$apiSCS/api/SampleApprovalInfo/$id').toString());
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ApprovalInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load approval info');
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
