import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';
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
            color: colorNetral,
            fontSize: 16.rt(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
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
      body: Obx(() {
        final product = controller.selectedProduct.value;

        if (product == null) {
          return Center(
            child: Text(
              'No product selected',
              style: TextStyle(fontSize: 16.rt(context)),
            ),
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
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64.ri(context),
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
                            padding: EdgeInsets.all(16.rp(context)),
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.nama}-${product.brand}',
                                  style: TextStyle(
                                    fontSize: 22.rt(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                ),
                                SizedBox(height: 4.rs(context)),
                                Text(
                                  product.kode,
                                  style: TextStyle(
                                    fontSize: 16.rt(context),
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
                      padding: EdgeInsets.all(16.rp(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Detail:',
                            style: TextStyle(
                              fontSize: 16.rt(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.rs(context)),
                          _buildDetailRow(context, 'Brand', product.brand),
                          _buildDetailRow(context, 'Name', product.nama),
                          _buildDetailRow(context, 'Function', product.fungsi),
                          _buildDetailRow(
                              context, 'Usage Instructions', product.caraPakai),
                          _buildDetailRow(context, 'Usage \nExamples',
                              product.contohPenggunaan),
                          _buildDetailRow(
                              context, 'Country Name', product.negaraPemasok),
                          _buildDetailRow(
                              context, 'Producer', product.produsen),
                          if (product.produkCategory.isNotEmpty)
                            _buildDetailRow(context, 'Product Category',
                                product.produkCategory),
                          if (product.produkSubCategory.isNotEmpty)
                            _buildDetailRow(context, 'Product SubCategory',
                                product.produkSubCategory),
                          _buildDetailRow(
                              context, 'Product Status', product.produkStatus),
                          _buildDetailRow(context, 'Net Weight',
                              '${product.beratBersih} kg'),
                          _buildDetailRow(context, 'Dimensions',
                              '${product.panjang} x ${product.lebar} x ${product.tinggi} cm'),
                          _buildDetailRow(
                              context, 'Storage Type', product.tipePenyimpanan),
                          _buildDetailRow(
                              context, 'Product BU', product.produkBU),
                          _buildDetailRow(context, 'Lead Time',
                              '${product.waktuTenggang} days'),
                          _buildDetailRow(context, 'Shelf Life',
                              '${product.umurSimpan} days'),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 14.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.rs(context),
            child: Text(
              label,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.rt(context)),
            ),
          ),
        ],
      ),
    );
  }
}
