import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/screens/welcome_screen.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/Second_Page.dart';


void main() => runApp(MaterialApp(
    initialRoute: 'welcome/',
    routes: {
      'welcome/' : (context) => Wrapper(),
      '/': (context) => Home(),
      '/second': (context) => SecondPage()
    },
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  List<Local> toLocal(var localsMap){
      List<Local> placesList = [];
      for(int i = 0; i < localsMap.length; i++){
        Local newLocal = Local(
          name: localsMap[i]['name'],
          imageUrl: localsMap[i]['imageUrl'],
          description: localsMap[i]['description']
        );
        placesList.add(newLocal);
      }
      return placesList;
  }

  //gets data from the specific collection
  Future<QuerySnapshot> getData(String collectionName){
    collectionName = collectionName.toLowerCase();
    return Firestore.instance
    .collection('_$collectionName').orderBy('score',descending: true)
    .getDocuments();
  }

  void queryForLocals() async{

    QuerySnapshot queriedSnapshot = await getData(g.whatList[g.selectedWhere][g.selectedWhat]);
    List<String> listOfQueriedDocuments = [];  // a list of the ID's from the query
    
    for(int i = 0 ; i < queriedSnapshot.documents.length ; i++){
      listOfQueriedDocuments.add(queriedSnapshot.documents[i].documentID);
    }// creates a list of IDs from the collection queried

    /// Adding 
    var localsMap = [];
    for(int i = 0 ; i < listOfQueriedDocuments.length; i++){
        var db = await Firestore.instance
                .collection('locals_bucharest')
                .document(listOfQueriedDocuments[i])
                .get();
        localsMap.add(db.data);
    }
    print(localsMap);
    List<Local> placesList = toLocal(localsMap);
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
                              onPressed: () async{
                              queryForLocals();
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
