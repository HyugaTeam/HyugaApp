import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/main/home.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/LoadingScreen.dart';
import 'package:hyuga_app/screens/main/Second_Page.dart';
import 'package:hyuga_app/services/message_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  print("LOCATIA INCEPE");
  
  g.isIOS = Platform.isIOS == true? true : false;
  queryingService.getUserLocation().then((value) { print("LOCATIA ESTE" + value.toString());  print("LOCATIA SE TERMINA");});
  MessagingService().requestNotificationPermissions();
  
  runApp(StreamProvider<OurUser>.value( 
      value: authService.user,
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

          '/': (context) => Home(),

          'loading/wrapper/': (context) => LoadingScreen(),

          '/second': (context) => SecondPage(),

          //'/third': (context) => ThirdPageGenerator.generateRoute(settings)
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
            color: Colors.blueGrey,
          ),
          textTheme: TextTheme(
            subtitle2: TextStyle(
              color: Colors.black
            ) 
          ),
          highlightColor: Colors.orange[600],
          backgroundColor: Colors.white,
          accentColor: Colors.blueGrey,
          fontFamily: 'Comfortaa'
        ),
        //home: Home()
      ),
    )
  );
}

