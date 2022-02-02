import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/main/Home.dart';
import 'package:hyuga_app/widgets/MainMenu_OptionsDropAction.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class MainMenuButton extends StatefulWidget {

  final String? name;
  String? buttonText;
  final List<String>? options;
  final Function(int)? changeText;

  MainMenuButton({Key? key, this.name,this.options,this.buttonText,this.changeText}) :super(key: key);
  MainMenuButtonState createState() => MainMenuButtonState(
    name: this.name,
    options: this.options,
    buttonText: this.buttonText,
  );
}

class MainMenuButtonState extends State<MainMenuButton>{

  /// Used for getting the button's coordinates
  var _key = GlobalKey<MainMenuButtonState>();
  String? name;  
  List<String>? options;
  String? buttonText;
  Color buttonColor = Colors.white;
  Color textColor = Colors.black;

  void initState(){
    super.initState();
    if(name=="What?" ){
      print("adasdasdasdasdasdasdasdasd");
    }
  }


  // / Method which updates the Text displayed on the button whenever
  // / the user changes it
  void changeText(int index){
    setState((){
      if(name == 'What?'){
        buttonText = g.whatListTranslation[g.selectedWhere!][index];
        buttonColor = Colors.blueGrey;
        textColor = Colors.white;
      }
      else{
        buttonText = options![index];
        buttonColor = Colors.blueGrey;
        textColor = Colors.white;
      }
      if(name == 'Where?' && g.selectedWhat != null){
        print("S-a schimba Where ul");
        HomeButtonsController.addWhereValue(index);
      }
    });
  }

  /// Method which returns the button's coordinates in the page
  _getPosition(){
    RenderBox? renderBoxButton;
    renderBoxButton = _key.currentContext!.findRenderObject() as RenderBox?;
    final coordinatesButton = renderBoxButton!.localToGlobal(Offset.zero);
    return coordinatesButton;
 }

  ///Method which opens a dialog whenever the button is pressed
  Future<int?> createDialog(BuildContext context) {
      return showDialog(
        context: context, 
        builder: (context){
          return SizedBox(
            child: Container(
              padding: EdgeInsets.only(
                top: _getPosition().dy - 30,
                left: _getPosition().dx,
                right: _getPosition().dx,
              ),
              child: OptionsDropButton(
                  options: name == 'What?' ? g.whatListTranslation[g.selectedWhere!] : options,
                  question: name,
                  sizeOfButton: _getPosition(),
                  button: this.widget,
              )
            )
          );
        },
        );
  }

  Stream<int>? whereButtonChanged;
  MainMenuButtonState({ this.name,this.options,this.buttonText}){
    /// We add the subscription to the 'Where' Button stream in case 'this' is the 'What' Button so we can change its appearance
    if(name == 'What?'){
      print("SUNTEM PE WHAT");
      whereButtonChanged = HomeButtonsController.whereButton;
    }
  }
  
  Widget build(BuildContext context){
    return StreamBuilder<Object>(
      stream: HomeButtonsController.whereButton,
      builder: (context, snapshot) {
        if(name == 'What?' && (snapshot.hasData && g.whatListTranslation[snapshot.data as int].contains(buttonText) == false )){
          buttonText = 'Specific';
          buttonColor = Colors.white;
          textColor = Colors.black;
          g.selectedWhat = null;
          print("selected What? is " + g.selectedWhat.toString());
        }
          return Row( /// This Row Widget is inactive !(bcs it only has the Container)
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 50,
              key: _key,
              child: ButtonTheme(
                  minWidth: 310,
                  height: 50,
                  child: RaisedButton.icon(
                      animationDuration: Duration(
                        milliseconds: 100
                      ),
                      splashColor: Colors.blueGrey,
                      color: buttonColor, //changes when the selected option first changes
                      elevation: 5,
                      onPressed: () {
                        if(name=='What?' && g.selectedWhere==null){
                          if(g.isSnackBarActive == false){
                            g.isSnackBarActive = true;
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Selecteaza intai categoria.',
                                textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.orange[600],
                              )
                            ).closed.then((SnackBarClosedReason reason){
                              g.isSnackBarActive = false;
                          }
                          );
                         }
                        }
                        else createDialog(context).then((index){
                          index!= null? changeText(index):null;
                        });
                      },
                      label: Text(
                        buttonText!,
                        style: TextStyle(
                            fontSize: 28*(1/MediaQuery.of(context).textScaleFactor) ,
                            color: textColor,
                            letterSpacing: -1,
                            fontFamily: 'Comfortaa'
                            ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 52,
                        color: Colors.orange[600],
                      ), 
                    )
              )
            ),
          ],
        );
      }
    );
  }
}
