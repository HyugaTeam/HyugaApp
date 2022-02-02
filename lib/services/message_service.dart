import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

/// This Stateful Widget handles all the Firebase Push Notification service
class MessagingService{

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  MessagingService get instance => messagingService;

  /// Requests permission to send notifications on IOS
  requestNotificationPermissions(){
     
    if(g.isIOS)
      _fcm.requestPermission();
  }

  @override
  MessagingService() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("onMessage: "+ event.data.toString());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      print("onResume: "+ event.data.toString());
    });
    // FirebaseMessaging.onBackgroundMessage((event) async => 
    //   print("onLaunch: "+ event.data.toString())
    // );
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: "+ message.toString());
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: "+ message.toString());
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: "+ message.toString());
    //   }
    // );
  }
}

MessagingService messagingService = MessagingService();