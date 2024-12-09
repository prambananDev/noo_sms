import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUploadCard extends StatelessWidget {
  final String title;
  final File? image;
  final Uint8List? webImage;
  final VoidCallback onCameraPress;
  final VoidCallback onGalleryPress;
  final String heroTagCamera;
  final String heroTagGallery;

  const ImageUploadCard({
    super.key,
    required this.title,
    this.image,
    this.webImage,
    required this.onCameraPress,
    required this.onGalleryPress,
    required this.heroTagCamera,
    required this.heroTagGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        width: 150,
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
    if (image == null && webImage == null) {
      return Text(title);
    }

    return Column(
      children: [
        Text(title),
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
          ),
      ],
    );
  }
}
