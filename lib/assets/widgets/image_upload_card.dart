import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';

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
    // Responsive width calculation with safety checks
    double cardWidth;
    final screenWidth = MediaQuery.of(context).size.width;

    if (ResponsiveUtil.isIPad(context)) {
      cardWidth =
          (screenWidth * 0.45).clamp(200.0, 600.0); // Clamp values for safety
    } else {
      cardWidth = (screenWidth * 0.62).clamp(150.0, 400.0);
    }

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: _safeResponsive(context, 2.rp(context), 8.0),
          vertical: _safeResponsive(context, 4.rp(context), 8.0)),
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            _safeResponsive(context, 16.rr(context), 16.0)),
        border: Border.all(
          color: Colors.grey[300] ?? Colors.grey.shade300,
        ),
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
            padding: EdgeInsets.fromLTRB(
                _safeResponsive(context, 8.rp(context), 8.0),
                _safeResponsive(context, 6.rp(context), 6.0),
                _safeResponsive(context, 8.rp(context), 8.0),
                _safeResponsive(context, 4.rp(context), 4.0)),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _safeResponsive(context, 16.rt(context), 16.0),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: _buildImageDisplayWithZoom(context),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: _safeResponsive(context, 4.rp(context), 4.0),
                bottom: _safeResponsive(context, 6.rp(context), 6.0)),
            child: _buildUploadButtons(context),
          ),
        ],
      ),
    );
  }

  // Safety helper to prevent crashes from responsive utilities
  double _safeResponsive(
      BuildContext context, double responsiveValue, double fallback) {
    try {
      final value = responsiveValue;
      return value.isFinite && value > 0 ? value : fallback;
    } catch (e) {
      return fallback;
    }
  }

  Widget _buildImageDisplayWithZoom(BuildContext context) {
    if (!_hasImage()) {
      return _buildImageDisplay(context);
    }

    return GestureDetector(
      onTap: () => _showFullScreenPhotoPreview(context),
      child: _buildImageDisplay(context),
    );
  }

  bool _hasImage() {
    return image != null ||
        webImage != null ||
        (imageUrl != null && imageUrl!.isNotEmpty);
  }

  Widget _buildImageDisplay(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb && webImage != null) {
      imageWidget = Image.memory(
        webImage!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(context),
      );
    } else if (!kIsWeb && image != null) {
      imageWidget = Image.file(
        image!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(context),
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
              strokeWidth: _safeResponsive(context, 3.rs(context), 3.0),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(context),
      );
    } else {
      return Container(
        height: ResponsiveUtil.isIPad(context)
            ? _safeResponsive(context, 250.rs(context), 250.0)
            : _safeResponsive(context, 200.rs(context), 200.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined,
                size: _safeResponsive(context, 50.ri(context), 50.0),
                color: Colors.grey),
            SizedBox(height: _safeResponsive(context, 8.rs(context), 8.0)),
            Text(
              'No image selected',
              style: TextStyle(
                color: Colors.grey,
                fontSize: _safeResponsive(context, 12.rt(context), 12.0),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Responsive height constraints with safety checks
    double minHeight = ResponsiveUtil.isIPad(context)
        ? _safeResponsive(context, 180.rs(context), 180.0)
        : _safeResponsive(context, 150.rs(context), 150.0);
    double maxHeight = ResponsiveUtil.isIPad(context)
        ? _safeResponsive(context, 400.rs(context), 400.0)
        : _safeResponsive(context, 300.rs(context), 300.0);

    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: _safeResponsive(context, 12.rp(context), 12.0)),
      child: AspectRatio(
        aspectRatio: 1, // Square aspect ratio
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _safeResponsive(context, 8.rr(context), 8.0)),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: _safeResponsive(context, 50.ri(context), 50.0),
              color: Colors.red),
          SizedBox(height: _safeResponsive(context, 8.rs(context), 8.0)),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.red,
              fontSize: _safeResponsive(context, 12.rt(context), 12.0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButtons(BuildContext context) {
    // Responsive button size with safety checks
    double buttonSize = ResponsiveUtil.isIPad(context)
        ? _safeResponsive(context, 45.rs(context), 45.0)
        : _safeResponsive(context, 40.rs(context), 40.0);
    double iconSize = ResponsiveUtil.isIPad(context)
        ? _safeResponsive(context, 28.ri(context), 28.0)
        : _safeResponsive(context, 24.ri(context), 24.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FloatingActionButton(
            mini: true,
            heroTag: heroTagCamera,
            onPressed: () {
              // Add safety check before calling camera
              try {
                onCameraPress();
              } catch (e) {
                debugPrint('Camera button error: $e');
                // You could show a snackbar or dialog here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera not available'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Take Photo',
            elevation: _safeResponsive(context, 2.rs(context), 2.0),
            child: Icon(
              Icons.add_a_photo,
              size: iconSize,
            ),
          ),
        ),
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FloatingActionButton(
            mini: true,
            heroTag: heroTagGallery,
            onPressed: () {
              // Add safety check before calling gallery
              try {
                onGalleryPress();
              } catch (e) {
                debugPrint('Gallery button error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery not available'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Choose from Gallery',
            elevation: _safeResponsive(context, 2.rs(context), 2.0),
            child: Icon(
              Icons.photo_library,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenPhotoPreview(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding:
              EdgeInsets.all(_safeResponsive(context, 8.rp(context), 8.0)),
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(
                    _safeResponsive(context, 20.rp(context), 20.0)),
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildFullScreenImage(context),
              ),
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(
                      _safeResponsive(context, 8.rp(context), 8.0)),
                  child: CircleAvatar(
                    radius: ResponsiveUtil.isIPad(context)
                        ? _safeResponsive(context, 25.rs(context), 25.0)
                        : _safeResponsive(context, 20.rs(context), 20.0),
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: ResponsiveUtil.isIPad(context)
                            ? _safeResponsive(context, 28.ri(context), 28.0)
                            : _safeResponsive(context, 24.ri(context), 24.0),
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
    } catch (e) {
      debugPrint('Error showing full screen preview: $e');
    }
  }

  Widget _buildFullScreenImage(BuildContext context) {
    if (kIsWeb && webImage != null) {
      return Image.memory(
        webImage!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFullScreenError(context),
      );
    } else if (!kIsWeb && image != null) {
      return Image.file(
        image!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFullScreenError(context),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: _safeResponsive(context, 4.rs(context), 4.0),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildFullScreenError(context),
      );
    } else {
      return Center(
        child: Text(
          "No image available",
          style: TextStyle(
              color: Colors.white,
              fontSize: _safeResponsive(context, 18.rt(context), 18.0)),
        ),
      );
    }
  }

  Widget _buildFullScreenError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: _safeResponsive(context, 70.ri(context), 70.0),
              color: Colors.white),
          SizedBox(height: _safeResponsive(context, 16.rs(context), 16.0)),
          Text(
            'Failed to load image',
            style: TextStyle(
                color: Colors.white,
                fontSize: _safeResponsive(context, 18.rt(context), 18.0)),
          ),
        ],
      ),
    );
  }
}
