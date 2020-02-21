import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/widgets/MainMenu_OptionsDropAction.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;


class MainMenuButton extends StatelessWidget{
  @override
  
  GlobalKey _key = GlobalKey(); /// Used for getting the button's coordinates
  GlobalKey _key1 = GlobalKey();/// Used for changing the label's text when selecting an option
  final String name;
  final List<String> options;

  String buttonText = '';
  void changeText(){
    setState(){
      buttonText = 'sdas';
      return buttonText;
    }
  }

  _getPosition(){
   final RenderBox renderBoxButton = _key.currentContext.findRenderObject();
   final coordinatesButton = renderBoxButton.localToGlobal(Offset.zero);
   //print("POSITION of $renderBoxButton: $coordinatesButton");
   return coordinatesButton;
 }

  MainMenuButton({this.name,this.options});

  Widget build(BuildContext context){
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        //ChangingText(),
        //Spacer(), /// Just a Spacer from the border, may be removed 
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
        //Spacer(),
         Container(
          constraints: BoxConstraints(
            maxHeight: 30,
            maxWidth: 50
          ),
          //color: Colors.red,
          child: TextField(
            key: _key1,
            
            decoration: InputDecoration(
              hintText: "select an option",
              border: OutlineInputBorder(borderSide: BorderSide())
            ),
            //g.selectedOptions[name]==null ? "select a location" : options[g.selectedOptions[name]],
            readOnly : true,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),
          )
        ) 
      ],
    );
  }
}

class ChangingText extends StatefulWidget {
  @override
  final String label;
  ChangingText({this.label});
  _ChangingTextState createState() => _ChangingTextState(
    label: this.label
    );
}

class _ChangingTextState extends State<ChangingText> {
  @override
  String label = 'select an option';
  void changeText (String str){
    setState(){
      label = str;
    }
  }
  _ChangingTextState({this.label});
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Text(
        label
      )
    );
  }
}