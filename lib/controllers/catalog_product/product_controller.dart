import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/controllers/catalog_product/product_repo.dart';
import 'package:noo_sms/models/product_catalog_model.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = ProductRepository();

  final RxList<Product> searchResults = <Product>[].obs;
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  final _debounce = Debouncer(milliseconds: 500);

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);

    fetchInitialProducts();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void fetchInitialProducts() {
    searchProducts(" ");
  }

  void _onSearchChanged() {
    final query = searchController.text;
    searchQuery.value = query;
    isSearching.value = true;

    _debounce.run(() {
      searchProducts(query);
    });
  }

  Future<void> searchProducts(String keyword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await _repository.searchProducts(keyword);

      searchResults.value = results;
      isSearching.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to search products: $e';
      isSearching.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProductDetails(int productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final product = await _repository.getProductById(productId);

      if (product != null) {
        selectedProduct.value = product;
      } else {
        errorMessage.value = 'Product not found';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load product details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectProduct(Product product) {
    selectedProduct.value = product;
  }

  void clearSearch() {
    searchController.clear();

    fetchInitialProducts();
    searchQuery.value = '';
    isSearching.value = false;
  }

  void clearSelectedProduct() {
    selectedProduct.value = null;
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
