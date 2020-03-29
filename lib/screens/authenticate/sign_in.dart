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
    return Theme(
      data: ThemeData(
        primaryColor: Colors.blueGrey,
        highlightColor: Colors.orange[600]
      ),
        child: Scaffold(
        
        backgroundColor: Colors.blueGrey,
        
        body: Center(
          child: Column(
            children: <Widget>[
              Spacer(),
              Text(
                'Hello!',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 30
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical:20,horizontal:50),
                child: MaterialButton(
                  splashColor: Colors.orange[100],
                  color: Colors.orange[600],
                  minWidth: 120,
                  height: 35,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "Let's go!",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () async{
                      dynamic signInResult = await _authService.signInAnon(); // it either returns a user
                      if(signInResult == null)
                        print('sign-in failed');
                      else {
                        Navigator.popAndPushNamed(context, '/');
                        print(signInResult.uid);
                      }
                  }
                )
              ),
              Spacer()
            ],
          ),
        )
      ),
    );
  }
}