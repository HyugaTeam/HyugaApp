import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/main/home.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/LoadingScreen.dart';
import 'package:hyuga_app/screens/main/Second_Page.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  queryingService.getUserLocation();
  
  runApp(StreamProvider<User>.value( 
      value: authService.user,
      child: MaterialApp(
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

        theme: ThemeData(
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

