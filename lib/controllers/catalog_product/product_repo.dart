import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:noo_sms/models/product_catalog_model.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  final http.Client _client = http.Client();

  final String _baseUrl = 'catalog.prb.co.id';

  final Map<String, List<Product>> _productsCache = {};
  final Map<int, Product> _productDetailCache = {};

  final int _cacheDuration = 300000;
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<Product>> searchProducts(String keyword) async {
    final String trimmedKeyword = keyword.trim();
    final cacheKey = 'search_$trimmedKeyword';

    if (_productsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!).inMilliseconds <
            _cacheDuration) {
      return _productsCache[cacheKey]!;
    }

    try {
      final uri = Uri.http(
          _baseUrl, '/Products/GetProdukAjax', {'keyword': trimmedKeyword});

      final response = await _client.get(
        uri,
        headers: {'Connection': 'keep-alive'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        final products = data.map((item) => Product.fromJson(item)).toList();

        _productsCache[cacheKey] = products;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return products;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Product?> getProductById(int id) async {
    if (_productDetailCache.containsKey(id)) {
      return _productDetailCache[id];
    }

    for (var products in _productsCache.values) {
      final product = products.firstWhere(
        (product) => product.id == id,
        orElse: () => Product(
          id: -1,
          kode: '',
          nama: '',
          brand: '',
          fungsi: '',
          caraPakai: '',
          contohPenggunaan: '',
          gambar: '',
          satuan: [],
          negaraPemasok: '',
          produsen: '',
          produkCategory: '',
          produkSubCategory: '',
          produkStatus: '',
          beratBersih: 0.0,
          panjang: 0.0,
          lebar: 0.0,
          tinggi: 0.0,
          tipePenyimpanan: '',
          produkBU: '',
          waktuTenggang: -1,
          umurSimpan: -1,
        ),
      );

      if (product.id != -1) {
        _productDetailCache[id] = product;
        return product;
      }
    }

    return null;
  }

  void clearCache() {
    _productsCache.clear();
    _productDetailCache.clear();
    _cacheTimestamps.clear();
  }

  void dispose() {
    _client.close();
  }
}
