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
      body: Center(
        child: Shimmer.fromColors(
            baseColor: Colors.blueGrey[100],
            highlightColor: Colors.blueGrey,
            period: Duration(seconds: 1),
            child: Text(
              'Loading',
              style: TextStyle(
                fontSize: 30
              ),
            ),
        )
      )
    );
  }
}