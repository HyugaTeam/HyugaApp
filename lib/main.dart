import 'dart:io';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/main/home_map.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/main/Second_Page.dart';
import 'package:hyuga_app/services/iap_service.dart';
import 'package:hyuga_app/services/message_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';




void main() async{
  
  await config();

  runApp(StreamProvider<OurUser?>.value( 
      initialData: authService.currentUser,
      value: authService.user,
      child: StreamProvider<bool?>.value(
        initialData: null,
        value: queryingService.locationEnabledStream.stream,
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
            'wrapper/': (context) => Wrapper(),

            '/': (context) => HomeMapPage(),

            'loading/wrapper/': (context) => Wrapper(),

            '/second': (context) => SecondPage(),
          }, 
          // Route generator (designed for the Third Page only)
          onGenerateRoute: ThirdPageGenerator.generateRoute,

          navigatorObservers: [AnalyticsService().getAnalyticsObserver()],

          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(
                color: Colors.white
              ),
              suffixStyle: TextStyle(
                color: Colors.white
              )
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.orange[600]
            ),
            appBarTheme: AppBarTheme(
              color: Color(0xFFb78a97)
              //color: Colors.blueGrey,
            ),
            textTheme: TextTheme(
              subtitle2: TextStyle(
                color: Colors.black
              ) 
            ),
            // highlightColor: Colors.orange[600],
            // backgroundColor: Colors.white,
            // accentColor: Colors.blueGrey,
            // primaryColorDark: Colors.orange[600]

            primaryColor: Color(0xFF600F2B),
            //highlightColor: Color(0xFF600F2B),
            highlightColor: Color(0xFFCFBA70),
            backgroundColor: Colors.white,
            accentColor: Color(0xFFb78a97),
            primaryColorDark: Color(0xFF600F2B),

            // primaryColor: Color(0xFF600F2B),
            // highlightColor: Color(0xFFb78a97),
            // backgroundColor: Colors.white,
            // accentColor: Color(0xFFCFBA70),
            // primaryColorDark: Color(0xFF340808),
            fontFamily: 'Comfortaa'
          ),
        ),
      ),
    )
  );
}

/// Function that handles all the initialization for the app
Future<void> config() async{
  FirebaseOptions firebaseOptions = const FirebaseOptions(
    appId: '1:1009284415459:web:3fe12199aeadcfcf326ad6',
    apiKey: 'AIzaSyBeApv-LQI5lDvkZUFD-5yiMLu55KOe6Bo',
    projectId: 'hyuga-app',
    messagingSenderId: '1009284415459',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if(kIsWeb)
    await Firebase.initializeApp(options: firebaseOptions);
  else
    await Firebase.initializeApp();
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
}

