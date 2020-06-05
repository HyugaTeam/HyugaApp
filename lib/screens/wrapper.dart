import 'package:flutter/material.dart';
import 'package:hyuga_app/main.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/authenticate/authenticate.dart';
import 'package:provider/provider.dart';

import 'main/home.dart';


/// Wrapper for the Authentification Screen and the MainMenu Screen
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);
    if(user == null)
      return Authenticate();
    else
      return Home(); 
  }
}


