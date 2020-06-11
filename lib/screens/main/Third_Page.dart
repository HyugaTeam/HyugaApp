import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:shimmer/shimmer.dart';


// The generator of the third page
class ThirdPageGenerator{

  //Function which generates the ThirdPage
  static Route<dynamic> generateRoute(RouteSettings settings){
    Local args = settings.arguments;  
    return MaterialPageRoute(
      builder: (_) => ThirdPage(
        local: args

      )
    );
  }
}


class ThirdPage extends StatefulWidget {

  final Local local;
  //final Future<Image> size;
  
  ThirdPage({this.local});

  @override
  _ThirdPageState createState() => _ThirdPageState(
    localLongitude: local.location.longitude,
    localLatitude: local.location.latitude
  );
}

class _ThirdPageState extends State<ThirdPage> {

  double titleOpacity = 0.0;
  ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
    initialScrollOffset: 0
  );
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

  

  // Configures how the title is progressively shown as the user's scrolling the page downwards
  @override
  void initState(){
    _scrollController.addListener(() { 
      setState(() {
        if(_scrollController.offset<197){
          titleOpacity = 0;
        }
        else 
          if(_scrollController.offset >= 197 && _scrollController.offset< 220)
            titleOpacity = (_scrollController.offset-195)*4/100;
          else titleOpacity = 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(),
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orange[600]
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),*/
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              // stretchTriggerOffset: 30,
              // onStretchTrigger: (){
              //     return Future.delayed(Duration(seconds: 1)).then((s)=>print("stretch-triggered"));
              // },
              // stretch: true,
              title: Opacity(
                  opacity: titleOpacity,
                  child: Center(
                    child: Text(widget.local.name),
                  ),
              ),
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                background: FutureBuilder(
                  future: widget.local.image,
                  builder: (context,imgSnapshot){
                    if(!imgSnapshot.hasData)
                      return Container(
                        width: 400,
                        height: 200,
                        color: Colors.white,
                      );
                    else 
                      return Container(
                        color: Colors.white,
                        child: imgSnapshot.data
                      );
                  }
                ),
              ),
              backgroundColor: Colors.blueGrey,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pop(context);
                }
              ),
            ),
          ];
        },
        body: Container(
          child: ListView(
            // controller: ScrollController(
            //   keepScrollOffset: false
            // ),
            physics: ScrollPhysics(),
            children: [
              Column(
                children: <Widget>[
                  Container( // Name
                    alignment: Alignment(-0.8, 1),
                    padding: EdgeInsets.only(
                      bottom:10
                    ),
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
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[200],
                                highlightColor: Colors.white,
                                child: Container(
                                  height: 100,
                                  color: Colors.blueGrey,
                                ),
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
                                  return Column(
                                    children: <Widget>[
                                      Image.memory(snapshot.data[index]),
                                      index == snapshot.data.length-1 ? Container() : Container(height: 20)
                                    ],
                                  );
                                  
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
      )
    );
  }
}
