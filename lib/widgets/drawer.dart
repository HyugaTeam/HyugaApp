import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/AdminPanel_Page.dart';
import 'package:hyuga_app/widgets/UserQRCode_Page.dart';

class ProfileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: StreamBuilder<User>( 
          stream: authService.user,
          builder: (context, snapshot) {
            if(snapshot.hasData && !snapshot.data.isAnonymous)
              return Column(  // The StreamBuilder returns this path if the user is logged in and NOT anonymous
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
                          Container(
                            width: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                snapshot.data.photoURL,
                                width: 50,
                                // frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
                                //   return Padding(
                                //     padding: EdgeInsets.all(8.0),
                                //     child: child,
                                //   );
                                // },
                                // loadingBuilder: (context, child, loadingProgress){
                                //   if(loadingProgress == null)
                                //     return child;
                                //   return CircularProgressIndicator(
                                //     value: loadingProgress.expectedTotalBytes != null
                                //         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                //         : null,
                                //   );
                                //   //return child;
                                // },
                                errorBuilder: (context, error, stacktrace){
                                  return Image.asset(
                                    'assets/images/empty-profile.png',
                                    width:50
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                          snapshot.data.displayName,
                          style: TextStyle(
                            fontSize: 20,
                          fontWeight: FontWeight.bold
                          )
                            )
                        ]
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(), // used to disable scroll
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        ListTile(leading: FaIcon(Icons.place, color: Colors.blueGrey,), 
                          title: Text('My places'), 
                          onTap: (){}
                        ),
                        ListTile(
                          leading: FaIcon(FontAwesomeIcons.qrcode, color: Colors.blueGrey), 
                          title: Text('My code'), 
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){ return UserQRCode(); }));
                          }
                        ),
                        authService.currentUser.isManager == true ? 
                        ListTile(
                          leading: FaIcon(FontAwesomeIcons.chartLine, color: Colors.blueGrey),
                          title: Text('Admin Panel'),
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){ return AdminPanel(); }));
                          },
                        ) 
                        : Container(), 
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
                                if(authService.user == null)
                                  print("Daskhfjghfjsdf");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            else 
              return Column(  // The StreamBuilder returns this path if the user is logged out or anonymous
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
                  Expanded(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(), /// used to disable scroll
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container( // sign-out button
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.orange[600],
                            splashColor: Colors.deepOrangeAccent,
                            child: Text("Log in"),
                            onPressed: () async {
                              await AuthService().signOut();
                              if(AuthService().user == null)
                                print("Daskhfjghfjsdf");
                              //Navigator.of(context).push<Route>(MaterialPageRoute(builder: (context) => SignIn() ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
          }
        ),
      );
  }
}