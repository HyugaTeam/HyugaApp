import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  
  void showNextScreen() async{
    return await Future.delayed(
      Duration(seconds: 2),
      (){
        //Navigator.pushNamed(context, '/');
      }
    );
  }

  WelcomeScreen(){
    showNextScreen();
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: Center(
          child: Text('Hyuga')
        ),
    );
  }
}