import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart'; // For exceptions library
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:rxdart/rxdart.dart'; 
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


//A class which handles the sign-in process
class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  //final FacebookLogin _facebookLogin = FacebookLogin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  PublishSubject<bool> loading = PublishSubject<bool>(); // used for the async
  bool? isLoading;
  OurUser? currentUser; /// used for the 'manager' property
  
  AuthService(){
    user.listen(
      (value){
        currentUser = value;
        if(currentUser != null){
          loading.add(true);
          isLoading = true;
          try{
            DocumentReference ref = _db.collection('users').doc(value!.uid);
            ref.get().then((DocumentSnapshot user) {
              dynamic userData = user.data() as Map?;
              if(user != null && userData != null){
                if(userData.containsKey('manager') == true)
                  currentUser!.isManager = userData['manager'];
                else 
                  currentUser!.isManager = null;
                if(userData.containsKey('score') == true)
                  currentUser!.score = userData['score'];
                else
                  // Changed due to null-safety migration
                  // currentUser!.score = null;
                  currentUser!.score = 0;
              }
              loading.add(false);
              isLoading = false;
            });
          }
          catch(error){
            loading.add(false);
            isLoading = false;
          }
         }
      },
    );
  }
  
  Stream<QuerySnapshot>? get seatingStatus {
    if(currentUser != null)
      if(currentUser!.isAnonymous != true)
        return _db.collection('users').doc(currentUser!.uid)
        .collection('scan_history')
        .where('is_active', isEqualTo: true)
        .orderBy('date_start',descending: true)
        .snapshots();
    return null;
  }
  

  // create user object based on FirebaseUser
  OurUser? _ourUserFromFirebaseUser(User? user){
    /// Added in order to set the User ID property for the Google Analytics Service
    if(user!= null)
      AnalyticsService().setUserProperties(user.uid);

    return user != null 
    ? OurUser(
      uid: user.uid,
      email: user.email,
      photoURL: user.photoURL,
      displayName: user.displayName != null 
        ? user.displayName 
        : (user.email != null
          ? user.email!.substring(0,user.email!.indexOf('@'))
          : "Guest"),
      isAnonymous : user.isAnonymous
    ) 
    : null;
  }

  void handleAuthError(FirebaseException error){
    print(error);
  }

  //auth change user stream
  Stream<OurUser?> get user{
    return (_auth.authStateChanges()
      .map(_ourUserFromFirebaseUser));
  }

  /// Whenever a new user signs up, this method saves his unique token for Cloud Messaging
  /// The token matches his 'uid' in Firestore
  Future<void> _saveDeviceToken(String uid) async{
    String? fcmToken;
    await _fcm.getToken().then((value) => fcmToken = value);
    if(fcmToken != null){
      var tokenRef = _db.collection('users').doc(uid)
      .collection('tokens').doc(fcmToken);
      tokenRef.set(
        {
          'token' : fcmToken,
          'date_created' : FieldValue.serverTimestamp(),
          'platform' : g.isIOS == true? 'ios' : 'android'
        },
        //SetOptions(merge: true)
      );
    }
  }

  void updateUserData(User user, [String? credentialProvider]) async{

    DocumentReference ref = _db.collection('users').doc(user.uid);
    DocumentSnapshot document = await ref.get();
    await _saveDeviceToken(user.uid);
    if(document.data() == null){
      AnalyticsService().analytics.logSignUp(signUpMethod: credentialProvider!);
      // Commented temporarly in order to skip the tutorial
      //g.isNewUser = true;
      ref.set({
        'uid' : user.uid,
        'email' : user.email,
        'photoURL' : user.photoURL,
        'display_name' : (user.displayName != null || user.isAnonymous == true) ? user.displayName : user.email!.substring(0,user.email!.indexOf('@')),
        'score' : 0,
        'date_registered': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true)
      );
      
    }
  }

  // sign in anonimously
  Future signInAnon() async{
    try{
      UserCredential result = await _auth.signInAnonymously();
      // Commented temporarly in order to skip the tutorial
      //g.isNewUser = true;
      AnalyticsService().analytics.logLogin(loginMethod: 'anonymous');
      return result;
    } catch(error){
      print(error);
      return null;
    }
  }

  // sign in method for Facebook
  Future signInWithFacebook() async{
    try{
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email']
      );
      User? user;
      //print(result.accessToken.);
      //var facebookAuthProvider = FacebookAuthProvider();
      //facebookAuthProvider.
      final AuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token
      );
      dynamic authResult = await _auth.signInWithCredential(credential);
      user = authResult.user;
      if(user != null){
        updateUserData(user, 'facebook');
        AnalyticsService().analytics.logLogin(loginMethod: 'facebook');
      }      
    }
    catch(err){
      print("FACEBOOK LOGIN ERROR: "+ err.toString());
    }
    // try{
    //   final result = await _facebookLogin.logIn(['email']);
    //   User user;
    //   switch(result.status){
    //     case FacebookLoginStatus.loggedIn:
    //       final AuthCredential credential = FacebookAuthProvider.credential(
    //         result.accessToken.token
    //       );
          
    //       dynamic authResult =  await _auth.signInWithCredential(credential);
    //       user = authResult.user;

    //       break;
    //     case FacebookLoginStatus.cancelledByUser:
    //       print(result.status);
    //       // TODO: Handle this case.
    //       break;
    //     case FacebookLoginStatus.error:
    //       return PlatformException(code: 'ERROR_INVALID_CREDENTIAL');
    //       break;
    //   }
    //   if(user!=null)
    //     updateUserData(user,'facebook');
    //   AnalyticsService().analytics.logLogin(loginMethod: 'facebook');
    // }
    // catch(error){
    //   return error;
    // }
  }

  // sign in method for Google
  Future signInWithGoogle() async{
    try{
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, 
        accessToken: googleAuth.accessToken
      );
      final User? user = (await _auth.signInWithCredential(credential)).user;
      if(user != null)
        updateUserData(user,'google');
      
      AnalyticsService().analytics.logLogin(loginMethod: 'google');
    }
    catch(error){
      print(error);
      return(error);
    }
  }

  // sign in with Apple
  // Changed the method to fit the new plug-in (sign_in_with_apple) and replaced (apple_sign_in)
  Future signInWithApple() async{
    //1. perform the sign-in request
    // final AuthorizationResult result = await AppleSignIn.performRequests(
    //   [AppleIdRequest(requestedScopes: [Scope.email,Scope.fullName])]
    // );
    final signInWithAppleStatus = await SignInWithApple.isAvailable();
    switch(signInWithAppleStatus){
      case true:
        /// TODO: Treat all cases
        try{
          final appleIdCredential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
            );
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: appleIdCredential.identityToken,
            accessToken: appleIdCredential.authorizationCode
          );
          final user = (await _auth.signInWithCredential(credential)).user;
          if(user != null)
            updateUserData(user, 'apple');
          AnalyticsService().analytics.logLogin(loginMethod: 'apple');
          // final credential = AuthCredential(providerId: 'apple.com', signInMethod: signInMethod)
          // final user = (await _auth.signinwith(credential)).user;
          // if(user != null)
          //   updateUserData(user, 'apple');
          // AnalyticsService().analytics.logLogin(loginMethod: 'apple');
        }
        catch(exception){
          print(exception);
        }
      break;
      case false:
        print("apple sign in is not avaialable");
    }
    // switch(result.status){
    //   case AuthorizationStatus.authorized:
    //     final appleIdCredential = result.credential;
    //     final oAuthProvider = OAuthProvider('apple.com');
    //     final credential = oAuthProvider.credential(
    //       idToken: String.fromCharCodes(appleIdCredential.identityToken),
    //       accessToken: String.fromCharCodes(appleIdCredential.authorizationCode)
    //     );
    //     final user = (await _auth.signInWithCredential(credential)).user;
    //     if(user != null)
    //       updateUserData(user, 'apple');
    //     AnalyticsService().analytics.logLogin(loginMethod: 'apple');
    //   break;
    //   case AuthorizationStatus.error:
    //     print(result.status);
    //   break;
    //   case AuthorizationStatus.cancelled:
    //     print(result.status);
    //   break;
    // }

  }

  // sign in by email & password

  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if(user != null)
        updateUserData(user);
      AnalyticsService().analytics.logLogin(loginMethod: 'email_and_password');
    }
    catch(error){
      print(error);
      return error;
    }
  }

  // register with email & password

  Future registerWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if(result.user != null)
        updateUserData(result.user!,'email_and_password');
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
      await _auth.signOut();
      
    }
    catch(error){
      return(error);
    }
  }

}

AuthService authService = AuthService();