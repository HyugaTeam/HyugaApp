import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
export 'package:provider/provider.dart';

class AuthenticationPageProvider with ChangeNotifier{
  String? email;
  String? password;
  bool formVisibility = false;

  ScrollController scrollController = ScrollController();
  GlobalKey formFieldKey = GlobalKey();

  
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

  void signInWithEmailAndPassword(BuildContext context) async {
    dynamic signInResult = await Authentication.signInWithEmailAndPassword(email!, password!);
    //print(signInResult.runtimeType);
    if(signInResult.runtimeType == FirebaseException) {
      FirebaseException authException = signInResult;
      handleAuthError(context, authException);
    }

    notifyListeners();
  }

  void signInWithApple(){
    Authentication.signInWithApple();

    notifyListeners();
  }
  void signInWithGoogle(BuildContext context){
    dynamic signInResult = Authentication.signInWithGoogle(); 
    if(signInResult.runtimeType == FirebaseException) 
      handleAuthError(context, signInResult);

    notifyListeners();
  }

  void signInWithFacebook(BuildContext context){
    dynamic signInResult = Authentication.signInWithFacebook(); 
    if(signInResult.runtimeType == FirebaseException) 
      handleAuthError(context, signInResult);

    notifyListeners();
  }

  void updateFormVisibility(){
    formVisibility = !formVisibility;

    notifyListeners();
  }

  void animateScrollController(){
    RenderBox field = formFieldKey.currentContext!.findRenderObject() as RenderBox;
    print(field.localToGlobal(Offset.zero));
    scrollController.animateTo(
      field.localToGlobal(Offset.zero).dy, 
      duration: Duration(milliseconds: 100), 
      curve: Curves.easeIn
    );

    notifyListeners();
  }
  void updateEmail(String value){
    email = value.trim();

    notifyListeners();
  }
  void updatePassword(String value){
    password = value.trim();

    notifyListeners();
  }
} 