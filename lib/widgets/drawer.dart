import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/drawer/ReservationsHistory_Page.dart.dart';
import 'package:hyuga_app/screens/drawer/ScanPlaceCode_Page.dart';
import 'package:hyuga_app/screens/drawer/ScannedLocals_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/drawer/UserQRCode_Page.dart';

class ProfileDrawer extends StatelessWidget {
  String username = "" ;
  ProfileDrawer(){
    if(authService.currentUser.displayName != null)
      username = authService.currentUser.displayName;
    else if(authService.currentUser.email != null)
     username = authService.currentUser.email.substring(0,authService.currentUser.email.indexOf('@'));
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: StreamBuilder( 
          stream: authService.user,
          builder: (context, snapshot) {
            if(snapshot.hasData && !authService.currentUser.isAnonymous)
              return Column(  // The StreamBuilder returns this path if the user is LOGGED IN and NOT ANONYMOUS
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.only(left: 15, bottom: 15),
                    decoration: BoxDecoration(color: Colors.blueGrey),
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
                                    authService.currentUser.photoURL != null? authService.currentUser.photoURL : '',
                                    width: 50,
                                    loadingBuilder: (context, child, loadingProgress){
                                      if(loadingProgress == null)
                                        return child;
                                      return CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                            : null,
                                      );
                                    },
                                    errorBuilder: (context, error, stacktrace){
                                      print(authService.currentUser.photoURL);
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
                                username,
                                style: TextStyle(
                                  fontSize: username.length <16? 20 : 14,
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
                        StreamBuilder<bool>(
                          stream: authService.loading.stream,
                          builder: (context, snapshot) {
                          return authService.currentUser.isManager == null 
                            ? ListTile(leading: FaIcon(FontAwesomeIcons.percent, color: Colors.blueGrey, size: 20,), 
                                title: Text('Istoric scanari'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ScannedLocalsPage(); }));
                                }
                            )
                            : Container();
                          }
                        ),
                        StreamBuilder<bool>(
                          stream: authService.loading.stream,
                          builder: (context, snapshot) {
                          return authService.currentUser.isManager == null 
                            ? ListTile(leading: FaIcon(FontAwesomeIcons.bookOpen, color: Colors.blueGrey, size: 20), 
                                title: Text('Istoric rezervari'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ReservationsHistoryPage(); }));
                                }
                            )
                            : Container();
                          }
                        ),
                        /// Either shows the 'My Code' button or nothing depending on the user's 'manager' property
                        StreamBuilder<bool>(
                          stream: authService.loading.stream,
                          builder: (context, snapshot) {
                            return authService.currentUser.isManager == null 
                              ? ListTile(
                                leading: FaIcon(FontAwesomeIcons.qrcode, color: Colors.blueGrey), 
                                title: Text('Codul meu'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return UserQRCode(context); }));
                                }
                              )
                              : Container();
                          }
                        ),
                        // The 'Activate table' button
                        // StreamBuilder<bool>(
                        //   stream: authService.loading.stream,
                        //   builder: (context, snapshot) {
                        //     return authService.currentUser.isManager == null 
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
                              color: Colors.orange[600],
                              splashColor: Colors.deepOrangeAccent,
                              child: Text("Log out"),
                              onPressed: () async {
                                await authService.signOut();
                                Navigator.popUntil(context, (route){
                                  if(route.isFirst)
                                    return true;
                                  return false;
                                });
                                if(authService.user == null)
                                  print("Daskhfjghfjsdf");
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
                    decoration: BoxDecoration(color: Colors.blueGrey),
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
                  Container( // sign-out button
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.orange[600],
                      splashColor: Colors.deepOrangeAccent,
                      child: Text("Log in",style: TextStyle(fontWeight: FontWeight.bold),),
                      onPressed: () async {
                        await authService.signOut();
                        if(authService.user == null)
                          print("Daskhfjghfjsdf");
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