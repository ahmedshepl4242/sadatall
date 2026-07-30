import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../core/config/api_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class VendorResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const VendorResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<VendorResetPasswordScreen> createState() =>
      _VendorResetPasswordScreenState();
}

class _VendorResetPasswordScreenState extends State<VendorResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.fetchBaseUrl();
      final dio = Dio();
      await dio.post(
        '$baseUrl/auth/vendor/reset-password',
        data: {
          'resetToken': widget.resetToken,
          'newPassword': _passwordController.text,
        },
        options: Options(headers: {'X-Tenant-ID': AppConstants.tenantId}),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['error'] ?? 'حدث خطأ، يرجى المحاولة مرة أخرى';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'كلمة مرور جديدة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.lock_outline,
                    size: 72, color: AppTheme.primaryColor),
                const SizedBox(height: 24),
                Text(
                  'أدخل كلمة المرور الجديدة',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'يجب أن تكون 6 أحرف على الأقل وتحتوي على حرف كبير وصغير ورقم',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور الجديدة',
                  hint: 'أدخل كلمة المرور الجديدة',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                    if (v.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(v)) {
                      return 'يجب أن تحتوي على حرف كبير وصغير ورقم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmController,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
                    if (v != _passwordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'حفظ كلمة المرور',
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
