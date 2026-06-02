import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../data/models/captain_request_model.dart";
import "../../data/services/requests_service.dart";
import "../../../../core/utils/app_utils.dart";

final requestsServiceProvider = Provider<RequestsService>((ref) => RequestsService());

// Submit Request Provider
final submitRequestProvider = StateNotifierProvider<SubmitRequestNotifier, SubmitRequestState>((ref) {
  return SubmitRequestNotifier(ref.watch(requestsServiceProvider));
});

class SubmitRequestState {
  final bool isLoading;
  final String? error;
  final bool isSubmitted;

  const SubmitRequestState({
    this.isLoading = false,
    this.error,
    this.isSubmitted = false,
  });

  SubmitRequestState copyWith({
    bool? isLoading,
    String? error,
    bool? isSubmitted,
  }) {
    return SubmitRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class SubmitRequestNotifier extends StateNotifier<SubmitRequestState> {
  final RequestsService _requestsService;

  SubmitRequestNotifier(this._requestsService) : super(const SubmitRequestState());

  Future<bool> submitRequest(String description) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _requestsService.submitRequest(description);
      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
      return false;
    }
  }

  void reset() {
    state = const SubmitRequestState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Requests List Provider
final requestsListProvider = StateNotifierProvider<RequestsListNotifier, RequestsListState>((ref) {
  return RequestsListNotifier(ref.watch(requestsServiceProvider));
});

class RequestsListState {
  final List<CaptainRequestModel> requests;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const RequestsListState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  RequestsListState copyWith({
    List<CaptainRequestModel>? requests,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return RequestsListState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class RequestsListNotifier extends StateNotifier<RequestsListState> {
  final RequestsService _requestsService;

  RequestsListNotifier(this._requestsService) : super(const RequestsListState());

  Future<void> loadRequests({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final isFirstPage = refresh || state.requests.isEmpty;
    final page = isFirstPage ? 1 : state.currentPage + 1;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final newRequests = await _requestsService.getRequests(page: page);
      
      final updatedRequests = isFirstPage 
          ? newRequests 
          : [...state.requests, ...newRequests];

      state = state.copyWith(
        requests: updatedRequests,
        isLoading: false,
        currentPage: page,
        hasMore: newRequests.length >= 10,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
    }
  }

  Future<bool> deleteRequest(String requestId) async {
    try {
      await _requestsService.deleteRequest(requestId);
      // Remove the deleted request from the list
      final updatedRequests = state.requests.where((request) => request.id != requestId).toList();
      state = state.copyWith(requests: updatedRequests);
      return true;
    } catch (e) {
      state = state.copyWith(error: AppUtils.getLocalizedErrorMessage(e));
      return false;
    }
  }

  void resetPagination() {
    state = const RequestsListState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
