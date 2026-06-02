import '../constants/app_constants.dart';

class Validators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    final phoneRegex = RegExp(AppConstants.phoneRegex);
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صحيح';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.maxPasswordLength} حرف على الأكثر';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != originalPassword) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  static String? validateName(String? value, {String? fieldName}) {
    final field = fieldName ?? 'الاسم';
    
    if (value == null || value.trim().isEmpty) {
      return '$field مطلوب';
    }
    
    if (value.trim().length < AppConstants.minNameLength) {
      return '$field يجب أن يكون ${AppConstants.minNameLength} أحرف على الأقل';
    }
    
    if (value.trim().length > AppConstants.maxNameLength) {
      return '$field يجب أن يكون ${AppConstants.maxNameLength} حرف على الأكثر';
    }
    
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    
    if (value.trim().length > AppConstants.maxAddressLength) {
      return 'العنوان يجب أن يكون ${AppConstants.maxAddressLength} حرف على الأكثر';
    }
    
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الوصف مطلوب';
    }
    
    if (value.trim().length > AppConstants.maxDescriptionLength) {
      return 'الوصف يجب أن يكون ${AppConstants.maxDescriptionLength} حرف على الأكثر';
    }
    
    return null;
  }

  static String? validateNeighborhood(int? value) {
    if (value == null || value <= 0) {
      return 'يرجى اختيار الحي';
    }
    
    return null;
  }

  static String? validateLocation(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'الموقع مطلوب';
    }
    
    if (latitude < -90 || latitude > 90) {
      return 'خط العرض غير صحيح';
    }
    
    if (longitude < -180 || longitude > 180) {
      return 'خط الطول غير صحيح';
    }
    
    return null;
  }

  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}