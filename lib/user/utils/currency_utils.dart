class CurrencyUtils {
  /// Formats a number as Egyptian Pound currency
  static String formatEGP(double amount) {
    return '${amount.toStringAsFixed(2)} ج.م';
  }

  /// Formats a number as Egyptian Pound currency with integer display for whole numbers
  static String formatEGPSmart(double amount) {
    if (amount == amount.toInt()) {
      return '${amount.toInt()} ج.م';
    }
    return '${amount.toStringAsFixed(2)} ج.م';
  }

  /// Formats with thousand separators
  static String formatEGPWithSeparators(double amount) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = amount.toStringAsFixed(2);
    result = result.replaceAllMapped(formatter, (Match m) => '${m[1]},');
    return '$result ج.م';
  }

  /// Parses EGP string back to double
  static double? parseEGP(String egpString) {
    try {
      final cleanString = egpString.replaceAll('ج.م', '').replaceAll(',', '').trim();
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Validates EGP input
  static bool isValidEGPAmount(String value) {
    try {
      final amount = double.parse(value);
      return amount >= 0;
    } catch (e) {
      return false;
    }
  }

  /// Example usage in TextField for price input
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'السعر مطلوب';
    }
    
    if (!isValidEGPAmount(value)) {
      return 'يرجى إدخال سعر صحيح';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount < 0) {
      return 'السعر يجب أن يكون أكبر من أو يساوي صفر';
    }
    
    return null;
  }
}