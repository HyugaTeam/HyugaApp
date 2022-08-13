import 'package:flutter/material.dart';

class HeroProfileImage extends StatelessWidget {

  final Image? profileImage;
  HeroProfileImage({this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          child: Hero(
            tag: 'profile-image',
            child: profileImage!
          ),
        ),
      )
    );
  }
}