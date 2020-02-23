import 'package:flutter/material.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

void main() => runApp(MaterialApp(
  theme: ThemeData(
    backgroundColor: Colors.white,
  ),
  home: Home()));

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  areaDrop(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return Container(
          margin: EdgeInsets.symmetric(),
          child: Align(
              alignment: Alignment(0,0.8),
              child: RaisedButton(
                  onPressed: () {},
                  child: Text(
                      "Select Area", //TODO implementan o harta
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
                decorationThickness: 1)
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 8,  /// Slightly increased the 'elevation' value from the appBar and the 'body'
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 20,
          color: Colors.black,
          onPressed: () {},
        ),
         ///actions: <Widget>[],    ///Un-comment in case we want to add further Widgets on the appBar
      ),
      body: Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxHeight: 650,
            maxWidth: 400,
            ),
          alignment: Alignment(0,0),
          //color: Colors.red,
          child: Column( /// Replaced 'Stack' with 'Column' for the Buttons
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MainMenuButton(  /// 'Where' Button
                        name: "Where?",
                        options: g.whereList,
                        ),
                      MainMenuButton(  /// 'What' Button
                        name: "What?",  
                        options: g.whatList[0],
                        ),
                      MainMenuButton(  /// 'How Many' Button
                        name: "How many?",
                        options: g.howManyList,
                      ),
                      MainMenuButton(  /// 'Ambiance' Button
                        name: "Ambiance",
                        options: g.ambianceList
                      ),
                      MainMenuButton(
                        name: "Area",
                        options: g.areaList
                      )
                      /*Container(   /// "AREA" BUTTON
                          child: Align(
                              alignment: Alignment(0, 0.30),
                              child: ButtonTheme(
                                  minWidth: 230,
                                  height: 60,
                              child: RaisedButton.icon(
                                  elevation: 4,
                                  onPressed: () {
                                    areaDrop(context);
                                  },
                                  icon: Icon(
                                      Icons.arrow_drop_down_circle),
                                  label: Text(
                                    "Area",
                                    style: TextStyle(fontSize: 30,
                                        color: Colors.black),
                                  ),
                                  color: Colors.white)
                          )
                      )),*/
                      ],
                ),
        ),
        Container(   ///  'HYUGA' TITLE
           padding: EdgeInsets.all(10),
           child: Align(
               alignment: Alignment(0, 1),
               child: Text(
                 "HYUGA",
                 textAlign: TextAlign.center,
                 overflow: TextOverflow.ellipsis,
                 style: TextStyle(
                     fontSize: 25.0,
                     fontWeight: FontWeight.bold),
               ))),
      ]),
      
    );
  }
}