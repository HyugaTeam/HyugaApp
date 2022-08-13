import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/web_version/navbar.dart';

class BecomePartnerWebPage extends StatelessWidget {

  static const String route = "/devino-partener";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Center(
        child: Text("Parteneri"),
      ),
    );
  }
}