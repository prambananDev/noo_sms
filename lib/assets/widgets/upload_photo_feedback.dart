import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DynamicBottomFeedback extends StatelessWidget {
  final String salesId;
  final Function(String, ImageSource) onCameraTap;
  final Function(String, ImageSource) onGalleryTap;

  const DynamicBottomFeedback({
    super.key,
    required this.salesId,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Upload POD"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop;
              onGalleryTap(salesId, ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop;
              onCameraTap(salesId, ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }
}
