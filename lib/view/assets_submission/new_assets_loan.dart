import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/assets_submission/submission_controller.dart';
import 'package:search_choices/search_choices.dart';
import 'package:intl/intl.dart';

class NewAssetLoanPage extends StatefulWidget {
  const NewAssetLoanPage({Key? key}) : super(key: key);
  @override
  State<NewAssetLoanPage> createState() => _NewAssetLoanPage();
}

class _NewAssetLoanPage extends State<NewAssetLoanPage> {
  final AssetController _assetController = Get.find<AssetController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _assetController.fetchCustomers();
      _assetController.fetchAssetAvail();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Form Peminjaman Asset",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Customer:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(
            () {
              return SearchChoices.single(
                items: _assetController.customers.isEmpty
                    ? []
                    : _assetController.customers
                        .map((customer) => DropdownMenuItem<String>(
                              value: customer.accountNum,
                              child: Text(customer.custNameAlias),
                            ))
                        .toList(),
                value: _assetController.selectedCustomerId.isEmpty
                    ? null
                    : _assetController.selectedCustomerId.value,
                hint: "Pilih Customer",
                onChanged: (value) {
                  if (value != null) {
                    _assetController.selectedCustomerId.value = value as String;
                  }
                },
                isExpanded: true,
                dialogBox: true,
                displayClearIcon: true,
                menuBackgroundColor: colorNetral,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text("Asset:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(
            () {
              return SearchChoices.single(
                items: _assetController.assetAvail.isEmpty
                    ? []
                    : _assetController.assetAvail
                        .map((asset) => DropdownMenuItem<int>(
                              value: asset.id,
                              child: Text(asset.asset),
                            ))
                        .toList(),
                value: _assetController.selectedAssetId.value == 0
                    ? null
                    : _assetController.selectedAssetId.value,
                hint: "Pilih Data Asset",
                onChanged: (value) {
                  if (value != null) {
                    _assetController.selectedAssetId.value = value as int;
                  }
                },
                isExpanded: true,
                dialogBox: true,
                displayClearIcon: true,
                menuBackgroundColor: colorNetral,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text("Tanggal Peminjaman:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _assetController.selectedDate.value != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(_assetController.selectedDate.value!)
                        : "Pilih Tanggal",
                    style: TextStyle(
                      color: _assetController.selectedDate.value != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          const Text("Keterangan:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _assetController.keteranganController,
            decoration: InputDecoration(
              hintText: "Masukkan keterangan",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Obx(() => _assetController.errorMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _assetController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => _assetController.isSuccess.value
              ? const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Peminjaman asset berhasil disubmit!",
                    style: TextStyle(color: Colors.green),
                  ),
                )
              : const SizedBox.shrink()),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: colorAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() => GestureDetector(
                    onTap: _assetController.isSubmitting.value
                        ? null
                        : () => _assetController.submitAssetLoan(),
                    child: _assetController.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "Submit ",
                            style: TextStyle(
                              color: colorNetral,
                              fontSize: 16,
                            ),
                          ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _assetController.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _assetController.selectedDate.value = picked;
    }
  }
}
