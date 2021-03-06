import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/authenticate/register.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  //final AuthService authService = AuthService();
  String email;
  String password;
  bool formVisibility = false;

  void handleAuthError(BuildContext context, signInResult){

    void showErrorSnackBar(String message){
      if(g.isSnackBarActive == false){
        g.isSnackBarActive = true;
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          )
        ).closed.then((reason) => g.isSnackBarActive = false);

      }
    }
    if(signInResult.code == 'ERROR_INVALID_CREDENTIAL')
      showErrorSnackBar( "The selected credential is invalid!");
    if(signInResult.code == 'ERROR_USER_DISABLED') 
      showErrorSnackBar( "The entered email is invalid!");
    if(signInResult.code == 'ERROR_EMAIL_ALREADY_IN_USE') 
      showErrorSnackBar("The entered email is already in use! Try another sign-in method.");
    if(signInResult.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL")
      showErrorSnackBar("The email used is already used by another account.");
}

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 15,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold
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
              SizedBox(height: 130),
              Text( // Hello text
                'Hello!',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 40
                ),
              ),
              Text(
                "Let's log in!",
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
                        print(signInResult.user.uid);
                      }
                  }
                )
              ),

              // DropdownButton<Widget>(
              //   value: Text("Continue with email"),
              //   onChanged: (Widget widget) => setState(() => ),
              // ),
              MaterialButton(  /// continue with email button
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
                    children: <Widget>[
                      FaIcon(FontAwesomeIcons.solidEnvelope, color:  Colors.blueGrey,),
                      Container(width: 80,),
                      Text("Continue with email"),
                    ],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    formVisibility = !formVisibility;
                  });
                },
                ),
              Visibility(
                maintainState: true,
                maintainAnimation: true,
                visible: formVisibility,
                replacement: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black26
                    )
                  ),
                  //padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Container(  // The form for Email+Password sign-in method
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
                        RaisedButton(  /// "Sign-In" button
                          
                          child: Text("Sign in"),
                          onPressed: () async{
                            print(email);
                            print(password);
                            dynamic signInResult = await authService.signInWithEmailAndPassword(email, password);
                            if(signInResult.runtimeType == PlatformException) 
                              handleAuthError(context, signInResult);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Don't have an account?"),
                            Container(
                              // constraints: BoxConstraints(
                              //   minWidth: 40,
                              //   maxWidth: 50,
                              //   minHeight: 20,
                              //   maxHeight: 20 
                              // ),
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                              child: InkWell(   /// "Register with Email" button
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.orange[600]
                                  ),
                                ),
                                //splashColor: Colors.transparent,
                                //focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Register()));
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ),
                ),
                ),
              ),
              //SizedBox(height:40),
              SizedBox(height: 20),
              MaterialButton(   /// Continue with Google button
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FaIcon(FontAwesomeIcons.google,color: Colors.blueGrey,),
                      Container(width: 80,),
                      Text("Continue with Google"),
                    ],
                  ),
                ),
                onPressed: (){
                  dynamic signInResult = authService.signInWithGoogle(); 
                  if(signInResult.runtimeType == PlatformException) 
                    handleAuthError(context, signInResult);
                },
              ),
              SizedBox(height: 20),
              MaterialButton(   /// Continue with Facebook button
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
                    children: <Widget>[
                      FaIcon(FontAwesomeIcons.facebook, color: Colors.blueGrey,),
                      Container(width: 80,),
                      Text("Continue with Facebook"),
                    ],
                  ),
                ),
                onPressed: (){
                  dynamic signInResult = authService.signInWithFacebook();
                  if(signInResult.runtimeType == PlatformException) 
                    handleAuthError(context, signInResult);  
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