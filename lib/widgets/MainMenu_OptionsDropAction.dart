import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
/// Use g.'name of variable' to access a global variable (they are declared in a separate file)

class OptionsDropButton extends StatefulWidget {
  @override
  final String question;
  final List<String> options;
  final Offset sizeOfButton;
  //final MainMenuButton button;
  final button;
  OptionsDropButton({this.options, this.sizeOfButton, this.question,this.button});
  _OptionsDropButtonState createState() => _OptionsDropButtonState(
    question: this.question,
    options: this.options,
    sizeOfButton: this.sizeOfButton,
    button: this.button
    );
}

class _OptionsDropButtonState extends State<OptionsDropButton> {
  
  List<String> options;
  Offset sizeOfButton;
  String question;
  MainMenuButton button;

  _OptionsDropButtonState({this.options, this.sizeOfButton, this.question, this.button});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AbsorbPointer(
          child: button,
        ),
        ListView.builder(  /// A widget for listing the options
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), /// Doesn't allow the List to be scrollable
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index){
            return RaisedButton(  
              padding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
              onPressed: (){
                switch (question) {
                  case 'Where?':
                    g.selectedWhere = index;
                    break;
                  case 'What?':
                    g.selectedWhat = index;
                    break;
                  case 'How many?':
                    g.selectedHowMany = index;
                    break;
                  case 'Ambiance':
                    g.selectedAmbiance = index;
                    break;
                  case 'Area':
                    g.selectedArea = index;
                    break;
                  default:
                }
                Navigator.of(context).pop(index);
              },
              child: Text(
                    options[index],
                    style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        //fontWeight: FontWeight.bold
                    ),
                  ),
              );
            },
        )
      ],
    );
  }
}

