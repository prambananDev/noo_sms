import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
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
        margin: const EdgeInsets.only(left: 16, right: 16, top: 56),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asset : $assetName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Customer : $customerName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tanggal Peminjaman : $loanDate',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tanggal Diterima',
                        style: TextStyle(fontSize: 14)),
                    TextField(
                      controller: tanggalDiterimaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Tanggal Diterima',
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tanggal Pengembalian',
                        style: TextStyle(fontSize: 14)),
                    TextField(
                      controller: tanggalPengembalianController,
                      decoration: const InputDecoration(hintText: 'dd/mm/yyyy'),
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
                    const SizedBox(height: 20),
                    const Text('Keterangan', style: TextStyle(fontSize: 14)),
                    TextField(
                      controller: keteranganController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter additional information',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(176, 133, 126, 126),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          fontSize: 16,
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
