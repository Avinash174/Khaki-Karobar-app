import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kHasCompletedOnboardingKey = 'hasCompletedOnboarding';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    checkOnboardingStatus();
  }

  Future<bool> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(kHasCompletedOnboardingKey) ?? false;
      return state;
    } catch (_) {
      state = false;
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kHasCompletedOnboardingKey, true);
    } catch (_) {}
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});
