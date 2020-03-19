import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/welcome_screen.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/Second_Page.dart';
import 'package:hyuga_app/widgets/Third_Page.dart';


void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  debugShowMaterialGrid: false,
    initialRoute: 'welcome/',
    routes: {
      'welcome/' : (context) => Wrapper(),
      '/': (context) => Home(),
      '/second': (context) => SecondPage(),
      //'/third': (context) => ThirdPageGenerator.generateRoute(settings)
    },
    onGenerateRoute: ThirdPageGenerator.generateRoute,
    theme: ThemeData(
      backgroundColor: Colors.white,
      accentColor: Colors.black,
    ),
    //home: Home()
    )
  );

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

/*bool checkOptions(){
  if(g.selectedAmbiance==null || g.selectedWhat==null || 
     g.selectedArea==null || g.selected)
     
}*/

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
      appBar: AppBar(
        title: Text("Hello!",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
                fontSize: 23,
                decorationThickness: 1)
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,  /// Slightly increased the 'elevation' value from the appBar and the 'body'
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 20,
          color: Colors.black,
          onPressed: () {},
        ),
         ///actions: <Widget>[],    ///Un-comment in case we want to add further Widgets on the appBar
      ),
      body: Builder(
        builder: (context) => Stack( // used a builder for the context
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
                            child: Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[Expanded(
                              child: IconButton(
                                splashColor: Colors.white,
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white
                                ),
                              onPressed: () async{
                              //if(checkOptions())
                              try
                              {
                                g.placesList=[];
                                await QueryService().queryForLocals();
                                print(g.placesList);
                                Navigator.pushNamed(context, '/second');
                              }
                              catch(error)
                              {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(content: 
                                    Text(
                                      'Make sure you select an option for each field',
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.orange[600],
                                  )
                                );
                              }
                              }
                              ),
                            )],
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
                   "Hyuga",
                   textAlign: TextAlign.center,
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                       fontFamily: 'Comfortaa',
                       fontSize: 25.0,
                       fontWeight: FontWeight.bold),
                 )
              )
          ),
        ]),
      ),
      
    );
  }
}
