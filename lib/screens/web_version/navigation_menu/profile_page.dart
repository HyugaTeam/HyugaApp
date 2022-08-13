import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/web_version/navbar.dart';

class ProfileWebPage extends StatelessWidget {

  static const String route = "/profil";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Center(
        child: Text("Profil"),
      ),
    );
  }
}