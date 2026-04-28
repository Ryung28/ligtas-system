import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features_v2/onboarding_guide/data/services/onboarding_guide_service.dart';

final onboardingGuideServiceProvider = Provider<OnboardingGuideService>((ref) {
  return OnboardingGuideService();
});

final shouldShowViewerDashboardTourProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingGuideServiceProvider);
  return service.shouldShowViewerDashboardTour();
});

final shouldShowMyItemsTourProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingGuideServiceProvider);
  return service.shouldShowMyItemsTour();
});

final shouldShowQrScanTourProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingGuideServiceProvider);
  return service.shouldShowQrScanTour();
});

final pendingQrFromDashboardProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingGuideServiceProvider);
  return service.getPendingQrFromDashboard();
});
