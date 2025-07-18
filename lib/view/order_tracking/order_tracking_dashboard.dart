import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';
import 'package:noo_sms/models/order_tracking_model.dart';

class DashboardOrderTrack extends StatefulWidget {
  const DashboardOrderTrack({Key? key}) : super(key: key);

  @override
  State<DashboardOrderTrack> createState() => _DashboardOrderTrackState();
}

class _DashboardOrderTrackState extends State<DashboardOrderTrack> {
  final OrderTrackingController controller = Get.put(OrderTrackingController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      _onSearchChanged(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    controller.onCustomerSearchChanged(query);
  }

  void _clearSearch() {
    searchController.clear();
    controller.clearCustomerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: TextStyle(
            color: colorNetral,
            fontSize: 16.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56.rs(context),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35.ri(context),
          ),
        ),
        backgroundColor: colorAccent,
        actions: [
          IconButton(
            onPressed: () {
              controller.refreshData();
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24.ri(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.rp(context)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.rr(context)),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: searchController,
                cursorColor: colorAccent,
                style: TextStyle(fontSize: 16.rt(context)),
                onChanged: (value) {
                  _onSearchChanged(value);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorAccent,
                    size: 20.ri(context),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _clearSearch();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[500],
                            size: 20.ri(context),
                          ),
                        )
                      : null,
                  hintText: 'Search customer name, ID, or alias...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.rt(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.rp(context),
                    vertical: 12.rp(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
              ),
              SizedBox(height: 16.rs(context)),
              Text(
                'Loading customers...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.rt(context),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.filteredData.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.rp(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.rp(context)),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isSearching.value
                        ? Icons.search_off
                        : Icons.people_outline,
                    size: 48.ri(context),
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24.rs(context)),
                Text(
                  controller.isSearching.value
                      ? 'No results found'
                      : 'No customers available',
                  style: TextStyle(
                    fontSize: 18.rt(context),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  controller.isSearching.value
                      ? 'Try searching with different keywords'
                      : 'Customer data will appear here when available',
                  style: TextStyle(
                    fontSize: 14.rt(context),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (controller.isSearching.value) ...[
                  SizedBox(height: 24.rs(context)),
                  ElevatedButton.icon(
                    onPressed: () => _clearSearch(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.rp(context),
                        vertical: 12.rp(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.rr(context)),
                      ),
                    ),
                    icon: Icon(
                      Icons.clear,
                      size: 18.ri(context),
                    ),
                    label: Text(
                      'Clear Search',
                      style: TextStyle(fontSize: 16.rt(context)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.rp(context)),
        itemCount: controller.filteredData.length,
        itemBuilder: (context, index) {
          return _buildListItem(context, controller.filteredData[index]);
        },
      );
    });
  }

  Widget _buildListItem(
    BuildContext context,
    OrderTrackingModel item,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8.rp(context),
      ),
      padding: EdgeInsets.all(8.rp(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.rr(context)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerID(context, item),
              _buildCustomerName(context, item),
              SizedBox(height: 60.rs(context)),
            ],
          ),
          Positioned(
            bottom: 10.rp(context),
            right: 10.rp(context),
            child: GestureDetector(
              onTap: () {
                controller.navigateToDetail(item);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorAccent,
                  borderRadius: BorderRadius.circular(12.rr(context)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.rp(context),
                  vertical: 4.rp(context),
                ),
                child: Text(
                  "Detail",
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

  Widget _buildCustomerID(BuildContext context, OrderTrackingModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ID : ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              item.custId,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerName(BuildContext context, OrderTrackingModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Name : ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.rt(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              item.custName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.rt(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
