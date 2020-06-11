import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User>(context);
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
    //           ),.
    //         );
    //       else
    //         return Container(
    //           child: Wrapper(),
    //         );
    //     }
    //   );
    // }
    // else
      return Container(
          child: Wrapper(),
          /// will add more options
      );
  }
}