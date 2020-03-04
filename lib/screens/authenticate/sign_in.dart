import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 10,
        title: Text(
          'Hello !',
          style: TextStyle(
            color: Theme.of(context).accentColor
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical:20,horizontal:50),
        child: RaisedButton(
          child: Text('Sign in as guest'),
          onPressed: () async{
              dynamic signInResult = await _authService.signInAnon(); // it either returns a user
              if(signInResult == null)
                print('sign-in failed');
              else {
                Navigator.pushNamed(context, '/');
                print(signInResult.uid);
              }
          }
        )
      )
    );
  }
}