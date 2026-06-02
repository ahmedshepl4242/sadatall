import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/order_model.dart';
import '../providers/orders_provider.dart';
import 'special_order_details_screen.dart';

class AvailableOrdersScreen extends ConsumerStatefulWidget {
  const AvailableOrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AvailableOrdersScreen> createState() =>
      _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends ConsumerState<AvailableOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load orders only if there are no existing orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(availableOrdersProvider);
      if (currentState.orders.isEmpty && !currentState.isLoading) {
        ref.read(availableOrdersProvider.notifier).loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = ref.read(availableOrdersProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(availableOrdersProvider.notifier).loadOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(availableOrdersProvider);

    if (ordersState.orders.isEmpty && !ordersState.isLoading) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(availableOrdersProvider.notifier)
            .loadOrders(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: ordersState.orders.length + (ordersState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == ordersState.orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildOrderCard(
            context,
            ordersState.orders[index],
            ordersState,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طلبات متاحة',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد طلبات متاحة في الوقت الحالي\nسيتم إشعارك عند توفر طلبات جديدة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    AvailableOrdersState ordersState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'رقم الطلب: #${order.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.vendorId == '-1') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text(
                              'طلب خاص',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (order.deliveryPrice != null)
                  Text(
                    AppUtils.formatPrice(order.deliveryPrice!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.store,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.vendorName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${order.neighborhood?.name ?? ''} - ${order.userAddress}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  AppUtils.timeAgo(order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'عرض التفاصيل',
                    onPressed: () {
                      _showOrderDetails(context, order);
                    },
                    type: ButtonType.outlined,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'قبول الطلب',
                    onPressed:
                        ordersState.isAccepting &&
                            ordersState.acceptingOrderId == order.id
                        ? null
                        : () {
                            _acceptOrder(context, order);
                          },
                    isLoading:
                        ordersState.isAccepting &&
                        ordersState.acceptingOrderId == order.id,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    // For special orders (vendorId == -1), navigate to dedicated screen
    if (order.vendorId == '-1') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SpecialOrderDetailsScreen(order: order),
        ),
      );
      return;
    }

    // For normal orders, show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.onSurfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تفاصيل الطلب',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('رقم الطلب:', '#${order.id}'),
                        _buildDetailRow('وصف الطلب', order.description),
                        _buildDetailRow('المطعم/المتجر:', order.vendorName),
                        _buildDetailRow('رقم المطعم/المتجر:', order.vendor!.contactNumber),
                        _buildDetailRow(
                          'الحي:',
                          order.neighborhood?.name ?? 'غير محدد',
                        ),
                        if (order.user != null)
                          _buildDetailRow('اسم العميل:', order.user!.userName),
                        _buildDetailRow('عنوان العميل:', order.userAddress),
                        _buildDetailRow('رقم الهاتف:', order.phoneNumber),
                        if (order.price != null)
                          _buildDetailRow(
                            'سعر الطلب:',
                            AppUtils.formatPrice(order.price!),
                          ),
                        if (order.deliveryPrice != null)
                          _buildDetailRow(
                            'سعر التوصيل:',
                            AppUtils.formatPrice(order.deliveryPrice!),
                          ),
                        _buildDetailRow(
                          'حالة الطلب:',
                          _getStatusText(order.status),
                        ),
                        _buildDetailRow(
                          'وقت الطلب:',
                          AppUtils.formatDateTime(order.createdAt.toLocal()),
                        ),
                        if (order.additionalNotes != null &&
                            order.additionalNotes!.isNotEmpty)
                          _buildDetailRow('ملاحظات:', order.additionalNotes!),
                        const SizedBox(height: 16),
                        if (order.userLatitude != null &&
                            order.userLongitude != null)
                          CustomButton(
                            text: 'عرض الموقع على الخريطة',
                            onPressed: () {
                              _openInMaps(
                                order.userLatitude!,
                                order.userLongitude!,
                              );
                            },
                            type: ButtonType.outlined,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final ordersState = ref.watch(availableOrdersProvider);
                    return CustomButton(
                      text: 'قبول الطلب',
                      onPressed:
                          ordersState.isAccepting &&
                              ordersState.acceptingOrderId == order.id
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              _acceptOrder(context, order);
                            },
                      isLoading:
                          ordersState.isAccepting &&
                          ordersState.acceptingOrderId == order.id,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.onSurface),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  void _acceptOrder(BuildContext context, OrderModel order) async {
    // For special orders (vendorId == -1), show delivery price dialog
    if (order.vendorId == '-1') {
      _showDeliveryPriceDialog(context, order);
      return;
    }

    // For normal orders, show confirmation dialog
    final parentContext = context; // save the screen context

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('قبول الطلب'),
          content: Text(
            'هل تريد قبول طلب #${order.id}؟.',
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('قبول'),
              onPressed: () async {
                final notifier = ref.read(availableOrdersProvider.notifier);
                Navigator.of(dialogContext).pop();

                final success = await notifier.acceptOrder(order.id);

                if (!mounted) return;

                if (success) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('تم قبول الطلب بنجاح'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  final error = ref.read(availableOrdersProvider).error;
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(error ?? 'فشل في قبول الطلب')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeliveryPriceDialog(BuildContext context, OrderModel order) {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final parentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تحديد سعر التوصيل'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب خاص #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يجب تحديد سعر التوصيل للطلبات الخاصة',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'سعر التوصيل',
                  hint: 'أدخل سعر التوصيل',
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.attach_money),
                  validator: Validators.deliveryPrice,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            Consumer(
              builder: (context, dialogRef, child) {
                final state = dialogRef.watch(availableOrdersProvider);
                final isLoading = state.isAccepting && state.acceptingOrderId == order.id;
                return TextButton(
                  onPressed: isLoading ? null : () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final deliveryPrice = double.tryParse(priceController.text);
                    if (deliveryPrice == null || deliveryPrice <= 0) {
                      return;
                    }

                    final notifier = dialogRef.read(availableOrdersProvider.notifier);
                    Navigator.of(dialogContext).pop();

                    final success = await notifier
                        .acceptOrder(order.id, deliveryPrice: deliveryPrice);

                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('تم قبول الطلب بنجاح'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      final error = ref.read(availableOrdersProvider).error;
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(child: Text(error ?? 'فشل في قبول الطلب')),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('قبول'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار الموافقة';
      case OrderStatus.counterOfferSent:
        return 'عرض مضاد مُرسل';
      case OrderStatus.counterOfferAccepted:
        return 'عرض مضاد مقبول';
      case OrderStatus.acceptedByCaptain:
        return 'مقبول من الكابتن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  void _openInMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح تطبيق الخرائط')),
        );
      }
    }
  }
}
