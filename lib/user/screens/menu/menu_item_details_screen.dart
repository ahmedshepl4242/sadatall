import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/smart_image.dart';

class MenuItemDetailsScreen extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemDetailsScreen({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عنصر القائمة ${menuItem.id}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (menuItem.photoUrl != null) ...[
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SmartImage(
                    imageSource: menuItem.photoUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'عنصر القائمة ${menuItem.id}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'معرف المتجر: ${menuItem.vendorId}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'معرف العنصر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menuItem.id,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}