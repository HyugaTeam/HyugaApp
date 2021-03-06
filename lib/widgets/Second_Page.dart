import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/drawer.dart';

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
  Color buttonColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
            //color: Colors.grey[300],
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 30,
              left: 8,
              right: 8
            ),
            child: ListView.builder( 
              physics: const AlwaysScrollableScrollPhysics(), 
              itemCount: g.placesList.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          //color: Theme.of(context).backgroundColor,
                          //color: Colors.grey[300]
                        ),
                        child:  Stack(
                          children: <Widget>[
                            Material(
                              child: InkWell(
                                onTap: (){print('////////////');},
                                splashColor: Colors.orange[600],
                                child: Container(
                                  width: 400,
                                  height:200 
                                )
                              )
                            ),
                            MaterialButton(
                            //color: Colors.blueGrey,
                            textTheme: ButtonTextTheme.primary,
                            onPressed:(){
                              Navigator.pushNamed(
                                context, 
                                '/third',
                                arguments: g.placesList[index]
                              );
                            },
                            child: Column(
                                children: <Widget>[
                                  Container( // The Main Image
                                    color: Colors.blue,
                                    width: 400,
                                    height: 200,
                                    child: g.placesList[index].image,
                                    ),
                                  Container( // Text's container
                                    decoration: BoxDecoration(
                                      color: buttonColor,
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                      left: 20
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text( // 'Name' text
                                            g.placesList[index].name != null ? g.placesList[index].name: 'null',
                                            style: TextStyle(
                                              shadows: [Shadow(
                                                blurRadius: 2,
                                                color: Colors.black, 
                                                offset: Offset(0.7,0.7)
                                                ),
                                              ],
                                              fontSize: 20,
                                              letterSpacing: 0.4,
                                              fontWeight: FontWeight.values[4],
                                              color: Colors.white,
                                              fontFamily: 'Roboto'
                                            ),
                                          ),
                                      //Text('${QueryService().getLocation()}')
                                      ],
                                    ),
                                    alignment: Alignment(-1, -1),
                                  ),
                                ],
                                )
                          ),
                          ],
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