import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../utils/image_utils.dart';

class SmartImage extends StatelessWidget {
  final String? imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final AlignmentGeometry alignment;

  const SmartImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource == null || imageSource!.isEmpty) {
      return _buildErrorWidget();
    }

    // Check if it's a data URI (base64 image)
    if (imageSource!.startsWith('data:image/')) {
      return _buildBase64Image();
    }

    // Assume it's a network URL
    return Image.network(
      imageSource!,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildBase64Image() {
    try {
      final bytes = ImageUtils.base64ToBytes(imageSource!);
      if (bytes == null) {
        return _buildErrorWidget();
      }

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          alignment: alignment,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 40,
          ),
        );
  }
}