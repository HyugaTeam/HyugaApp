import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hyuga_app/models/locals/user.dart';

//A class which handles the sign-in process
class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  User _ourUserFromFirebaseUser(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<User> get user{
    return _auth.onAuthStateChanged
      .map(_ourUserFromFirebaseUser);
  }

  // sign in anonimously
  Future signInAnon() async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _ourUserFromFirebaseUser(user);
    } catch(error){
      print(error.toString());
      return null;
    }
  }

  // sign in by email & password

  // register with email & password

  // sign out
}