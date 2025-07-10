import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noo_sms/assets/global.dart';
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
              color: colorNetral, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        backgroundColor: colorAccent,
        actions: [
          IconButton(
            onPressed: () {
              controller.fetchCust();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(controller),
              _buildStatusBar(controller),
              Expanded(
                child: _buildBody(controller),
              ),
            ],
          ),
          Obx(() => controller.showLoadMoreButton.value
              ? Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 75,
                  child: FloatingActionButton.extended(
                    onPressed: () => controller.loadMoreCustomers(),
                    backgroundColor: colorAccent.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    label: const Text("Load More"),
                  ),
                )
              : const SizedBox()),
          Obx(() => controller.showScrollButtons.value
              ? Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => controller.scrollToTop(),
                        backgroundColor: colorAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        heroTag: "scrollTop",
                        child: const Icon(Icons.keyboard_arrow_up),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => controller.scrollToBottom(),
                        backgroundColor: colorAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        heroTag: "scrollBottom",
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildStatusBar(EditCustController controller) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.isSearching.value
                    ? "Showing: ${controller.filteredCustomers.length}/${controller.customer.length}"
                    : "Total: ${controller.customer.length}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!controller.isSearching.value &&
                  controller.customer.isNotEmpty)
                Text(
                  "Page Size: ${controller.pageSize.value}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildSearchBar(EditCustController controller) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search by customer name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorAccent, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
          ),
          Obx(() => controller.isSearching.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Found: ${controller.filteredCustomers.length}/${controller.customer.length}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // TextButton.icon(
                      //   onPressed: () => controller.loadAllForSearch(),
                      //   icon: const Icon(Icons.download, size: 16),
                      //   label: const Text("Load All For Better Search"),
                      //   style: TextButton.styleFrom(
                      //     foregroundColor: colorAccent,
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 0,
                      //     ),
                      //     minimumSize: Size.zero,
                      //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //   ),
                      // ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBody(EditCustController controller) {
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
                const Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  "No results found for '${controller.searchQuery.value}'",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.clearSearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                  ),
                  child: const Text("Clear Search"),
                ),
              ],
            ),
          );
        }

        return Center(
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
                "No data available",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchCust(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                child: const Text("Retry"),
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
                // Show loading indicator at the end when loading more
                if (index == controller.filteredCustomers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildListItem(BuildContext context, EditCustModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfoRow(item),
              _buildDateStatusRow(item),
              _buildStatusInfo(item),
              _buildStatusItem(item),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Detail",
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

  Widget _buildCustomerInfoRow(EditCustModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top when wrapping
        children: [
          const Text(
            "Name : ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              item.custName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              maxLines: 2, // Allow up to 2 lines
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatusRow(EditCustModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Date : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.createdDate != null
                ? _formatDate(item.createdDate!)
                : "No Date",
            style: const TextStyle(
              fontSize: 16,
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

  Widget _buildStatusInfo(EditCustModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Customer ID : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.custId,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(EditCustModel item) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Company Status : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            item.companyStatus,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
