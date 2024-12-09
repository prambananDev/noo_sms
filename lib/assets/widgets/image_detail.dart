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
    return Row(
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
          child: Container(
            height: 100,
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => Image.network(
        imageUrl,
        filterQuality: FilterQuality.medium,
        cacheHeight: 400,
        cacheWidth: 300,
      ),
    );
  }
}
