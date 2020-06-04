import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/drawer.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  
  ScrollController _scrollViewController;

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
  void initState(){
    super.initState();
    _scrollViewController = new ScrollController();
  }

  void addToFavorites(int index){
     
  }

 

  Color buttonColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
      ),
      drawer: ProfileDrawer(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
            //color: Colors.grey[300],
            color: Colors.white,
            padding: EdgeInsets.only(
              //top: 30,
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
                            MaterialButton(
                            //color: Colors.blueGrey,
                            textTheme: ButtonTextTheme.primary,
                            // onPressed:(){
                            //   Navigator.pushNamed(
                            //     context, 
                            //     '/third',
                            //     arguments: g.placesList[index]
                            //   );
                            // },
                            onPressed: (){},
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
                                              shadows: [ Shadow(
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
                          Container(
                            alignment: Alignment.center,
                            child: Opacity(  // The InkWell responsible for the splash effect
                              opacity: 0.2,
                              child: Material(
                                type: MaterialType.button,
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (){
                                    Navigator.pushNamed(
                                      context, 
                                      '/third',
                                      arguments: g.placesList[index]
                                    );
                                    print('////////////');
                                  },
                                  splashColor: Colors.orange[600],
                                  child: Container(
                                    width: 349,
                                    height: 240 
                                  )
                                )
                              ),
                            ),
                          ),
                          Positioned(  // 'Add to favorites button'
                              right:0,
                              top: 0,
                              child: FloatingActionButton(
                                hoverElevation: 0,
                                heroTag: null, // Added to prevent "There are multiple heroes that share the same tag within a subtree."
                                elevation: 1,
                                backgroundColor: Colors.orange[600],
                                child: FaIcon(FontAwesomeIcons.plus),
                                onPressed: (){
                                  if(g.isSnackBarActive == false){
                                    g.isSnackBarActive = true;
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      backgroundColor: Colors.orange[600],
                                      content: Text("Added to favorites."),
                                    )).closed.then((reason){
                                      g.isSnackBarActive = false;
                                    });
                                    
                                  }
                                },
                              ),
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