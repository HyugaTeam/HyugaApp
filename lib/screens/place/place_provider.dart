import 'dart:convert';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
export 'package:provider/provider.dart';

class PlacePageProvider with ChangeNotifier{

  Place place;
  BitmapDescriptor? pin;
  WrapperHomePageProvider wrapperHomePageProvider;
  Polyline? polyline;
  String? distance;
  String? time;
  int selectedCategoryIndex = 0;

  PlacePageProvider(this.place, this.wrapperHomePageProvider){
    getPin();
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

  Future<void> getPin() async{
    pin = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(20,20)), localAsset("pin"));

    notifyListeners();
  }

  Future<void> openMap(BuildContext context) async{

    Uri uri = Uri(
      scheme: "https",
      host: "google.com",
      path: "maps/search/",
      queryParameters: {
        "api" : 1.toString(),
        "query" : "${place.location.latitude},${place.location.longitude}"
      }
    );
    if(await canLaunchUrl(uri)){
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    }
    else {
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

  }

  // Launches both Uber app and Place's Menu
  Future<void> launchUber(BuildContext context, LocationData? currentLocation, [bool universalLinks = false]) async {

    if(!checkLocationEnabled(context, currentLocation))
      return;

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

  Future<void> getTimeAndDistance(userLocation, placeLocation) async{
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

  Future<Image> getSecondImage(String id) async{
    var image = await FirebaseStorage.instance.ref("photos/europe/bucharest/$id/${id}_1.jpg")
    .getDownloadURL();
    return Image.network(
      image,
      alignment: FractionalOffset.topCenter,
      fit: BoxFit.cover,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
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

  Future<Image> getThirdImage(String id) async{
    var image = await FirebaseStorage.instance.ref("photos/europe/bucharest/$id/${id}_2.jpg")
    .getDownloadURL();
    return Image.network(
      image,
      alignment: FractionalOffset.topCenter,
      fit: BoxFit.cover,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
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

  Future<Image> getFourthImage(String id) async{
    var image = await FirebaseStorage.instance.ref("photos/europe/bucharest/$id/${id}_m.jpg")
    .getDownloadURL();
    return Image.network(
      image,
      alignment: FractionalOffset.topCenter,
      fit: BoxFit.cover,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
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
}