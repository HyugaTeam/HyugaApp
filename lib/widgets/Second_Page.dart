import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart';
import 'package:hyuga_app/locals/local.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "Hello again",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.only(
            top: 30,
            left: 8,
            right: 8
          ),
          child: ListView.builder(
            itemCount: localsList[selectedWhere].length,
            itemBuilder: (BuildContext contex, int index)  {
              return MaterialButton(
                onPressed:(){
                  //Navigator.pop(context);
                },
                child: Container(
                  //padding: EdgeInsets.all(20),
                  height: 250,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage(
                          localsList[selectedWhere][index].imageUrl
                      )
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      
                        ],
                    )
                  ),
                );
              }
            )
        ),
    );
  }
}