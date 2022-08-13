import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/register/register_provider.dart';
import 'package:hyuga_app/services/auth_service.dart';

class RegisterPage extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<RegisterPageProvider>();
    return Theme(
      data: ThemeData(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.orange[600]
        ),
        primaryColor: Theme.of(context).primaryColor,
        highlightColor: Theme.of(context).primaryColor
      ),
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarOpacity: 0.5,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context)=>Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 200),
                Text(
                  'Înregistrare',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 40
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: provider.formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (input) => input!.isEmpty ? "You must enter an email" : null,
                          decoration: InputDecoration(
                            focusColor: Theme.of(context).primaryColor,
                            labelText: 'Email',
                            hoverColor: Colors.orange[600]
                          ),
                          onChanged: provider.updateEmail
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (input) => input!.length < 6 ? "Your password must have at least 6 characters" : null,
                          decoration: InputDecoration(
                            labelText: 'Parola',
                            fillColor: Colors.orange[600]
                          ),
                          obscureText: true,
                          onChanged: provider.updatePassword
                        ),
                        SizedBox(height: 20),
                        RaisedButton(
                          elevation: 0,
                          highlightElevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Theme.of(context).highlightColor,
                          child: Text("Sign up"),
                          onPressed: () async{
                            if(provider.formKey.currentState!.validate()){
                              dynamic registerResult = await authService.registerWithEmailAndPassword(provider.email!, provider.password!);
                              //print(registerResult.toString());
                              if(registerResult.runtimeType == FirebaseException){
                                FirebaseException authException = registerResult;
                                if(authException.code == 'weak-password')
                                  provider.showErrorSnackBar(context, "Parola este prea slaba");
                                if(authException.code == 'invalid-email') 
                                  provider.showErrorSnackBar(context, "Emailul este invalid");
                                if(authException.code == 'email-already-in-use') 
                                  provider.showErrorSnackBar(context, "Emailul este deja folosit.");
                              }
                              else if(registerResult is User){ // not actually an error, but that's the name of the method
                                provider.showErrorSnackBar(context, 'Registered succesfully!');
                                Navigator.pop(context);
                              } 
                              else{
                                provider.showErrorSnackBar(context, 'There was an error');
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