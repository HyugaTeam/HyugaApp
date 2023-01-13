import 'package:authentication/authentication.dart';

/// 02.09.2020 changed the 'User' class name to 'OurUser' (bcs of Firestore update)
/// 09.12.2022 changed to 'UserProfile'
class UserProfile{
  
  final String? uid;
  final String? email;
  final String? photoURL;
  String displayName;
  final bool? isAnonymous;
  String? phoneNumber;
  int/*!*/ score = 0;
  bool? isManager;

  UserProfile({this.uid,this.email,this.photoURL, required this.displayName, this.isAnonymous, this.phoneNumber});
  

  // Can only return a number in the range [0,5]
  int getLevel(){
    if(score != null){
      if(score < 1) // level 0
        return 0;
      else if(score < 3) // level 1
        return 1;
      else if(score < 8) // level 2
        return 2;
      else if(score < 23) // level 3
        return 3;
      else if(score < 48) // level 4
        return 4;
      else return 5; // level 5
    }
    return 0;
  }

}


/// Converts a User to UserProfile
Future<UserProfile?> userToUserProfile(User? user) async{
  if(user != null){
    var userProfile = UserProfile(
      uid: user.uid,
      email: user.email,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName != null 
        ? user.displayName !
        : (user.email != null
          ? user.email!.substring(0,user.email!.indexOf('@'))
          : "Oaspete"),
      isAnonymous : user.isAnonymous,
    );

    /// Fetch extra data from the user's document in Firestore (users/{user})  
    if(!user.isAnonymous)
      await FirebaseFirestore.instance.collection('users').doc(userProfile.uid).get()
      .then((doc){
        if(doc.data() != null){
          userProfile.isManager = doc.data()!.containsKey('manager') && doc.data()!['manager'] == true;
          if(doc.data()!.containsKey('contact_phone_number')){
            userProfile.phoneNumber = doc.data()!['contact_phone_number'];
          }
          if(doc.data()!.containsKey('display_name')){
            userProfile.displayName = doc.data()!['display_name'];
          }
        }
      });
    
    return userProfile;

  }
  else return null;
}
