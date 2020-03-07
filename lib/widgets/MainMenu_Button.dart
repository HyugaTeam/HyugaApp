import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/widgets/MainMenu_OptionsDropAction.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class MainMenuButton extends StatefulWidget {
  @override
  final String name;
  final List<String> options;
  MainMenuButton({this.name,this.options});
  MainMenuButtonState createState() => MainMenuButtonState(
    name: this.name,
    options: this.options,
    buttonText: this.name
  );
}

class MainMenuButtonState extends State<MainMenuButton>{
  @override

  /// Used for getting the button's coordinates
  var _key = GlobalKey<MainMenuButtonState>(); 
  String name;  
  List<String> options;
  String buttonText;
  Color buttonColor = Colors.white;
  Color textColor = Colors.black;
  @override

  /// Method which updates the Text displayed on the button whenever
  /// the user changes it
  void changeText(index){
    setState((){
      //buttonText = 'okBoomer';
      
      if(name == 'What?'){
        buttonText = g.whatList[g.selectedWhere][index];
        buttonColor = Colors.blueGrey;
        textColor = Colors.white;
      }
      else{
        buttonText = options[index];
        buttonColor = Colors.blueGrey;
        textColor = Colors.white;
      }
    });
  }

  /// Method which returns the button's coordinates in the page
  _getPosition(){
   final RenderBox renderBoxButton = _key.currentContext.findRenderObject();
   final coordinatesButton = renderBoxButton.localToGlobal(Offset.zero);
   //print("POSITION of $renderBoxButton: $coordinatesButton");
   return coordinatesButton;
 }

  ///Method which opens a dialog whenever the button is pressed
  Future<int> createDialog(BuildContext context) {
      return showDialog(context: context, builder: (context){
          return SizedBox(
            child: Container(
              //color: Colors.blue,
              padding: EdgeInsets.only(
                top: _getPosition().dy - 50,
                left: _getPosition().dx,
                right: _getPosition().dx,
                //bottom: _getPosition().dy
              ),
              child: OptionsDropButton(
                  options: name == 'What?' ? g.whatList[g.selectedWhere] : options,
                  question: name,
                  sizeOfButton: _getPosition(),
                  button: this.widget,
              )
            )
          );
        },
        );
  }

  MainMenuButtonState({this.name,this.options,this.buttonText});

  Widget build(BuildContext context){
    return Row( /// This Row Widget is inactive !(bcs it only has the Container)
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          key : _key,
          child: ButtonTheme(
              minWidth: 290,
              height: 50,
              child: RaisedButton.icon(
                  splashColor: Colors.blueGrey,
                  color: buttonColor, //changes when the selected option first changes
                  elevation: 5,
                  onPressed: () {
                    createDialog(context).then((index){
                      index!= null? changeText(index): null ;
                    });
                  },
                  icon: Icon(Icons.arrow_drop_down_circle),
                  label: Text(
                    buttonText,
                    style: TextStyle(
                        fontSize: 30,
                        color: textColor,
                        fontFamily: 'Roboto'
                        ),
                  ),
                )
          )
        ),
      ],
    );
  }
}
