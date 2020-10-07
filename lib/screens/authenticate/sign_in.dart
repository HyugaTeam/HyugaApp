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

  ScrollController _scrollController;
  GlobalKey _formFieldKey = GlobalKey();

  @override
  void initState() {
    _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   if(_scrollController)
    // });
    super.initState();
  }

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
      showErrorSnackBar( "Bad credentials! The selected sign-up option is invalid!");
    if(signInResult.code == 'ERROR_USER_DISABLED') 
      showErrorSnackBar( "The entered email is invalid!");
    if(signInResult.code == 'ERROR_EMAIL_ALREADY_IN_USE') 
      showErrorSnackBar("The entered email is already in use! Try another sign-in method.");
    if(signInResult.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL")
      showErrorSnackBar("The email used is already used by another account.");
}

  @override
  Widget build(BuildContext context) {

    g.resetSearchParameters(); /// Eventually called when the user logs out and the Home page no longer corresponds to the previous parameters

    return Theme(
      data: ThemeData(
        accentColor: Colors.blueGrey,
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 15,
            color: Colors.blueGrey,
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
        primaryColor: Colors.black45,
        highlightColor: Colors.orange[600]
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        //backgroundColor: Colors.white,
        body: Builder(
          builder: (context) => Center(
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              SizedBox(height: 130),
              Center(
                child: Text( // Hello text
                  'hyuga',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 40
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Let's log in!",
                ),
              ),
              Container(  // sign-in anonymously button
                padding: EdgeInsets.symmetric(vertical:20,horizontal:95),
                child: MaterialButton(
                  splashColor: Colors.orange[100],
                  color: Colors.orange[600],
                  minWidth: 150,
                  height: 35,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "Sari peste", style: TextStyle(fontSize: 13),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/images/google-logo-icon.png',width: 24,),
                      //Container(width: 80,),
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
                      //Container(width: 80,),
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
                      minWidth: 370,
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
                          //padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
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
                                  
                                  child: Text("Log in"),
                                  onPressed: () async{
                                    print(email);
                                    print(password);
                                    dynamic signInResult = await authService.signInWithEmailAndPassword(email, password);
                                    if(signInResult.runtimeType == PlatformException) 
                                      handleAuthError(context, signInResult);
                                  },
                                ),
                                Container(
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Nu ai cont?"),
                                      Container(
                                        // constraints: BoxConstraints(
                                        //   minWidth: 40,
                                        //   maxWidth: 50,
                                        //   minHeight: 20,
                                        //   maxHeight: 20 
                                        // ),
                                        //padding: EdgeInsets.only(top: 10,bottom: 10, left: 20),
                                        child: InkWell(   /// "Register with Email" button
                                          child: Text(
                                            "Inregistare",
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
              formVisibility 
                    ? Container(
                      height: MediaQuery.of(context).size.height*0.35,
                      
                    )
                    : Container()
              ],
            ),
          ),
        )
      ),
    );
  }
}