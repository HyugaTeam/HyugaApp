import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/authenticate/register.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  //final AuthService authService = AuthService();
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 15,
            color: Colors.blueGrey,
          )
        ),
        buttonTheme: ButtonThemeData(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          minWidth: 230,
          buttonColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        primaryColor: Colors.black45,
        highlightColor: Colors.orange[600]
      ),
      child: Scaffold(
      resizeToAvoidBottomPadding: false,
      //backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 150),
            Text(
              'Hello!',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 40
              ),
            ),
            Text(
              "Let's log in!",
              style: TextStyle(
                
              ),
            ),
            Container(  // sign-in anonymously button
              padding: EdgeInsets.symmetric(vertical:20,horizontal:50),
              child: MaterialButton(
                splashColor: Colors.orange[100],
                color: Colors.orange[600],
                minWidth: 150,
                height: 35,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  "Skip for now",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () async{
                    dynamic signInResult = await authService.signInAnon(); // it either returns a user
                    if(signInResult == null)
                      print('sign-in failed');
                    else {
                      print(signInResult.uid);
                    }
                }
              )
            ),
            Container(  // The form for Email+Password sign-in method
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Form(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hoverColor: Colors.blue
                      ),
                      // controller: TextEditingController(
                      //   text: "asjdasjd",
                      // ),
                      onChanged: (value){
                        setState(()=> email = value);
                      }
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        fillColor: Colors.orange[600]
                      ),
                      obscureText: true,
                      onChanged: (value){
                        setState(()=>password = value);
                      },
                    ),
                    SizedBox(height: 20),
                    RaisedButton(  /// sign-in button
                      
                      child: Text("Sign in"),
                      onPressed: () async{
                        print(email);
                        print(password);
                        dynamic signInResult = await authService.signInWithEmailAndPassword(email, password);
                        if(signInResult == null)
                          print('sign-in failed');
                        else{
                          print(signInResult.uid);
                        }
                      },
                    ),
                  ],
                )
              ),
            ),
            //SizedBox(height:40),
            RaisedButton(   /// Register with Email button
              child: Text("Register with email"),
              onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Register()));
              },
            ),
            SizedBox(height: 20),
            RaisedButton(   /// Continue with Google button
              child: Text("Continue with Google"),
              onPressed: (){
                dynamic result = authService.signInWithGoogle();  
              },
            ),
            SizedBox(height: 20),
            RaisedButton(   /// Continue with Facebook button
              child: Text("Continue with Facebook"),
              onPressed: (){
                dynamic result = authService.signInWithFacebook();  
              },
            ),
            ],
          ),
        ),
      )
      ),
    );
  }
}