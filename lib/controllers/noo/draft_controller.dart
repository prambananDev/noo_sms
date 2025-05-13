import 'package:get/get.dart';
import 'package:noo_sms/controllers/noo/customer_form_controller.dart';
import 'package:noo_sms/models/draft_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class DraftController extends GetxController {
  final store = intMapStoreFactory.store('listNOO');
  final RxList<DraftModel> drafts = <DraftModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    try {
      isLoading.value = true;
      var dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      var dbPath = join(dir.path, 'NOO.db');
      var db = await databaseFactoryIo.openDatabase(dbPath);

      final records = await store.find(db);
      drafts.value =
          records.map((record) => DraftModel.fromJson(record.value)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load drafts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDraft(CustomerFormController formController) async {
    try {
      isLoading.value = true;
      final draftData = DraftModel(
        custName: formController.customerNameController.text,
        brandName: formController.brandNameController.text,
        salesOffice: formController.selectedSalesOffice,
        customerGroup: formController.selectedCustomerGroup,
        businessUnit: formController.selectedBusinessUnit,
        category: formController.selectedCategory,
        category1: formController.selectedCategory1,
        regional: formController.selectedAXRegional,
        segment: formController.selectedSegment,
        subSegment: formController.selectedSubSegment,
        classField: formController.selectedClass,
        companyStatus: formController.selectedCompanyStatus,
        currency: formController.selectedCurrency,
        priceGroup: formController.selectedPriceGroup,
        paymMode: formController.selectedPaymentMode,
        contactPerson: formController.contactPersonController.text,
        ktp: formController.ktpController.text,
        ktpAddress: formController.ktpAddressController.text,
        npwp: formController.npwpController.text,
        phoneNo: formController.phoneController.text,
        faxNo: formController.faxController.text,
        emailAddress: formController.emailAddressController.text,
        website: formController.websiteController.text,
        fotoKTP: formController.imageKTP?.path,
        fotoNPWP: formController.imageNPWP?.path,
        fotoSIUP: formController.imageSIUP?.path,
        longitude: formController.longitudeControllerDelivery.text,
        latitude: formController.latitudeControllerDelivery.text,
        fotoGedung1: formController.imageBusinessPhotoFront?.path,
        fotoGedung2: formController.imageBusinessPhotoInside?.path,
        fotoGedung3: formController.imageSPPKP?.path,
        companyAddresses: {
          'Name': formController.companyNameController.text,
          'StreetName': formController.streetCompanyController.text,
          'Kelurahan': formController.kelurahanController.text,
          'Kecamatan': formController.kecamatanController.text,
          'City': formController.cityController.text,
          'State': formController.provinceController.text,
          'Country': formController.countryController.text,
          'ZipCode': int.tryParse(formController.zipCodeController.text) ?? 0,
        },
        taxAddresses: {
          'Name': formController.taxNameController.text,
          'StreetName': formController.taxStreetController.text,
        },
        deliveryAddresses: [
          {
            'Name': formController.deliveryNameController.text,
            'StreetName': formController.streetCompanyControllerDelivery.text,
            'Kelurahan': formController.kelurahanControllerDelivery.text,
            'Kecamatan': formController.kecamatanControllerDelivery.value.text,
            'City': formController.cityControllerDelivery.text,
            'State': formController.provinceControllerDelivery.text,
            'Country': formController.countryControllerDelivery.text,
            'ZipCode':
                int.tryParse(formController.zipCodeControllerDelivery.text) ??
                    0,
          },
          {
            'Name': formController.deliveryNameController2.text,
            'StreetName': formController.streetCompanyControllerDelivery2.text,
            'Kelurahan': formController.kelurahanControllerDelivery2.text,
            'Kecamatan': formController.kecamatanControllerDelivery2.value.text,
            'City': formController.cityControllerDelivery2.text,
            'State': formController.provinceControllerDelivery2.text,
            'Country': formController.countryControllerDelivery2.text,
            'ZipCode':
                int.tryParse(formController.zipCodeControllerDelivery2.text) ??
                    0,
          },
        ],
      );

      var dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      var dbPath = join(dir.path, 'NOO.db');
      var db = await databaseFactoryIo.openDatabase(dbPath);

      await store.add(db, draftData.toJson());
      Get.snackbar('Success', 'Draft saved successfully');
      await loadDrafts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save draft: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDraft(int id) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var dbPath = join(dir.path, 'NOO.db');
      var db = await databaseFactoryIo.openDatabase(dbPath);
      await store.record(id).delete(db);
      await loadDrafts();
      Get.snackbar('Success', 'Draft deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete draft: $e');
    }
  }
}
