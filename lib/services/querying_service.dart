import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/models/locals/local.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

// Class responsible for the whole querying service for locals
// This class acts as a singleton
class QueryService{
  
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final Reference storageRef = storage.ref();
  static PublishSubject<bool> userLocationStream = PublishSubject<bool>();
  PublishSubject<bool> locationEnabledStream = PublishSubject<bool>();
  static LocationData _userLocation ;
  
  static final QueryService _instance = new QueryService._privateConstructor();

  factory QueryService(){
    return _instance;
  }

  /// The actual constructor of the class
  QueryService._privateConstructor(){
    checkAndRequestForLocationService();
    locationEnabledStream.listen((value) {print(value.toString()+ " locationenabledStream");});
    //getUserLocation().then((value) => _userLocation = value);
    Location.instance.changeSettings(
      interval: 10000
    );
  }

  /// A getter for the user's location
  LocationData get userLocation{
    return _userLocation;
  }

  // Checks if the locations is enabled, then ask for enabling the location, then ACTUALLY gets the location
  void checkAndRequestForLocationService() async{
    bool _serviceEnabled = await Location.instance.serviceEnabled();
    if(!_serviceEnabled){
      print("cere serviciu");
      bool result = await Location.instance.requestService();
      if(!result)
        return locationEnabledStream.add(false);
    }
    locationEnabledStream.add(true);
    try {
      PermissionStatus result = await Location.instance.requestPermission();
      if(result == PermissionStatus.denied || result == PermissionStatus.deniedForever)
        throw(PlatformException(code: result == PermissionStatus.denied ? "PERMISSION_DENIED" : "PERMISSION_DENIED_NEVER_ASK"));
      // PermissionStatus res = await Location.instance.hasPermission();
      // print(res.toString() + "res");
      // if(res == PermissionStatus.denied || res == PermissionStatus.deniedForever){
      //   print("sssssssssssssssssssss");
      //   userLocationStream.add(false);
      //   return askPermission();
      // }
      await Location.instance.getLocation();
      userLocationStream.add(true);
      Location.instance.onLocationChanged.listen((LocationData instantUserLocation) { 
        print(instantUserLocation);
        _userLocation = instantUserLocation;
        userLocationStream.add(true);
      });
    }
    catch(error){
      if(error.code == "PERMISSION_DENIED_NEVER_ASK" || error.code == "PERMISSION_DENIED")
        userLocationStream.add(false);
      
    }
  }

  void askPermission() async{
    PermissionStatus result = await Location.instance.requestPermission();
    if(result == PermissionStatus.granted)
      checkAndRequestForLocationService();
  }
  

  

  // Method that converts a map of Firebase Locals to OUR Locals
  List<Local> toLocal(var localsMap){
      List<Local> placesList = [];
      for(int i = 0; i < localsMap.length; i++){
        Local newLocal = Local(
          id: localsMap[i]['id'],
          name: localsMap[i]['name'],
          description: localsMap[i]['description'],
          location: localsMap[i]['location']
        );
        placesList.add(newLocal);
      }
      return placesList;
  }
  
  // Old method, no longer in use
  String getCollectionName(String collectionName){
    if(collectionName == 'Board Games')
      collectionName = '_board_games';
    else collectionName = '_${collectionName.toLowerCase()}';
    return collectionName;
  }
  // Old method, no longer in use
  Future <QuerySnapshot> getDataByHowManyAndAmbiance() {
    
    String selectedAmbiance;
    int selectedHowMany;
    
    switch (g.selectedAmbiance) {
      case 0:
        selectedAmbiance = 'c';
        break;
      case 2:
        selectedAmbiance = 'sf';
        break;
      default: selectedAmbiance = null;
    }
    switch (g.selectedHowMany) {
      case 0:
        selectedHowMany = 1;
        break;
      case 1:
        selectedHowMany = 2;
        break;
      case 2:
        selectedHowMany = 4;
        break;
      case 3:
        selectedHowMany = 6;
        break;
      default: selectedHowMany = 9;
    }

    if(selectedAmbiance != null)
      return _db.collection('locals_bucharest')
          .where('ambiance',isEqualTo: selectedAmbiance)
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .get();
    else
      return _db.collection('locals_bucharest')
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .get();
  }
  
  //Old method, no longer in use
  Future<QuerySnapshot> getDataByWhat(String collectionName){
    if (collectionName == 'Board Games')
      collectionName = 'board_games';
    else collectionName = collectionName.toLowerCase();
    return _db
    .collection('_$collectionName').orderBy('score',descending: true)
    .get();
  }
  
  // Obtains the images from Firebase Storage
  Future<Image> getImage(String fileName) async {
      Uint8List imageFile;
      int maxSize = 10*1024*1024;
      String pathName = 'photos/europe/bucharest/$fileName';
      print(pathName);
      var storageRef = storage.ref().child(pathName);
      imageFile = await storageRef.child('$fileName'+'_profile.jpg').getData(maxSize);
      return Image.memory(
        imageFile,
        fit: BoxFit.fill,
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

  /// Deprecated, too slow for queries
  Future<List<Uint8List>> _getImages(String documentID) async{

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = documentID;
      String pathName = 'photos/europe/bucharest/$fileName';
      

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      List<Uint8List> listOfImages = [];
      int pictureIndex = 1;
      try{
        
        do{
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
        return null;
      }
  }
  
  // Asks for permission and gets the User's location 
  Future<LocationData> getUserLocation() async{

    // Location location = new Location();
    // LocationData position;

    
    // //bool _serviceEnabled;
    // // _serviceEnabled = await location.serviceEnabled();
    // // if (!_serviceEnabled) {
    // //   locationEnabledStream.add(false);
    // // }
    // // else locationEnabledStream.add(true);

    // try {
    //   position = await location.getLocation();
    //   userLocationStream.add(true);
    // }
    // catch(error){
    //   if(error.code == "PERMISSION_DENIED_NEVER_ASK" || error.code == "PERMISSION_DENIED")
    //     userLocationStream.add(false);
      
    // }
    // return position;

  }
 
  double getLocalLocation(LengthUnit unit, GeoPoint location){
    if(location == null)
      print("LOCATION IS NULL");
    LocationData localLocation ;
    localLocation = LocationData.fromMap({
      'latitude': location.latitude,
      'longitude': location.longitude
      }
    );
    Distance distance = Distance();
    double fromAtoB = distance.as(
      unit,
      LatLng(localLocation.latitude, localLocation.longitude),
      LatLng(_userLocation.latitude, _userLocation.longitude)
      );
    return fromAtoB;
  }

  /// Not in use for the moment
  Future<String> getLocationAddress(GeoPoint location) async {
    final coordinates = Coordinates(location.latitude,location.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var firstAddress = addresses.first;
    print("STRADA ESTE "+firstAddress.addressLine.substring(0,firstAddress.addressLine.indexOf(',')));
    var street = firstAddress.addressLine.substring(0,firstAddress.addressLine.indexOf(','));
    return street;
  }

  Local docSnapToLocal(DocumentSnapshot doc){
    Future<String> address;

    var profileImage = getImage(doc.id);
    Map<String, dynamic> placeData = doc.data();

    return Local(
      cost: placeData['cost'],
      score: placeData['score'],
      id: doc.id,
      image: profileImage,
      name: placeData['name'],
      location:placeData['location'],
      description: placeData['description'],
      capacity: placeData['capacity'],
      discounts: placeData['discounts'],
      address: address,
      reference: placeData.containsKey('manager_reference') ? placeData['manager_reference']: null,
      schedule: placeData.containsKey('schedule') ? placeData['schedule']: null,
      deals: placeData.containsKey('deals') ? placeData['deals']: null,
      menu: placeData.containsKey('menu') ? placeData['menu']: null,
      hasOpenspace: placeData.containsKey('open_space') ? placeData['open_space']: null,
      hasReservations: placeData.containsKey('reservations') ? placeData['reservations']: null,
      isPartner: placeData.containsKey('partner') ? placeData['partner']: false
    );
  }

  // Handles the whole process of querying
  Future fetch(bool onlyDiscountLocals) async{
    
    if(g.selectedArea == 0 && _userLocation == null){
      _userLocation = await getUserLocation();
      print("DONE-----------");
    }
    print(onlyDiscountLocals);
    String selectedAmbiance;
    int selectedHowMany;
    switch (g.selectedAmbiance) {
      case 0:
        selectedAmbiance = 'c';
        break;
      case 2:
        selectedAmbiance = 'sf';
        break;
      default: selectedAmbiance = null;
    }

    switch (g.selectedHowMany) {
      case 0:
        selectedHowMany = 1;
        break;
      case 1:
        selectedHowMany = 2;
        break;
      case 2:
        selectedHowMany = 4;
        break;
      case 3:
        selectedHowMany = 6;
        break;
      default: selectedHowMany = 9;
    }
    QuerySnapshot locals;
    print(g.whatList[g.selectedWhere][g.selectedWhat].toLowerCase());

    if(selectedAmbiance != null)  // query by 'ambiance' if selected
      locals = await _db.collection('locals_bucharest')
      .where('ambiance', isEqualTo: selectedAmbiance)
      .orderBy('profile.${g.whatList[g.selectedWhere][g.selectedWhat].toLowerCase()}', descending: true)
      .get();
    else // ignore 'ambiance' field if not selected
     locals = await _db.collection('locals_bucharest') 
     .orderBy('profile.${g.whatList[g.selectedWhere][g.selectedWhat].toLowerCase()}', descending: true)
     .get();
    
    print(locals.docs.length);
    locals.docs.forEach( (element) {
      print("\nsaddas"+ element.data().toString());  
    });

    return (locals.docs
    .where((element){
      bool result = true;
      if(_userLocation != null && g.selectedArea == 0) { // Filters the result by the 1km radius criteria
        LocationData localLocation ;
        localLocation = LocationData.fromMap({
          'latitude': element.data()['location'].latitude,
          'longitude': element.data()['location'].longitude
          }
        );
        Distance distance = Distance();
        double fromAtoB = distance.as(
          LengthUnit.Meter,
          LatLng(localLocation.latitude, localLocation.longitude),
          LatLng(_userLocation.latitude, _userLocation.longitude)
        );
        if(fromAtoB > 3000)
          result = false;
        print(fromAtoB);
      }
      if(element.data()['capacity'] < selectedHowMany)
        result = false;
      if(element.data()['discounts'] != null)
      print(
        element.data()['discounts'][DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()].toString()
      );
      if(onlyDiscountLocals == true 
        && (element.data()['discounts'] == null || ( element.data()['discounts'] != null &&
        element.data()['discounts'][DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()] == null ))
        && (element.data()['deals'] == null || ( element.data()['deals'] != null &&
        element.data()['deals'][DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()] == null ))){
          print(result.toString() + "result");
          result = false;
        }
      return result;
    })
    .map(docSnapToLocal)).toList();
  }

  Future fetchOnlyDiscounts() async{
    Future<QuerySnapshot> localsWithDiscounts = _db.collection('locals_bucharest')
    .orderBy('discounts.${DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()}')
    .get();
    Future<QuerySnapshot> localsWithDeals = _db.collection('locals_bucharest')
    .orderBy('deals.${DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()}')
    .get();
    Set<DocumentSnapshot> locals = new Set();
    await Future.wait(
      [
        localsWithDiscounts,
        localsWithDeals
      ]).then((List<QuerySnapshot> result) {
        Set<DocumentSnapshot> docs1 = result[0].docs.toSet();
        Set<DocumentSnapshot> docs2 = result[1].docs.toSet();
        docs1.forEach(
          (elem) {
            docs2.removeWhere((doc)=> doc.id == elem.id);
            locals.add(elem);
          } 
        );
        docs2.forEach(
          (elem) => locals.add(elem)
        );
      }
    );
    return (locals
    .map(docSnapToLocal)).toList();
  }

}

QueryService queryingService = new QueryService(); 