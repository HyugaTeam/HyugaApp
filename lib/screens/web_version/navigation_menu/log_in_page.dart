import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/web_version/navbar.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class LogInWebPage extends StatefulWidget {

  static const String route = "/log-in";

  @override
  _LogInWebPageState createState() => _LogInWebPageState();
}

class _LogInWebPageState extends State<LogInWebPage> {
  GlobalKey _formFieldKey = GlobalKey();

  late String _email;

  late String _password;

  void showErrorSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).highlightColor,
      )
    );
  }

  void handleAuthError(BuildContext context, FirebaseException signInResult){
    print("code"+signInResult.code);
    if(signInResult.code == 'user-not-found')
      showErrorSnackBar(context, "Combinatia email+parola este gresita");
    if(signInResult.code == 'wrong-password')
      showErrorSnackBar(context, "Parola este gresita");
    if(signInResult.code == 'ERROR_USER_DISABLED') 
      showErrorSnackBar(context, "unknown");
    if(signInResult.code == 'A aparut o eroare, incearca din nou') 
      showErrorSnackBar(context, "The entered email is already in use! Try another sign-in method.");
    if(signInResult.code == "invalid-email")
      showErrorSnackBar(context, "Emailul este gresit");
  }

  Widget _buildSocialButton(BuildContext context, String text, Function signIn, Widget icon){
    return  MaterialButton(   /// Continue with Google button
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          width: 1,
          color: Colors.black26
        )
      ),
      minWidth: 360,
      height: 50,
      child: Container(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            icon,
            Text(text),
          ],
        ),
      ),
      onPressed: () async{
        await signIn().then((signInResult){
          if(signInResult.runtimeType == PlatformException) 
            handleAuthError(context, signInResult);
          else Navigator.pushReplacementNamed(context, 'wrapper/');
          }
        );
        //dynamic signInResult = await signIn(); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width*0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Left Side
              _buildLogInForm(),
              ///Spacer
              Container(height: 200,width: 1,color: Theme.of(context).primaryColor,),
              ///Right Side
              Container(
                height: 250,
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(context, "Continuă prin Google", authService.signInWithGoogle, Image.asset('assets/images/google-logo-icon.png',width: 24,),),
                    _buildSocialButton(context, "Continuă prin Facebook", authService.signInWithFacebook, FaIcon(FontAwesomeIcons.facebook, color: Colors.blue,)),
                    _buildSocialButton(context, "Continuă prin Apple", authService.signInWithApple, FaIcon(FontAwesomeIcons.apple, color: Colors.black,),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogInForm() {
    return Container(
      width: 500,
      height: 300,
      margin: EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Container(  // The form for Email+Password sign-in method
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: Form(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextFormField( /// Email form field
              key: _formFieldKey,
              decoration: InputDecoration(
                labelText: 'Email',
                hoverColor: Colors.blue,
                labelStyle: TextStyle(
                  color: Colors.black
                )
              ),
              onChanged: (value){
                setState(()=> _email = value.trim());
              }
            ),
            SizedBox(height: 20),
            TextFormField( /// Password form field
              decoration: InputDecoration(
                labelText: 'Password',
                fillColor: Colors.orange[600],
                labelStyle: TextStyle(
                  color: Colors.black
                )
              ),
              obscureText: true,
              onChanged: (value){
                setState(()=> _password = value);
              },
            ),
            SizedBox(height: 20),
            RaisedButton(  /// "Sign-In" button
              
              child: Text("Log in"),
              onPressed: () async{
                dynamic signInResult = await authService.signInWithEmailAndPassword(_email, _password);
                //print(signInResult.runtimeType);
                if(signInResult.runtimeType == FirebaseException) {
                  FirebaseException authException = signInResult;
                  handleAuthError(context, authException);
                }
              },
            ),
            SizedBox(height: 20),
            Container(
              width: 500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Nu ai cont?"),
                  Container(
                    child: InkWell(   /// "Register with Email" button
                      child: Text(
                        "Înregistrare",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      highlightColor: Colors.transparent,
                      onTap: (){
                          //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> Register()));
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ),
    ),
  );
  }
}