import 'dart:io';

import 'package:flutter/material.dart';
import '../../utils/image_utils.dart';

class SmartCircleAvatar extends StatelessWidget {
  final String? imageSource;
  final File? imageFile;
  final double radius;
  final Color? backgroundColor;
  final Widget? child;

  const SmartCircleAvatar({
    super.key,
    this.imageSource,
    this.imageFile,
    required this.radius,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;

    // Priority: imageFile > imageSource > child
    if (imageFile != null) {
      backgroundImage = FileImage(imageFile!);
    } else if (imageSource != null && imageSource!.isNotEmpty) {
      if (imageSource!.startsWith('data:image/')) {
        // Handle base64 data URI
        final bytes = ImageUtils.base64ToBytes(imageSource!);
        if (bytes != null) {
          backgroundImage = MemoryImage(bytes);
        }
      } else {
        // Handle network URL
        backgroundImage = NetworkImage(imageSource!);
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: backgroundImage,
      onBackgroundImageError: backgroundImage != null ? (error, stackTrace) {
        // Handle image loading errors
        debugPrint('CircleAvatar image error: $error');
      } : null,
      child: backgroundImage == null ? child : null,
    );
  }
}