import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

/// Displays a phone number that is always clickable: tap to call, long-press
/// or tap the copy icon to copy the number to the clipboard.
class ClickablePhoneField extends StatelessWidget {
  final String phoneNumber;
  final TextStyle? style;

  const ClickablePhoneField({
    super.key,
    required this.phoneNumber,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _makePhoneCall(phoneNumber),
            onLongPress: () => _copyPhoneNumber(context, phoneNumber),
            child: Text(
              phoneNumber,
              style: style ??
                  const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 18,
            icon: const Icon(Icons.copy, color: AppTheme.textSecondary),
            onPressed: () => _copyPhoneNumber(context, phoneNumber),
          ),
        ),
      ],
    );
  }

  void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الرقم')),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
