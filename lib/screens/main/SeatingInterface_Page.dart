import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';

class SeatingInterface extends StatefulWidget {

  // Map<String,dynamic> place;

  // void getPlaceData() async{
  //   Firebase
  // }

  final DocumentSnapshot place;
  SeatingInterface({this.place}){
    //getPlaceData()
  }

  @override
  _SeatingInterfaceState createState() => _SeatingInterfaceState();
}

class _SeatingInterfaceState extends State<SeatingInterface> {

  Image placeImage = Image.memory(Uint8List(0));
  ScrollController _scrollController;

  Future<Local> getPlaceData() async{
    //print(widget.place.data()['place_id']);
    DocumentSnapshot placeData = await FirebaseFirestore.instance
    .collection('locals_bucharest').doc(widget.place.data()['place_id']).get();
    print(placeData.data());
    Local place = queryingService.docSnapToLocal(placeData);
    return place;
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  FutureBuilder<Local>(
        future: getPlaceData(),
        builder: (context, place) {
          if(!place.hasData)
            return Center(child: CircularProgressIndicator());
          else {
            //place.data.image.then((image) => setState(() => placeImage = image));
            return Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              GoogleMap( /// The background Google Map
                markers: {
                  Marker(
                    markerId: MarkerId("1"),
                    position: LatLng(place.data.location.latitude,place.data.location.longitude),
                  )
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(place.data.location.latitude,place.data.location.longitude),
                  zoom: 16
                ),
              ),
              Opacity( // An orange shade on the map
                opacity: 0.2,                
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.orange[600],
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   child: Container(
              //     width: 400,
              //     height: 200,
              //     child: FutureBuilder(
              //       future: place.data.image,
              //       builder: (context, image){
              //         if(!image.hasData)
              //           return Container();
              //         else return image.data;
              //       }
              //     ),
              //   ),
              // ),
              Positioned( // The text about the place
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
                    color: Colors.white
                  ),
                  width: MediaQuery.of(context).size.width*0.8,
                  height: MediaQuery.of(context).size.height*0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Te afli la ${widget.place.data()['place_name']}",
                          style: TextStyle(
                            fontSize: 18
                          ),
                        )
                      ),
                      SizedBox(height: 15,),
                      Text(
                        "Pofta buna!",
                        style: TextStyle(
                          fontSize: 23
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              // Container(
              //   alignment: Alignment.bottomCenter,
              //   //color: Colors.blueGrey,
              //   width: double.infinity,
              //   height: 30,
              //   child: Text(
              //     "hyuga",
              //     style: TextStyle(
              //       fontSize: 18,
              //       //backgroundColor: Colors.blueGrey
              //     ),
              //   ),
              // ),
              DraggableScrollableSheet(
                initialChildSize: 0.25,
                maxChildSize: 0.8,
                builder: (context,_scrollController){
                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      color: Colors.white,
                      // decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                      // ),
                      height: MediaQuery.of(context).size.height*0.8,
                      child: Column(
                        children: [
                          Container( // The place's image
                            width: 400,
                            height: 250,
                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                            ),
                            child: FutureBuilder(
                              future: place.data.image,
                              builder: (context, image){
                                if(!image.hasData)
                                  return Container();
                                else return image.data;
                              }
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text("")
                            )
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          );
          }
        }
      ),
    );
  }
}