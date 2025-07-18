import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/assets_submission/submission_controller.dart';

class AllAssetsPage extends StatefulWidget {
  const AllAssetsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AllAssetsPage> createState() => _AllAssetsPage();
}

class _AllAssetsPage extends State<AllAssetsPage> {
  final AssetController _assetController = Get.put(AssetController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assetController.fetchAssets(1, 10);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
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
      onRefresh: () async {
        await _assetController.fetchAssets(1, 10);
      },
      child: Obx(() {
        if (_assetController.isLoading.value &&
            _assetController.assets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_assetController.assets.isEmpty) {
          return Center(
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
                  "Data not available",
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.rp(context)),
          itemCount: _assetController.assets.length,
          itemBuilder: (context, index) {
            final asset = _assetController.assets[index];
            return _buildListItem(context, asset);
          },
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic asset) {
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
          Padding(
            padding: EdgeInsets.all(6.rp(context)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Status : ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.rt(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4.rp(context),
                    horizontal: 12.rp(context),
                  ),
                  decoration: BoxDecoration(
                    color: asset.status ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12.rr(context)),
                  ),
                  child: Text(
                    asset.statusName ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.rt(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildInfoItem("Asset ID", asset.id?.toString() ?? '-'),
          _buildInfoItem("Jenis Asset", asset.jenisAssetNama ?? '-'),
          _buildInfoItem("Serial Number", asset.serialNumber ?? '-'),
          _buildInfoItem("Merk", asset.merk ?? '-'),
          _buildInfoItem("Kapasitas", asset.kapasitas ?? '-'),
          _buildInfoItem("Daya Listrik", asset.dayaListrik ?? '-'),
          _buildInfoItem("Lokasi Gudang", asset.lokasiGudang ?? '-'),
          _buildInfoItem("Customer", asset.customer ?? '-'),
          SizedBox(height: 20.rs(context)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label : ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.rt(context),
            ),
          ),
        ],
      ),
    );
  }
}
