import 'dart:typed_data';

class DocumentImage {
  final String type;
  final String path;
  final DateTime timestamp;
  final String username;
  final Uint8List? webImage;
  final bool isWeb;

  DocumentImage({
    required this.type,
    required this.path,
    required this.timestamp,
    required this.username,
    this.webImage,
    this.isWeb = false,
  });
}
