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
    return Card(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildImageDisplay(),
                  ],
                ),
              ),
            ),
            _buildUploadButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (kIsWeb && webImage != null) {
      return _buildImageWidget(
        child: Image.memory(
          webImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      );
    } else if (image != null) {
      return _buildImageWidget(
        child: Image.file(
          image!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildImageWidget(
        child: Image.network(
          imageUrl!,
          height: 200,
          width: double.infinity,
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
        ),
      );
    } else {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'No image selected',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildImageWidget({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
        minHeight: 200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: heroTagCamera,
            onPressed: onCameraPress,
            tooltip: 'Take Photo',
            child: const Icon(Icons.add_a_photo),
          ),
          FloatingActionButton(
            mini: true,
            heroTag: heroTagGallery,
            onPressed: onGalleryPress,
            tooltip: 'Choose from Gallery',
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
