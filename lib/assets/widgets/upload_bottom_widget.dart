import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class DynamicBottomSheet extends StatelessWidget {
  final String salesId;
  final Function(String, ImageSource) onCameraTap;
  final Function(String, ImageSource) onGalleryTap;

  const DynamicBottomSheet({
    super.key,
    required this.salesId,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () {
              Get.back();
              onCameraTap(salesId, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Gallery'),
            onTap: () {
              Get.back();
              onGalleryTap(salesId, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
