import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assetController.fetchAssetsHistory(1, 10);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Obx(() => _buildContent()),
    );
  }

  Future<void> _handleRefresh() async {
    await _assetController.fetchAssetsHistory(1, 10);
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
      padding: EdgeInsets.all(16.rp(context)),
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
        SizedBox(height: 100.rs(context)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.ri(context),
                color: Colors.red,
              ),
              SizedBox(height: 8.rs(context)),
              Text(
                "Error loading data",
                style: TextStyle(
                  fontSize: 16.rt(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.rs(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.rp(context)),
                child: Text(
                  _assetController.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.rt(context)),
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
      children: [
        SizedBox(height: 100.rs(context)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 48.ri(context),
                color: Colors.grey,
              ),
              SizedBox(height: 8.rs(context)),
              Text(
                "No loan history available",
                style: TextStyle(fontSize: 16.rt(context)),
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
      margin: EdgeInsets.symmetric(
        horizontal: 16.rp(context),
        vertical: 8.rp(context),
      ),
      padding: EdgeInsets.all(16.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.rr(context)),
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
              padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Received Photo:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.rt(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.rs(context)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.rr(context)),
                    child: Image.network(
                      assetHistory.fotoDiterima!,
                      height: 150.rs(context),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150.rs(context),
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50.ri(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20.rs(context)),
          assetHistory.status == 3
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _navigateToReturnPage(
                        context, controller, assetHistory),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(12.rr(context)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.rp(context),
                        vertical: 8.rp(context),
                      ),
                      child: Text(
                        "Kembalikan",
                        style: TextStyle(
                          color: colorNetral,
                          fontSize: 16.rt(context),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _navigateToReturnPage(
      BuildContext context, AssetController controller, Item assetHistory) {
    controller.fetchAssetDetail(assetHistory.id!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetReturnPage(
          id: assetHistory.id!,
          assetName: assetHistory.asset!,
          customerName: assetHistory.customerId!,
          loanDate: assetHistory.tanggalPeminjaman!,
          tanggalDiterima: assetHistory.tanggalDiterima,
          notes: assetHistory.keterangan,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label : ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
