import 'package:firebase_auth/firebase_auth.dart';
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

class _SignInState extends State<SignIn> with TickerProviderStateMixin {

  String email;
  String password;
  bool formVisibility = false;

  ScrollController _scrollController;
  GlobalKey _formFieldKey = GlobalKey();

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller, 
      curve: Curves.elasticInOut
    );
  }

  void showErrorSnackBar(BuildContext context, String message){
    if(g.isSnackBarActive == true){
      Scaffold.of(context).removeCurrentSnackBar();
    }
    if(g.isSnackBarActive == false){
      g.isSnackBarActive = true;
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).highlightColor,
        )
      ).closed.then((reason) => g.isSnackBarActive = false);
    }
  }
  void handleAuthError(BuildContext context, FirebaseAuthException signInResult){
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    g.resetSearchParameters(); /// Eventually called when the user logs out and the Home page no longer corresponds to the previous parameters

    return Theme(
      data: ThemeData(
        accentColor: Theme.of(context).accentColor,
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 15,
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Comfortaa'
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
        splashColor: Theme.of(context).accentColor,
        //highlightColor: Colors.black45,
        primaryColor: Theme.of(context).primaryColor
        
        //highlightColor: Colors.orange[600]
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (context) {
            _controller.forward();
            return ScaleTransition(
              scale: _animation,
              child: Center(
                child: ListView(
                  controller: _scrollController,
                  //padding: EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    /// Upper region
                    Container(
                      height: MediaQuery.of(context).size.height*0.35,
                      color: Theme.of(context).accentColor, 
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.1),
                          Center(
                            child: Image.asset(
                              'assets/images/wine-street-logo.png',
                              //'assets/images/hyuga-logo.png',
                              width: 80,
                            )
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text( // Hello text
                            'wine street',
                              //'hyuga',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 40
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                    /// Lower region
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)
                        ),
                        color: Colors.white,
                      ),
                      height: formVisibility
                      ? MediaQuery.of(context).size.height*0.65 + 100
                      : MediaQuery.of(context).size.height*0.65,
                      // height: MediaQuery.of(context).size.height*0.65,
                      child: Column(
                        children: [
                          Container(  // sign-in anonymously button
                            padding: EdgeInsets.symmetric(vertical:20,horizontal:95),
                            child: MaterialButton(
                              splashColor: Theme.of(context).accentColor,
                              //splashColor: Colors.orange[100],
                              color: Theme.of(context).accentColor,
                              minWidth: 150,
                              height: 35,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                "Sari peste", 
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Image.asset('assets/images/google-logo-icon.png',width: 24,),
                                  Text("Continua prin Google"),
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FaIcon(FontAwesomeIcons.facebook, color: Colors.blue,),
                                  Text("Continua prin Facebook"),
                                ],
                              ),
                            ),
                            onPressed: (){
                              dynamic signInResult = authService.signInWithFacebook();
                              if(signInResult.runtimeType == PlatformException) 
                                handleAuthError(context, signInResult);  
                            },
                          ),
                          g.isIOS 
                          ? SizedBox(height: 20,)
                          : Container(),
                          g.isIOS   // checks if the platform on which the app is ran is IOS
                          ? MaterialButton(   /// Continue with AppleID button
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FaIcon(FontAwesomeIcons.apple, color: Colors.black,),
                                  //Container(width: 80,),
                                  Text("Continua prin Apple"),
                                ],
                              ),
                            ),
                            onPressed: (){
                              authService.signInWithApple();
                            },
                          )
                          : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                style: BorderStyle.solid,
                                color: Colors.black26
                              )
                            ),
                            child: Column(
                              children: <Widget>[
                                MaterialButton(  /// The 'Continue with email' button
                                  shape: ContinuousRectangleBorder(
                                    side: BorderSide.none
                                  ),
                                  minWidth: 360,
                                  height: 50,
                                  child: Container(
                                    width: 300,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.solidEnvelope, color:  Colors.blueGrey,),
                                        Text("Continua prin email"),
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      formVisibility = !formVisibility;
                                    });
                                  },
                                  ),
                                  Visibility( // The dialog shown under the 'Continue with email' button
                                    maintainState: true,
                                    maintainAnimation: true,
                                    visible: formVisibility,
                                    replacement: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Container(  // The form for Email+Password sign-in method
                                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                                      child: Form(
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(height: 20),
                                            TextFormField(
                                              key: _formFieldKey,
                                              onTap: (){
                                                RenderBox field = _formFieldKey.currentContext.findRenderObject();
                                                print(field.localToGlobal(Offset.zero));
                                                _scrollController.animateTo(
                                                  field.localToGlobal(Offset.zero).dy, 
                                                  duration: Duration(milliseconds: 100), 
                                                curve: Curves.easeIn);
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                hoverColor: Colors.blue
                                              ),
                                              onChanged: (value){
                                                setState(()=> email = value.trim());
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
                                              
                                              child: Text("Log in"),
                                              onPressed: () async{
                                                dynamic signInResult = await authService.signInWithEmailAndPassword(email, password);
                                                //print(signInResult.runtimeType);
                                                if(signInResult.runtimeType == FirebaseAuthException) {
                                                  FirebaseAuthException authException = signInResult;
                                                  handleAuthError(context, authException);
                                                }
                                              },
                                            ),
                                            Container(
                                              width: double.maxFinite,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Text("Nu ai cont?"),
                                                  Container(
                                                    child: InkWell(   /// "Register with Email" button
                                                      child: Text(
                                                        "Inregistrare",
                                                        style: TextStyle(
                                                          color: Theme.of(context).accentColor,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      highlightColor: Colors.transparent,
                                                      onTap: (){
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Register()));
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
                                    ),
                                  ),
                                
                              ],
                            ),
                          ),
                          // formVisibility 
                          // ? Container(
                          //   height: MediaQuery.of(context).size.height*0.35,
                            
                          // )
                          // : Container()
                        ],
                      ),
                    ),
                    // Center(
                    //   child: Text(
                    //     "Let's log in!",
                    //   ),
                    // ),
                    ],
                ),
              ),
            );
          }
        )
      ),
    );
  }
}