import 'dart:io';
//import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:authentication/authentication.dart';
import 'package:authentication/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/become_partner_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/contact_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/log_in_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/partners_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/profile_page.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/iap_service.dart';
import 'package:hyuga_app/services/message_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/config.dart';
import 'screens/wrapper/wrapper.dart';
import 'screens/wrapper/wrapper_provider.dart';




void main() async{
  
  await config();

  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          initialData: null, 
          value: Authentication.user,
        ),
        StreamProvider<UserProfile?>.value(
          initialData: Authentication.currentUserProfile, 
          value: Authentication.userProfile,
        ),
      ],
      child: MaterialApp(
        /// Locales aren't used yet
        // supportedLocales: [
        //   Locale('en','US'),
        //   Locale('ro','RO')
        // ],
        // localizationsDelegates: [
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalMaterialLocalizations.delegate
        // ],
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        initialRoute: 'wrapper/',
        routes: {
          'wrapper/': (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => WrapperProvider(),),
            ],
            child: Wrapper()
          ),
          // '/': (context) => HomeMapPage(),

          // 'loading/wrapper/': (context) => Wrapper(),

          // '/second': (context) => SecondPage(),
          
          /// '/devino-partener'
          BecomePartnerWebPage.route : (context) => BecomePartnerWebPage(),
          /// '/parteneri'
          PartnersWebPage.route : (context) => PartnersWebPage(),
          /// '/contact'
          ContactWebPage.route : (context) => ContactWebPage(),
          /// '/log-in'
          LogInWebPage.route : (context) => LogInWebPage(),
          /// '/profil'
          ProfileWebPage.route : (context) => ProfileWebPage()
 
        }, 
        // Route generator (designed for the Third Page only)
        onGenerateRoute: ThirdPageGenerator.generateRoute,

        navigatorObservers: [AnalyticsService().getAnalyticsObserver()],

        theme: theme(context)
        // theme: ThemeData(
        //   inputDecorationTheme: InputDecorationTheme(
        //     labelStyle: TextStyle(
        //       color: Colors.white
        //     ),
        //     suffixStyle: TextStyle(
        //       color: Colors.white
        //     )
        //   ),
        //   snackBarTheme: SnackBarThemeData(
        //     backgroundColor: Colors.orange[600]
        //   ),
        //   appBarTheme: AppBarTheme(
        //     color: Color(0xFFb78a97)
        //     //color: Colors.blueGrey,
        //   ),
        //   textTheme: TextTheme(
        //     subtitle2: TextStyle(
        //       color: Colors.black
        //     ) 
        //   ),
        //   // highlightColor: Colors.orange[600],
        //   // backgroundColor: Colors.white,
        //   // accentColor: Colors.blueGrey,
        //   // primaryColorDark: Colors.orange[600]

        //   primaryColor: Color(0xFF600F2B),
        //   //highlightColor: Color(0xFF600F2B),
        //   highlightColor: Color(0xFFCFBA70),
        //   backgroundColor: Colors.white,
        //   accentColor: Color(0xFFb78a97),
        //   primaryColorDark: Color(0xFF600F2B),

        //   // primaryColor: Color(0xFF600F2B),
        //   // highlightColor: Color(0xFFb78a97),
        //   // backgroundColor: Colors.white,
        //   // accentColor: Color(0xFFCFBA70),
        //   // primaryColorDark: Color(0xFF340808),
        //   fontFamily: 'Comfortaa'
        // ),
      ),
    );
  }
}

/// Function that handles all the initialization for the app
Future<void> config() async{
  FirebaseOptions firebaseOptions = const FirebaseOptions(
    appId: '1:1009284415459:web:3fe12199aeadcfcf326ad6',
    apiKey: 'AIzaSyBeApv-LQI5lDvkZUFD-5yiMLu55KOe6Bo',
    projectId: 'hyuga-app',
    messagingSenderId: '1009284415459',
    storageBucket: 'hyuga-app.appspot.com'
  );
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    FacebookAuth.instance.webAndDesktopInitialize(
      appId: "2317348558566656",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }
  WidgetsFlutterBinding.ensureInitialized();

  /// Setup stripe
  
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

  /// Setup firebase
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if(kIsWeb)
    await Firebase.initializeApp(options: firebaseOptions);
  else
  // var app1 =
    await Firebase.initializeApp();

  // var app = await Firebase.initializeApp(name: "feastique", options: FirebaseOptions(
  //   apiKey: "AIzaSyBoMqKAFF4peONrDXl0j9-GSmr1yoccBGU", 
  //   appId: "1:462249976642:android:3e722f67f7a101dc3d5edb", 
  //   messagingSenderId: "462249976642", 
  //   projectId: "feastique"
  // ));
  // FirebaseFirestore.instanceFor(app: app).collection('config').doc('assets').get().then((doc) => FirebaseFirestore.instance.collection('config').doc("assets").set(doc.data()!));

  await FirebaseFirestore.instance.collectionGroup('managed_locals').get().then((query) => query.docs.forEach((doc) {
    FirebaseFirestore.instance.collection("locals_bucharest").doc(doc.id).set({
      "manager_reference": doc.reference
    },
    SetOptions(merge: true));
  }));
  // await FirebaseFirestore.instance.collection("locals_bucharest").get().then((query) {
  //   query.docs.forEach((doc) {
  //     doc.reference.set({
  //       "ambience" : doc.data()['ambiance'] == 'c' ? "calm" : "social-friendly"     
  //     },
  //     SetOptions(merge:true)
  //     );
  //   });
  // });

  /// Initialize the Firebase App Check debug tokens
  // FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
  // await firebaseAppCheck.activate();
  // await firebaseAppCheck.setTokenAutoRefreshEnabled(true);
  /// Enables the In-App Purchase connection (only for Android)
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  if(!kIsWeb){
    IAP().initialize();
    //Adapty.activate();
    print("LOCATIA INCEPE");
    
    g.isIOS = Platform.isIOS == true? true : false;
  }
  queryingService = QueryService();
  MessagingService().requestNotificationPermissions();
  /// Init the Authentication package
  Authentication();

  // var query = await FirebaseFirestore.instance.collection("locals_bucharest").get();
  // query.docs.forEach((doc) {
  //   doc.reference.set({
  //       "city" : "bucharest" 
  //     },
  //     SetOptions(merge: true)
  //     );
  // });
}

