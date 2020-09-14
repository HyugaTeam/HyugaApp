import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/Reservation_Panel.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:intl/intl.dart'; // ADDED FOR THE DATE FORMATTING SYSTEM
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/uber_service.dart';
import 'package:url_launcher/url_launcher.dart';


// The generator of the third page
class ThirdPageGenerator{

  //Function which generates the ThirdPage
  static Route<dynamic> generateRoute(RouteSettings settings){
    List<dynamic> args = settings.arguments;
    Local local = args[0];  // This is the first argument(The 'Local')
    bool onlyDiscounts = args[1]; // This is the second argument(whether it shows only discounts or not)
    return MaterialPageRoute(
      builder: (_) => ThirdPage(
        local: local,
        onlyDiscounts: onlyDiscounts
      )
    );
  }
}



class ThirdPage extends StatefulWidget {

  final Local local;
  final bool onlyDiscounts;
  //final Future<Image> size;
  
  ThirdPage({this.local,this.onlyDiscounts}){
    
    ///Added for test
    if(this.onlyDiscounts == null){
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local.id,
          "place_name": local.name,
          "place_path": "${g.whereList[g.selectedWhere]}_${g.whatList[g.selectedWhere][g.selectedWhat]}_${g.howManyList[g.selectedHowMany]}_${g.ambianceList[g.selectedAmbiance]}_${g.areaList[g.selectedArea]}"
        }
      ).then((value) => print(local.id+local.name));
    }
    else{
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local.id,
          "place_name": local.name,
          "place_path": "only_discounts"
        }
      );
    }

    // if(this.onlyDiscounts == null) /// This path is followed if the user visits the Place from the Second Page
    //   AnalyticsService().analytics.logViewItem(
    //     itemId: local.id, 
    //     itemName: local.name,
    //     itemCategory: "${g.whereList[g.selectedWhere]}_${g.whatList[g.selectedWhere][g.selectedWhat]}_${g.howManyList[g.selectedHowMany]}_${g.ambianceList[g.selectedAmbiance]}_${g.areaList[g.selectedArea]}",
    //   );
    // else AnalyticsService().analytics.logViewItem( /// ----""----- from the 'Only Discounts' Page
    //   itemId: local.id, 
    //   itemName: local.name,
    //   itemCategory: "only_discounts",
    // );
  }

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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
  double getDiscountForUser(double maxDiscount){
    List<num> userDiscounts = g.discounts.firstWhere((element) => element['maxim'] == maxDiscount)['per_level'];
    return userDiscounts[authService.currentUser.getLevel()].toDouble();
  }

  // Configures how the title is progressively shown as the user's scrolling the page downwards
  @override
  void initState(){
    print(widget.local.reference.toString());

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
                          extendBodyBehindAppBar: true,
                          appBar: AppBar(
                            iconTheme: IconThemeData(
                              color: Colors.black,
                              size: 30
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      title: Center(child: Text("Discounturi", style: TextStyle(fontWeight: FontWeight.bold),)),
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
                                              "Scaneaza codul in intervalul dorit pentru a primi reducerea.",
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
                                      int.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14))
                                      .toString() + '%',
                                      /// Old computation for the Discount per level
                                      //getDiscountForUser(double.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14)))
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
                  Container(
                    color: Colors.blueGrey.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Program:"
                      ),
                    )
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Lu")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Ma")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Mi")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Jo")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Vi")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Sa")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "00:00"
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Du")
                            ),
                            Text(
                              "12:00",
                            ),
                            Text(
                              "22:00"
                            )
                          ],
                        )
                      ],
                    )
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          highlightElevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          color:Colors.blueGrey,
                          child: Text(
                            "Meniu",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          onPressed: (){
                            _launchInBrowser("http://hotel-restaurant-transilvania.ro/include/Meniu-Restaurant-Transilvania.pdf");
                          }
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child: Text(
                            "Terasa:   Da"
                          ),
                        )
                      ],
                    )
                  ),
                  RaisedButton(
                    color: Colors.orange[600],
                    highlightElevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text(
                      "Rezerva o masa",
                    ),
                    onPressed: (){
                      showDialog(context: context, builder: (newContext) => Provider(
                        create: (context) => widget.local, 
                        child: ReservationPanel(context:newContext))
                      );
                    },
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
