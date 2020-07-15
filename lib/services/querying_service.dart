import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/models/locals/local.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

// Class resposible for the whole querying service for locals
// This class acts as a singleton
class QueryService{


  static final Firestore _db = Firestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final StorageReference storageRef = storage.ref();
  static LocationData _userLocation ;
  
  /// A getter for the user's location
  LocationData get userLocation{
    return _userLocation;
  }

  QueryService(){
    getUserLocation().then((value) => _userLocation = value);

    Location.instance.onLocationChanged.listen((LocationData instantUserLocation) { 
      _userLocation = instantUserLocation;
    });
  }

  // Method that converts a map of Firebase Locals to OUR Locals
  List<Local> toLocal(var localsMap){
      List<Local> placesList = [];
      for(int i = 0; i < localsMap.length; i++){
        Local newLocal = Local(
          id: localsMap[i]['id'],
          name: localsMap[i]['name'],
          //imageUrl: localsMap[i]['imageUrl'],
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
      //return Firestore.instance.collection('locals_bucharest')
      return _db.collection('locals_bucharest')
          .where('ambiance',isEqualTo: selectedAmbiance)
          //.where('score.lemonade',isGreaterThan: null)///////////////
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .getDocuments();
    else
      //return Firestore.instance.collection('locals_bucharest')
      return _db.collection('locals_bucharest')
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .getDocuments();
  }
  
  //Old method, no longer in use
  Future<QuerySnapshot> getDataByWhat(String collectionName){
    if (collectionName == 'Board Games')
      collectionName = 'board_games';
    else collectionName = collectionName.toLowerCase();
    //return Firestore.instance
    return _db
    .collection('_$collectionName').orderBy('score',descending: true)
    .getDocuments();
  }
  
  // Obtains the images from Firebase Storage
  Future<Image> getImage(String fileName) async {
      Uint8List imageFile;
      int maxSize = 10*1024*1024;
      String pathName = 'photos/europe/bucharest/$fileName';
      print(pathName);
      //var storageRef = FirebaseStorage.instance.ref().child(pathName);
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
  
  // Asks for permission and gets the User's location 
  Future<LocationData> getUserLocation() async{

    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData position;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }


    try {
      position = await location.getLocation();
    }
    catch(error){
      print(error);
    }
    return position;

  }
  // Old method, no longer in user
  Future queryForLocals() async{

    // Position userLocation = await getUserLocation();
    // Position userLocation ;
    // getUserLocation().then((value)=>userLocation = value);
    // Position localLocation;
    // print(userLocation);

    // QuerySnapshot queriedSnapshotByWhat = await getDataByWhat(g.whatList[g.selectedWhere][g.selectedWhat]);
    // List<String> listOfQueriedDocuments = [];  // a list of the ID's from the query
    
    // for(int i = 0 ; i < queriedSnapshotByWhat.documents.length ; i++){
    //   listOfQueriedDocuments.add(queriedSnapshotByWhat
    //                             .documents[i].documentID);
    // }// creates a list of IDs from the collection queried by 'What'
    // Set<String> queriedDocumentsByWhat = listOfQueriedDocuments.toSet();
    
    // // A snapshot of the documents ('Ambiance' and 'How Many')
    // QuerySnapshot queriedSnapshotByAmbAndHM = await getDataByHowManyAndAmbiance();
    // listOfQueriedDocuments.clear();
    // for(int i = 0 ; i < queriedSnapshotByAmbAndHM.documents.length ; i++){
    //   listOfQueriedDocuments.add(queriedSnapshotByAmbAndHM
    //                             .documents[i].documentID);
    // }// creates a list of IDs from the collection queried by 'Amb and HM'
    // Set<String> queriedDocumentsByAmbAndHM = listOfQueriedDocuments.toSet();
    
    // listOfQueriedDocuments.clear();
    // listOfQueriedDocuments = 
    // queriedDocumentsByAmbAndHM.intersection(queriedDocumentsByWhat).toList();
    // //listOfQueriedDocuments.sort((x,y)=>x.)
    // for(int i = 0 ; i < listOfQueriedDocuments.length; i++){
        
    //     var db = await _db
    //             .collection('locals_bucharest')
    //             .document(listOfQueriedDocuments[i])
    //             .get();
        
    //     if(userLocation!=null && g.selectedArea==0){
    //         localLocation = Position(
    //           latitude: db.data['location'].latitude,
    //           longitude: db.data['location'].longitude
    //         );
    //         Distance distance = Distance();
    //         double fromAtoB = distance.as(
    //           LengthUnit.Meter,
    //           LatLng(localLocation.latitude, localLocation.longitude),
    //           LatLng(userLocation.latitude, userLocation.longitude)
    //           );
    //         //if(fromAtoB > 1000)
    //          // return;
    //         print(fromAtoB);
    //     }
    //     Image img = await getImage(db.documentID);
    //     g.placesList.add(Local(
    //       description: db.data['description'],
    //       id: db.documentID,
    //       score: (await Firestore.instance
    //       .collection(getCollectionName(
    //         g.whatList[g.selectedWhere][g.selectedWhat]))
    //         .document(db.documentID).get()).data['score'],
    //       //image: img,
    //       cost: db.data['cost'],
    //       name: db.data['name'],
    //       location: db.data['location'],
    //       )
    //     );
    // }
    // g.placesList.sort((y,x)=>x.score.compareTo(y.score));
  }
 
  double getLocalLocation(GeoPoint location){
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
          LengthUnit.Kilometer,
          LatLng(localLocation.latitude, localLocation.longitude),
          LatLng(_userLocation.latitude, _userLocation.longitude)
          );
    return fromAtoB;
  }

  Future getLocationAddress(GeoPoint location) async {
    final coordinates = Coordinates(location.latitude,location.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var firstAddress = addresses.first;
    print(firstAddress.addressLine.substring(0,firstAddress.addressLine.indexOf(',')));
    var street = firstAddress.addressLine.substring(0,firstAddress.addressLine.indexOf(','));
    return firstAddress;
  }

  Local _docSnapToLocal(DocumentSnapshot doc){

    // var profileImage = Image.network(
    //   'https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/photos%2Feurope%2Fbucharest%2Facuarela_bistro%2Facuarela_bistro_profile.jpg?alt=media&token=cee42f66-d71d-4493-8e9a-b4ed509110b9',
    //   frameBuilder: (context,child,index,loaded) => Shimmer(
    //   gradient: LinearGradient(colors: [Colors.grey, Colors.white]),
    //   child: Container(),
    // ),
    // errorBuilder: (context,obj,stackTrace){return Container(child: Center(child: Text('smth went wrong'),),);},
    // );
    Future<Address> address;
//    try{
//      address = getLocationAddress(doc.data['location']);
//    }
//    catch(err){
//      address = Address(addressLine: '');
//    }

    var profileImage = getImage(doc.documentID);
    var images = _getImages(doc.documentID);

    return Local(
      cost: doc.data['cost'],
      score: doc.data['score'],
      id: doc.documentID,
      image: profileImage,
      name: doc.data['name'],
      location:doc.data['location'],
      description: doc.data['description'],
      capacity: doc.data['capacity'],
      discounts: doc.data['discounts'],
      images: images,
      address: address
    );
  }

  // Handles the whole process of querying
  Future fetch() async{
    
    if(g.selectedArea == 0){
      _userLocation = await getUserLocation();
      print("DONE-----------");
    }

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
      .getDocuments();
    else // ignore 'ambiance' field if not selected
     locals = await _db.collection('locals_bucharest') 
     .orderBy('profile.${g.whatList[g.selectedWhere][g.selectedWhat].toLowerCase()}', descending: true)
     .getDocuments();
    
    print(locals.documents.length);
    locals.documents.forEach( (element) {
      print("\nsaddas"+ element.data.toString());
      
        
    });
    return (locals.documents
    .where((element){
      bool result = true;
      if(_userLocation != null && g.selectedArea == 0) { // Filters the result by the 1km radius criteria
        LocationData localLocation ;
        localLocation = LocationData.fromMap({
          'latitude': element.data['location'].latitude,
          'longitude': element.data['location'].longitude
          }
        );
        Distance distance = Distance();
        double fromAtoB = distance.as(
          LengthUnit.Meter,
          LatLng(localLocation.latitude, localLocation.longitude),
          LatLng(_userLocation.latitude, _userLocation.longitude)
          );
        if(fromAtoB > 1000)
          result = false;
        print(fromAtoB);
      }
      if(element.data['capacity'] < selectedHowMany)
        result = false;
      return result;
    })
    .map(_docSnapToLocal)).toList();
  }
}

QueryService queryingService = new QueryService(); 




// class QueryService{

//   static final Firestore _db = Firestore.instance;
//   static final FirebaseStorage storage = FirebaseStorage.instance;
//   static final StorageReference storageReference = storage.ref();

//   // Method that converts a map of Firebase Locals to OUR Locals
//   List<Local> toLocal(var localsMap){
//       List<Local> placesList = [];
//       for(int i = 0; i < localsMap.length; i++){
//         Local newLocal = Local(
//           id: localsMap[i]['id'],
//           name: localsMap[i]['name'],
//           //imageUrl: localsMap[i]['imageUrl'],
//           description: localsMap[i]['description'],
//           location: localsMap[i]['location']
//         );
//         placesList.add(newLocal);
//       }
//       return placesList;
//   }
  
//   //Used when getting the 'score' field
//   String getCollectionName(String collectionName){
//     if(collectionName == 'Board Games')
//       collectionName = '_board_games';
//     else collectionName = '_${collectionName.toLowerCase()}';
//     return collectionName;
//   }

//   // Queries by the 'HowMany' and 'Ambiance' fields
//   Future <QuerySnapshot> getDataByHowManyAndAmbiance() {
    
//     String selectedAmbiance;
//     int selectedHowMany;
    
//     switch (g.selectedAmbiance) {
//       case 0:
//         selectedAmbiance = 'c';
//         break;
//       case 2:
//         selectedAmbiance = 'sf';
//         break;
//       default: selectedAmbiance = null;
//     }

//     switch (g.selectedHowMany) {
//       case 0:
//         selectedHowMany = 1;
//         break;
//       case 1:
//         selectedHowMany = 2;
//         break;
//       case 2:
//         selectedHowMany = 4;
//         break;
//       case 3:
//         selectedHowMany = 6;
//         break;
//       default: selectedHowMany = 9;
//     }
    
//     if(selectedAmbiance != null)
//       return Firestore.instance.collection('locals_bucharest')
//           .where('ambiance',isEqualTo: selectedAmbiance)
//           //.where('score.lemonade',isGreaterThan: null)///////////////
//           .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
//           .getDocuments();
//     else
//       return Firestore.instance.collection('locals_bucharest')
//           .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
//           .getDocuments();
//   }
  
//   //Queries data from the specific collection (by 'What' criteria)
//   Future<QuerySnapshot> getDataByWhat(String collectionName){
//     if (collectionName == 'Board Games')
//       collectionName = 'board_games';
//     else collectionName = collectionName.toLowerCase();
//     return Firestore.instance
//     .collection('_$collectionName').orderBy('score',descending: true)
//     .getDocuments();
//   }

//   Future<Image> getImage(String fileName) async {
//       Uint8List imageFile;
//       int maxSize = 10*1024*1024;
//       String pathName = 'photos/europe/bucharest/$fileName';
//       print(pathName);
//       var storageRef = FirebaseStorage.instance.ref().child(pathName);
//       imageFile = await storageRef.child('$fileName'+'_profile.jpg').getData(maxSize);
//       return Image.memory(
//         imageFile,
//         fit: BoxFit.fill,
//       );
//   }

//   // Gets the User's location
//   Future<Position>getLocation() async{
//     Position position = await Geolocator() 
//             .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     return position;
//   }

//   // Handles the whole process of querying
//   Future queryForLocals() async{

//     Position userLocation = await getLocation();
//     Position localLocation;
//     print(userLocation);

//     QuerySnapshot queriedSnapshotByWhat = await getDataByWhat(g.whatList[g.selectedWhere][g.selectedWhat]);
//     List<String> listOfQueriedDocuments = [];  // a list of the ID's from the query
    
//     for(int i = 0 ; i < queriedSnapshotByWhat.documents.length ; i++){
//       listOfQueriedDocuments.add(queriedSnapshotByWhat
//                                 .documents[i].documentID);
//     }// creates a list of IDs from the collection queried by 'What'
//     Set<String> queriedDocumentsByWhat = listOfQueriedDocuments.toSet();

    
//     // A snapshot of the documents ('Ambiance' and 'How Many')
//     QuerySnapshot queriedSnapshotByAmbAndHM = await getDataByHowManyAndAmbiance();
//     listOfQueriedDocuments.clear();
//     for(int i = 0 ; i < queriedSnapshotByAmbAndHM.documents.length ; i++){
//       listOfQueriedDocuments.add(queriedSnapshotByAmbAndHM
//                                 .documents[i].documentID);
//     }// creates a list of IDs from the collection queried by 'Amb and HM'
//     Set<String> queriedDocumentsByAmbAndHM = listOfQueriedDocuments.toSet();
    
//     listOfQueriedDocuments.clear();
//     listOfQueriedDocuments = 
//     queriedDocumentsByAmbAndHM.intersection(queriedDocumentsByWhat).toList();
//     //listOfQueriedDocuments.sort((x,y)=>x.)
//     for(int i = 0 ; i < listOfQueriedDocuments.length; i++){
//         var db = await Firestore.instance
//                 .collection('locals_bucharest')
//                 .document(listOfQueriedDocuments[i])
//                 .get();

        
//         if(userLocation!=null && g.selectedArea==0){
//             localLocation = Position(
//               latitude: db.data['location'].latitude,
//               longitude: db.data['location'].longitude
//             );
//             Distance distance = Distance();
//             double fromAtoB = distance.as(
//               LengthUnit.Meter,
//               LatLng(localLocation.latitude, localLocation.longitude),
//               LatLng(userLocation.latitude, userLocation.longitude)
//               );
//             //if(fromAtoB > 1000)
//              // return;
//             print(fromAtoB);
//         }
//         Image img = await getImage(db.documentID);
//         g.placesList.add(Local(
//           description: db.data['description'],
//           id: db.documentID,
//           score: (await Firestore.instance
//           .collection(getCollectionName(
//             g.whatList[g.selectedWhere][g.selectedWhat]))
//             .document(db.documentID).get()).data['score'],
//           image: img,
//           cost: db.data['cost'],
//           name: db.data['name'],
//           location: db.data['location'],
//           )
//         );
//     }
//     g.placesList.sort((y,x)=>x.score.compareTo(y.score));
//   }

//   Future fetch(){
//     String selectedAmbiance;
//     int selectedHowMany;
    
//     switch (g.selectedAmbiance) {
//       case 0:
//         selectedAmbiance = 'c';
//         break;
//       case 2:
//         selectedAmbiance = 'sf';
//         break;
//       default: selectedAmbiance = null;
//     }

//     switch (g.selectedHowMany) {
//       case 0:
//         selectedHowMany = 1;
//         break;
//       case 1:
//         selectedHowMany = 2;
//         break;
//       case 2:
//         selectedHowMany = 4;
//         break;
//       case 3:
//         selectedHowMany = 6;
//         break;
//       default: selectedHowMany = 9;
//     }
//   }

// }

// QueryService queryService = QueryService();