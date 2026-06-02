class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    if (!RegExp(r'^(?=.*\p{L})(?=.*\d)', unicode: true).hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على أحرف (بأي لغة) وأرقام';
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المستخدم مطلوب';
    }

    if (value.length < 3 || value.length > 50) {
      return 'اسم المستخدم يجب أن يكون بين 3-50 حرف';
    }

    if (!RegExp(
      r'^[\u0600-\u06FFa-zA-Z0-9_ ]+$',
      unicode: true,
    ).hasMatch(value)) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف (عربية أو إنجليزية) وأرقام وشرطة سفلية ومسافات فقط';
    }

    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName يجب أن يكون $maxLength حرف كحد أقصى';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName يجب أن يكون $minLength حرف كحد أدنى';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'السعر غير صحيح';
    }

    return null;
  }

  static String? nationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرقم القومي مطلوب';
    }

    if (value.length != 14) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }

    if (!RegExp(r'^\d{14}$').hasMatch(value)) {
      return 'الرقم القومي يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  static String? deliveryPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'سعر التوصيل مطلوب';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'سعر التوصيل يجب أن يكون أكبر من صفر';
    }

    return null;
  }
}
