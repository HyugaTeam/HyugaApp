import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
export 'package:provider/provider.dart';

class ProfilePageProvider with ChangeNotifier{
  User? user;
}