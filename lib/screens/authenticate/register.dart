import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  var _formKey = GlobalKey<FormState>();
  String email;
  String password;

  void showErrorSnackBar(BuildContext context, String message){
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return Theme(
      data: ThemeData(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.orange[600]
        ),
        primaryColor: Colors.orange[600],
        highlightColor: Colors.orange[600]
      ),
        child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context)=>Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 200),
                Text(
                  'Register',
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
                            labelText: 'Password',
                            fillColor: Colors.orange[600]
                          ),
                          obscureText: true,
                          onChanged: (value){
                           setState(()=>password = value);
                          },
                        ),
                        SizedBox(height: 20),
                        RaisedButton(
                          child: Text("Sign up"),
                          onPressed: () async{
                            if(_formKey.currentState.validate()){
                              print(email);
                              print(password);
                              dynamic registerResult = await authService.registerWithEmailAndPassword(email, password);
                              //print(registerResult.toString());
                              if(registerResult.code == 'ERROR_WEAK_PASSWORD')
                                showErrorSnackBar(context, "The password is too weak!");
                              if(registerResult.code == 'ERROR_INVALID_EMAIL') 
                                showErrorSnackBar(context, "The entered email is invalid!");
                              if(registerResult.code == 'ERROR_EMAIL_ALREADY_IN_USE') 
                                showErrorSnackBar(context, "The entered email is already in use!");
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