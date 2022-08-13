import 'package:flutter/material.dart';
export 'package:provider/provider.dart';

class RegisterPageProvider with ChangeNotifier{
  var formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  
  void updateEmail(String value){
    email = value.trim();

    notifyListeners();
  }
  void updatePassword(String value){
    password = value.trim();

    notifyListeners();
  }

  void showErrorSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).highlightColor,
      )
    );
  }
}