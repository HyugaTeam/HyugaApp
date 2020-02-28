import 'package:flutter/material.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

void main() => runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/second': (context) => SecondPage()
    },
    theme: ThemeData(
      backgroundColor: Colors.white,
    ),
    //home: Home()
    )
  );

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
            ),
          alignment: Alignment(0,0),
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
                      MainMenuButton( /// 'Area' Button
                        name: "Area",
                        options: g.areaList
                      ),
                      Container( /// The 'Search' Button
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        constraints: BoxConstraints(
                          minHeight: 40,
                          maxWidth: 120
                        ),
                        padding: EdgeInsets.symmetric(            
                        ),
                        child: Center(
                          child: ButtonTheme(
                            child: Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[Expanded(
                              child: IconButton(

                                splashColor: Colors.white,
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white
                                ),
                              onPressed: (){
                                // return showDialog(context: context, builder: (context){
                                //       return Container(
                                //         color: Colors.grey,
                                //         child: Text('hello there!'),
                                //       );
                                //     }
                                //   );
                                Navigator.pushNamed(context, '/second');
                                }
                              ),
                            )],
                          )
                        )
                      ),
                    ),
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
               )
            )
        ),
      ]),
      
    );
  }
}

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(100),
              decoration: BoxDecoration(
                color: Colors.blueGrey
              ),
              child: Text('hello'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Message')
            )
          ],
        ),
      ),
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