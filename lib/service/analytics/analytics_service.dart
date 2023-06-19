import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._internal();

  static final AnalyticsService instance = AnalyticsService._internal();
  factory AnalyticsService() => instance;

  final FirebaseAnalytics manager = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    await manager.logEvent(name: name, parameters: parameters);
  }
}
