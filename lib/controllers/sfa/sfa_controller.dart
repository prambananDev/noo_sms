import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/constant/api_constant.dart';
import 'package:noo_sms/controllers/sfa/sfa_repo.dart';
import 'package:noo_sms/models/sfa_model.dart';
import 'package:noo_sms/view/dashboard/dashboard_sfa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class SfaController extends GetxController {
  final SfaRepository _repository = SfaRepository();

  final RxList<SfaRecord> sfaRecords = <SfaRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPhotoLoading = false.obs;

  final RxBool isLoadingCustomerInfo = false.obs;

  final RxString errorMessage = ''.obs;

  final RxBool isProspect = false.obs;
  final RxList<VisitCustomer> customers = <VisitCustomer>[].obs;
  final Rx<VisitCustomer?> selectedCustomer = Rx<VisitCustomer?>(null);
  final RxList<VisitPurpose> purpose = <VisitPurpose>[].obs;
  final Rx<VisitPurpose?> selectedPurpose = Rx<VisitPurpose?>(null);
  final Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);
  final Rx<File?> image = Rx<File?>(null);
  final RxString imageName = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isExisting = true.obs;
  final RxBool toggleExistingVal = false.obs;
  final RxBool photoUploaded = false.obs;
  final RxString uploadedPhotoName = ''.obs;

  final RxBool isCheckedIn = false.obs;
  final RxInt currentVisitId = RxInt(-1);

  final RxString username = ''.obs;
  final Map<bool, List<VisitCustomer>> _cachedCustomers = {false: [], true: []};
  final Map<bool, List<VisitPurpose>> _cachedPurpose = {false: [], true: []};

  final RxString selectedCustomerName = ''.obs;
  final RxString selectedCustomerId = ''.obs;
  final RxString currentLat = ''.obs;
  final RxString currentLong = ''.obs;

  TextEditingController purposeController = TextEditingController();
  TextEditingController resultsController = TextEditingController();
  TextEditingController followupController = TextEditingController();
  TextEditingController followupDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    getUserData();
    getCurrentLocation();
  }

  @override
  void onClose() {
    purposeController.dispose();
    resultsController.dispose();
    followupController.dispose();
    followupDateController.dispose();
    super.onClose();
  }

  void clearForm() {
    selectedCustomer.value = null;
    selectedCustomerName.value = '';
    selectedCustomerId.value = '';
    customerInfo.value = null;
    image.value = null;
    imageName.value = '';
    photoUploaded.value = false;
    uploadedPhotoName.value = '';
    isCheckedIn.value = false;
    currentVisitId.value = -1;

    purposeController.clear();
    resultsController.clear();
    followupController.clear();
    followupDateController.text = '';
  }

  Future<void> initializeData() async {
    try {
      isLoading.value = true;
      await getUserData();
      if (username.value.isNotEmpty) {
        await fetchSfaRecords();
      }
    } catch (e) {
      errorMessage.value = 'Failed to initialize: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      username.value = prefs.getString('username') ?? '';
      if (username.value.isNotEmpty) {
        await fetchSfaRecords();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Position position = await Geolocator.getCurrentPosition();
      currentLat.value =
          prefs.getString("getLatitude") ?? position.latitude.toString();

      currentLong.value =
          prefs.getString("getLongitude") ?? position.longitude.toString();
    } catch (e) {}
  }

  Future<void> fetchSfaRecords() async {
    if (username.value.isEmpty) {
      errorMessage.value = 'Employee ID not available';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final records = await _repository.fetchSfaRecords(username.value);

      sfaRecords.value = records;
    } catch (e) {
      errorMessage.value = 'Failed to load SFA records: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExisting(bool value) {
    toggleExistingVal.value = value;
    isExisting.value = !toggleExistingVal.value;

    selectedCustomer.value = null;
    selectedCustomerName.value = '';
    selectedCustomerId.value = '';
    customerInfo.value = null;

    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      if (_cachedCustomers[isExisting.value]!.isNotEmpty) {
        customers.value = _cachedCustomers[isExisting.value]!;
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final fetchedCustomers =
          await _repository.fetchCustomers(isExisting.value);

      _cachedCustomers[isExisting.value] = fetchedCustomers;

      customers.value = fetchedCustomers;
    } catch (e) {
      errorMessage.value = 'Failed to load customers';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPurpose() async {
    try {
      if (_cachedPurpose.containsKey(isExisting.value) &&
          _cachedPurpose[isExisting.value]!.isNotEmpty) {
        Future.microtask(() {
          purpose.value = _cachedPurpose[isExisting.value]!;
        });
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final fetchedPurpose = await _repository.fetchPurpose(isExisting.value);

      _cachedPurpose[isExisting.value] = fetchedPurpose;

      Future.microtask(() {
        purpose.value = fetchedPurpose;
        isLoading.value = false;
      });
    } catch (e) {
      errorMessage.value = 'Failed to load purpose data';
      isLoading.value = false;
    }
  }

  void saveSelectedCustomer(VisitCustomer customer) async {
    selectedCustomer.value = customer;
    selectedCustomerName.value = customer.customerName;
    selectedCustomerId.value = customer.id.toString();
    await fetchCustomerInfo();
  }

  Future<void> fetchCustomerInfo() async {
    try {
      isLoadingCustomerInfo.value = true;
      errorMessage.value = '';

      final info = await _repository.fetchCustInfo(selectedCustomerId.value);
      customerInfo.value = info;
    } catch (e) {
      errorMessage.value = 'Failed to load customers';
    } finally {
      isLoadingCustomerInfo.value = false;
    }
  }

  Future<void> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        image.value = File(photo.path);
        imageName.value = photo.name;

        Get.snackbar(
          'Photo Captured',
          'Tap Upload Photo to upload it to the server',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture photo: $e';
    }
  }

  Future<bool> uploadPhoto() async {
    if (image.value == null) {
      errorMessage.value = 'No photo selected';
      Get.snackbar(
        'Error',
        'Please take a photo first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    if (selectedCustomerId.value.isEmpty) {
      errorMessage.value = 'No customer selected';
      Get.snackbar(
        'Error',
        'Please select a customer first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final result =
          await _repository.uploadPhoto(image.value!, selectedCustomerId.value);

      uploadedPhotoName.value = result.photoName;
      photoUploaded.value = true;

      Get.snackbar(
        'Success',
        'Photo uploaded successfully! You can now check-in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to upload photo: $e';
      Get.snackbar(
        'Error',
        'Failed to upload photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        image.value = File(photo.path);
        imageName.value = photo.name;

        Get.snackbar(
          'Photo Selected',
          'Tap Upload Photo to upload it to the server',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to select photo: $e';
    }
  }

  Future<bool> submitCheckIn() async {
    try {
      if (!photoUploaded.value) {
        Get.snackbar(
          'Error',
          'Please upload a photo first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }

      if (customerInfo.value == null) {
        Get.snackbar(
          'Error',
          'Customer information is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }

      if (currentLat.value.isEmpty || currentLong.value.isEmpty) {
        await getCurrentLocation();
      }

      if (currentLat.value.isEmpty) currentLat.value = "0.0";
      if (currentLong.value.isEmpty) currentLong.value = "0.0";

      isSubmitting.value = true;

      Map<String, dynamic> checkInData = {
        "prospect": isExisting.value ? 0 : 1,
        "type": 1,
        "customer": selectedCustomerId.value,
        "customerName": selectedCustomerName.value,
        "contactTitle": customerInfo.value?.alias ?? "N/A",
        "address": customerInfo.value?.address ?? "",
        "contactPerson": customerInfo.value?.contact ?? "",
        "contactNumber": customerInfo.value?.contactNum ?? "",
        "purpose": purposeController.text,
        "results": resultsController.text,
        "followup": followupController.text,
        "followupDate": followupDateController.text,
        "checkInFoto": uploadedPhotoName.value,
        "long": currentLong.value,
        "lat": currentLat.value,
        "createdBy": username.value
      };

      final response = await _repository.submitCheckIn(checkInData);

      currentVisitId.value = response.visitId;
      isCheckedIn.value = true;

      Get.snackbar(
        'Success',
        'Check-in completed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 5),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to check-in: $e';
      Get.snackbar(
        'Error',
        'Failed to check-in: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> submitCheckOut(BuildContext context) async {
    try {
      if (currentVisitId.value <= 0) {
        Get.snackbar(
          'Error',
          'No active check-in found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }

      await getCurrentLocation();

      isSubmitting.value = true;

      Map<String, dynamic> checkOutData = {
        "id": currentVisitId.value,
        "prospect": isExisting.value ? 0 : 1,
        "type": selectedPurpose.value?.id ?? "NA",
        "customer": selectedCustomerId.value,
        "customerName": selectedCustomerName.value,
        "contactTitle": customerInfo.value?.alias ?? "N/A",
        "address": customerInfo.value?.address ?? "",
        "contactPerson": customerInfo.value?.contact ?? "",
        "contactNumber": customerInfo.value?.contactNum ?? "",
        "purpose": purposeController.text,
        "results": resultsController.text,
        "followup": followupController.text,
        "followupDate": followupDateController.text,
        "checkInFoto": uploadedPhotoName.value,
        "long": currentLong.value,
        "lat": currentLat.value,
        "createdBy": username.value
      };

      final success = await _repository.submitCheckOut(checkOutData);

      if (success) {
        Get.snackbar(
          'Success',
          'Check-out completed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 3),
        );

        await fetchSfaRecords();

        Navigator.pop(context);
        isCheckedIn.value = false;
        currentVisitId.value = -1;

        return true;
      } else {
        throw Exception('Failed to check-out');
      }
    } catch (e) {
      errorMessage.value = 'Failed to check-out: $e';
      Get.snackbar(
        'Error',
        'Failed to check-out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void loadRecordForEdit(SfaRecord record) async {
    selectedCustomerId.value = record.customer ?? "";
    selectedCustomerName.value = record.customerName ?? "";

    final bool hasCheckIn =
        record.checkIn != null && record.checkIn!.isNotEmpty;
    final bool hasCheckOut =
        record.checkOut != null && record.checkOut!.isNotEmpty;

    isCheckedIn.value = hasCheckIn && !hasCheckOut;

    if (record.id != null) {
      currentVisitId.value = record.id!;
    }

    if (record.checkInFoto != null && record.checkInFoto!.isNotEmpty) {
      uploadedPhotoName.value = record.checkInFoto!;

      isPhotoLoading.value = true;
      bool exists = await _repository.checkPhotoExists(uploadedPhotoName.value);
      isPhotoLoading.value = false;

      photoUploaded.value = exists;

      if (!exists) {
        uploadedPhotoName.value = '';
        Get.snackbar(
          'Photo Not Found',
          'The previously uploaded photo could not be found on the server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
      }
    }

    fetchCustomerInfo();
  }

  String formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    if (dateStr.contains('1900-01-01')) return '';

    try {
      DateTime dateTime;

      if (dateStr.contains('T')) {
        dateTime = DateTime.parse(dateStr);
      } else if (dateStr.contains('-') && dateStr.split('-')[0].length == 4) {
        final parts = dateStr.split('-');
        dateTime = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2].split(' ')[0]),
        );
      } else if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        dateTime = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return '';
      }

      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void setDefaultFollowupDate() {
    if (followupDateController.text.isEmpty) {
      followupDateController.text =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
  }

  String getPhotoUrl() {
    if (uploadedPhotoName.value.isEmpty) return '';
    return '$apiSMS/VisitCustomer/CheckIn?filename=${uploadedPhotoName.value}';
  }

  void clearCache() {
    _cachedCustomers[true] = [];
    _cachedCustomers[false] = [];
  }

  Future<void> refreshCustomers() async {
    _cachedCustomers[isExisting.value] = [];
    await fetchCustomers();
  }

  Future<void> refreshCustomerInfo() async {
    customerInfo.value = null;
    await fetchCustomerInfo();
  }
}
