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

  @override
  Widget build(BuildContext context) {
    

    return Theme(
      data: ThemeData(
        primaryColor: Colors.orange[600],
        highlightColor: Colors.orange[600]
      ),
        child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Center(
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
                            if(registerResult == null)
                              print("register-failed");
                            else{
                              Navigator.of(context).pop();
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
        )
      ),
    );
  }
}