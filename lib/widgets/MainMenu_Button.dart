import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/widgets/MainMenu_OptionsDropAction.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class MainMenuButton extends StatefulWidget {

  final String name;
  String buttonText;
  final List<String> options;
  //final Function(int) changeText;

  MainMenuButton({this.name,this.options,this.buttonText});
  MainMenuButtonState createState() => MainMenuButtonState(
    name: this.name,
    options: this.options,
    buttonText: this.buttonText,
    //changeText: this.changeText
  );
}

class MainMenuButtonState extends State<MainMenuButton>{

  /// Used for getting the button's coordinates
  var _key = GlobalKey<MainMenuButtonState>();
  String name;  
  List<String> options;
  String buttonText;
  Color buttonColor = Colors.white;
  Color textColor = Colors.black;
  //Function(int) changeText;

  void initState(){
    super.initState();
    if(name=="What?" ){
      print("adasdasdasdasdasdasdasdasd");
    }
  }


  // / Method which updates the Text displayed on the button whenever
  // / the user changes it
  void changeText(index){
    setState((){
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
      if(name == 'Where?' && g.selectedWhat!=null){
        //print(whatKey.currentWidget.toString());
      }
    });
  }

  /// Method which returns the button's coordinates in the page
  _getPosition(){
    RenderBox renderBoxButton;
    renderBoxButton = _key.currentContext.findRenderObject();
    final coordinatesButton = renderBoxButton.localToGlobal(Offset.zero);
    return coordinatesButton;
 }

  ///Method which opens a dialog whenever the button is pressed
  Future<int> createDialog(BuildContext context) {
      return showDialog(
        context: context, 
        builder: (context){
          return SizedBox(
            child: Container(
              padding: EdgeInsets.only(
                top: _getPosition().dy - 30,
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
          height: 50,
          key: _key,
          //key: name != "What?" ? _key : whatKey,
          child: ButtonTheme(
              minWidth: 290,
              height: 50,
              child: RaisedButton.icon(
                  animationDuration: Duration(
                    milliseconds: 100
                  ),
                  splashColor: Colors.blueGrey,
                  color: buttonColor, //changes when the selected option first changes
                  elevation: 5,
                  onPressed: () {
                    if(buttonText=='What?' && g.selectedWhere==null)
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Please select the desired location',
                          textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.orange[600],
                      ));
                    else createDialog(context).then((index){
                      index!= null? changeText(index):null;
                    });
                  },
                  label: Text(
                    buttonText,
                    style: TextStyle(
                        fontSize: 30,
                        color: textColor,
                        fontFamily: 'Roboto'
                        ),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down, //changed
                    size: 52, //added
                    color: Colors.orange[600],
                  ), //added
                )
          )
        ),
      ],
    );
  }
}
