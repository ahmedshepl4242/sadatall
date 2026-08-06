import 'package:flutter/material.dart';
import 'package:sadat_delivery_merged/user/models/order.dart';
import 'package:sadat_delivery_merged/user/screens/orders/order_details_screen.dart';

class NotificationHandler {
  static void handleOrderStatusUpdate(
    BuildContext context,
    String orderId,
    String newStatus,
  ) {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة طلبك #$orderId'),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            // Navigate to order details
            _navigateToOrderDetails(context, int.tryParse(orderId) ?? 0);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void handleNewOrderConfirmation(
    BuildContext context,
    String orderId,
  ) {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تأكيد طلبك #$orderId بنجاح'),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            // Navigate to order details
            _navigateToOrderDetails(context, int.tryParse(orderId) ?? 0);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void handleCaptainAssigned(
    BuildContext context,
    String orderId,
    String captainName,
  ) {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تعيين كابتن $captainName لطلبك #$orderId'),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            // Navigate to order details
            _navigateToOrderDetails(context, int.tryParse(orderId) ?? 0);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void handleOrderDelivered(
    BuildContext context,
    String orderId,
  ) {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم توصيل طلبك #$orderId بنجاح'),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            // Navigate to order details
            _navigateToOrderDetails(context, int.tryParse(orderId) ?? 0);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void handleOrderCancelled(
    BuildContext context,
    String orderId,
  ) {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء طلبك #$orderId'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void _navigateToOrderDetails(BuildContext context, int orderId) {
    if (orderId > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderDetailsScreen(
            order: Order(
              id: orderId,
              userId: 0,
              vendorId: 0,
              status: '',
              description: '',
              price: 0,
              userAddress: '',
              phoneNumber: '',
              neighborhoodId: 0,
              isRated: false,
              createdAt: DateTime.now(),
            ),
          ),
        ),
      );
    }
  }
}
