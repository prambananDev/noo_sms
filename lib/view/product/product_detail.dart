import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/catalog_product/product_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductController controller = Get.find<ProductController>();

  ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Product Details',
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
      body: Obx(() {
        final product = controller.selectedProduct.value;

        if (product == null) {
          return const Center(
            child: Text('No product selected'),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            product.gambar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.nama}-${product.brand}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.kode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Detail:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Brand', product.brand),
                          _buildDetailRow('Name', product.nama),
                          _buildDetailRow('Function', product.fungsi),
                          _buildDetailRow(
                              'Usage Instructions', product.caraPakai),
                          _buildDetailRow(
                              'Usage \nExamples', product.contohPenggunaan),
                          _buildDetailRow(
                              'Country Name', product.negaraPemasok),
                          _buildDetailRow('Producer', product.produsen),
                          if (product.produkCategory.isNotEmpty)
                            _buildDetailRow(
                                'Product Category', product.produkCategory),
                          if (product.produkSubCategory.isNotEmpty)
                            _buildDetailRow('Product SubCategory',
                                product.produkSubCategory),
                          _buildDetailRow(
                              'Product Status', product.produkStatus),
                          _buildDetailRow(
                              'Net Weight', '${product.beratBersih} kg'),
                          _buildDetailRow('Dimensions',
                              '${product.panjang} x ${product.lebar} x ${product.tinggi} cm'),
                          _buildDetailRow(
                              'Storage Type', product.tipePenyimpanan),
                          _buildDetailRow('Product BU', product.produkBU),
                          _buildDetailRow(
                              'Lead Time', '${product.waktuTenggang} days'),
                          _buildDetailRow(
                              'Shelf Life', '${product.umurSimpan} days'),
                          //          _buildDetailRow('Packaging', product.kemasan!),
                          // if (product.komposisi != null &&
                          //     product.komposisi!.isNotEmpty)
                          // _buildDetailRow(
                          //     'Composition', product.komposisi ?? ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
