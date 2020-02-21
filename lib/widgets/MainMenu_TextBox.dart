import 'package:hyuga_app/globals/Global_Variables.dart';
import 'package:flutter/material.dart';

class TextBox extends StatefulWidget {
  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  @override
  String currentText = 'Cafe';
  void changeText(){
    setState((){
      
    });
  }
  
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, 
    );
  }
}