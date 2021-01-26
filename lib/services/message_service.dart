import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

/// This Stateful Widget handles all the Firebase Push Notification service
class MessagingService{

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  
  MessagingService get instance => messagingService;

  /// Requests permission to send notifications on IOS
  requestNotificationPermissions(){
     
    if(g.isIOS)
      _fcm.requestNotificationPermissions(IosNotificationSettings());
  }

  @override
  MessagingService() {

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: "+ message.toString());
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: "+ message.toString());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: "+ message.toString());
      }
    );
  }
}

MessagingService messagingService = MessagingService();