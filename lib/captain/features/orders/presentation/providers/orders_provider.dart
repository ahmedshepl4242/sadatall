import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/services/orders_service.dart';
import '../../../../core/utils/app_utils.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) => OrdersService());

// Available Orders Provider
final availableOrdersProvider =
    StateNotifierProvider<AvailableOrdersNotifier, AvailableOrdersState>((ref) {
      return AvailableOrdersNotifier(ref.watch(ordersServiceProvider));
    });

class AvailableOrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final bool isAccepting;
  final String? acceptingOrderId;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const AvailableOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isAccepting = false,
    this.acceptingOrderId,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  AvailableOrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    bool? isAccepting,
    String? acceptingOrderId,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return AvailableOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isAccepting: isAccepting ?? this.isAccepting,
      acceptingOrderId: acceptingOrderId,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class AvailableOrdersNotifier extends StateNotifier<AvailableOrdersState> {
  final OrdersService _ordersService;

  AvailableOrdersNotifier(this._ordersService)
    : super(const AvailableOrdersState());

  Future<void> loadOrders({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final isFirstPage = refresh || state.orders.isEmpty;
    final page = isFirstPage ? 1 : state.currentPage + 1;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newOrders = await _ordersService.getAvailableOrders(page: page);

      final updatedOrders = isFirstPage
          ? newOrders
          : [...state.orders, ...newOrders];

      state = state.copyWith(
        orders: updatedOrders,
        isLoading: false,
        currentPage: page,
        hasMore: newOrders.length >= 10, // Assuming 10 is the page size
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
    }
  }

  void resetPagination() {
    state = const AvailableOrdersState();
  }

  Future<bool> acceptOrder(String orderId, {double? deliveryPrice}) async {
    // Set accepting state
    state = state.copyWith(
      isAccepting: true,
      acceptingOrderId: orderId,
      error: null,
    );

    try {
      await _ordersService.acceptOrder(orderId, deliveryPrice: deliveryPrice);
      // Remove the accepted order from the list
      final updatedOrders = state.orders
          .where((order) => order.id != orderId)
          .toList();
      state = state.copyWith(
        orders: updatedOrders,
        isAccepting: false,
        acceptingOrderId: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isAccepting: false,
        acceptingOrderId: null,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Current Orders Provider (supports multiple current orders)
final currentOrdersProvider =
    StateNotifierProvider<CurrentOrdersNotifier, CurrentOrdersState>((ref) {
      return CurrentOrdersNotifier(ref.watch(ordersServiceProvider));
    });

class CurrentOrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? processingOrderId;
  final String? error;

  const CurrentOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.processingOrderId,
    this.error,
  });

  CurrentOrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? processingOrderId,
    String? error,
  }) {
    return CurrentOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      processingOrderId: processingOrderId,
      error: error,
    );
  }
}

class CurrentOrdersNotifier extends StateNotifier<CurrentOrdersState> {
  final OrdersService _ordersService;

  CurrentOrdersNotifier(this._ordersService) : super(const CurrentOrdersState());

  Future<void> loadCurrentOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders = await _ordersService.getCaptainOrders(
        status: OrderStatus.acceptedByCaptain.value,
        limit: 100,
      );

      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
    }
  }

  Future<bool> markDelivered(String orderId) async {
    state = state.copyWith(processingOrderId: orderId, error: null);

    try {
      await _ordersService.markDelivered(orderId);
      // Remove the delivered order from the list
      final updatedOrders = state.orders
          .where((order) => order.id != orderId)
          .toList();
      state = state.copyWith(
        orders: updatedOrders,
        processingOrderId: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        processingOrderId: null,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> notifyArrived(String orderId) async {
    state = state.copyWith(processingOrderId: orderId, error: null);

    try {
      await _ordersService.notifyArrived(orderId);
      state = state.copyWith(processingOrderId: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        processingOrderId: null,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Delivered Orders Provider
final deliveredOrdersProvider =
    StateNotifierProvider<DeliveredOrdersNotifier, DeliveredOrdersState>((ref) {
      return DeliveredOrdersNotifier(ref.watch(ordersServiceProvider));
    });

class DeliveredOrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const DeliveredOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  DeliveredOrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return DeliveredOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class DeliveredOrdersNotifier extends StateNotifier<DeliveredOrdersState> {
  final OrdersService _ordersService;

  DeliveredOrdersNotifier(this._ordersService)
    : super(const DeliveredOrdersState());

  Future<void> loadOrders({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final isFirstPage = refresh || state.orders.isEmpty;
    final page = isFirstPage ? 1 : state.currentPage + 1;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newOrders = await _ordersService.getDeliveredOrders(page: page);

      final updatedOrders = isFirstPage
          ? newOrders
          : [...state.orders, ...newOrders];

      state = state.copyWith(
        orders: updatedOrders,
        isLoading: false,
        currentPage: page,
        hasMore: newOrders.length >= 10,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
    }
  }

  void resetPagination() {
    state = const DeliveredOrdersState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
