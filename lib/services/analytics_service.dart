import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService{
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  
  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: analytics);

  Future setUserProperties(String uid) async{
    await analytics.setUserId(uid);
  }
}