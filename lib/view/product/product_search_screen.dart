import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
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
        title: Text(
          'Product Catalog',
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
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Get.theme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              controller.searchProducts(value);
            },
          ),
          const SizedBox(height: 8),
          Obx(() => controller.isSearching.value
              ? const Text(
                  'Searching...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              : controller.searchQuery.value.isNotEmpty &&
                      controller.searchResults.isEmpty &&
                      !controller.isLoading.value
                  ? const Text(
                      'No products found',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${controller.errorMessage.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.searchQuery.value.isNotEmpty) {
                    controller.searchProducts(controller.searchQuery.value);
                  } else {
                    // If search query is empty, fetch initial products
                    controller.fetchInitialProducts();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        if (controller.searchQuery.value.isEmpty &&
            !controller.isLoading.value) {
          // Changed this to only show when not loading and no previous search
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Try different keywords',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.gambar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Brand: ${product.brand}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${product.kode}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.fungsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
