import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePageProvider with ChangeNotifier{

  bool isLoading = false;

  Future<void> updateProfileImage() async{
    _loading();

    XFile? newImage = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 1000, maxWidth: 1000);
    if(newImage != null)
      await Authentication.updateProfileImage(newImage.path);
    _loading();

    notifyListeners();
  }

  Future<void> deleteAccount() async{
    _loading();
    var uid = Authentication.auth.currentUser!.uid;
    await Authentication.deleteAccount();
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    _loading();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}