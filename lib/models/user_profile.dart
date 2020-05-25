import 'package:hyuga_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authService.profile.listen(
      (state) => setState(
        ()=> _profile = state 
        )
    );
    authService.loading.listen(
      (state) => setState(
        ()=> _profile = state
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}