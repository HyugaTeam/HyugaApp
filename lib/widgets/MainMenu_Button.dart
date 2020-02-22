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
    options: this.options
  );
}

class MainMenuButtonState extends State<MainMenuButton>{
  @override
  /// Used for getting the button's coordinates
  var _key = new GlobalKey<MainMenuButtonState>(); 

  String name;  
  List<String> options;
  String buttonText = 'select an option';
  
  
  void changeText(String str){
    setState((){
      buttonText = str;
    });
  }

  _getPosition(){
   final RenderBox renderBoxButton = _key.currentContext.findRenderObject();
   final coordinatesButton = renderBoxButton.localToGlobal(Offset.zero);
   //print("POSITION of $renderBoxButton: $coordinatesButton");
   return coordinatesButton;
 }

  MainMenuButtonState({this.name,this.options});

  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Spacer(),
        Container(
        key : _key,
        child: ButtonTheme(
            minWidth: 230,
            height: 50,
            child: RaisedButton.icon(
                elevation: 5,
                onPressed: () {
                  return showDialog(context: context, builder: (context){
                    return Padding(
                      padding: EdgeInsets.only(
                        top: _getPosition().dy,
                        left: 37,  /// Manually adjusted value
                        right: 148,  /// ---""----
                        //bottom: MediaQuery.of(context).size.height-_getPosition().dy
                      ),
                      child: OptionsDropButton(
                          options: name == 'What?' ? g.whatList[g.selectedWhere] : options,
                          question: name,
                          sizeOfButton: _getPosition(),
                          keyForText: _key
                      )
                    );
                  });
                },
                icon: Icon(Icons.arrow_drop_down_circle),
                label: Text(
                  name,
                  style: TextStyle(fontSize: 30,
                      color: Colors.black),
                ),
                color: Colors.white)
        )
    ),
        Container(
      constraints: BoxConstraints(maxWidth: 200,maxHeight: 100),
      padding: EdgeInsets.only(
        left: 20
      ),
      //color: Colors.blue,
      child: Text(
        buttonText,
        maxLines: 2,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey
        ),
      )
    )
      ],
    );
  }
}

/*class ChangingText extends StatefulWidget {
  @override
  final String label;
  ChangingText({this.label});
  _ChangingTextState createState() => _ChangingTextState(
    label: this.label
    );
}

class _ChangingTextState extends State<ChangingText> {

  @override
  String label;
  _ChangingTextState({this.label});
  void changeSmth (String str){
    setState((){
      label = str;
    });
  }
  
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200,maxHeight: 100),
      padding: EdgeInsets.only(
        left: 20
      ),
      //color: Colors.blue,
      child: Text(
        label,
        maxLines: 2,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey
        ),
      )
    );
  }
}*/