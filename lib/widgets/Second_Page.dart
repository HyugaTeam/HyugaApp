import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart';
import 'package:hyuga_app/models/locals/local.dart';

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
          color: Colors.grey[300],
          padding: EdgeInsets.only(
            top: 30,
            left: 8,
            right: 8
          ),
          child: ListView.builder(
            itemCount: localsList[selectedWhere].length,
            itemBuilder: (BuildContext context, int index)  {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                child:  MaterialButton(
                onPressed:(){
                  //Navigator.pop(context);
                  //TODO Implement the new page
                },
                //padding: EdgeInsets.all(10),
                child: /*Container(
                  //padding: EdgeInsets.all(20),
                  height: 250,
                  width: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.red,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                          localsList[selectedWhere][index].imageUrl
                      )
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(localsList[selectedWhere][index].name),

                        ],
                    )
                  ),*/
                  Column(
                    children: <Widget>[
                      Container( // The Main Image
                        alignment: Alignment(0, -1),
                        width: 400,
                        height: 200,
                        child: Image(
                            fit: BoxFit.fill,
                            image: AssetImage(localsList[selectedWhere][index].imageUrl),
                        ),
                      ),
                      Text(localsList[selectedWhere][index].name),
                    ],
                    )
                )
              );
              }
            )
        ),
    );
  }
}