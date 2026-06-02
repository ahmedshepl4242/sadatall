import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// A widget that displays text with clickable phone numbers.
/// Phone numbers are automatically detected and highlighted.
class ClickablePhoneText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? phoneStyle;

  const ClickablePhoneText({
    super.key,
    required this.text,
    this.style,
    this.phoneStyle,
  });

  // Regex to match various phone number formats
  // Matches: 01234567890, 0123-456-7890, +201234567890, etc.
  static final RegExp _phoneRegex = RegExp(
    r'(\+?\d{1,4}[-.\s]?)?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}',
  );

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? const TextStyle(color: AppColors.onSurface);
    final defaultPhoneStyle = phoneStyle ??
        const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
        );

    final spans = _buildTextSpans(text, defaultStyle, defaultPhoneStyle);

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<TextSpan> _buildTextSpans(
    String text,
    TextStyle normalStyle,
    TextStyle phoneStyle,
  ) {
    final spans = <TextSpan>[];
    final matches = _phoneRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    int lastEnd = 0;
    for (final match in matches) {
      // Validate that this looks like a real phone number (at least 7 digits)
      final phoneNumber = match.group(0)!;
      final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

      if (digitsOnly.length < 7) {
        // Not a valid phone number, skip
        continue;
      }

      // Add text before the phone number
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: normalStyle,
        ));
      }

      // Add the clickable phone number
      spans.add(TextSpan(
        text: phoneNumber,
        style: phoneStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => _makePhoneCall(phoneNumber),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after the last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: normalStyle,
      ));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: normalStyle)] : spans;
  }

  static Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean the phone number for the tel: URI
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = 'tel:$cleanNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

/// A widget specifically for displaying a phone number field that is always clickable
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
        GestureDetector(
          onTap: () => _makePhoneCall(phoneNumber),
          child: Text(
            phoneNumber,
            style: style ??
                const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
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
            icon: const Icon(Icons.copy, color: AppColors.onSurfaceVariant),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الرقم')),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = 'tel:$cleanNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
