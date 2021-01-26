import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/authenticate/authenticate.dart';
import 'package:hyuga_app/screens/manager/AdminPanel_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/widgets/SlideShow_Intro.dart';
import 'package:provider/provider.dart';
import 'main/home.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;


/// Wrapper for the Authentification Screen and the MainMenu Screen
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<OurUser>(context);
    print(user.toString() + 'din provider');
      if(user != null)
        return StreamBuilder(
          stream: authService.loading,
          builder: (context, snapshot) {
            if(!snapshot.hasData && authService.isLoading == null)
              return Scaffold(body: Center(child: LoadingAnimation(),),);
            else if(authService.currentUser.isManager == true)
              return AdminPanel();
            else if(g.isNewUser)
              return SlideShowIntro();
            else
              return Home();
          }
        ); 
      else
        return Authenticate();
    
  }
}


