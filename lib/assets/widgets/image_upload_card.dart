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
        width: MediaQuery.of(context).size.width * 0.85,
        child: ListView(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: _buildImageContent(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: heroTagCamera,
                      onPressed: onCameraPress,
                      tooltip: 'Camera',
                      child: const Icon(Icons.add_a_photo),
                    ),
                    FloatingActionButton(
                      mini: true,
                      heroTag: heroTagGallery,
                      onPressed: onGalleryPress,
                      tooltip: 'Gallery',
                      child: const Icon(Icons.photo_album),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (kIsWeb && webImage != null)
          Image.memory(
            webImage!,
            filterQuality: FilterQuality.medium,
            cacheHeight: 400,
            cacheWidth: 300,
            fit: BoxFit.cover,
          )
        else if (image != null)
          Image.file(
            image!,
            filterQuality: FilterQuality.medium,
            cacheHeight: 400,
            cacheWidth: 300,
            fit: BoxFit.cover,
          )
        else if (imageUrl != null)
          Image.network(
            imageUrl!,
            filterQuality: FilterQuality.medium,
            cacheHeight: 400,
            cacheWidth: 300,
            fit: BoxFit.cover,
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
                child: Icon(Icons.error_outline, size: 50),
              );
            },
          )
        else
          const SizedBox(
            height: 200,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
