import 'dart:io';

import 'package:authentication/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

/// A singleton class that handles the entire authentication process of the app
class Authentication{
  static bool isLoading = false;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static UserProfile? currentUserProfile;

  /// Stream of the current user's profile
  static PublishSubject<UserProfile?> userProfile = PublishSubject();

  /// Auth state of the app as a stream
  static Stream<User?> get user{
    
    return auth.authStateChanges();
  }

  /// Creates a new user document in the Firestore for a new signed up user
  static void updateUserData(User user, [String? credentialProvider]) async{
    DocumentReference ref = _db.collection('users').doc(user.uid);
    DocumentSnapshot doc = await ref.get();
    //await _saveDeviceToken(user.uid);
    if(doc.data() == null){
      ref.set({
        'uid' : user.uid,
        'email' : user.email,
        'photoURL' : user.photoURL,
        'display_name' : (user.displayName != null || user.isAnonymous == true) ? user.displayName : user.email!.substring(0,user.email!.indexOf('@')),
        'date_registered': FieldValue.serverTimestamp(),
        'provider': credentialProvider
        },
        SetOptions(merge: true)
      );
    }
  }

  static Future<void> updateProfileImage(String path) async{
    try{
      var ref = FirebaseStorage.instance.ref().child("users/${auth.currentUser!.uid}/profile.jpg");
      await ref.putFile(File(path));
      await auth.currentUser!.updatePhotoURL(await ref.getDownloadURL());
    } 
    catch(error){

    }
  }
  
  static Future signInAnonimously() async{
    try{
      UserCredential result = await auth.signInAnonymously();
      return result;
    }
    catch(error){
      print(error);
      return error;
    }
  }
  
  // Sign in with Google
  static Future signInWithGoogle() async{
    try{
      var googleSignIn = GoogleSignIn();  
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, 
        accessToken: googleAuth.accessToken
      );
      UserCredential result = await auth.signInWithCredential(credential);
      if(result.user != null)
        updateUserData(result.user!,'email_and_password');
      return result;
    }
    catch(error){
      print(error);
      return error;
    }
  }

  // Sign in with Google
  static Future signInWithFacebook() async{
    try{
      final LoginResult facebookLoginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      final AuthCredential credential = FacebookAuthProvider.credential(
        facebookLoginResult.accessToken!.token
      );
      UserCredential result = await auth.signInWithCredential(credential);
      if(result.user != null)
        updateUserData(result.user!,'facebook');
      return result;
    }
    catch(error){
      print(error);
      return error;
    }
  }

  /// Sign in with Apple
  static Future signInWithApple() async{
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
          final user = (await auth.signInWithCredential(credential)).user;
          if(user != null)
            updateUserData(user, 'apple');
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

  // Sign in by email and password
  static Future signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    }
    catch(error){
      print(error);
      return error;
    }
  }

  /// Register with email and password
  static Future registerWithEmailAndPassword(String email, String password) async{

    try{
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      if(result.user != null)
        updateUserData(result.user!,'email_and_password');
      return result;
    }
    catch(error){
      return error;
    }
  }

  /// Sign out
  static Future signOut() async{
    try{
      await auth.signOut();
    }
    catch(error){
      return(error);
    }
  }

  static Future deleteAccount() async{
    try{
      await auth.currentUser!.delete();
    }
    catch(error){
      return(error);
    }
  }

  Authentication._init(){
    userProfile.listen((userProfile) {
      currentUserProfile = userProfile;
    });
    print("profile 1");

   // register();
    user.listen((currentUser) async{
      _loading();
      print("profile");
      var currentUserProfile = await getUserData(currentUser);
      userProfile.add(currentUserProfile);
      _loading();
    });
  }

  /// Fetches data about the current logged user from the database
  Future<UserProfile?> getUserData(User? currentUser) async {
    var currentUserProfile = userToUserProfile(currentUser);
    if(currentUser != null && !currentUser.isAnonymous){
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get().then((doc){
        currentUserProfile!.isManager = doc.data()!['manager'] ?? false;
      });
    }

    return currentUserProfile;
  } 

  static void register() async{
    var accounts = [
      // {
      //   "email": "beraria.centrala.bucuresti419@gmail.com",
      //   "password": "2LOP1DAF"
      // },
      // {
      //   "email": "beraria.park.bucuresti713@gmail.com",
      //   "password": "KSJF0213"
      // },
      // {
      //   "email": "bistro.3739.bucuresti198@gmail.com",
      //   "password": "AP23AF1J"
      // },
      // {
      //   "email": "bistropolitan.bucuresti235@gmail.com",
      //   "password": "APBF23A1"
      // },
      // {
      //   "email": "bruno.wine.bar956@gmail.com",
      //   "password": "BJFB1237"
      // },
      // {
      //   "email": "casa.dantelei.bucuresti443@gmail.com",
      //   "password": "JF42N7SD"
      // // },
      // {
      //   "email": "hop.garden.bucuresti739@gmail.com",
      //   "password": "RFNVJK82"
      // },
      // {
      //   "email": "karta.bucuresti903@gmail.com",
      //   "password": "27BHJD13"
      // },
      // {
      //   "email": "le.boutique.bucuresti594@gmail.com",
      //   "password": "823BJD1A"
      // },
      // {
      //   "email": "trattoria.mezzaluna.bucuresti845@gmail.com",
      //   "password": "VL23JS14"
      // },
      // {
      //   "email": "osteria.zucca.bucuresti450@gmail.com",
      //   "password": "POR2BN12"
      // },
      // {
      //   "email": "santorini.restaurant.bucuresti087@gmail.com",
      //   "password": "NMHJ4156"
      // },
      // {
      //   "email": "terasa.florilor.bucuresti890@gmail.com",
      //   "password": "1OLE23F0"
      // },
      // {
      //   "email": "texas.bbq.decebal517@gmail.com",
      //   "password": "YHN24A12"
      // },
      // {
      //   "email": "moon.brasserie.bucuresti347@gmail.com",
      //   "password": "MQW786X1"
      // },
      // {
      //   "email": "trattoria.monza.ior903@gmail.com",
      //   "password": "WX47A8V1"
      // },
      // {
      //   "email": "za.lokal.bucuresti670@gmail.com",
      //   "password": "JK83HB23"
      // },
      // {
      //   "email": "trattoria.monza.dtaberei903@gmail.com",
      //   "password": "WX47A8V1"
      // },
      // {
      //   "email": "maimuta.plangatoare.cluj201@gmail.com",
      //   "password": "WK7A24BD"
      // },
      // {
      //   "email": "bistro.1568.cluj452@gmail.com",
      //   "password": "KAJSL231A"
      // },
    ];
    accounts.forEach((element) async{
      await registerWithEmailAndPassword(element['email']!, element['password']!);
      await signOut();
    });
  }

  _loading(){
    isLoading = !isLoading;
  }

  static final Authentication _instance = Authentication._init();
  factory Authentication() => _instance;

}