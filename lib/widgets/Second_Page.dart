import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  
  /*Image getImage(int index){

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = g.placesList[index].id;
      String pathName = 'photos/europe/bucharest/$fileName';

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
     
      storageRef.child('$fileName'+'_profile.jpg').getData(maxSize).then((data){
        imageFile = data;
        }
      );
      Future.delayed(Duration(seconds: 2));
      var image = Image.memory(imageFile,fit: BoxFit.fill,);
      return image;
  }*/
  @override
  void initState(
    
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      /*appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        backgroundColor: Theme.of(context).backgroundColor,
        /*title: Center(
          child: Text(
            '${g.placesList.length} results',
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold
            ),
          ),
        ),*/
      ),*/
      body: Container(
          //color: Colors.grey[300],
          color: Colors.white,
          padding: EdgeInsets.only(
            top: 30,
            left: 8,
            right: 8
          ),
          child: ListView.builder(  
            itemCount: g.placesList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        //color: Theme.of(context).backgroundColor,
                        //color: Colors.grey[300]
                      ),
                      padding: EdgeInsets.only(
                        //top:30,
                      ),
                      child:  MaterialButton(
                      onPressed:(){
                        //Navigator.pop(context);
                        //TODO Implement the THIRD page
                      },
                      child: Column(
                          children: <Widget>[
                            Container( // The Main Image
                              color: Colors.blue,
                              width: 400,
                              height: 200,
                              child: g.placesList[index].image,
                              ), //profileImage
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                /*gradient: LinearGradient(
                                  colors: [Colors.grey[300],Colors.blueGrey]
                                )*/
                              ),
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 20
                              ),
                              child: Text(
                                  g.placesList[index].name != null ? g.placesList[index].name: 'null' + '${g.placesList[index].description}',
                                  style: TextStyle(
                                    shadows: [Shadow(
                                      blurRadius: 5,
                                      color: Colors.black, 
                                      offset: Offset(1,1)
                                      ),
                                    ],
                                    fontSize: 20,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    //backgroundColor: Colors.blueGrey,
                                    fontFamily: 'Roboto'
                                  ),
                                ),
                              alignment: Alignment(-1, -1),
                            ),
                          ],
                          )
                      )
                    ),
                    SizedBox(
                      height:20
                    )
                ],
              );
            }
          )
        ),
    );
  }
}