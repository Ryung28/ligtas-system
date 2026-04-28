import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGuideService {
  static const String _dashboardTourSeenKey =
      'viewer_dashboard_onboarding_tour_seen_v1';
  static const String _myItemsTourSeenKey =
      'viewer_my_items_onboarding_tour_seen_v1';
  static const String _qrScanTourSeenKey =
      'viewer_qr_scan_onboarding_tour_seen_v1';
  static const String _pendingQrFromDashboardKey =
      'viewer_pending_qr_from_dashboard_v1';

  Future<bool> shouldShowViewerDashboardTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_dashboardTourSeenKey) ?? false;
    return !seen;
  }

  Future<void> markViewerDashboardTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dashboardTourSeenKey, true);
  }

  Future<void> resetViewerDashboardTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dashboardTourSeenKey, false);
  }

  Future<bool> shouldShowMyItemsTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_myItemsTourSeenKey) ?? false;
    return !seen;
  }

  Future<void> markMyItemsTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_myItemsTourSeenKey, true);
  }

  Future<void> resetMyItemsTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_myItemsTourSeenKey, false);
  }

  Future<bool> shouldShowQrScanTour() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_qrScanTourSeenKey) ?? false;
    return !seen;
  }

  Future<void> markQrScanTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_qrScanTourSeenKey, true);
  }

  Future<void> resetQrScanTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_qrScanTourSeenKey, false);
  }

  Future<void> resetAllViewerTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dashboardTourSeenKey, false);
    await prefs.setBool(_myItemsTourSeenKey, false);
    await prefs.setBool(_qrScanTourSeenKey, false);
    await prefs.setBool(_pendingQrFromDashboardKey, false);
  }

  Future<void> setPendingQrFromDashboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingQrFromDashboardKey, value);
  }

  Future<bool> getPendingQrFromDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pendingQrFromDashboardKey) ?? false;
  }
}
