import 'package:flutter/material.dart';


void main() => runApp(MaterialApp(
  home: Home()
));

class Home extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
    appBar: AppBar(
      title: Text(
        "Hyuga",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 23,
          decorationThickness: 1
          )
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
    ),
    body: Stack(children:[Positioned( 
      top: 50,
      left: 50,
      child: MyStatefulWidget(),
      ),
      ])
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'Where';
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Where','Coffee Shop', 'Restaurant', 'Pub']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}