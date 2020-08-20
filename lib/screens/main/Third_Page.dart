import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:intl/intl.dart'; // ADDED FOR THE DATE FORMATTING SYSTEM
import 'package:shimmer/shimmer.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/uber_service.dart';


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

  Future<Image> firstImage;
  Future <Image> secondImage;
  DateTime today;
  double titleOpacity = 0.0;
  ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
    initialScrollOffset: 0
  );
  final double localLongitude,localLatitude;
  List<Uint8List> listOfImages;

  _ThirdPageState({this.localLongitude,this.localLatitude}){
    today = DateTime.now().toLocal();
  }

  //Deprecated
  //Queries for the other images
  Future<List<Uint8List>> _getImages() async{

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      List<Uint8List> listOfImages = [];
      //int pictureIndex = 1;
      try{
        
        //do{
          //print('///////////////////'+'$fileName'+'_$pictureIndex.jpg');
          //await storageRef.child('$fileName'+'_$pictureIndex.jpg')
          await storageRef.child('$fileName'+'_1.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
          //pictureIndex++;
        //}while(pictureIndex<2);

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

  Future<Image> _getFirstImage() async{
    Uint8List imageFile;
    int maxSize = 6*1024*1024;
    String fileName = widget.local.id;
    String pathName = 'photos/europe/bucharest/$fileName';
    var storageRef = FirebaseStorage.instance.ref().child(pathName);
    try{
      await storageRef.child('$fileName'+'_1.jpg')
        .getData(maxSize).then((data){
          imageFile = data;
          }
        );
      return Image.memory(
        imageFile,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            child: child,
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      );
    }
    catch(error){
      print(error);
    }
    return null; // if nothing else happens
  }

  Future<Image> _getSecondImage() async{
    Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile,
          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        );
      }
      catch(error){
        print(error);
      }
      return null; // if nothing else happens
  }

  double getDiscountForUser(double maxDiscount){
    List<num> userDiscounts = g.discounts.firstWhere((element) => element['maxim'] == maxDiscount)['per_level'];
    return userDiscounts[authService.currentUser.getLevel()].toDouble();
  }

  // Configures how the title is progressively shown as the user's scrolling the page downwards
  @override
  void initState(){
    firstImage = _getFirstImage();
    secondImage = _getSecondImage();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container( // Name
                        alignment: Alignment(-0.8, 1),
                        width: 300,
                        padding: EdgeInsets.only(
                          left: 20,
                          bottom:10
                        ),
                        child: Text(
                          widget.local.name==null? 'wrong':widget.local.name,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 21,
                            fontWeight: FontWeight.values[5]
                          ),
                        )
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30,top: 8),
                        constraints: BoxConstraints(
                          maxWidth: 100,
                          maxHeight: 50
                        ),
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: widget.local.cost,
                            itemBuilder: (context, costIndex){
                              return FaIcon(FontAwesomeIcons.dollarSign, color: Colors.orange[600],);
                            },
                          ),
                      )                      
                    ],
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
                      onTap: (latlng){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                          body: GoogleMap(
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
                              ),
                            },
                          ),
                        )));
                      },
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
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
                  Container( // First Image
                    padding: EdgeInsets.only(top:30),
                    child: FutureBuilder(
                      future: firstImage,
                      builder: (context, image){
                        if(!image.hasData){
                          return Shimmer.fromColors(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            ), 
                            baseColor: Colors.white, 
                            highlightColor: Colors.orange[600]
                          );
                        }
                        else return image.data;
                      }
                    ),
                  ),
                  // The 'Discounts' Widget
                  widget.local.discounts != null && widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null
                    ? ListTile(
                      title: Text("Discounts", style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Container(
                        height: 120,
                        child: ListView.builder(
                          itemExtent: 135, /// Added to add some space between the tiles
                          padding: EdgeInsets.all(10),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.local.discounts != null ?  
                                      (widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null? 
                                        widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()].length : 0): 
                                      0,
                          /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to 
                          /// the current weekday. If not, the field will be empty
                          itemBuilder: (BuildContext context, int index){
                            return Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: (){
                                      if(g.isSnackBarActive == false){
                                        g.isSnackBarActive = true;
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Scan your code in your preferred time interval and receive the discount.",
                                              textAlign: TextAlign.center,
                                            ),
                                            backgroundColor: Colors.orange[600],
                                          )).closed.then((SnackBarClosedReason reason){
                                          g.isSnackBarActive = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black45, 
                                            offset: Offset(1.5,1),
                                            blurRadius: 2,
                                            spreadRadius: 0.2
                                          )
                                        ],
                                        color: Colors.orange[600],
                                        borderRadius: BorderRadius.circular(25)
                                      ),
                                      child: Text(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                                              [index].substring(0,5) 
                                              +  ' - ' + 
                                              widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                                              [index].substring(6,11),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto'
                                              ),
                                            )  // A concatenation of the string representing the time interval
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      
                                      getDiscountForUser(double.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14)))
                                      .toString() + '%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Roboto'
                                      )
                                      )
                                  )
                                ],
                              ),
                            );
                          }
                        ),
                      )
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Center(child: Text("Localul nu are astazi reduceri.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                    ),
                  Container( // Second Image
                    padding: EdgeInsets.only(top:30),
                    child: FutureBuilder(
                      future: secondImage,
                      builder: (context, image){
                        if(!image.hasData){
                          return Shimmer.fromColors(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            ), 
                            baseColor: Colors.white, 
                            highlightColor: Colors.orange[600]
                          );
                        }
                        else return image.data;
                      }
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.only(top:30),
                  //   child: FutureBuilder(
                  //     future: _getImages(),
                  //     builder:(context,snapshot){
                  //       if(!snapshot.hasData){
                  //         // data didn't load
                  //         return Shimmer.fromColors(
                  //           period: Duration(milliseconds: 1500),
                  //           baseColor: Colors.grey[300],
                  //           highlightColor: Colors.white,
                  //           child: Container(
                  //             height: 200,
                  //             color: Colors.blueGrey,
                  //           ),
                  //         ); 
                  //       }
                  //       else {
                  //         // data is loaded
                  //         return ListView.separated(
                  //           physics: NeverScrollableScrollPhysics(),
                  //           shrinkWrap: true,
                  //           itemCount: snapshot.data.length,
                  //           separatorBuilder: (context,index){
                  //             if(index == 0){ // Shows the discounts carrousel
                  //               return widget.local.discounts != null && widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null
                  //               ? ListTile(
                  //                 title: Text("Discounts", style: TextStyle(fontWeight: FontWeight.bold),),
                  //                 subtitle: Container(
                  //                   height: 120,
                  //                   child: ListView.builder(
                  //                     itemExtent: 135, /// Added to add some space between the tiles
                  //                     padding: EdgeInsets.all(10),
                  //                     scrollDirection: Axis.horizontal,
                  //                     itemCount: widget.local.discounts != null ?  
                  //                                 (widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null? 
                  //                                   widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()].length : 0): 
                  //                                 0,
                  //                     /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to 
                  //                     /// the current weekday. If not, the field will be empty
                  //                     itemBuilder: (BuildContext context, int index){
                  //                       return Container(
                  //                         width: 100,
                  //                         height: 100,
                  //                         child: Column(
                  //                           children: <Widget>[
                  //                             GestureDetector(
                  //                               onTap: (){
                  //                                 if(g.isSnackBarActive == false){
                  //                                   g.isSnackBarActive = true;
                  //                                   Scaffold.of(context).showSnackBar(
                  //                                     SnackBar(
                  //                                       content: Text(
                  //                                         "Scan your code in your preferred time interval and receive the discount.",
                  //                                         textAlign: TextAlign.center,
                  //                                       ),
                  //                                       backgroundColor: Colors.orange[600],
                  //                                     )).closed.then((SnackBarClosedReason reason){
                  //                                     g.isSnackBarActive = false;
                  //                                   });
                  //                                 }
                  //                               },
                  //                               child: Container(
                  //                                 alignment: Alignment.center,
                  //                                 height: 30,
                  //                                 width: 120,
                  //                                 decoration: BoxDecoration(
                  //                                   boxShadow: [
                  //                                     BoxShadow(
                  //                                       color: Colors.black45, 
                  //                                       offset: Offset(1.5,1),
                  //                                       blurRadius: 2,
                  //                                       spreadRadius: 0.2
                  //                                     )
                  //                                   ],
                  //                                   color: Colors.orange[600],
                  //                                   borderRadius: BorderRadius.circular(25)
                  //                                 ),
                  //                                 child: Text(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                  //                                         [index].substring(0,5) 
                  //                                         + ' - ' + 
                  //                                         widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                  //                                         [index].substring(6,11),
                  //                                         style: TextStyle(
                  //                                           fontSize: 16,
                  //                                           fontFamily: 'Roboto'
                  //                                         ),
                  //                                       )  // A concatenation of the string representing the time interval
                  //                               ),
                  //                             ),
                  //                             Padding(
                  //                               padding: EdgeInsets.all(10),
                  //                               child: Text(
                                                  
                  //                                 getDiscountForUser(double.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14)))
                  //                                 .toString() + '%',
                  //                                 style: TextStyle(
                  //                                   fontSize: 20,
                  //                                   fontFamily: 'Roboto'
                  //                                 )
                  //                                 )
                  //                             )
                  //                           ],
                  //                         ),
                  //                       );
                  //                     }
                  //                   ),
                  //                 )
                  //               )
                  //               : Padding(
                  //                 padding: const EdgeInsets.symmetric(vertical: 30.0),
                  //                 child: Center(child: Text("Localul nu are astazi reduceri.")),
                  //               );
                  //             }
                  //             else return Container();
                  //           },
                  //           // controller: ScrollController(
                  //           //   keepScrollOffset: false
                  //           // ),
                  //           itemBuilder: (context,index){
                  //             //print(snapshot.data.length);
                  //             return Column(
                  //               children: <Widget>[
                  //                 Image.memory(snapshot.data[index]),
                  //                 index == snapshot.data.length-1 ? Container() : Container(height: 20)
                  //               ],
                  //             );
                              
                  //           },
                  //         );
                  //       }
                  //     }
                  //   )
                  // )
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
