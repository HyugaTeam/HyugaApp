import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/drawer/ReservationsHistory_Page.dart.dart';
import 'package:hyuga_app/screens/drawer/ask_for_help_page.dart';
import 'package:hyuga_app/screens/drawer/events_page.dart';
import 'package:hyuga_app/services/auth_service.dart';

class ProfileDrawer extends StatelessWidget {
  String? username = "" ;
  ProfileDrawer(){
    if(Authentication.auth.currentUser!.displayName != null)
      username = Authentication.auth.currentUser!.displayName;
    else if(Authentication.auth.currentUser!.email != null)
     username = Authentication.auth.currentUser!.email!.substring(0,Authentication.auth.currentUser!.email!.indexOf('@'));
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: StreamBuilder( 
          stream: Authentication.user,
          builder: (context, snapshot) {
            if(snapshot.hasData && !Authentication.auth.currentUser!.isAnonymous)
              return Column(  // The StreamBuilder returns this path if the user is LOGGED IN and NOT ANONYMOUS
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.only(left: 15, bottom: 15),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Container( 
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column( // Column containing the ProfilePicture and DisplayName
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[ 
                              Container(
                                width: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    Authentication.auth.currentUser!.photoURL != null? Authentication.auth.currentUser!.photoURL! : '',
                                    width: 50,
                                    loadingBuilder: (context, child, loadingProgress){
                                      if(loadingProgress == null)
                                        return child;
                                      return CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      );
                                    },
                                    errorBuilder: (context, error, stacktrace){
                                      print(Authentication.auth.currentUser!.photoURL);
                                      return Image.asset(
                                        'assets/images/empty-profile.png',
                                        width:50
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text(// Shows either the user's display name, or the email used for registration
                                username!,
                                style: TextStyle(
                                  fontSize: username!.length <16? 20 : 14,
                                fontWeight: FontWeight.bold
                                )
                              )
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        /// Either shows the 'Scan History' button or nothing depending on the user's 'manager' property
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //   return Authentication.auth.currentUser.isManager == null 
                        //     ? ListTile(leading: FaIcon(FontAwesomeIcons.percent, color: Theme.of(context).primaryColor, size: 20,), 
                        //         title: Text('Istoric scanari'), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ScannedLocalsPage(); }));
                        //         }
                        //     )
                        //     : Container();
                        //   }
                        // ),
                        Builder(
                          builder: (context){
                            final isManager = Authentication.currentUserProfile != null && Authentication.currentUserProfile!.isManager!;
                            if(isManager)
                              return ListTile(leading: FaIcon(FontAwesomeIcons.calendar, color: Theme.of(context).primaryColor, size: 20), 
                                title: Text('Evenimente'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return EventsPage(); }));
                                }
                            );
                            return Container();
                          },
                        ),
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //   return Authentication.auth.currentUser!.isManager == null 
                        //     ? ListTile(leading: FaIcon(FontAwesomeIcons.calendar, color: Theme.of(context).primaryColor, size: 20), 
                        //         title: Text('Evenimente'), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return EventsPage(); }));
                        //         }
                        //     )
                        //     : Container();
                        //   }
                        // ),
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //   return Authentication.auth.currentUser!.isManager == null 
                        //     ? ListTile(leading: FaIcon(FontAwesomeIcons.bookOpen, color: Theme.of(context).primaryColor, size: 20), 
                        //         title: Text('Istoric rezervări'), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ReservationsHistoryPage(); }));
                        //         }
                        //     )
                        //     : Container();
                        //   }
                        // ),


                        /// Either shows the 'My Code' button or nothing depending on the user's 'manager' property
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //     return Authentication.auth.currentUser!.isManager == null 
                        //       ? ListTile(
                        //         leading: FaIcon(FontAwesomeIcons.qrcode, color: Theme.of(context).primaryColor), 
                        //         title: Text('Codul meu'), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return UserQRCode(context); }));
                        //         }
                        //       )
                        //       : Container();
                        //   }
                        // ),
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //     return Authentication.auth.currentUser!.isManager == null 
                        //       ? ListTile(
                        //         //tileColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        //         leading: FaIcon(FontAwesomeIcons.questionCircle, color: Theme.of(context).primaryColor), 
                        //         title: Text(
                        //           'Ajutor'
                        //         ), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return AskForHelpPage(); }));
                        //         }
                        //       )
                        //       : Container();
                        //   }
                        // ),
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //     return Authentication.auth.currentUser!.isManager == null 
                        //       ? ListTile(
                        //         tileColor: Theme.of(context).accentColor.withOpacity(0.5),
                        //         leading: FaIcon(FontAwesomeIcons.gem, color: Theme.of(context).accentColor), 
                        //         title: Text(
                        //           'Premium',
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.bold
                        //           )
                        //         ), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return SubscribePaymentPage(); }));
                        //         }
                        //       )
                        //       : Container();
                        //   }
                        // ),
                        // The 'Activate table' button
                        // StreamBuilder<bool>(
                        //   stream: Authentication.auth.loading.stream,
                        //   builder: (context, snapshot) {
                        //     return Authentication.auth.currentUser.isManager == null 
                        //       ? ListTile(
                        //         leading: FaIcon(FontAwesomeIcons.camera, color: Colors.blueGrey), 
                        //         title: Text('Activeaza masa'), 
                        //         onTap: (){
                        //           Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ScanPlaceCode(context: context,); }));
                        //         }
                        //       )
                        //       : Container();
                        //   }
                        // ),
                        Expanded(
                          child: Container(),
                        ),
                        ListTile(
                          title: Container( // sign-out button
                            padding: EdgeInsets.symmetric(horizontal: 80),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Theme.of(context).primaryColor,
                              splashColor: Colors.deepOrangeAccent,
                              child: Text("Log out"),
                              onPressed: () async {
                                await Authentication.auth.signOut();
                                Navigator.popUntil(context, (route){
                                  if(route.isFirst)
                                    return true;
                                  return false;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.05,
                        )
                      ],
                    ),
                  ),
                ],
              );
            else 
              return Column(  // The StreamBuilder returns this path if the user is LOGGED OUT or ANONYMOUS
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.only(left: 15, bottom: 15),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[ 
                          Padding( /// The profile picture
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/empty-profile.png',
                                width:50
                              )
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            'Guest',
                            style: TextStyle(
                              fontSize: 20,
                            fontWeight: FontWeight.bold
                            )
                          )
                        ]
                      ),
                    ),
                  ),
                  Spacer(),
                  Container( // sign-out button
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Theme.of(context).primaryColor,
                      splashColor: Colors.deepOrangeAccent,
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      onPressed: () async {
                        await Authentication.auth.signOut();
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              );
          }
        ),
      );
  }
}