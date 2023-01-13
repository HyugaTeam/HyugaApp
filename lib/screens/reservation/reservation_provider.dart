import 'dart:convert';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/models/reservation/reservation.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher_string.dart';
export 'package:provider/provider.dart';

class ReservationPageProvider with ChangeNotifier{
  
  Reservation reservation;
  Future<Image> image;
  bool isLoading = false;
  WrapperHomePageProvider wrapperHomePageProvider;
  Polyline? polyline;
  String? distance;
  String? time;
  BitmapDescriptor? pin;
  Place? place;

  ReservationPageProvider(this.reservation, this.image, this.wrapperHomePageProvider){
    getPlace();
    getPin();
  }

  Future<void> getPin() async{
    pin = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(20,20)), localAsset("pin"));

    notifyListeners();
  }

  Future<void> getPlace() async{
    _loading();

    var data = (await FirebaseFirestore.instance.collection("locals_bucharest").doc(reservation.placeId).get());
    place = docToPlace(data);

    _loading();

    notifyListeners();
  }

  Future<void> cancelReservation() async{
    _loading();
    await reservation.userReservationRef.set(
      {
        "canceled": true
      },
      SetOptions(merge: true)
    );
    await reservation.placeReservationRef.set(
      {
        "canceled": true
      },
      SetOptions(merge: true)
    );
    reservation.canceled = true;

    _loading();

    notifyListeners();
  }

  // Launches both Uber app and Place's Menu
  Future<void> launchUber(BuildContext context, LocationData? currentLocation, [bool universalLinks = false]) async {

    print("data");
    if(!checkLocationEnabled(context, currentLocation))
      return;

    var data = (await FirebaseFirestore.instance.collection("locals_bucharest").doc(reservation.placeId).get());
    print(data);
    var place = docToPlace(data);

  print("url");
    String url = "https://m.uber.com/ul/?client_id=LNvSpVc4ZskDaV1rDZe8hGZy02dPfN84&action=setPickup&pickup[latitude]=" 
    + "${currentLocation!.latitude}"+
    "&pickup[longitude]=" 
    + "${currentLocation.longitude}" +
    "&pickup[nickname]="
    + "" +
    "&pickup[formatted_address]="
    + "" +
    "&dropoff[latitude]="
    + place.location.latitude.toString() + 
    "&dropoff[longitude]="
    + place.location.longitude.toString() +
    "&dropoff[nickname]="
    + place.name.replaceAll(' ', '%20') +
    "&dropoff[formatted_address]="
    + "" +
    "&product_id="
    +"a1111c8c-c720-46c3-8534-2fcdd730040d"
    ;
    print(url);
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalNonBrowserApplication);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "A apărut o problemă"
          )
        )
      );
    }
    notifyListeners();
  }

  bool checkLocationEnabled(BuildContext context, LocationData? currentLocation){
    print(currentLocation.toString() + "LOCATIE");
    if(currentLocation == null){
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: Text("Nu putem configura traseul fără locația dumneavoastră :(")
              ),
              TextButton(
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)
                ),
                onPressed: () => wrapperHomePageProvider.getLocation(),
                child: Text("Permite", style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  decoration: TextDecoration.underline,
                  fontSize: 15
                ),),
              )
            ],
          ),
        )
      );
      return false;
    }
    return true;
  }

  double distanceBetween(LocationData a, GeoPoint b){
    return sqrt(pow(a.latitude! - b.latitude, 2).toDouble() + pow(a.longitude! - b.longitude, 2));
  }

  Future<void> getPolylines(BuildContext context, LatLng userLocation, LatLng placeLocation) async{
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPiKey = "AIzaSyAqeSGb2Zv51XBzmcwemqKM3lSWpT-ufq0";

    List<LatLng> polylineCoordinates = [];
    
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(userLocation.latitude, userLocation.longitude),
      PointLatLng(placeLocation.latitude, placeLocation.longitude),
      travelMode: TravelMode.walking,
    );
    //print(result.status);
    //print(result.points.toString() + " POINTS");
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    else {
      print(result.errorMessage);
    }    
    
    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    polyline = Polyline(
      polylineId: id,
      color: Theme.of(context).colorScheme.secondary,
      points: polylineCoordinates,
      width: 5,

    );
    notifyListeners();
  }

  Future<void> getTimeAndDistance(userLocation, placeLocation) async{

    var doc = (await FirebaseFirestore.instance.collection("locals_bucharest").doc(reservation.placeId).get());
    var place = docToPlace(doc);

    var apiKey = "AIzaSyAhLm5Q70ev_AEGd_5R2YQtsJOJTQxCbeg";
    Uri uri = Uri(
      scheme: "https",
      host: "maps.googleapis.com",
      path: "/maps/api/distancematrix/json",
      queryParameters: {
        "destinations" : "${place.location.latitude},${place.location.longitude}",
        "mode": "driving",
        "origins" : "${userLocation.latitude},${userLocation.longitude}",
        "key" : apiKey
      }
    );
    print(uri);
    var response = await http.get(uri);
    // print(response.body);
    var data = jsonDecode(response.body);
    print(data['rows'][0]['elements'][0]['distance']['text']);    
    distance = data['rows'][0]['elements'][0]['distance']['text'];
    time = data['rows'][0]['elements'][0]['duration']['text'];

    notifyListeners();
  }

  void _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}