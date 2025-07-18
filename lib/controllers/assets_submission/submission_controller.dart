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

  // Safe state update method that schedules updates after current build
  void _safeStateUpdate(VoidCallback updateCallback) {
    if (Get.isRegistered<AssetController>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateCallback();
      });
    } else {
      updateCallback();
    }
  }

  Future<void> fetchAssets(int page, int pageSize) async {
    try {
      _safeStateUpdate(() {
        isLoading.value = true;
        errorMessage.value = '';
      });

      List<Asset> fetchedAssets = await _repository.fetchAssets(page, pageSize);

      _safeStateUpdate(() {
        assets.value = fetchedAssets;
      });
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error fetching assets: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchAssetsHistory(int page, int pageSize) async {
    try {
      _safeStateUpdate(() {
        isLoading.value = true;
        errorMessage.value = '';
      });

      AssetHistory historyData =
          await _repository.fetchAssetsHistory(page, pageSize);

      _safeStateUpdate(() {
        assetsHistory.value = historyData.items;
      });
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error fetching assets: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchCustomers() async {
    try {
      _safeStateUpdate(() {
        isLoading.value = true;
      });

      var fetchedCustomers = await _repository.fetchCustomers();

      _safeStateUpdate(() {
        customers.value = fetchedCustomers;
      });
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error fetching customers: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchAssetAvail() async {
    try {
      _safeStateUpdate(() {
        isLoading.value = true;
      });

      var fetchAssetAvail = await _repository.fetchAssetAvail();

      _safeStateUpdate(() {
        assetAvail.value = fetchAssetAvail;
      });
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error fetching asset availability: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchAssetDetail(int id) async {
    try {
      _safeStateUpdate(() {
        isLoading.value = true;
        assetDetail.value = null;
      });

      var detail = await _repository.fetchAssetDetail(id);

      _safeStateUpdate(() {
        assetDetail.value = detail;
      });
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error fetching asset detail: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  Future<void> submitAssetLoan() async {
    try {
      if (selectedCustomerId.isEmpty ||
          selectedAssetId.value == 0 ||
          selectedDate.value == null ||
          keteranganController.text.isEmpty) {
        _safeStateUpdate(() {
          errorMessage.value = 'Semua field harus diisi';
        });
        return;
      }

      _safeStateUpdate(() {
        isSubmitting.value = true;
        errorMessage.value = '';
      });

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
        _safeStateUpdate(() {
          isSuccess.value = true;
        });
        clearForm();
        // Refresh the available assets list after successful submission
        await fetchAssetsHistory(1, 10);
      }
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error submitting loan: $e';
      });
    } finally {
      _safeStateUpdate(() {
        isSubmitting.value = false;
      });
    }
  }

  Future<void> submitAssetReturn(
    int assetId,
    String? tanggalPengembalian,
    BuildContext context,
  ) async {
    try {
      _safeStateUpdate(() {
        isSubmitting.value = true;
        errorMessage.value = '';
      });

      AssetReturn assetReturn = AssetReturn(
        assetId: assetId,
        tanggalPengembalian: tanggalPengembalian!,
      );

      bool result = await _repository.submitAssetReturn(assetReturn);

      if (result) {
        _safeStateUpdate(() {
          isSuccess.value = true;
        });
        clearForm();
        await fetchAssetAvail();

        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(
                content: Text('Asset return submitted successfully!')),
          );
        }

        await fetchAssetsHistory(1, 10);

        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _safeStateUpdate(() {
        errorMessage.value = 'Error submitting asset return: $e';
      });

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('Error submitting asset return: $e')),
        );
      }
    } finally {
      _safeStateUpdate(() {
        isSubmitting.value = false;
      });
    }
  }

  void clearForm() {
    selectedCustomerId.value = '';
    selectedAssetId.value = 0;
    selectedDate.value = null;
    keteranganController.text = '';
  }

  @override
  void onClose() {
    keteranganController.dispose();
    super.onClose();
  }
}
