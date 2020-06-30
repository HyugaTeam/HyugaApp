import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/authenticate/authenticate.dart';
import 'package:hyuga_app/screens/manager/AdminPanel_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'main/home.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;


/// Wrapper for the Authentification Screen and the MainMenu Screen
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user.toString() + 'din provider');
    // if(g.isStarting){
    //   return FutureBuilder(
    //     future: Future.delayed(Duration(seconds: 5)).then((value){return true;}),
    //     builder:(context,ss){
    //     g.isStarting = false;
    //       if(!ss.hasData)
    //         return Container(
    //           child: Scaffold(
    //             appBar: AppBar(title: Text("STARTING")),
    //             body: Center(
    //               child: CircularProgressIndicator()
    //             ),
    //           ),
    //         );
    //       else 
    //         if(user != null)
    //           return Home(); 
    //         else
    //           return Authenticate();
    //     }
    //   );
    // }
    // else
      if(user != null)
        return StreamBuilder(
          stream: authService.loading,
          builder: (context, snapshot) {
            if(!snapshot.hasData || (snapshot.hasData && snapshot.data == true))
              return Scaffold(body: Center(child: CircularProgressIndicator(),),);
            else if(snapshot.data == false && authService.currentUser.isManager == true)
              return AdminPanel();
            else
              return Home();
          }
        ); 
      else
        return Authenticate();
    
  }
}


