import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/assets_submission/submission_controller.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/models/submission_model.dart';
import 'package:noo_sms/view/assets_submission/asset_return.dart';

class AssetHistoryPage extends StatefulWidget {
  const AssetHistoryPage({Key? key}) : super(key: key);

  @override
  State<AssetHistoryPage> createState() => _AssetHistoryPageState();
}

class _AssetHistoryPageState extends State<AssetHistoryPage> {
  late final AssetController _assetController = Get.put(AssetController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _assetController.fetchAssetsHistory(1, 10);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration.zero, () {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _assetController.fetchAssetsHistory(1, 10);
            });
          });
        },
        child: _buildContent(),
      );
    });
  }

  Widget _buildContent() {
    if (_assetController.isLoading.value &&
        _assetController.assetsHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assetController.assetsHistory.isEmpty) {
      if (_assetController.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _assetController.assetsHistory.length,
      itemBuilder: (context, index) {
        final assetHistory = _assetController.assetsHistory[index];
        return _buildListItem(context, assetHistory, _assetController);
      },
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              const Text(
                "Error loading data",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _assetController.errorMessage.value,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                "No loan history available",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(
      BuildContext context, Item assetHistory, AssetController controller) {
    String formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return '-';
      try {
        final DateTime date = DateTime.parse(dateString);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return dateString;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          _buildInfoItem("Customer", assetHistory.customerId ?? '-'),
          _buildInfoItem("Asset", assetHistory.asset ?? '-'),
          _buildInfoItem("Pinjam", formatDate(assetHistory.tanggalPeminjaman)),
          _buildInfoItem(
              "Kembali", formatDate(assetHistory.tanggalPengembalian)),
          if (assetHistory.keterangan != null &&
              assetHistory.keterangan!.isNotEmpty)
            _buildInfoItem("Notes", assetHistory.keterangan ?? '-'),
          if (assetHistory.fotoDiterima != null &&
              assetHistory.fotoDiterima!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Received Photo:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      assetHistory.fotoDiterima!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          assetHistory.status == 3
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      controller.fetchAssetDetail(assetHistory.id!);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AssetReturnPage(
                          id: assetHistory.id!,
                          assetName: assetHistory.asset!,
                          customerName: assetHistory.customerId!,
                          loanDate: assetHistory.tanggalPeminjaman!,
                          tanggalDiterima: assetHistory.tanggalDiterima,
                          notes: assetHistory.keterangan,
                        );
                      }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        "Kembalikan",
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label : ",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
