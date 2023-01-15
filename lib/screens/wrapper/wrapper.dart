import 'package:authentication/authentication.dart';
import 'package:authentication/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/LoadingScreen.dart';
import 'package:hyuga_app/screens/authentication/authentication_page.dart';
import 'package:hyuga_app/screens/authentication/authentication_provider.dart';
import 'package:hyuga_app/screens/manager/AdminPanel_Page.dart';
import 'package:hyuga_app/screens/manager_wrapper_home/manager_wrapper_home_page.dart';
import 'package:hyuga_app/screens/manager_wrapper_home/manager_wrapper_home_provider.dart';
import 'package:hyuga_app/screens/onboarding/onboarding_page.dart';
import 'package:hyuga_app/screens/onboarding/onboarding_provider.dart';
import 'package:hyuga_app/screens/web_version/web_landing_page.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_page.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/widgets/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wrapper_provider.dart';


/// Wrapper for the Authentification Screen and the MainMenu Screen
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context); 
    final userProfile = Provider.of<UserProfile?>(context);
    final provider = context.watch<WrapperProvider>();
    if(kIsWeb) // The Web Landing Page
      return WebLandingPage();
    // final hasLocationServiceEnabled = Provider.of<bool?>(context);
    // print("user: " + user.toString() + ' locatie pornita: '+ hasLocationServiceEnabled.toString());
        // if(hasLocationServiceEnabled != null)
        // if(hasLocationServiceEnabled == false) /// Changed from '==false' to '!=false' due to a strange bug in location service
        //   return Scaffold( /// Location not enabled
        //     body: Container(
        //       padding: EdgeInsets.only(left: 30),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Image.asset(
        //             'assets/images/wine-street-logo.png',
        //             //'assets/images/hyuga-logo.png',
        //             width:50
        //           ),
        //           SizedBox(height: 30,),
        //           RichText(
        //             textAlign: TextAlign.center,
        //             text: TextSpan(
        //               children: [
        //                 TextSpan(
        //                   text: "Wine Street nu poate functiona fara locatie :(\n"

        //                 ),
        //                 TextSpan(
        //                   text: "Porneste locatia din setari.\n\n\n"
        //                 ),
                        
        //                 WidgetSpan(
        //                   child: RaisedButton(
        //                     shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(20)
        //                     ),
        //                     color: Theme.of(context).highlightColor,
        //                     child: Text("Solicita locatia", style: TextStyle(fontWeight: FontWeight.bold)),
        //                     onPressed: (){
        //                       QueryService().checkAndRequestForLocationService();
        //                     },
        //                   )
        //                 )                          
        //               ],
        //               style: TextStyle(
        //                 fontFamily: 'Comfortaa',
        //                 fontSize: 16,
        //                 color: Colors.black,
        //                 fontWeight: FontWeight.bold
        //               )
        //             ),
                    
        //           ),
        //         ],
        //       ),
        //     )
        // );
        // return StreamProvider<bool?>.value(
        //   initialData: null,
        //   value: QueryService.userLocationStream.stream,
        //   builder: (context, child) {
        //       print(user.toString() + 'din provider');
        print("user profile " + Authentication.currentUserProfile.toString() );
        if(user != null)
          if(Authentication.isLoading)
            return LoadingPage();
          else{
            if(Authentication.currentUserProfile != null && !Authentication.currentUserProfile!.isAnonymous! && Authentication.currentUserProfile!.isManager!)
              return ChangeNotifierProvider(
                create: (_) => ManagerWrapperHomePageProvider(),
                child: ManagerWrapperHomePage()
              );
            else return ChangeNotifierProvider(
              create: (context) => WrapperHomePageProvider(context),
              //lazy: false,
              child: WrapperHomePage()
            );
          }
          // return StreamProvider<bool?>.value(
          //   initialData: null,
          //   value: authService.loading,
          //   builder: (context, child) {
          //     var isLoading = Provider.of<bool?>(context);
          //     if(isLoading == null && authService.isLoading == null)
          //       return Scaffold(body: Center(child: SpinningLogo(),),);
          //     else if(authService.currentUser!.isManager == true)
          //       return AdminPanel();
          //     // else if(g.isNewUser)
          //     //   return SlideShowIntro();
          //     else
          //       /// Changed for WineStreet
          //       return ChangeNotifierProvider(
          //         create: (context) => WrapperHomePageProvider(context),
          //         child: WrapperHomePage()
          //       );
          //   }
          // ); 
        
        /// Check if the user is new and has seen the onboarding screen
        else return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, AsyncSnapshot<SharedPreferences> snapshot){
            switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return LoadingPage();
            default:
              if (!snapshot.hasError) {
                return snapshot.data!.getBool("welcome") != null
                    ? ChangeNotifierProvider(
                      create: (context) => AuthenticationPageProvider(),
                      child: AuthenticationPage()
                    )
                    : MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (context) => OnboardingPageProvider(),),
                          ChangeNotifierProvider.value(value: provider)
                        ],
                        child: OnboardingPage()
                    );
              } else {
                return ChangeNotifierProvider(
                  create: (context) => AuthenticationPageProvider(),
                  child: AuthenticationPage()
                );
              }
          }
          },
        );
        
          // return ChangeNotifierProvider(
          //   create: (_) => AuthenticationPageProvider(),
          //   child: AuthenticationPage()
          // );
      }
            // }
          // );
      // }
}

