import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  var _formKey = GlobalKey<FormState>();
  String email;
  String password;

  void showErrorSnackBar(BuildContext context, String message){
    if(g.isSnackBarActive == false){
      g.isSnackBarActive = true;
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).highlightColor,
        )
      ).closed.then((value) => g.isSnackBarActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Theme(
      data: ThemeData(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.orange[600]
        ),
        primaryColor: Theme.of(context).accentColor,
        highlightColor: Theme.of(context).accentColor
      ),
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarOpacity: 0.5,
          elevation: 0,
        ),
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context)=>Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 200),
                Text(
                  'Inregistrare',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 40
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (input) => input.isEmpty ? "You must enter an email" : null,
                          decoration: InputDecoration(
                            focusColor: Theme.of(context).accentColor,
                            labelText: 'Email',
                            hoverColor: Colors.orange[600]
                          ),
                          onChanged: (value){
                            setState(()=>email = value);
                          }
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (input) => input.length < 6 ? "Your password must have at least 6 characters" : null,
                          decoration: InputDecoration(
                            labelText: 'Parola',
                            fillColor: Colors.orange[600]
                          ),
                          obscureText: true,
                          onChanged: (value){
                           setState(()=>password = value);
                          },
                        ),
                        SizedBox(height: 20),
                        RaisedButton(
                          elevation: 0,
                          highlightElevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Theme.of(context).highlightColor,
                          child: Text("Sign up"),
                          onPressed: () async{
                            if(_formKey.currentState.validate()){
                              print(email);
                              print(password);
                              dynamic registerResult = await authService.registerWithEmailAndPassword(email, password);
                              //print(registerResult.toString());
                              if(registerResult.runtimeType == FirebaseAuthException){
                                FirebaseAuthException authException = registerResult;
                                if(authException.code == 'weak-password')
                                  showErrorSnackBar(context, "Parola este prea slaba");
                                if(authException.code == 'invalid-email') 
                                  showErrorSnackBar(context, "Emailul este invalid");
                                if(authException.code == 'email-already-in-use') 
                                  showErrorSnackBar(context, "Emailul este deja folosit.");
                              }
                              else if(registerResult is UserCredential){ // not actually an error, but that's the name of the method
                                showErrorSnackBar(context, 'Registered succesfully!');
                                Navigator.pop(context);
                              } 
                              else{
                                showErrorSnackBar(context, 'There was an error');
                              }
                            }
                          },
                        ),
                      ],
                    )
                  ),
                ) ///log in form
              ],
            ),
          ),
        )
      ),
    );
  }
}