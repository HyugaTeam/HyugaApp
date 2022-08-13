import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/authentication/authentication_provider.dart';
import 'package:hyuga_app/screens/register/register_page.dart';
import 'package:hyuga_app/screens/register/register_provider.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
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


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //g.resetSearchParameters(); /// Eventually called when the user logs out and the Home page no longer corresponds to the previous parameters
    var provider = context.watch<AuthenticationPageProvider>();

    return Theme(
      data: ThemeData(
        primaryColor: Theme.of(context).primaryColor,
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 15,
            color: Theme.of(context).primaryColor,
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
        splashColor: Theme.of(context).primaryColor,
        //highlightColor: Colors.black45,
        //primaryColor: Theme.of(context).primaryColor
        
        //highlightColor: Colors.orange[600]
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            _controller.forward();
            return ScaleTransition(
              scale: _animation,
              child: Center(
                child: ListView(
                  //physics: NeverScrollableScrollPhysics(),
                  controller: provider.scrollController,
                  //padding: EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    /// Upper region
                    Container(
                      height: MediaQuery.of(context).size.height*0.35,
                      color: Theme.of(context).primaryColor, 
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
                      height: provider.formVisibility
                      ? MediaQuery.of(context).size.height*0.65 + 100
                      : MediaQuery.of(context).size.height*0.65,
                      // height: MediaQuery.of(context).size.height*0.65,
                      child: Column(
                        children: [
                          Container(  // sign-in anonymously button
                            padding: EdgeInsets.symmetric(vertical:20,horizontal:95),
                            child: MaterialButton(
                              splashColor: Theme.of(context).primaryColor,
                              //splashColor: Colors.orange[100],
                              color: Theme.of(context).primaryColor,
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
                              //width: 300,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Image.asset('assets/images/google-logo-icon.png',width: 24,),
                                  Text("Continuă prin Google"),
                                ],
                              ),
                            ),
                            onPressed: () => provider.signInWithGoogle(context),
                          ),
                          SizedBox(height: 20),
                          MaterialButton(   /// Continue with Facebook button
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
                              //width: 300,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FaIcon(FontAwesomeIcons.facebook, color: Colors.blue,),
                                  Text("Continuă prin Facebook"),
                                ],
                              ),
                            ),
                            onPressed: () => provider.signInWithFacebook(context),
                          ),
                          g.isIOS 
                          ? SizedBox(height: 20,)
                          : Container(),
                          g.isIOS   // checks if the platform on which the app is ran is IOS
                          ? MaterialButton(   /// Continue with AppleID button
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
                              //width: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FaIcon(FontAwesomeIcons.apple, color: Colors.black,),
                                  //Container(width: 80,),
                                  Text("Continuă prin Apple"),
                                ],
                              ),
                            ),
                            onPressed: () => provider.signInWithApple()
                          )
                          : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // border: Border.all(
                              //   width: 1,
                              //   style: BorderStyle.solid,
                              //   color: Colors.black26
                              // )
                            ),
                            child: Column(
                              children: <Widget>[
                                MaterialButton(  /// The 'Continue with email' button
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
                                    //width: 300,
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.solidEnvelope, color:  Colors.blueGrey,),
                                        Text("Continuă prin email"),
                                      ],
                                    ),
                                  ),
                                  onPressed: () => provider.updateFormVisibility()
                                  ),
                                  Visibility( // The dialog shown under the 'Continue with email' button
                                    maintainState: true,
                                    maintainAnimation: true,
                                    visible: provider.formVisibility,
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
                                              key: provider.formFieldKey,
                                              onTap: () => provider.animateScrollController(),
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                hoverColor: Colors.blue
                                              ),
                                              onChanged: (value) => provider.updateEmail(value)
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                fillColor: Colors.orange[600]
                                              ),
                                              obscureText: true,
                                              onChanged: (value) => provider.updatePassword(value),
                                            ),
                                            SizedBox(height: 20),
                                            RaisedButton(  /// "Sign-In" button
                                              child: Text("Log in"),
                                              onPressed: () => provider.signInWithEmailAndPassword(context)
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
                                                        "Înregistrare",
                                                        style: TextStyle(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      highlightColor: Colors.transparent,
                                                      onTap: (){
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
                                                        ChangeNotifierProvider(
                                                          create: (_) => RegisterPageProvider(),
                                                          child: RegisterPage()
                                                        )));
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
                        ],
                      ),
                    ),
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