import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/assets_submission/submission_controller.dart';

class AssetReturnPage extends StatelessWidget {
  final int id;
  final String assetName;
  final String customerName;
  final String loanDate;
  final String? tanggalDiterima;
  final String? tanggalPengembalian;
  final String? notes;

  const AssetReturnPage({
    super.key,
    required this.id,
    required this.assetName,
    required this.customerName,
    required this.loanDate,
    this.tanggalDiterima,
    this.tanggalPengembalian,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController tanggalDiterimaController =
        TextEditingController(text: '');
    TextEditingController tanggalPengembalianController =
        TextEditingController(text: '');
    TextEditingController keteranganController =
        TextEditingController(text: '');

    if (notes != null && notes!.isNotEmpty) {
      keteranganController.text = notes!;
    }

    tanggalDiterimaController.text =
        tanggalDiterima?.isNotEmpty == true ? tanggalDiterima! : '-';

    if (tanggalPengembalian != null && tanggalPengembalian!.isNotEmpty) {
      tanggalPengembalianController.text = tanggalPengembalian!;
    }

    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.only(
          left: 16.rp(context),
          right: 16.rp(context),
          top: 56.rs(context),
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.rp(context)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asset : $assetName',
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.rs(context)),
                    Text(
                      'Customer : $customerName',
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.rs(context)),
                    Text(
                      'Tanggal Peminjaman : $loanDate',
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.rs(context)),
                    Text(
                      'Tanggal Diterima',
                      style: TextStyle(fontSize: 14.rt(context)),
                    ),
                    TextField(
                      controller: tanggalDiterimaController,
                      readOnly: true,
                      style: TextStyle(fontSize: 14.rt(context)),
                      decoration: InputDecoration(
                        hintText: 'Tanggal Diterima',
                        hintStyle: TextStyle(fontSize: 14.rt(context)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.rp(context),
                          vertical: 12.rp(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.rs(context)),
                    Text(
                      'Tanggal Pengembalian',
                      style: TextStyle(fontSize: 14.rt(context)),
                    ),
                    TextField(
                      controller: tanggalPengembalianController,
                      style: TextStyle(fontSize: 14.rt(context)),
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        hintStyle: TextStyle(fontSize: 14.rt(context)),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.rp(context),
                          vertical: 12.rp(context),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          final formattedDate =
                              DateFormat('dd/MM/yyyy').format(pickedDate);
                          tanggalPengembalianController.text = formattedDate;
                        }
                      },
                    ),
                    SizedBox(height: 20.rs(context)),
                    Text(
                      'Keterangan',
                      style: TextStyle(fontSize: 14.rt(context)),
                    ),
                    TextField(
                      controller: keteranganController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14.rt(context)),
                      decoration: InputDecoration(
                        hintText: 'Enter additional information',
                        hintStyle: TextStyle(fontSize: 14.rt(context)),
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.rp(context),
                          vertical: 12.rp(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 70.rs(context)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.rp(context),
              right: 16.rp(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(176, 133, 126, 126),
                      borderRadius: BorderRadius.circular(12.rr(context)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.rp(context),
                      vertical: 8.rp(context),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16.rt(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.rp(context)),
                  Container(
                    decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(12.rr(context)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.rp(context),
                      vertical: 8.rp(context),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        String tanggalPengembaliana =
                            tanggalPengembalianController.text.trim();
                        if (tanggalPengembaliana.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Tanggal Pengembalian harus diisi!')),
                          );
                          return;
                        }
                        Get.find<AssetController>().submitAssetReturn(
                            id, tanggalPengembaliana, context);
                      },
                      child: Text(
                        'Ajukan Pengembalian',
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16.rt(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
