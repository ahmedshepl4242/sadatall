import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/vendor_service.dart';
import '../../services/contact_service.dart';
import '../../models/vendor.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/smart_circle_avatar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final VendorService _vendorService = VendorService();
  final ContactService _contactService = ContactService();

  Vendor? _vendor;
  ContactInfo? _contactInfo;
  bool _isLoading = true;
  bool _isStatusLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _vendorService.getProfile(),
        _contactService.getContactInfo(),
      ]);

      final profileResponse = results[0] as dynamic;
      final contactInfo = results[1] as ContactInfo?;

      if (!mounted) return;

      if (profileResponse.success && profileResponse.data != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setVendorLockStatus(false);
        setState(() {
          _vendor = profileResponse.data!;
          _contactInfo = contactInfo;
        });
      } else if (profileResponse.error != null) {
        if (profileResponse.error!.contains('يرجى الانتظار حتى يتم فتح الحساب')) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.setVendorLockStatus(true);
          _showVendorLockedDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileResponse.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showVendorLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الحساب مغلق'),
          content: const Text(
              'حسابك مغلق مؤقتًا، يرجى إغلاق التطبيق وإعادة فتحه بعد فتح الحساب من قبل الإدارة'),
        );
      },
    );
  }

  Future<void> _toggleStatus() async {
    if (_vendor == null || _isStatusLoading) return;

    setState(() {
      _isStatusLoading = true;
    });

    final currentStatus = _vendor!.isOpen == 'true';
    final newStatus = (!currentStatus).toString();

    try {
      final response = await _vendorService.updateStatus(newStatus);
      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _vendor = response.data!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'تم تحديث الحالة بنجاح'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'فشل في تحديث الحالة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث الحالة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStatusLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppTheme.primaryColor,
                  size: 50.0,
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatusCard(),
                      if (_contactInfo != null) ...[
                        const SizedBox(height: 24),
                        _buildContactCard(_contactInfo!),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SmartCircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              imageSource: _vendor?.imageUrl,
              child: const Icon(Icons.store,
                  size: 30, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك، ${_vendor?.vendorName ?? 'التاجر'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _vendor?.address ?? 'لا يوجد عنوان',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOpen = _vendor?.isOpen == 'true';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOpen
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOpen
                    ? Icons.store_outlined
                    : Icons.store_mall_directory_outlined,
                color: isOpen ? AppTheme.primaryColor : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة المتجر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isOpen ? 'مفتوح الآن' : 'مغلق الآن',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOpen ? AppTheme.primaryColor : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _isStatusLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: isOpen,
                    onChanged: (_) => _toggleStatus(),
                    activeThumbColor: AppTheme.primaryColor,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(ContactInfo info) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'تواصل معنا',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people_outline,
                      color: AppTheme.primaryColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (info.whatsapp.isNotEmpty)
              _buildContactRow(
                label: 'واتساب',
                value: info.whatsapp,
                icon: Icons.chat,
                iconColor: const Color(0xFF25D366),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () => _launchUrl(
                    'https://wa.me/${info.whatsapp.replaceAll('+', '')}'),
              ),
            if (info.facebook.isNotEmpty)
              _buildContactRow(
                label: 'فيسبوك',
                value: 'صفحتنا على فيسبوك',
                icon: Icons.facebook,
                iconColor: const Color(0xFF1877F2),
                bgColor: const Color(0xFFE3F2FD),
                onTap: () => _launchUrl(info.facebook),
              ),
            if (info.phone1.isNotEmpty)
              _buildContactRow(
                label: 'هاتف 1',
                value: info.phone1,
                icon: Icons.phone,
                iconColor: Colors.orange,
                bgColor: const Color(0xFFFFF3E0),
                onTap: () => _launchUrl('tel:${info.phone1}'),
              ),
            if (info.phone2.isNotEmpty)
              _buildContactRow(
                label: 'هاتف 2',
                value: info.phone2,
                icon: Icons.phone,
                iconColor: Colors.purple,
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => _launchUrl('tel:${info.phone2}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
