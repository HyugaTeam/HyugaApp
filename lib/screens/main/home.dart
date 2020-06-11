import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/ManagerQRScan_Page.dart';
import 'package:hyuga_app/widgets/drawer.dart';


class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
}

// method called upon initiating the searching process
bool checkOptions() {
  if (g.selectedAmbiance == null ||
      g.selectedWhat == null ||
      g.selectedArea == null ||
      g.selectedHowMany == null ||
      g.selectedWhere == null) return false;
  return true;
}

class _HomeState extends State<Home> {

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  ProfileDrawer _drawer = ProfileDrawer();

  List<MainMenuButton> listOfButtons = [
    MainMenuButton(
      /// 'Where' Button
      name: "Where?",
      options: g.whereList,
      buttonText: "Where?",
      //changeText: (index)=>changeText(index),
    ),
    MainMenuButton(

        /// 'What' Button
        name: "What?",
        options: g.whatList[0],
        buttonText: "What?"),
    MainMenuButton(

        /// 'How Many' Button
        name: "How many?",
        options: g.howManyList,
        buttonText: "How many?"),
    MainMenuButton(
      /// 'Ambiance' Button
      name: "Ambiance",
      options: g.ambianceList,
      buttonText: "Ambiance",
    ),
    MainMenuButton(
      /// 'Area' Button
      name: "Area",
      options: g.areaList,
      buttonText: "Area",
    ),
  ];

  void changeText(int index) {
    setState(() {
      // This if-statement handles the particularity of "What"'s button dropdown criteria
      if (listOfButtons[index].name == 'What?') {
        listOfButtons[index].buttonText = g.whatList[g.selectedWhere][index];
        //listOfButtons[index].buttonColor = Colors.blueGrey;
        //listOfButtons[index].textColor = Colors.white;
      } else {
        listOfButtons[index].buttonText = listOfButtons[index].options[index];
        //listOfButtons[index].buttonColor = Colors.blueGrey;
        //listOfButtons[index].textColor = Colors.white;
      }
      if (listOfButtons[index].name == 'Where?' && g.selectedWhat != null) {
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
      floatingActionButton: StreamBuilder(
        stream: authService.loading.stream,
        builder: (context, snapshot) {
          if(snapshot.hasData)
            if(snapshot.data == false && authService.currentUser.isManager == true)
              return FloatingActionButton(
                backgroundColor: Colors.orange,
                child: Icon(Icons.photo_camera),
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ManagerQRScan()));
                },
              );
          return Container(); // just an empty container
        }
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      key: _drawerKey,
      drawer: _drawer,
      appBar: AppBar(
        title: Text(
          "Hello!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
            fontSize: 23,
            decorationThickness: 1)),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 20,
          color: Colors.black,
          onPressed: () async {
            _drawerKey.currentState.openDrawer();
          },
        ),
        ///actions: <Widget>[],    ///Un-comment in case we want to add further Widgets on the appBar
      ),
      body: Builder(
        builder: (context) => Stack(// used a builder for the context
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxHeight: 650,
              ),
              alignment: Alignment(0, 0),
              child: Column(
                /// Replaced 'Stack' with 'Column' for the Buttons
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  listOfButtons[0],
                  listOfButtons[1],
                  listOfButtons[2],
                  listOfButtons[3],
                  listOfButtons[4],
                  Container(
                    /// The 'Search' Button
                    padding: EdgeInsets.symmetric(),
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
                        child: Icon(Icons.search, color: Colors.white),
                        onPressed: () async {
                          if (checkOptions()) {
                            Navigator.pushNamed(context, '/second');
                            // g.placesList = [];
                            // Navigator.pushNamed(context, '/loading');
                            // QueryService().queryForLocals().then((data) {
                            //   Navigator.pushReplacementNamed(
                            //       context, '/second');
                            // });
                            // print(g.placesList);
                          } 
                          else {
                            if(g.isSnackBarActive == false){
                              g.isSnackBarActive = true;
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Make sure you select an option for each field',
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.orange[600],
                              )).closed.then((SnackBarClosedReason reason){
                                g.isSnackBarActive = false;
                              });
                            }
                          }
                        }
                      )
                    ),
                  ),
                ],
              ),
            ),
            Container(
              ///  'HYUGA' TITLE
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment(0, 1),
                child: Text(
                  "hyuga",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 25.0,
                      //fontWeight: FontWeight.bold
                  ),
                )
              )
            ),
          ]
        ),
      ),
    );
  }
}