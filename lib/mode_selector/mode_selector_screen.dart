import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_mode.dart';

const String _kModeKey = 'selected_app_mode';

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({super.key});

  Future<void> _selectMode(BuildContext context, AppMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModeKey, mode.name);
    // Update the global notifier — RootApp rebuilds in-place, no runApp call.
    appModeNotifier.value = mode.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo / title
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "تعالالي لخدمات التوصيل",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختر نوع الحساب للمتابعة',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Mode buttons
                _ModeCard(
                  icon: Icons.person_rounded,
                  label: 'مستخدم',
                  description: 'تصفح المتاجر واطلب الآن',
                  color: const Color(0xFF2196F3),
                  onTap: () => _selectMode(context, AppMode.user),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  icon: Icons.store_rounded,
                  label: 'تاجر',
                  description: 'إدارة متجرك وطلباتك',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _selectMode(context, AppMode.vendor),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  icon: Icons.delivery_dining_rounded,
                  label: 'كابتن توصيل',
                  description: 'استلام الطلبات والتوصيل',
                  color: const Color(0xFFFF5722),
                  onTap: () => _selectMode(context, AppMode.captain),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
