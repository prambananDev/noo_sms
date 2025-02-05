import 'package:flutter/material.dart';

class ImageDetailRow extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ImageDetailRow({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(62, 0, 20, 0),
            child: Text(":"),
          ),
          Flexible(
            child: InkWell(
              onTap: () => _showFullScreenImage(context),
              child: Image.network(
                imageUrl,
                filterQuality: FilterQuality.medium,
                cacheHeight: 400,
                cacheWidth: 300,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!.toDouble()
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Show a placeholder (e.g., SizedBox) when the image fails to load
                  return const SizedBox(
                    height: 100,
                    width: 100,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.network(
          imageUrl,
          filterQuality: FilterQuality.medium,
          cacheHeight: 400,
          cacheWidth: 300,
          errorBuilder: (context, error, stackTrace) {
            // Handle errors in fullscreen mode as well
            return const Center(
              child: Text("Image not available"),
            );
          },
        ),
      ),
    );
  }
}
