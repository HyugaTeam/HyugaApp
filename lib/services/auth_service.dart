import 'package:firebase_auth/firebase_auth.dart';
import 'package:hyuga_app/models/locals/user.dart';

//A class which handles the sign-in process
class AuthService{

  final  FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  User _ourUserFromFirebaseUser(FirebaseUser user){
    return user != null ? new User(uid: user.uid) : null;
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