import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../core/config/api_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.fetchBaseUrl();
      final dio = Dio();
      await dio.post(
        '$baseUrl/auth/vendor/forgot-password',
        data: {'contactNumber': _contactNumberController.text.trim()},
        options: Options(headers: {'X-Tenant-ID': AppConstants.tenantId}),
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorOtpVerificationScreen(
            contactNumber: _contactNumberController.text.trim(),
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          'حدث خطأ، يرجى المحاولة مرة أخرى';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
          'نسيت كلمة المرور',
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'إعادة تعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'أدخل رقم التواصل المسجل وسنرسل لك رمزاً للتحقق',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _contactNumberController,
                  label: 'رقم التواصل',
                  hint: 'أدخل رقم التواصل المسجل',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'رقم التواصل مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'إرسال الرمز',
                  onPressed: _sendOtp,
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
