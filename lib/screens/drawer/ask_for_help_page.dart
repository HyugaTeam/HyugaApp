import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/drawer/ask_for_help_page/another_problem_page.dart';
import 'package:hyuga_app/screens/drawer/ask_for_help_page/help_with_deal_page.dart';

class AskForHelpPage extends StatefulWidget {
  @override
  _AskForHelpPageState createState() => _AskForHelpPageState();
}

class _AskForHelpPageState extends State<AskForHelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajutor",
          style: TextStyle(
            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     vertical: MediaQuery.of(context).size.height*0.05,
          //     horizontal: MediaQuery.of(context).size.width*0.1
          //   ),
          //   child: Text(
          //     "Am nevoie de ajutor",
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold
          //     ),
          //   ),
          // ),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "Cum revendic o ofertă?"
                ),
                trailing: Icon(FontAwesomeIcons.arrowRight),
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return HelpWithDealPage(); }));
                },
              ),
              // ListTile(
              //   title: Text(
              //     "Am o problemă"
              //   ),
              //   trailing: Icon(FontAwesomeIcons.arrowRight),
              //   onTap: (){
              //     Navigator.of(context).push(MaterialPageRoute(builder: (context){ return AskForHelpPage(); }));
              //   },
              // ),
              ListTile(
                title: Text(
                  "Altă problemă"
                ),
                trailing: Icon(FontAwesomeIcons.arrowRight),
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){ return AnotherProblemPage(); }));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}