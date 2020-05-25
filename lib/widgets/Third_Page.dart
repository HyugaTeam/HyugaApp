import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';


// The generator of the third page
class ThirdPageGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){
      Local args = settings.arguments;  
      return MaterialPageRoute(
        builder: (_) => ThirdPage(
          local: args)
        );
  }
}


class ThirdPage extends StatefulWidget {

  final Local local;
  var size;
  
  ThirdPage({this.local}){
    size = local.image;
  }

  @override
  _ThirdPageState createState() => _ThirdPageState(
    localLongitude: local.location.longitude,
    localLatitude: local.location.latitude
  );
}

class _ThirdPageState extends State<ThirdPage> {

  final double localLongitude,localLatitude;
  _ThirdPageState({this.localLongitude,this.localLatitude});

  List<Uint8List> listOfImages;

  //Queries for the other images
    Future<List<Uint8List>> _getImages() async{

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      List<Uint8List> listOfImages = [];
      int pictureIndex = 1;
      try{

        do{
          //print('///////////////////'+'$fileName'+'_$pictureIndex.jpg');
          await storageRef.child('$fileName'+'_$pictureIndex.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
          pictureIndex++;
        }while(pictureIndex<2);

        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
        return listOfImages;
      }
      catch(error){
      //print('///////////////////////////////$error');
        return null;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orange[600]
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),*/

      body: Stack(
        children: <Widget>[
          Container(
        child: ListView(

          children:[
            Column(
              
              children: <Widget>[
                Stack(
                  children: [ 
                    Container( // Main Picture
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0,0.7],
                          colors: [Colors.transparent,Colors.black]
                        )
                        ),
                        child: widget.local.image
                    ),
                    
                  ]
                ),
                Container( // Name
                  alignment: Alignment(-0.8, 1),
                  padding: EdgeInsets.only(top:20,bottom:10),
                  child: Text(
                    widget.local.name==null? 'wrong':widget.local.name,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 21,
                      fontWeight: FontWeight.values[5]
                    ),
                  )
                ),
                Container( // Thin line
                  padding: EdgeInsets.only(top:10),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white,Colors.orange[600],Colors.white]
                    )
                  ),
                ),
                Container( // 'Description '
                  alignment: Alignment(-0.9, 0),
                  padding: EdgeInsets.only(top:20),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  )
                ),
                Container( // Description text
                  alignment: Alignment(-0.8, 0),
                  
                  padding: EdgeInsets.only(top:15,bottom: 15,left:10,right:5),
                  child: Text(
                    widget.local.description==null? 'wrong':widget.local.description,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic
                    ),
                  )
                ),
                Container( // Google Map
                  height: 150,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(localLatitude,localLongitude),
                      zoom: 15
                      ),
                      myLocationEnabled: true,
                      //trafficEnabled: true,
                      markers: {
                        Marker(
                          markerId: MarkerId('0'),
                          position: LatLng(localLatitude,localLongitude)
                        )
                      },
                      //TODO: Add a 'Return to location' button
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.only(top:30),
                  child: FutureBuilder(
                        future: _getImages(),
                        builder:(context,snapshot){
                          if(!snapshot.hasData){
                            // data didn't load
                            return Container(
                              height: 100,
                              color: Colors.blueGrey,
                              
                            ); 
                          }
                          else {
                            // data is loaded
                            return ListView.builder(
                              controller: ScrollController(
                                keepScrollOffset: false
                              ),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context,index){
                                print(snapshot.data.length);
                                return Image.memory(snapshot.data[index]);
                                
                              },
                            );
                          }
                        }
                      )
                )
                /*Container( // Uber Button
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: RaisedButton(
                        child: Text('Uber',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                        ),),
                        color: Colors.transparent,
                        onPressed: (){
                        },
                      ),
                    )*/
          ],)
          ]
        )
      ),
      
        ],
      )
    );
  }
}
