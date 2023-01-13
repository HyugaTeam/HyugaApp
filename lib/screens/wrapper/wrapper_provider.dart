import 'package:authentication/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authentication/authentication.dart';

class WrapperProvider with ChangeNotifier{
  bool isLoading = false;

  // Stream<UserProfile?> userProfile;

  WrapperProvider(){
    getData();
  }

  Future<void> getData() async{
    _loading();

    /// Whenever the user changes, if logged in, fetch data about the user from the database
    // Authentication.user.listen((user) async{
    //   if(user != null)
    //     await getUserData(user);
    // });
    
    ///Get the assets' names from Cloud Firestore
    var query = FirebaseFirestore.instance.collection("config").doc("assets");
    var doc = await query.get();
    var assetsData = doc.data();
    ///Get the assets
    for(int i = 0; i < assetsData!['icons'].length; i++){
      var assetName = assetsData['icons'][i];
      //print(assetName);
      var image = await FirebaseStorage.instance.ref("config/assets/icons/${assetName.toLowerCase()}.png").getDownloadURL();
      kAssets[assetName] = image;
      //print(kAssets[assetName].toString());
    }

    _loading();

    notifyListeners();
  }

  /// Fetches data about the current logged user from the database
  // Future<void> getUserData(User? user)async {
  //   userProfile = userToUserProfile(user);
  //   await FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((doc){
  //     userProfile!.isManager = doc.data()!['manager'];
  //   });
  //   print("manager " + userProfile!.isManager.toString());
  //   notifyListeners();
  // } 

  void finishOnboardingScreen() async{

    await SharedPreferences.getInstance()
    .then((result) {
      result.setBool("welcome", true);
    });
    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}