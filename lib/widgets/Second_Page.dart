import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          "Hello again"
        ),
      ),
      body: Center(
        child: Container(
          child: RaisedButton(
            onPressed:(){ 
              Navigator.pop(context);
              },
            child: Text(
              'push me'
              ),
            ),
         ),
      )
    );
  }
}