import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyuga_app/models/locals/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

//A class which handles the sign-in process
class AuthService{

  // instance of the Firebase Authantication system
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSingIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final Firestore _db = Firestore.instance;

  Stream<Map<String,dynamic>> profile; // custom user data from Firestore
  PublishSubject loading = PublishSubject();
  

  // create user object based on FirebaseUser
  User _ourUserFromFirebaseUser(FirebaseUser user){
    print(_auth.currentUser());
    return user != null 
    ? User(
      uid: user.uid,
      email: user.email,
      photoURL: user.photoUrl,
      displayName: user.displayName

    ) 
    : null;
  }

  void handleAuthError(AuthException error){
    print(error);
  }


  //auth change user stream
  Stream<User> get user{
    return _auth.onAuthStateChanged
      .map(_ourUserFromFirebaseUser);
  }

  void updateUserData(FirebaseUser user) async{
    DocumentReference ref = _db.collection('users').reference().document(user.uid);
    return ref.setData({
      'uid' : user.uid,
      'email' : user.email,
      'photoURL' : user.photoUrl,
      'displayName' : user.displayName,
      //'last seen': DateTime.now()

    },
    merge: true
    );
  }

  // sign in anonimously
  Future signInAnon() async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      updateUserData(user);
      //return _ourUserFromFirebaseUser(user);
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
          user = (await _auth.signInWithCredential(credential)).user;
          print("result.status");
          break;
        case FacebookLoginStatus.cancelledByUser:
          print(result.status);
          // TODO: Handle this case.
          break;
        case FacebookLoginStatus.error:
          print(result.errorMessage);
          // TODO: Handle this case.
          break;
      }
      if(user!=null)
        updateUserData(user);
    }
    catch(error){
      print(error);
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
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      if(user != null)
        updateUserData(user);
      //return _ourUserFromFirebaseUser(user);

    }
    catch(error){
      //handleAuthError(error);
      return(error);
    }
  }
  // sign in by email & password

  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      if(user != null)
        updateUserData(user);
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
      //print(error.toString());
      //handleAuthError(error);
      return(error);
    }
  }

}

AuthService authService = AuthService();