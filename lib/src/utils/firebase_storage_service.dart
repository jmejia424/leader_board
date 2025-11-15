import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum ImageSize { small, medium, large }

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Gets the download URL for a pinball machine image
  static Future<String> getPinballImageUrl(
    String pinballId,
    ImageSize size,
  ) async {
    return _getImageUrl('images/pinballs', pinballId, size);
  }

  /// Private helper method to get image URLs
  static Future<String> _getImageUrl(
    String basePath,
    String id,
    ImageSize size,
  ) async {
    try {
      final sizeString = _getSizeSuffix(size);
      final ref = _storage.ref().child('$basePath/${id}_$sizeString.jpeg');
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error loading image for $id (size: $size): $e');
      return '';
    }
  }

  /// Converts ImageSize enum to file suffix string
  static String _getSizeSuffix(ImageSize size) {
    switch (size) {
      case ImageSize.small:
        return 'small';
      case ImageSize.medium:
        return 'medium';
      case ImageSize.large:
        return 'large';
    }
  }
}
