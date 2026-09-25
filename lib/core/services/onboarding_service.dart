import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class OnboardingService {
  Future<bool> hasCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  Future<void> markCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(AppConstants.onboardingCompletedKey, true);
  }
}

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService(),
);