import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'MainMenu_OptionsDropAction.dart';



// DEPRECATED
class MainMenuButton2 extends StatelessWidget {

  String buttonText;
  final _key = new UniqueKey();
  String name;
  List<String> options;
  Function(int) changeText;
  Color buttonColor = Colors.white;
  Color textColor = Colors.black;

  _getPosition(BuildContext context){
    RenderBox renderBoxButton;
    print(context.findRootAncestorStateOfType());
    renderBoxButton = context.findRenderObject();
    final coordinatesButton = renderBoxButton.localToGlobal(Offset.zero);
    return coordinatesButton;
 }



  ///Method which opens a dialog whenever the button is pressed
  Future<int> createDialog(BuildContext context) {
      return showDialog(
        context: context, 
        builder: (context){
          Offset widgetPosition = _getPosition(context);
          return SizedBox(
            child: Container(
              padding: EdgeInsets.only(
                top: widgetPosition.dy - 30,
                left: widgetPosition.dx,
                right: widgetPosition.dx,
                //bottom: _getPosition().dy
              ),
              child: OptionsDropButton(
                  options: name == 'What?' ? g.whatList[g.selectedWhere] : options,
                  question: name,
                  sizeOfButton: _getPosition(context),
                  button: this,
              )
            )
          );
        },
        );
  }

  MainMenuButton2({this.name,this.options,this.changeText,this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
                }
                );
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
    );
  }
}