import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
import 'package:noo_sms/controllers/catalog_product/product_controller.dart';
import 'package:noo_sms/models/product_catalog_model.dart';
import 'package:noo_sms/view/product/product_detail.dart';

class ProductSearchScreen extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

  ProductSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56.rs(context),
        title: Text(
          'Product Catalog',
          style: TextStyle(
            color: colorNetral,
            fontSize: 18.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.rp(context)),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            style: TextStyle(fontSize: 16.rt(context)),
            decoration: InputDecoration(
              hintText: 'Search products...',
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
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.rr(context)),
                borderSide: BorderSide(color: colorAccent, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.rp(context),
                horizontal: 16.rp(context),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              controller.searchProducts(value);
            },
          ),
          SizedBox(height: 8.rs(context)),
          Obx(() => controller.isSearching.value
              ? Text(
                  'Searching...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14.rt(context),
                  ),
                )
              : controller.searchQuery.value.isNotEmpty &&
                      controller.searchResults.isEmpty &&
                      !controller.isLoading.value
                  ? Text(
                      'No products found',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14.rt(context),
                      ),
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        debugPrint(controller.errorMessage.value);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.ri(context),
                color: Colors.red,
              ),
              SizedBox(height: 16.rs(context)),
              Text(
                'Error: ${controller.errorMessage.value}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.rt(context),
                ),
              ),
              SizedBox(height: 16.rs(context)),
              ElevatedButton(
                onPressed: () {
                  if (controller.searchQuery.value.isNotEmpty) {
                    controller.searchProducts(controller.searchQuery.value);
                  } else {
                    controller.fetchInitialProducts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.rp(context),
                    vertical: 12.rp(context),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 16.rt(context)),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        if (controller.searchQuery.value.isEmpty &&
            !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64.ri(context),
                  color: Colors.grey,
                ),
                SizedBox(height: 16.rs(context)),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16.rt(context),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8.rs(context)),
                Text(
                  'Try different keywords',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.rt(context),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.rp(context)),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final product = controller.searchResults[index];
          return _buildProductCard(product, context);
        },
      );
    });
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.rs(context)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16.rr(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          controller.selectProduct(product);
          Get.to(() => ProductDetailScreen());
        },
        borderRadius: BorderRadius.circular(16.rr(context)),
        child: Padding(
          padding: EdgeInsets.all(16.rp(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.rr(context)),
                child: Image.network(
                  product.gambar,
                  width: 80.rs(context),
                  height: 80.rs(context),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80.rs(context),
                      height: 80.rs(context),
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 32.ri(context),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 16.rp(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: TextStyle(
                        fontSize: 16.rt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.rs(context)),
                    Text(
                      'Brand: ${product.brand}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.rt(context),
                      ),
                    ),
                    SizedBox(height: 4.rs(context)),
                    Text(
                      'Code: ${product.kode}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.rt(context),
                      ),
                    ),
                    SizedBox(height: 8.rs(context)),
                    Text(
                      product.fungsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.rt(context)),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24.ri(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
