import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../core/config/api_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import 'reset_password_screen.dart';

class VendorOtpVerificationScreen extends StatefulWidget {
  final String contactNumber;

  const VendorOtpVerificationScreen({
    super.key,
    required this.contactNumber,
  });

  @override
  State<VendorOtpVerificationScreen> createState() =>
      _VendorOtpVerificationScreenState();
}

class _VendorOtpVerificationScreenState
    extends State<VendorOtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _secondsLeft = 600;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 600);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل الرمز المكون من 6 أرقام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.fetchBaseUrl();
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/auth/vendor/verify-otp',
        data: {
          'contactNumber': widget.contactNumber,
          'otp': _otp,
        },
        options: Options(headers: {'X-Tenant-ID': AppConstants.tenantId}),
      );
      final resetToken = response.data['data']['resetToken'] as String;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VendorResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['error'] ?? 'الرمز غير صحيح أو منتهي الصلاحية';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      final baseUrl = await ApiConfig.fetchBaseUrl();
      final dio = Dio();
      await dio.post(
        '$baseUrl/auth/vendor/forgot-password',
        data: {'contactNumber': widget.contactNumber},
        options: Options(headers: {'X-Tenant-ID': AppConstants.tenantId}),
      );
      if (!mounted) return;
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رمز جديد'),
          backgroundColor: Colors.green,
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
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'التحقق من الرمز',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.mark_email_read_outlined,
                  size: 72, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                'تم إرسال الرمز',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'أدخل الرمز المرسل لرقم\n${widget.contactNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey ==
                                  LogicalKeyboardKey.backspace &&
                              _controllers[i].text.isEmpty &&
                              i > 0) {
                            _focusNodes[i - 1].requestFocus();
                            _controllers[i - 1].clear();
                          }
                        },
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          onChanged: (v) {
                            if (v.length > 1) {
                              final digits = v
                                  .replaceAll(RegExp(r'[^0-9]'), '')
                                  .split('');
                              for (var j = 0;
                                  j < digits.length && i + j < 6;
                                  j++) {
                                _controllers[i + j].text = digits[j];
                              }
                              final next =
                                  (i + digits.length).clamp(0, 5);
                              _focusNodes[next].requestFocus();
                              return;
                            }
                            if (v.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _secondsLeft > 0
                    ? 'صالح لمدة: $_timerText'
                    : 'انتهت صلاحية الرمز',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondsLeft > 0 ? AppTheme.textSecondary : Colors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'تحقق',
                onPressed: _verifyOtp,
                isLoading: _isLoading,
                height: 52,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    (_secondsLeft == 0 && !_isResending) ? _resendOtp : null,
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'إعادة إرسال الرمز',
                        style: TextStyle(
                          color: _secondsLeft == 0
                              ? AppTheme.primaryColor
                              : Colors.grey,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
