import 'dart:async';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For exceptions library
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:rxdart/rxdart.dart'; 
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

//A class which handles the sign-in process
class AuthService{

  // instance of the Firebase Authantication system
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSingIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final Firestore _db = Firestore.instance;

  PublishSubject<bool> loading = PublishSubject<bool>(); // used for the async
  bool isLoading;
  User currentUser; /// used for the 'manager' property
  
  AuthService(){
    user.listen(
      (value){
        currentUser = value;
        if(currentUser != null){
          loading.add(true);
          isLoading = true;
          DocumentReference ref = _db.collection('users').reference().document(value.uid);
          ref.get().then((DocumentSnapshot docSnap) {
            if(docSnap.data != null){
              print(docSnap.data);
              if(docSnap.data.containsKey('manager') == true)
                currentUser.isManager = docSnap.data['manager'];
              else 
                currentUser.isManager = null;
              if(docSnap.data.containsKey('score') == true)
                currentUser.score = docSnap.data['score'];
              else
                currentUser.score = null;
            }
            loading.add(false);
            isLoading = false;
          });
         }
      },
    );
  }
  

  // create user object based on FirebaseUser
  User _ourUserFromFirebaseUser(FirebaseUser user){
    
    /// Added in order to set the User ID property for the Google Analytics Service
    if(user!= null)
      AnalyticsService().setUserProperties(user.uid);

    return user != null 
    ? User(
      uid: user.uid,
      email: user.email,
      photoURL: user.photoUrl,
      displayName: user.displayName,
      isAnonymous : user.isAnonymous
    ) 
    : null;
  }

  void handleAuthError(AuthException error){
    print(error);
  }

  //auth change user stream
  Stream<User> get user{
    //print(_auth.onAuthStateChanged.first.whenComplete(() => print("first\n")).toString() + " din stream");
    return (_auth.onAuthStateChanged
      .map(_ourUserFromFirebaseUser));
  }

  void addToFavorites(){
    
  }

  void updateUserData(FirebaseUser user, [String credentialProvider]) async{

    DocumentReference ref = _db.collection('users').reference().document(user.uid);
    DocumentSnapshot document = await ref.get();
    if(document.data == null){
      AnalyticsService().analytics.logSignUp(signUpMethod: credentialProvider);
      g.isNewUser = true;
      ref.setData({
      'uid' : user.uid,
      'email' : user.email,
      'photoURL' : user.photoUrl,
      'displayName' : user.displayName,
      'score' : 0
    },
    merge: true
    );
    }
  }

  // sign in anonimously
  Future signInAnon() async{
    try{
      AuthResult result = await _auth.signInAnonymously().then((value){g.isNewUser = true;});
      return result;
    } catch(error){
      print(error);
      return null;
    }
  }

  // sign in method for Facebook
  Future signInWithFacebook() async{
    try{
      final result = await _facebookLogin.logIn(['email']);
      FirebaseUser user;
      //_facebookLogin.loginBehavior = FacebookLoginBehavior.nativeOnly;
      switch(result.status){
        case FacebookLoginStatus.loggedIn:
          final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token
          );
          
          //final vari = _auth.fetchSignInMethodsForEmail(email: result.accessToken.userId);
          dynamic authResult =  await _auth.signInWithCredential(credential);
          user = authResult.user;

          break;
        case FacebookLoginStatus.cancelledByUser:
          print(result.status);
          // TODO: Handle this case.
          break;
        case FacebookLoginStatus.error:
          return PlatformException(code: 'ERROR_INVALID_CREDENTIAL');
          break;
      }
      if(user!=null)
        updateUserData(user,'facebook');
      AnalyticsService().analytics.logLogin(loginMethod: 'facebook');
    }
    catch(error){
      return error;
    }
  }

  // sign in method for Google
  Future signInWithGoogle() async{
    try{
      final GoogleSignInAccount googleUser = await _googleSingIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, 
        accessToken: googleAuth.accessToken
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      if(user != null)
        updateUserData(user,'google');
      
      AnalyticsService().analytics.logLogin(loginMethod: 'google');
      //return _ourUserFromFirebaseUser(user);
    }
    catch(error){
      print(error);
      //handleAuthError(error);
      return(error);
    }
  }

  // sign in with Apple

  Future signInWithApple() async{
    //1. perform the sign-in request
    final AuthorizationResult result = await AppleSignIn.performRequests(
      [AppleIdRequest(requestedScopes: [Scope.email,Scope.fullName])]
    );
    switch(result.status){
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider(providerId: 'apple.com');
        final credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken: String.fromCharCodes(appleIdCredential.authorizationCode)
        );
        final user = (await _auth.signInWithCredential(credential)).user;
        if(user != null)
          updateUserData(user, 'apple');
        AnalyticsService().analytics.logLogin(loginMethod: 'apple');
      break;
      case AuthorizationStatus.error:
        print(result.status);
      break;
      case AuthorizationStatus.cancelled:
        print(result.status);
      break;
    }
  }

  // sign in by email & password

  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      if(user != null)
        updateUserData(user);
      AnalyticsService().analytics.logLogin(loginMethod: 'email_and_password');
      //return _ourUserFromFirebaseUser(user);
    }
    catch(error){
      print(error);
      return error;
    }
  }

  // register with email & password

  Future registerWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      //FirebaseUser user = result.user;
      if(result.user != null)
        updateUserData(result.user,'email_and_password');
      return result;
    }
    //on AuthException 
    catch(error){
      return error;
    }
  }

  // sign out
  Future signOut() async{
    try{
      //DocumentReference ref  = _db.collection('users').reference().document((await authService.user.last).uid);
      //await ref.delete();
      await _auth.signOut();
      
    }
    catch(error){
      //print(error.toString());
      //handleAuthError(error);
      return(error);
    }
  }

}

AuthService authService = AuthService();