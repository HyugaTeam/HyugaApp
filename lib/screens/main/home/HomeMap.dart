import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({ Key key }) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  
  List<Local> places = [];

  Future getPlaces(){
    return queryingService.fetchOnlyDiscounts().then((value){
      setState(() {
        places = value;      
      });
    });
  }
  @override
    void initState() {
      super.initState();
      getPlaces();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            northeast: LatLng(44.573465, 26.310127),
            southwest: LatLng(44.313637, 25.903731)
          )
        ),
        padding: EdgeInsets.only(bottom: 50),
        initialCameraPosition: CameraPosition(
          target: LatLng(44.427466, 26.102500),
          //target: LatLng(queryingService.userLocation.latitude, queryingService.userLocation.longitude),
          zoom: 14  
        ),
        markers: places.map( (item) =>
          Marker(
            infoWindow: InfoWindow(
              title: item.name,
              snippet: item.name
            ),
            markerId: MarkerId(item.name),
            position: LatLng(item.location.latitude, item.location.longitude)
          )
        ).toSet(),
      ),
    );
  }
}