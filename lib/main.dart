import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/main/Third_Page.dart';
import 'package:hyuga_app/screens/main/home.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LoadingScreen.dart';
import 'package:hyuga_app/screens/main/Second_Page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  

  runApp(StreamProvider<User>.value( 
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        initialRoute: 'welcome/',
        routes: {
          'welcome/': (context) => Wrapper(),

          '/': (context) => Home(),

          '/loading': (context) => LoadingScreen(),

          '/second': (context) => SecondPage(),

          //'/third': (context) => ThirdPageGenerator.generateRoute(settings)
        },

        onGenerateRoute: ThirdPageGenerator.generateRoute,

        theme: ThemeData(
          backgroundColor: Colors.white,
          accentColor: Colors.black,
          fontFamily: 'Comfortaa'
        ),
        //home: Home()
      ),
    )
  );
}

