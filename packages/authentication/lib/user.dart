import 'package:authentication/authentication.dart';

class UserProfile{
  
  final String uid;
  final String? email;
  final String? photoURL;
  final String? displayName;
  final bool? isAnonymous;
  String? phoneNumber;
  bool? isManager;

  UserProfile(this.uid, {this.email,this.photoURL, this.displayName, this.isAnonymous, this.phoneNumber});
}

/// Converts a User to UserProfile
UserProfile? userToUserProfile(User? user){
  return user != null
  ? UserProfile(
    user.uid,
    email: user.email,
    photoURL: user.photoURL,
    phoneNumber: user.phoneNumber,
    displayName: user.displayName != null 
      ? user.displayName 
      : (user.email != null
        ? user.email!.substring(0,user.email!.indexOf('@'))
        : "Guest"),
    isAnonymous : user.isAnonymous
  )
  : null;
}