import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/authenticate/sign_in.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    
    // if(g.isStarting){
    //   g.isStarting = false;
    //   return FutureBuilder(
    //     future: Future.delayed(Duration(seconds: 1)).then((value){return true;}),
    //     builder:(context,ss){
    //       if(!ss.hasData)
    //         return Container(
    //           child: Scaffold(
    //             body: Center(
    //               child: CircularProgressIndicator()
    //             ),
    //           ),
    //         );
    //       else
    //         return Container(
    //           child: SignIn(),
    //         );
    //     }
    //   );
    // }
    // else
      return Container(
          child: SignIn(),
          /// will add more options
      );
  }
}