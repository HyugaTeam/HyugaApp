import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/drawer/ScannedLocals_Page.dart';
import 'package:hyuga_app/screens/manager/AdminPanel_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/UserQRCode_Page.dart';

// class ProgressColorAnimation extends Animation{
//   @override
//   void addStatusListener(){

//   }
// }

class ProfileDrawer extends StatelessWidget {


  // double _progress;
  //  ProfileDrawer(){
  //    try{
  //     _progress = authService.currentUser.score.toDouble() / (authService.currentUser.getLevel()*500);
  //    }
  //    catch(error){
  //      print(error);
  //    }
  //  }
  String username = "" ;
  ProfileDrawer(){
    if(authService.currentUser.displayName != null)
      username = authService.currentUser.displayName;
    else if(authService.currentUser.email != null)
     username = authService.currentUser.email.substring(0,authService.currentUser.email.indexOf('@'));
  }
  
  @override
  Widget build(BuildContext context) {
    
    String _progress;
    try{
      if(authService.currentUser.score >=2500)
        _progress = '2500 / ' + (authService.currentUser.getLevel()*500).toString();
      else
        _progress = authService.currentUser.score.toString() + ' / ' + (authService.currentUser.getLevel()*500).toString();
    }
    catch(error){
      _progress = '';
    }
    

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
                                    // frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
                                    //   return child;
                                    // },
                                    loadingBuilder: (context, child, loadingProgress){
                                      if(loadingProgress == null)
                                        return child;
                                      return CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                            : null,
                                      );
                                      //return child;
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
                          Container(
                            padding: EdgeInsets.only(right: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                // REMOVED LEVEL TEMPORARILY
                                // Text(
                                //   "Level " + authService.currentUser.getLevel().toString(),
                                //   style: TextStyle(
                                //     fontSize: 20,
                                //     color: Colors.orange[600],
                                //     shadows: [Shadow(
                                //       color: Colors.black,
                                //       blurRadius: 1.5,
                                //       offset: Offset(1,1)
                                //     )]
                                //   ),
                                // ),
                                // Stack(
                                //   alignment: Alignment.center,
                                //   children: [
                                //     Container( // User's progress indicator for level
                                //       padding: EdgeInsets.only(top: 10),
                                //       width: 120,
                                //       height: 25,
                                //       child: LinearProgressIndicator(
                                //         valueColor: AlwaysStoppedAnimation(Colors.orange[600]),
                                //         //valueColor: C,
                                //         value: authService.currentUser.score.toDouble() 
                                //       ),
                                //     ),
                                //     Container( // Text (some sort of ratio) with User's score / necessary score for the next level
                                //       alignment: Alignment.center,
                                //       margin: EdgeInsets.only(top:12),
                                //       //padding: EdgeInsets.only(top: 10),
                                //       width: 100,
                                //       height: 20,
                                //       child: Text(
                                //         _progress
                                //       ),
                                //     )
                                //   ]
                                // )
                                
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(), // used to disable scroll
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        /// Either shows the 'Scan History' button or nothing depending on the user's 'manager' property
                        StreamBuilder<bool>(
                          stream: authService.loading.stream,
                          builder: (context, snapshot) {
                          return authService.currentUser.isManager == null 
                            ? ListTile(leading: FaIcon(Icons.place, color: Colors.blueGrey,), 
                                title: Text('Scan History'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ScannedLocalsPage(); }));
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
                                title: Text('My code'), 
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return UserQRCode(context); }));
                                }
                              )
                              : Container();
                          }
                        ),
                        // authService.currentUser.isManager == true ? 
                        // ListTile(
                        //   leading: FaIcon(FontAwesomeIcons.chartLine, color: Colors.blueGrey),
                        //   title: Text('Admin Panel'),
                        //   onTap: (){
                        //     Navigator.of(context).push(MaterialPageRoute(builder: (context){ return AdminPanel(); }));
                        //   },
                        // ) 
                        // : Container(), 
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
                              await authService.signOut();
                              if(authService.user == null)
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