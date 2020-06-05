import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Searching',
            style: TextStyle(
              fontSize: 30
            ),
          ),
          LinearProgressIndicator(
            backgroundColor: Theme.of(context).backgroundColor
          )
        ],
      )
    );
  }
}