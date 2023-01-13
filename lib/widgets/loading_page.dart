import 'package:flutter/material.dart';
import 'LoadingAnimation.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinningLogo()
      ),
    );
  }
}