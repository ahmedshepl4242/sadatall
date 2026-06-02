import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class CaptainLockedScreen extends ConsumerWidget {
  const CaptainLockedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock,
                size: 100,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'حسابك مُعلق',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لا يمكنك استخدام التطبيق حتى يتم إلغاء تعليق حسابك من قِبل المدير.\n\nيرجى التواصل مع الإدارة لحل هذه المشكلة، ثم قم بتسجيل الدخول مرة أخرى.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'تسجيل الخروج',
                onPressed: () => _logout(context, ref),
                isLoading: authState.isLoading,
                backgroundColor: AppColors.error,
                icon: Icons.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}