import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/main/home.dart';
import 'package:hyuga_app/screens/main/home_map.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/main/Second_Page.dart';
import 'package:hyuga_app/services/message_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  print("LOCATIA INCEPE");
  
  // g.isIOS = Platform.isIOS == true? true : false;
  queryingService = QueryService();
  MessagingService().requestNotificationPermissions();
  
  runApp(StreamProvider<OurUser>.value( 
      value: authService.user,
      child: StreamProvider<bool>.value(
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

