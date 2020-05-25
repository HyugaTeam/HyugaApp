import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/user.dart';
import 'package:hyuga_app/services/auth_service.dart';

class ProfileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: StreamBuilder<User>(
          stream: authService.user,
          builder: (context, snapshot) {
            if(snapshot.hasData)
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.all(100),
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    child: Text('hello'),
                  ),
                  ListTile(leading: Icon(Icons.place), title: Text('My places')),
                  ListTile(leading: Icon(Icons.code),title: Text('My code')),
                  Container( // sign-out button
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.orange[600],
                      splashColor: Colors.deepOrangeAccent,
                      child: Text("Log out"),
                      onPressed: () async{
                        await AuthService().signOut();
                        if(AuthService().user == null)
                          print("Daskhfjghfjsdf");
                      },
                    ),
                  )
                ],
              );
            else
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.all(100),
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    child: Text('hello'),
                  ),
                  ListTile(leading: Icon(Icons.place), title: Text('My places')),
                  ListTile(leading: Icon(Icons.code),title: Text('My code')),
                  Container( // sign-out button
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.orange[600],
                      splashColor: Colors.deepOrangeAccent,
                      child: Text("Log out"),
                      onPressed: () async{
                        await AuthService().signOut();
                        if(AuthService().user == null)
                          print("Daskhfjghfjsdf");
                      },
                    ),
                  )
                ],
              );
          }
        ),
      );
  }
}