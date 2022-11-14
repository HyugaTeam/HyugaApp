import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/place/place_page.dart';
import 'package:hyuga_app/screens/wrapper/wrapper.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_page.dart';

/// Not in use

class RouteManager{
  static const String wrapper = "/";
  // static const String wrapperHomePage = "/home";
  static const String registerPage = "/register";
  static const String placePage = "/place";

  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case wrapper: 
        return MaterialPageRoute(
          builder: (context) => Wrapper()
        );
      // case wrapperHomePage:
      //   return MaterialPageRoute(
      //     builder: (context) => WrapperHomePage()
      //   );
      case placePage: 
        return MaterialPageRoute(
          builder: (context) => PlacePage()
        );
      default: 
        return MaterialPageRoute(
          builder: (context) => WrapperHomePage()
        );
    }
  }
}