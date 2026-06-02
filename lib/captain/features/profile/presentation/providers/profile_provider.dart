import "dart:io";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../auth/data/models/captain_model.dart";
import "../../data/models/captain_stats.dart";
import "../../data/services/profile_service.dart";
import "../../../../core/utils/app_utils.dart";
import "../../../../core/services/storage_service.dart";

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(),
);

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref.watch(profileServiceProvider));
});

class ProfileState {
  final CaptainModel? captain;
  final CaptainStats? stats;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.captain,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    CaptainModel? captain,
    CaptainStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      captain: captain ?? this.captain,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;

  ProfileNotifier(this._profileService) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load both profile and stats in parallel
      final profileFuture = _profileService.getProfile();
      final statsFuture = _profileService.getStats();
      final results = await Future.wait([
        profileFuture,
        statsFuture,
      ], eagerError: false);

      final captain = results[0] as CaptainModel;
      CaptainStats? stats;

      try {
        stats = results[1] as CaptainStats;
      } catch (e) {
        // Stats loading failed, but profile loaded successfully
        print("Failed to load stats: $e");
      }
      state = state.copyWith(captain: captain, stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppUtils.getLocalizedErrorMessage(e),
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data, {File? photo}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _profileService.updateProfile(data, photo: photo);
      // Reload full profile after successful update
      final captain = await _profileService.getProfile();
      state = state.copyWith(captain: captain, isLoading: false);
      // Update stored captain data
      final storageService = StorageService();
      await storageService.setJson(
        StorageService.keyCaptainData,
        captain.toJson(),
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}
