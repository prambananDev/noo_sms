import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
        padding: EdgeInsets.all(16.rp(context)),
        controller: _scrollController,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.rp(context),
        vertical: 8.rp(context),
      ),
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.rs(context),
            spreadRadius: 1.rs(context),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Form Peminjaman Asset",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.rt(context),
              ),
            ),
          ),
          SizedBox(height: 16.rs(context)),
          Text(
            "Customer:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.rt(context),
            ),
          ),
          SizedBox(height: 8.rs(context)),
          Obx(
            () {
              return SearchChoices.single(
                items: _assetController.customers.isEmpty
                    ? []
                    : _assetController.customers
                        .map((customer) => DropdownMenuItem<String>(
                              value: customer.accountNum,
                              child: Text(
                                customer.custNameAlias,
                                style: TextStyle(fontSize: 14.rt(context)),
                              ),
                            ))
                        .toList(),
                value: _assetController.selectedCustomerId.isEmpty
                    ? null
                    : _assetController.selectedCustomerId.value,
                hint: Text(
                  "Pilih Customer",
                  style: TextStyle(fontSize: 14.rt(context)),
                ),
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
          SizedBox(height: 16.rs(context)),
          Text(
            "Asset:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.rt(context),
            ),
          ),
          SizedBox(height: 8.rs(context)),
          Obx(
            () {
              return SearchChoices.single(
                items: _assetController.assetAvail.isEmpty
                    ? []
                    : _assetController.assetAvail
                        .map((asset) => DropdownMenuItem<int>(
                              value: asset.id,
                              child: Text(
                                asset.asset,
                                style: TextStyle(fontSize: 14.rt(context)),
                              ),
                            ))
                        .toList(),
                value: _assetController.selectedAssetId.value == 0
                    ? null
                    : _assetController.selectedAssetId.value,
                hint: Text(
                  "Pilih Data Asset",
                  style: TextStyle(fontSize: 14.rt(context)),
                ),
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
          SizedBox(height: 16.rs(context)),
          Text(
            "Tanggal Peminjaman:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.rt(context),
            ),
          ),
          SizedBox(height: 8.rs(context)),
          Obx(() => InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.rp(context),
                    vertical: 15.rp(context),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.rr(context)),
                  ),
                  child: Text(
                    _assetController.selectedDate.value != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(_assetController.selectedDate.value!)
                        : "Pilih Tanggal",
                    style: TextStyle(
                      fontSize: 14.rt(context),
                      color: _assetController.selectedDate.value != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              )),
          SizedBox(height: 16.rs(context)),
          Text(
            "Keterangan:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.rt(context),
            ),
          ),
          SizedBox(height: 8.rs(context)),
          TextField(
            controller: _assetController.keteranganController,
            style: TextStyle(fontSize: 14.rt(context)),
            decoration: InputDecoration(
              hintText: "Masukkan keterangan",
              hintStyle: TextStyle(fontSize: 14.rt(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.rr(context)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.rp(context),
                vertical: 12.rp(context),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 24.rs(context)),
          Obx(() => _assetController.errorMessage.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(bottom: 16.rs(context)),
                  child: Text(
                    _assetController.errorMessage.value,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.rt(context),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => _assetController.isSuccess.value
              ? Padding(
                  padding: EdgeInsets.only(bottom: 16.rs(context)),
                  child: Text(
                    "Peminjaman asset berhasil disubmit!",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14.rt(context),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: colorAccent,
                borderRadius: BorderRadius.circular(12.rr(context)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.rp(context),
                vertical: 8.rp(context),
              ),
              child: Obx(() => GestureDetector(
                    onTap: _assetController.isSubmitting.value
                        ? null
                        : () => _assetController.submitAssetLoan(),
                    child: _assetController.isSubmitting.value
                        ? SizedBox(
                            height: 20.rs(context),
                            width: 20.rs(context),
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "Submit ",
                            style: TextStyle(
                              color: colorNetral,
                              fontSize: 16.rt(context),
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
