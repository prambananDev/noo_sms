import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUploadCard extends StatelessWidget {
  final String title;
  final File? image;
  final Uint8List? webImage;
  final String? imageUrl;
  final VoidCallback onCameraPress;
  final VoidCallback onGalleryPress;
  final String heroTagCamera;
  final String heroTagGallery;

  const ImageUploadCard({
    super.key,
    required this.title,
    this.image,
    this.webImage,
    this.imageUrl,
    required this.onCameraPress,
    required this.onGalleryPress,
    required this.heroTagCamera,
    required this.heroTagGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      width: MediaQuery.of(context).size.width * 0.62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: _buildImageDisplayWithZoom(context),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: _buildUploadButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplayWithZoom(BuildContext context) {
    if (!_hasImage()) {
      return _buildImageDisplay();
    }

    return GestureDetector(
      onTap: () => _showFullScreenPhotoPreview(context),
      child: _buildImageDisplay(),
    );
  }

  bool _hasImage() {
    return image != null ||
        webImage != null ||
        (imageUrl != null && imageUrl!.isNotEmpty);
  }

  Widget _buildImageDisplay() {
    Widget imageWidget;

    if (kIsWeb && webImage != null) {
      imageWidget = Image.memory(
        webImage!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    } else if (image != null) {
      imageWidget = Image.file(
        image!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 8),
                Text('Failed to load image',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      );
    } else {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No image selected', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 150,
        maxHeight: 300,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AspectRatio(
        aspectRatio: 1, // Square aspect ratio (change if needed)
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            mini: true,
            heroTag: heroTagCamera,
            onPressed: onCameraPress,
            tooltip: 'Take Photo',
            child: const Icon(
              Icons.add_a_photo,
              size: 24,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            mini: true,
            heroTag: heroTagGallery,
            onPressed: onGalleryPress,
            tooltip: 'Choose from Gallery',
            child: const Icon(
              Icons.photo_library,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenPhotoPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildFullScreenImage(),
            ),
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenImage() {
    if (kIsWeb && webImage != null) {
      return Image.memory(
        webImage!,
        fit: BoxFit.contain,
      );
    } else if (image != null) {
      return Image.file(
        image!,
        fit: BoxFit.contain,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 70, color: Colors.white),
                SizedBox(height: 16),
                Text('Failed to load image',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          "No image available",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }
}
