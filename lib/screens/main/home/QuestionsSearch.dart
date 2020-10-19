import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/MainMenu_Button.dart';

bool checkOptions() {
  if (g.selectedAmbiance == null ||
      g.selectedWhat == null ||
      g.selectedArea == null ||
      g.selectedHowMany == null ||
      g.selectedWhere == null) return false;
  return true;
}

/// Find the perfect restaurant widget
class QuestionsSearch extends StatefulWidget {

  @override
  _QuestionsSearchState createState() => _QuestionsSearchState();
}

class _QuestionsSearchState extends State<QuestionsSearch> {

    List<MainMenuButton> listOfButtons = [
    MainMenuButton(
      /// 'Where' Button
      name: "Where?",
      options: g.whereListTranslation,
      buttonText: "Categorie",
      key: UniqueKey(),
      //changeText: (index)=>changeText(index),
    ),
    MainMenuButton(

        /// 'What' Button
        name: "What?",
        options: g.whatListTranslation[0],
        buttonText: "Specific",
        key: UniqueKey(),
      ),
    MainMenuButton(

        /// 'How Many' Button
        name: "How many?",
        options: g.howManyListTranslation,
        buttonText: "Cate persoane?",
        key: UniqueKey(),
    ),
    MainMenuButton(
      /// 'Ambiance' Button
      name: "Ambiance",
      options: g.ambianceListTranslation,
      buttonText: "Ambianta",
      key: UniqueKey(),
    ),
    MainMenuButton(
      /// 'Area' Button
      name: "Area",
      options: g.areaListTranslation,
      buttonText: "Zona",
      key: UniqueKey(),
    ),
  ];

    void changeText(int index) {
    setState(() {
      // This if-statement handles the particularity of "What"'s button dropdown criteria
      if (listOfButtons[index].name == 'What?') {
        listOfButtons[index].buttonText = g.whatListTranslation[g.selectedWhere][index];
      } else {
        listOfButtons[index].buttonText = listOfButtons[index].options[index];
      }
      if (listOfButtons[index].name == 'Where?' && g.selectedWhat != null) {
        listOfButtons[1].buttonText = 'Categorie';
        g.selectedWhat = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.blueGrey,), onPressed: () => Navigator.pop(context)),
      ),
      extendBodyBehindAppBar: true,
      body: Builder(
        builder:(context) => Container(
          //height: 650,
          color: Theme.of(context).backgroundColor,
          constraints: BoxConstraints(
            //maxHeight: 350,
            minWidth: MediaQuery.of(context).size.width
          ),
          alignment: Alignment(0, 0),
          child: Column(
            /// Replaced 'Stack' with 'Column' for the Buttons
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              listOfButtons[0],
              listOfButtons[1],
              listOfButtons[2],
              listOfButtons[3],
              listOfButtons[4],
              Container(/// The 'Search' Button
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
                        print("incomplet");
                          g.isSnackBarActive = true;
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Selecteaza fiecare camp.',
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
      ),
    );
  }
}