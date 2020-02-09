import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {

  int i = 0;

  abc(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return Container(
        child: Align(
          alignment: Alignment(0,-0.3),
          child: RaisedButton(
            onPressed: () {},
             child: Text(
                 "Coffee\n\nTea\n\nLemonade\n\nSmoothie",
             style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold))
          )
        )
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello!",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 23,
                decorationThickness: 1)),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: Stack(children: [
        Container(
            child: Align(
                alignment: Alignment(0, 0.9),
                child: Text(
                  'HYUGA',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ))),
        Container(
            child: Align(
                alignment: Alignment(0, -0.80),
                child: RaisedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_drop_down_circle),
                    label: Text(
                      "Where",
                      //style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.white))),
        Container(
            child: Align(
                alignment: Alignment(0, -0.60),
                child: RaisedButton.icon(

                    onPressed: () {
                      abc(context);
//                    i++;
//                      new Container(child: Text(
//                          'Nietzsche ' + i.toString(),
//                      style: TextStyle(color: Colors.red)
//                      ));
                    },
                    icon: Icon(Icons.arrow_drop_down_circle),
                    label: Text(
                      "What",
                      //style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.white)))
      ]),
    );
  }
}


//class MyStatefulWidget extends StatefulWidget {
//  MyStatefulWidget({Key key}) : super(key: key);
//
//  @override
//  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
//}
//
//class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//  String dropdownValue = 'Where';
//
//  @override
//  Widget build(BuildContext context) {
//    return DropdownButton<String>(
//      value: dropdownValue,
//      icon: Icon(Icons.arrow_downward),
//      iconSize: 24,
//      elevation: 16,
//      style: TextStyle(color: Colors.black),
//      underline: Container(
//        height: 2,
//        color: Colors.black,
//      ),
//      onChanged: (String newValue) {
//        setState(() {
//          dropdownValue = newValue;
//        });
//      },
//      items: <String>['Where', 'Coffee Shop', 'Restaurant', 'Pub']
//          .map<DropdownMenuItem<String>>((String value) {
//        return DropdownMenuItem<String>(
//          value: value,
//          child: Text(value),
//        );
//      }).toList(),
//    );
//  }
//}

//class MyStatefulWidget_1 extends StatefulWidget {
//  MyStatefulWidget_1({Key key}) : super(key: key);
//
//  @override
//  _MyStatefulWidgetState_1 createState() => _MyStatefulWidgetState_1();
//}
//
//class _MyStatefulWidgetState_1 extends State<MyStatefulWidget_1> {
//  String dropdownValue = 'Cuisine';
//
//  @override
//  Widget build(BuildContext context) {
//    return DropdownButton<String>(
//      value: dropdownValue,
//      icon: Icon(Icons.arrow_downward),
//      iconSize: 24,
//      elevation: 16,
//      style: TextStyle(color: Colors.black),
//      underline: Container(
//        height: 2,
//        color: Colors.black,
//      ),
//      onChanged: (String newValue) {
//        setState(() {
//          dropdownValue = newValue;
//        });
//      },
//      items: <String>['Cuisine', 'Mediterranian', 'American', 'Asian', 'Indian']
//          .map<DropdownMenuItem<String>>((String value) {
//        return DropdownMenuItem<String>(
//          value: value,
//          child: Text(value),
//        );
//      }).toList(),
//    );
//  }
//}

