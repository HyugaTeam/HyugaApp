import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart' as Foundation;

class AnalyticsService{
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  AnalyticsService(){
    Foundation.kDebugMode
    ? analytics.setAnalyticsCollectionEnabled(false)
    : analytics.setAnalyticsCollectionEnabled(true);
  }
  
  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: analytics);

  Future setUserProperties(String uid) async{
    await analytics.setUserId(id: uid);
  }
}