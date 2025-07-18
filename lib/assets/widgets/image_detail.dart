import 'package:flutter/material.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';

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
      padding: EdgeInsets.symmetric(vertical: 8.rp(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: ResponsiveUtil.isIPad(context) ? 2 : 3,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.rt(context),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                ResponsiveUtil.isIPad(context)
                    ? 24.rp(context)
                    : 16.rp(context),
                0,
                16.rp(context),
                0),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 17.rt(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            flex: ResponsiveUtil.isIPad(context) ? 3 : 2,
            child: InkWell(
              onTap: () => _showFullScreenImage(context),
              borderRadius: BorderRadius.circular(8.rr(context)),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: ResponsiveUtil.isIPad(context)
                      ? 120.rs(context)
                      : 100.rs(context),
                  maxHeight: ResponsiveUtil.isIPad(context)
                      ? 200.rs(context)
                      : 150.rs(context),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.rr(context)),
                  child: Image.network(
                    imageUrl,
                    filterQuality: FilterQuality.medium,
                    cacheHeight: ResponsiveUtil.isIPad(context) ? 600 : 400,
                    cacheWidth: ResponsiveUtil.isIPad(context) ? 450 : 300,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: ResponsiveUtil.isIPad(context)
                            ? 120.rs(context)
                            : 100.rs(context),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.rr(context)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24.rs(context),
                                height: 24.rs(context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.rs(context),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                              .toDouble()
                                      : null,
                                ),
                              ),
                              SizedBox(height: 8.rs(context)),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 12.rt(context),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: ResponsiveUtil.isIPad(context)
                            ? 120.rs(context)
                            : 100.rs(context),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.rr(context)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 32.ri(context),
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8.rs(context)),
                              Text(
                                'Image not\navailable',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.rt(context),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.rp(context)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.rr(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.rr(context)),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(20.rp(context)),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.network(
                    imageUrl,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300.rs(context),
                        width: 300.rs(context),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.rr(context)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40.rs(context),
                                height: 40.rs(context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.rs(context),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                              .toDouble()
                                      : null,
                                ),
                              ),
                              SizedBox(height: 16.rs(context)),
                              Text(
                                'Loading image...',
                                style: TextStyle(
                                  fontSize: 16.rt(context),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300.rs(context),
                        width: 300.rs(context),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.rr(context)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 64.ri(context),
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.rs(context)),
                              Text(
                                "Image not available",
                                style: TextStyle(
                                  fontSize: 16.rt(context),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.rp(context),
              right: 8.rp(context),
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: ResponsiveUtil.isIPad(context)
                      ? 22.rs(context)
                      : 18.rs(context),
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: ResponsiveUtil.isIPad(context)
                          ? 24.ri(context)
                          : 20.ri(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
