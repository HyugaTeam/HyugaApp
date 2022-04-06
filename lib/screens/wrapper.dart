import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/authenticate/authenticate.dart';
import 'package:hyuga_app/screens/manager/AdminPanel_Page.dart';
import 'package:hyuga_app/screens/web_version/web_landing_page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/widgets/SlideShow_Intro.dart';
import 'package:provider/provider.dart';
import 'main/home_map.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;


/// Wrapper for the Authentification Screen and the MainMenu Screen
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<OurUser?>(context);
    if(kIsWeb) // The Web Landing Page
      return WebLandingPage();
    final hasLocationServiceEnabled = Provider.of<bool?>(context);
    print("user: " + user.toString() + ' locatie pornita: '+ hasLocationServiceEnabled.toString());
        if(hasLocationServiceEnabled != null)
        if(hasLocationServiceEnabled == false) /// Changed from '==false' to '!=false' due to a strange bug in location service
          return Scaffold( /// Location not enabled
            body: Container(
              padding: EdgeInsets.only(left: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/wine-street-logo.png',
                    //'assets/images/hyuga-logo.png',
                    width:50
                  ),
                  SizedBox(height: 30,),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Wine Street nu poate functiona fara locatie :(\n"

                        ),
                        TextSpan(
                          text: "Porneste locatia din setari.\n\n\n"
                        ),
                        
                        WidgetSpan(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            color: Theme.of(context).highlightColor,
                            child: Text("Solicita locatia", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: (){
                              QueryService().checkAndRequestForLocationService();
                            },
                          )
                        )                          
                      ],
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    
                  ),
                ],
              ),
            )
        );
        return StreamProvider<bool?>.value(
          initialData: null,
          value: QueryService.userLocationStream.stream,
          builder: (context, child) {
            var hasLocation = Provider.of<bool?>(context);
            bool? prevData;
            QueryService.userLocationStream.stream.last.then((prevData) => prevData = prevData);
            print((hasLocation != null).toString() + " hasData");
            print(hasLocation.toString()+ " hasLocation" + queryingService.userLocation.toString() + " userLocation");
            if(hasLocation == null && queryingService.userLocation == null)
              return Scaffold(
                body: Center(
                  child: SpinningLogo(),
                )
              );
            else if(hasLocation == false || prevData == false) // Permission for location denied
              return Scaffold(body: Container(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/wine-street-logo.png',
                          width:50
                        ),
                        SizedBox(height: 30,),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Wine Street nu are acces la locatie :(\n"

                              ),
                              TextSpan(
                                text: "Va rugam sa permiteti accesul din setari.\n\n\n"
                              ),
                              
                              WidgetSpan(
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  color: Theme.of(context).highlightColor,
                                  child: Text("Solicita acces", style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: (){
                                    QueryService().askPermission();
                                  },
                                  )
                              )                          
                            ],
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          
                        ),
                      ],
                    ),
                  ));
            else{
              print(user.toString() + 'din provider');
                if(user != null)
                  return StreamProvider<bool?>.value(
                    initialData: null,
                    value: authService.loading,
                    builder: (context, child) {
                      var isLoading = Provider.of<bool?>(context);
                      if(isLoading == null && authService.isLoading == null)
                        return Scaffold(body: Center(child: SpinningLogo(),),);
                      else if(authService.currentUser!.isManager == true)
                        return AdminPanel();
                      // else if(g.isNewUser)
                      //   return SlideShowIntro();
                      else
                        /// Changed for WineStreet
                        return HomeMapPage();
                    }
                  ); 
                else
                  return Authenticate();
              }
            }
          );
      }
}

