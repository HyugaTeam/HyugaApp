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
  final GlobalKey<MainMenuButtonState> keyForText;
  OptionsDropButton({Key key,this.options, this.sizeOfButton, this.question,this.keyForText}): super(key: key);
  _OptionsDropButtonState createState() => _OptionsDropButtonState(
    question: this.question,
    options: this.options,
    sizeOfButton: this.sizeOfButton
    );
}

class _OptionsDropButtonState extends State<OptionsDropButton> {
  
  List<String> options;
  Offset sizeOfButton;
  String question;

  _OptionsDropButtonState({this.options, this.sizeOfButton, this.question});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(  /// A widget for listing the options
          shrinkWrap: false,
          physics: NeverScrollableScrollPhysics(), /// Doesn't allow the List to be scrollable
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index){
            return RaisedButton(
              hoverColor: Colors.grey[500],
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
                Navigator.pop(context);
              },
              child: Text(
                    options[index],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
              );
            },
        );
  }
}

