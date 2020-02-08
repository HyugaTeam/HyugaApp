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
        "SugiPla",
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
      Positioned( 
      top: 100,
      left: 50,
      child: MyStatefulWidget_1(),
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



class MyStatefulWidget_1 extends StatefulWidget {
  MyStatefulWidget_1({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState_1 createState() => _MyStatefulWidgetState_1();
}

class _MyStatefulWidgetState_1 extends State<MyStatefulWidget_1> {
  String dropdownValue = 'Cuisine';
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
      items: <String>['Cuisine','Mediterranian','American', 'Asian', 'Indian']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}