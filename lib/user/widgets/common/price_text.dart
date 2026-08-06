import 'package:flutter/material.dart';
import '../../utils/currency_utils.dart';
import '../../theme/app_theme.dart';

class PriceText extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final bool useSeparators;
  final bool smartFormatting;

  const PriceText({
    super.key,
    required this.price,
    this.style,
    this.useSeparators = false,
    this.smartFormatting = true,
  });

  @override
  Widget build(BuildContext context) {
    String formattedPrice;
    
    if (useSeparators) {
      formattedPrice = CurrencyUtils.formatEGPWithSeparators(price);
    } else if (smartFormatting) {
      formattedPrice = CurrencyUtils.formatEGPSmart(price);
    } else {
      formattedPrice = CurrencyUtils.formatEGP(price);
    }

    return Text(
      formattedPrice,
      style: style ?? TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

class PriceTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool required;

  const PriceTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.required = false,
  });

  @override
  State<PriceTextField> createState() => _PriceTextFieldState();
}

class _PriceTextFieldState extends State<PriceTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? 'أدخل السعر',
        suffixText: 'ج.م',
        prefixIcon: const Icon(Icons.attach_money),
        border: const OutlineInputBorder(),
      ),
      validator: widget.validator ?? CurrencyUtils.validatePrice,
      onChanged: widget.onChanged,
    );
  }
}