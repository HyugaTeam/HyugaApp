import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/wrapper.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingScreen.dart';
import 'package:hyuga_app/widgets/MainMenuButton.dart';
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
      '/loading': (context) => LoadingScreen(),
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

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}


 // method called upon initiating the searching process
 bool checkOptions(){
  if(g.selectedAmbiance==null || g.selectedWhat==null || 
     g.selectedArea==null || g.selectedHowMany==null || 
     g.selectedWhere==null)
      return false;
  return true;
}


class _HomeState extends State<Home> {

  List<MainMenuButton> listOfButtons = [
    MainMenuButton(  /// 'Where' Button
                          name: "Where?",
                          options: g.whereList,
                          buttonText: "Where?",
                          
                          ),
    MainMenuButton(  /// 'What' Button
                          name: "What?",  
                          options: g.whatList[0],
                          buttonText:"What?"
                          ),
    MainMenuButton(  /// 'How Many' Button
                          name: "How many?",
                          options: g.howManyList,
                          buttonText: "How many?"
                        ),
    MainMenuButton(  /// 'Ambiance' Button
                          name: "Ambiance",
                          options: g.ambianceList,
                          buttonText: "Ambiance",
                        ),
    MainMenuButton( /// 'Area' Button
                          name: "Area",
                          options: g.areaList,
                          buttonText: "Area",
                        ),
  ];
  // List<MainMenuButton2> listOfButtons = [
  //   MainMenuButton2(  /// 'Where' Button
  //                         name: "Where?",
  //                         options: g.whereList,
  //                         buttonText: "Where?",
  //                         ),
  //   MainMenuButton2(  /// 'What' Button
  //                         name: "What?",  
  //                         options: g.whatList[0],
  //                         buttonText:"What?"
  //                         ),                 
  //   MainMenuButton2(  /// 'How Many' Button
  //                         name: "How many?",
  //                         options: g.howManyList,
  //                         buttonText: "How many?"
  //                       ),
  //   MainMenuButton2(  /// 'Ambiance' Button
  //                         name: "Ambiance",
  //                         options: g.ambianceList,
  //                         buttonText: "Ambiance",
  //                       ),
  //   MainMenuButton2( /// 'Area' Button
  //                         name: "Area",
  //                         options: g.areaList,
  //                         buttonText: "Area",
  //                       ),
  // ];
  

  void changeText(int index){
    setState((){
      // This if-statement handles the particularity of "What"'s button dropdown criteria
      if(listOfButtons[index].name == 'What?'){
        listOfButtons[index].buttonText = g.whatList[g.selectedWhere][index];
        //listOfButtons[index].buttonColor = Colors.blueGrey;
        //listOfButtons[index].textColor = Colors.white;
      }
      else{
        listOfButtons[index].buttonText = listOfButtons[index].options[index];
        //listOfButtons[index].buttonColor = Colors.blueGrey;
        //listOfButtons[index].textColor = Colors.white;
      }
      if(listOfButtons[index].name == 'Where?' && g.selectedWhat!=null){
        listOfButtons[1].buttonText = 'What?';
        //listOfButtons[1].buttonColor = Colors.white;
        //listOfButtons[1].textColor = Colors.black;
        g.selectedWhat = null;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 20,
          color: Colors.black,
          onPressed: () {
            //print("safnasfjasdgjbngbhnjaerghjaergtnj");
            //Scaffold.of(context).openDrawer();
          },
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
                        listOfButtons[0],
                        listOfButtons[1],
                        listOfButtons[2],
                        listOfButtons[3],
                        listOfButtons[4],
                        Container( /// The 'Search' Button
                          padding: EdgeInsets.symmetric(            
                          ),
                          child: Center(
                            child: MaterialButton(
                              highlightColor: Colors.transparent,
                              color: Colors.blueGrey,
                              splashColor: Colors.orange[600],
                              minWidth: 120,
                              height: 44,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Colors.white
                              ),
                            onPressed: () async{
                            if(checkOptions())
                            {
                              g.placesList=[];
                              Navigator.pushNamed(context, '/loading');
                              QueryService().queryForLocals().then((data){
                                 Navigator.pushReplacementNamed(context, '/second');
                              });
                              print(g.placesList);
                            }
                            else
                            {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Make sure you select an option for each field',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.orange[600],
                                )
                              );
                            }
                            }
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
                       fontWeight: FontWeight.bold
                       ),
                 )
              )
          ),
        ]),
      ),
      
    );
  }
}
