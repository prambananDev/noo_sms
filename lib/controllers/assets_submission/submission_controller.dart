import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/assets_submission/submission_repo.dart';
import 'package:noo_sms/models/submission_model.dart';

class AssetController extends GetxController {
  final SubmissionRepository _repository = SubmissionRepository();

  RxList<Asset> assets = <Asset>[].obs;
  RxList<Item> assetsHistory = <Item>[].obs;
  RxList<Customer> customers = <Customer>[].obs;
  RxList<AssetAvail> assetAvail = <AssetAvail>[].obs;
  final assetDetail = Rx<AssetDetail?>(null);

  RxString selectedCustomerId = ''.obs;
  RxInt selectedAssetId = 0.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  TextEditingController keteranganController = TextEditingController();
  RxBool isSubmitting = false.obs;
  RxBool isSuccess = false.obs;

  RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  Future<void> fetchAssets(int page, int pageSize) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<Asset> fetchedAssets = await _repository.fetchAssets(page, pageSize);

      assets.value = fetchedAssets;
    } catch (e) {
      errorMessage.value = 'Error fetching assets: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAssetsHistory(int page, int pageSize) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AssetHistory historyData =
          await _repository.fetchAssetsHistory(page, pageSize);

      assetsHistory.value = historyData.items;
    } catch (e) {
      errorMessage.value = 'Error fetching assets: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      var fetchedCustomers = await _repository.fetchCustomers();
      customers.value = fetchedCustomers;
    } catch (e) {
      errorMessage.value = 'Error fetching customersz: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAssetAvail() async {
    try {
      isLoading(true);
      var fetchAssetAvail = await _repository.fetchAssetAvail();
      assetAvail.value = fetchAssetAvail;
    } catch (e) {
      errorMessage.value = 'Error fetching customers2: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAssetDetail(int id) async {
    try {
      isLoading(true);
      assetDetail.value = null;

      var detail = await _repository.fetchAssetDetail(id);
      assetDetail.value = detail;
    } catch (e) {
      errorMessage.value = 'Error fetching asset detail: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitAssetLoan() async {
    try {
      if (selectedCustomerId.isEmpty ||
          selectedAssetId.value == 0 ||
          selectedDate.value == null ||
          keteranganController.text.isEmpty) {
        errorMessage.value = 'Semua field harus diisi';
        return;
      }

      isSubmitting.value = true;
      errorMessage.value = '';

      String formattedDate =
          "${selectedDate.value!.month.toString().padLeft(2, '0')}/${selectedDate.value!.day.toString().padLeft(2, '0')}/${selectedDate.value!.year}";

      AssetLoan assetLoan = AssetLoan(
        customerId: selectedCustomerId.value,
        assetId: selectedAssetId.value,
        tanggalPeminjaman: formattedDate,
        keterangan: keteranganController.text,
      );

      bool result = await _repository.submitAssetLoan(assetLoan);

      if (result) {
        isSuccess.value = true;
        clearForm();
        // Refresh the available assets list after successful submission
        await fetchAssetsHistory(1, 10);
      }
    } catch (e) {
      errorMessage.value = 'Error submitting loan: $e';
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitAssetReturn(
    int assetId,
    String? tanggalPengembalian,
    BuildContext context,
  ) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      AssetReturn assetReturn = AssetReturn(
        assetId: assetId,
        tanggalPengembalian: tanggalPengembalian!,
      );

      bool result = await _repository.submitAssetReturn(assetReturn);

      if (result) {
        isSuccess.value = true;
        clearForm();
        await fetchAssetAvail();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('Asset return submitted successfully!')),
        );
        await fetchAssetsHistory(1, 10);
        if (!context.mounted) return;

        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage.value = 'Error submitting asset return: $e';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Error submitting asset return: $e')),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    selectedCustomerId.value = '';
    selectedAssetId.value = 0;
    selectedDate.value = null;
    keteranganController.text = '';
  }
}
