import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/edit_customer/edit_customer_controller.dart';
import 'package:noo_sms/models/edit_cust_noo_model.dart';

class EditCustScreen extends StatelessWidget {
  final EditCustController controller = Get.put(EditCustController());

  EditCustScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Edit Customer',
          style: TextStyle(
            color: colorNetral,
            fontSize: 16.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        toolbarHeight: 56.rs(context),
        centerTitle: true,
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
              controller.fetchCust();
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24.ri(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(context, controller),
              _buildStatusBar(context, controller),
              Expanded(
                child: _buildBody(context, controller),
              ),
            ],
          ),
          Obx(() => controller.showLoadMoreButton.value
              ? Positioned(
                  bottom: 50.rs(context),
                  left: MediaQuery.of(context).size.width / 2 - 75.rs(context),
                  child: FloatingActionButton.extended(
                    onPressed: () => controller.loadMoreCustomers(),
                    backgroundColor: colorAccent.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    label: Text(
                      "Load More",
                      style: TextStyle(fontSize: 14.rt(context)),
                    ),
                  ),
                )
              : const SizedBox()),
          Obx(() => controller.showScrollButtons.value
              ? Positioned(
                  bottom: 16.rs(context),
                  right: 16.rs(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => controller.scrollToTop(),
                        backgroundColor: colorAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        heroTag: "scrollTop",
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 20.ri(context),
                        ),
                      ),
                      SizedBox(height: 8.rs(context)),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => controller.scrollToBottom(),
                        backgroundColor: colorAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        heroTag: "scrollBottom",
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.ri(context),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, EditCustController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.rp(context),
            vertical: 8.rp(context),
          ),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.isSearching.value
                    ? "Showing: ${controller.filteredCustomers.length}/${controller.customer.length}"
                    : "Total: ${controller.customer.length}",
                style: TextStyle(
                  fontSize: 12.rt(context),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!controller.isSearching.value &&
                  controller.customer.isNotEmpty)
                Text(
                  "Page Size: ${controller.pageSize.value}",
                  style: TextStyle(
                    fontSize: 12.rt(context),
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildSearchBar(BuildContext context, EditCustController controller) {
    return Container(
      padding: EdgeInsets.all(8.rp(context)),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            style: TextStyle(fontSize: 16.rt(context)),
            decoration: InputDecoration(
              hintText: 'Search by customer name...',
              hintStyle: TextStyle(fontSize: 16.rt(context)),
              prefixIcon: Icon(
                Icons.search,
                size: 24.ri(context),
              ),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 24.ri(context),
                      ),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.rr(context)),
                borderSide: BorderSide(color: colorAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.rr(context)),
                borderSide:
                    BorderSide(color: colorAccent, width: 2.rs(context)),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.rp(context),
                horizontal: 16.rp(context),
              ),
            ),
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
          ),
          Obx(() => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 8.rs(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Found: ${controller.filteredCustomers.length}/${controller.customer.length}",
                        style: TextStyle(
                          fontSize: 12.rt(context),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8.rs(context)),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, EditCustController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredCustomers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!controller.isLoading.value && controller.filteredCustomers.isEmpty) {
        if (controller.isSearching.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48.ri(context),
                  color: Colors.grey,
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  "No results found for '${controller.searchQuery.value}'",
                  style: TextStyle(fontSize: 16.rt(context)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.rs(context)),
                ElevatedButton(
                  onPressed: () => controller.clearSearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.rp(context),
                      vertical: 12.rp(context),
                    ),
                  ),
                  child: Text(
                    "Clear Search",
                    style: TextStyle(fontSize: 16.rt(context)),
                  ),
                ),
              ],
            ),
          );
        }

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
                "No data available",
                style: TextStyle(fontSize: 16.rt(context)),
              ),
              SizedBox(height: 16.rs(context)),
              ElevatedButton(
                onPressed: () => controller.fetchCust(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.rp(context),
                    vertical: 12.rp(context),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.filteredCustomers.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.filteredCustomers.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.rp(context)),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildListItem(
                    context, controller.filteredCustomers[index]);
              },
            ),
          ),
          if (controller.errorMessage.isNotEmpty)
            Container(
              color: Colors.red.shade100,
              padding: EdgeInsets.all(8.rp(context)),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 14.rt(context),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildListItem(BuildContext context, EditCustModel item) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.rp(context),
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
              _buildCustomerInfoRow(context, item),
              _buildDateStatusRow(context, item),
              _buildStatusInfo(context, item),
              _buildStatusItem(context, item),
              SizedBox(height: 60.rs(context)),
            ],
          ),
          Positioned(
            bottom: 10.rp(context),
            right: 10.rp(context),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  '/customer-detail-form',
                  arguments: {
                    'customerId': item.id,
                    'customerName': item.custName,
                  },
                );
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

  Widget _buildCustomerInfoRow(BuildContext context, EditCustModel item) {
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

  Widget _buildDateStatusRow(BuildContext context, EditCustModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Date : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.createdDate != null
                ? _formatDate(item.createdDate!)
                : "No Date",
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      if (date.isEmpty) return "No Date";
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Widget _buildStatusInfo(BuildContext context, EditCustModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Customer ID : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.custId,
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, EditCustModel item) {
    return Padding(
      padding: EdgeInsets.all(6.rp(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Company Status : ",
              style: TextStyle(
                fontSize: 16.rt(context),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.companyStatus,
            style: TextStyle(
              fontSize: 16.rt(context),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
